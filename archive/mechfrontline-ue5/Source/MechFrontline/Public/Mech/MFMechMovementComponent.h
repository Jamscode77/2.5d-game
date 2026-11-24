// Copyright MechFrontline. All rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/FloatingPawnMovement.h"
#include "MFMechMovementComponent.generated.h"

/**
 * Grounded / hovering frame locomotion scaffold.
 * Replace or extend with custom CharacterMovement later if you need root motion / slopes.
 */
UCLASS(ClassGroup = (Mech), meta = (BlueprintSpawnableComponent))
class MECHFRONTLINE_API UMFMechMovementComponent : public UFloatingPawnMovement
{
	GENERATED_BODY()

public:
	UMFMechMovementComponent();

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Boost")
	float BoostMultiplier = 1.75f;

	UPROPERTY(BlueprintReadOnly, Category = "Boost")
	bool bIsBoosting = false;

	UFUNCTION(BlueprintCallable, Category = "Boost")
	void SetBoosting(bool bNewBoosting);

	virtual void TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) override;

protected:
	float BaseMaxSpeed = 600.f;
};
