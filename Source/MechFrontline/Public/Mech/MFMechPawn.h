// Copyright MechFrontline. All rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Pawn.h"
#include "Types/MFTypes.h"
#include "MFMechPawn.generated.h"

class UCapsuleComponent;
class USkeletalMeshComponent;
class USpringArmComponent;
class UCameraComponent;
class UMFMechMovementComponent;
class UMFFrameDefinition;
class UMFHealthComponent;
class UMFHeatComponent;
class UMFWeaponLoadoutComponent;
class UMFTargetingComponent;

/**
 * Player / AI mobile frame pawn. Scaffold ownership of movement, vitals, weapons, camera.
 */
UCLASS(Blueprintable)
class MECHFRONTLINE_API AMFMechPawn : public APawn
{
	GENERATED_BODY()

public:
	AMFMechPawn();

	virtual void Tick(float DeltaSeconds) override;
	virtual void SetupPlayerInputComponent(UInputComponent* PlayerInputComponent) override;

	UFUNCTION(BlueprintCallable, Category = "Mech")
	void ApplyFrameDefinition(UMFFrameDefinition* Definition);

	UFUNCTION(BlueprintCallable, Category = "Mech|Input")
	void AddMoveInput(FVector2D Axis);

	UFUNCTION(BlueprintCallable, Category = "Mech|Input")
	void AddLookInput(FVector2D Axis);

	UFUNCTION(BlueprintCallable, Category = "Mech|Combat")
	void FirePrimary();

	UFUNCTION(BlueprintCallable, Category = "Mech|Combat")
	void CycleOrAcquireLock();

	UFUNCTION(BlueprintCallable, Category = "Mech|Movement")
	void SetBoosting(bool bBoosting);

	UFUNCTION(BlueprintPure, Category = "Mech")
	FMFFrameStatus GetFrameStatus() const;

	UFUNCTION(BlueprintPure, Category = "Mech")
	EMFFaction GetFaction() const { return Faction; }

	UFUNCTION(BlueprintCallable, Category = "Mech")
	void SetFaction(EMFFaction NewFaction) { Faction = NewFaction; }

protected:
	virtual void BeginPlay() override;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Components")
	TObjectPtr<UCapsuleComponent> Capsule;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Components")
	TObjectPtr<USkeletalMeshComponent> Mesh;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Components")
	TObjectPtr<USpringArmComponent> CameraBoom;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Components")
	TObjectPtr<UCameraComponent> FollowCamera;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Components")
	TObjectPtr<UMFMechMovementComponent> MechMovement;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Components")
	TObjectPtr<UMFHealthComponent> Health;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Components")
	TObjectPtr<UMFHeatComponent> Heat;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Components")
	TObjectPtr<UMFWeaponLoadoutComponent> Loadout;

	UPROPERTY(VisibleAnywhere, BlueprintReadOnly, Category = "Components")
	TObjectPtr<UMFTargetingComponent> Targeting;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Mech")
	TObjectPtr<UMFFrameDefinition> FrameDefinition;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Mech")
	EMFFaction Faction = EMFFaction::Player;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Camera")
	float LookYawRate = 120.f;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Camera")
	float LookPitchRate = 80.f;
};
