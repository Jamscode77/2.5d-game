// Copyright MechFrontline. All rights reserved.

#include "Mech/MFMechPawn.h"
#include "Mech/MFMechMovementComponent.h"
#include "Mech/MFFrameDefinition.h"
#include "Combat/MFHealthComponent.h"
#include "Combat/MFHeatComponent.h"
#include "Combat/MFWeaponLoadoutComponent.h"
#include "Combat/MFTargetingComponent.h"
#include "Components/CapsuleComponent.h"
#include "Components/SkeletalMeshComponent.h"
#include "GameFramework/SpringArmComponent.h"
#include "Camera/CameraComponent.h"
#include "MechFrontline.h"

AMFMechPawn::AMFMechPawn()
{
	PrimaryActorTick.bCanEverTick = true;

	Capsule = CreateDefaultSubobject<UCapsuleComponent>(TEXT("Capsule"));
	Capsule->InitCapsuleSize(80.f, 200.f);
	Capsule->SetCollisionProfileName(TEXT("Pawn"));
	RootComponent = Capsule;

	Mesh = CreateDefaultSubobject<USkeletalMeshComponent>(TEXT("Mesh"));
	Mesh->SetupAttachment(Capsule);
	Mesh->SetRelativeLocation(FVector(0.f, 0.f, -200.f));

	MechMovement = CreateDefaultSubobject<UMFMechMovementComponent>(TEXT("MechMovement"));
	MechMovement->UpdatedComponent = Capsule;

	CameraBoom = CreateDefaultSubobject<USpringArmComponent>(TEXT("CameraBoom"));
	CameraBoom->SetupAttachment(Capsule);
	CameraBoom->TargetArmLength = 800.f;
	CameraBoom->bUsePawnControlRotation = true;
	CameraBoom->bEnableCameraLag = true;
	CameraBoom->CameraLagSpeed = 8.f;

	FollowCamera = CreateDefaultSubobject<UCameraComponent>(TEXT("FollowCamera"));
	FollowCamera->SetupAttachment(CameraBoom, USpringArmComponent::SocketName);
	FollowCamera->bUsePawnControlRotation = false;

	Health = CreateDefaultSubobject<UMFHealthComponent>(TEXT("Health"));
	Heat = CreateDefaultSubobject<UMFHeatComponent>(TEXT("Heat"));
	Loadout = CreateDefaultSubobject<UMFWeaponLoadoutComponent>(TEXT("Loadout"));
	Targeting = CreateDefaultSubobject<UMFTargetingComponent>(TEXT("Targeting"));

	bUseControllerRotationYaw = false;
}

void AMFMechPawn::BeginPlay()
{
	Super::BeginPlay();
	if (FrameDefinition)
	{
		ApplyFrameDefinition(FrameDefinition);
	}
}

void AMFMechPawn::Tick(float DeltaSeconds)
{
	Super::Tick(DeltaSeconds);
	// Scaffold: clear momentary boost each frame unless held — controller sets boosting while held.
}

void AMFMechPawn::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
	Super::SetupPlayerInputComponent(PlayerInputComponent);
	// Enhanced Input is bound on AMFPlayerController.
}

void AMFMechPawn::ApplyFrameDefinition(UMFFrameDefinition* Definition)
{
	FrameDefinition = Definition;
	if (!Definition)
	{
		return;
	}

	if (MechMovement)
	{
		MechMovement->MaxSpeed = Definition->MaxWalkSpeed;
		MechMovement->BoostMultiplier = Definition->BoostSpeedMultiplier;
	}
	if (Health)
	{
		Health->InitializeHull(Definition->MaxHull);
	}
	if (Heat)
	{
		Heat->InitializeHeat(Definition->MaxHeat, Definition->HeatDissipationPerSecond);
	}
	if (Loadout)
	{
		Loadout->ApplyDefaultLoadout(Definition->DefaultLoadout);
	}

	UE_LOG(LogMechFrontline, Log, TEXT("Applied frame definition: %s"), *Definition->FrameId.ToString());
}

void AMFMechPawn::AddMoveInput(FVector2D Axis)
{
	if (!Controller)
	{
		return;
	}

	const FRotator YawRot(0.f, Controller->GetControlRotation().Yaw, 0.f);
	const FVector Forward = FRotationMatrix(YawRot).GetUnitAxis(EAxis::X);
	const FVector Right = FRotationMatrix(YawRot).GetUnitAxis(EAxis::Y);
	AddMovementInput(Forward, Axis.Y);
	AddMovementInput(Right, Axis.X);
}

void AMFMechPawn::AddLookInput(FVector2D Axis)
{
	AddControllerYawInput(Axis.X * LookYawRate * GetWorld()->GetDeltaSeconds());
	AddControllerPitchInput(Axis.Y * LookPitchRate * GetWorld()->GetDeltaSeconds());
}

void AMFMechPawn::FirePrimary()
{
	if (Heat && Heat->IsOverheated())
	{
		return;
	}
	if (Loadout)
	{
		Loadout->FireSlot(EMFWeaponSlot::Primary, Targeting ? Targeting->GetLockedTarget() : nullptr);
	}
}

void AMFMechPawn::CycleOrAcquireLock()
{
	if (Targeting)
	{
		Targeting->AcquireOrCycleLock(Faction);
	}
}

void AMFMechPawn::SetBoosting(bool bBoosting)
{
	if (MechMovement)
	{
		MechMovement->SetBoosting(bBoosting);
	}
}

FMFFrameStatus AMFMechPawn::GetFrameStatus() const
{
	FMFFrameStatus Status;
	if (Health)
	{
		Status.HullPercent = Health->GetHullPercent();
		Status.bIsDestroyed = Health->IsDestroyed();
	}
	if (Heat)
	{
		Status.HeatPercent = Heat->GetHeatPercent();
		Status.bIsOverheated = Heat->IsOverheated();
	}
	if (MechMovement)
	{
		Status.BoostPercent = MechMovement->bIsBoosting ? 1.f : 0.f; // scaffold placeholder
	}
	return Status;
}
