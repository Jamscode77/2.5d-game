// Copyright MechFrontline. All rights reserved.

#include "Mech/MFMechMovementComponent.h"

UMFMechMovementComponent::UMFMechMovementComponent()
{
	MaxSpeed = 600.f;
	Acceleration = 2400.f;
	Deceleration = 3000.f;
	TurningBoost = 8.f;
	BaseMaxSpeed = MaxSpeed;
}

void UMFMechMovementComponent::SetBoosting(bool bNewBoosting)
{
	bIsBoosting = bNewBoosting;
	MaxSpeed = bIsBoosting ? BaseMaxSpeed * BoostMultiplier : BaseMaxSpeed;
}

void UMFMechMovementComponent::TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction)
{
	Super::TickComponent(DeltaTime, TickType, ThisTickFunction);
	// Scaffold: boost energy drain / cooldown lives on AMFMechPawn.
}
