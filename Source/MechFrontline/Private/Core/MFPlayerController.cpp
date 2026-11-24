// Copyright MechFrontline. All rights reserved.

#include "Core/MFPlayerController.h"
#include "Mech/MFMechPawn.h"
#include "UI/MFHUDWidget.h"
#include "AI/MFSquadDirector.h"
#include "EnhancedInputComponent.h"
#include "EnhancedInputSubsystems.h"
#include "InputActionValue.h"
#include "MechFrontline.h"
#include "Blueprint/UserWidget.h"

AMFPlayerController::AMFPlayerController()
{
	bShowMouseCursor = false;
}

void AMFPlayerController::BeginPlay()
{
	Super::BeginPlay();

	if (ULocalPlayer* LP = GetLocalPlayer())
	{
		if (UEnhancedInputLocalPlayerSubsystem* Subsystem =
			ULocalPlayer::GetSubsystem<UEnhancedInputLocalPlayerSubsystem>(LP))
		{
			if (DefaultMappingContext)
			{
				Subsystem->AddMappingContext(DefaultMappingContext, 0);
			}
		}
	}

	if (HUDWidgetClass)
	{
		HUDWidget = CreateWidget<UMFHUDWidget>(this, HUDWidgetClass);
		if (HUDWidget)
		{
			HUDWidget->AddToViewport();
		}
	}
}

void AMFPlayerController::SetupInputComponent()
{
	Super::SetupInputComponent();

	if (UEnhancedInputComponent* EIC = Cast<UEnhancedInputComponent>(InputComponent))
	{
		if (MoveAction)
		{
			EIC->BindAction(MoveAction, ETriggerEvent::Triggered, this, &AMFPlayerController::HandleMove);
		}
		if (LookAction)
		{
			EIC->BindAction(LookAction, ETriggerEvent::Triggered, this, &AMFPlayerController::HandleLook);
		}
		if (FirePrimaryAction)
		{
			EIC->BindAction(FirePrimaryAction, ETriggerEvent::Triggered, this, &AMFPlayerController::HandleFirePrimary);
		}
		if (LockTargetAction)
		{
			EIC->BindAction(LockTargetAction, ETriggerEvent::Started, this, &AMFPlayerController::HandleLockTarget);
		}
		if (BoostAction)
		{
			EIC->BindAction(BoostAction, ETriggerEvent::Triggered, this, &AMFPlayerController::HandleBoost);
		}
	}
}

void AMFPlayerController::OnPossess(APawn* InPawn)
{
	Super::OnPossess(InPawn);
	UE_LOG(LogMechFrontline, Log, TEXT("Possessed pawn: %s"), *GetNameSafe(InPawn));
}

AMFMechPawn* AMFPlayerController::GetControlledMech() const
{
	return Cast<AMFMechPawn>(GetPawn());
}

void AMFPlayerController::IssueSquadOrder(EMFSquadOrder Order)
{
	if (UWorld* World = GetWorld())
	{
		if (AMFSquadDirector* Director = AMFSquadDirector::FindDirector(World))
		{
			Director->IssueOrder(Order, GetControlledMech());
		}
	}
}

void AMFPlayerController::HandleMove(const FInputActionValue& Value)
{
	if (AMFMechPawn* Mech = GetControlledMech())
	{
		const FVector2D Axis = Value.Get<FVector2D>();
		Mech->AddMoveInput(Axis);
	}
}

void AMFPlayerController::HandleLook(const FInputActionValue& Value)
{
	if (AMFMechPawn* Mech = GetControlledMech())
	{
		const FVector2D Axis = Value.Get<FVector2D>();
		Mech->AddLookInput(Axis);
	}
}

void AMFPlayerController::HandleFirePrimary(const FInputActionValue& Value)
{
	if (AMFMechPawn* Mech = GetControlledMech())
	{
		Mech->FirePrimary();
	}
}

void AMFPlayerController::HandleLockTarget(const FInputActionValue& Value)
{
	if (AMFMechPawn* Mech = GetControlledMech())
	{
		Mech->CycleOrAcquireLock();
	}
}

void AMFPlayerController::HandleBoost(const FInputActionValue& Value)
{
	if (AMFMechPawn* Mech = GetControlledMech())
	{
		Mech->SetBoosting(true);
	}
}
