// Copyright MechFrontline. All rights reserved.

#include "Combat/MFHeatComponent.h"

UMFHeatComponent::UMFHeatComponent()
{
	PrimaryComponentTick.bCanEverTick = true;
}

void UMFHeatComponent::InitializeHeat(float InMaxHeat, float InDissipationPerSecond)
{
	MaxHeat = FMath::Max(1.f, InMaxHeat);
	DissipationPerSecond = FMath::Max(0.f, InDissipationPerSecond);
	CurrentHeat = 0.f;
	bOverheated = false;
}

void UMFHeatComponent::TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction)
{
	Super::TickComponent(DeltaTime, TickType, ThisTickFunction);

	if (CurrentHeat > 0.f)
	{
		CurrentHeat = FMath::Max(0.f, CurrentHeat - DissipationPerSecond * DeltaTime);
	}

	if (bOverheated && GetHeatPercent() <= OverheatClearThreshold)
	{
		bOverheated = false;
		OnOverheatChanged.Broadcast(false);
	}
}

bool UMFHeatComponent::TryAddHeat(float Amount)
{
	if (bOverheated || Amount <= 0.f)
	{
		return false;
	}

	CurrentHeat = FMath::Min(MaxHeat, CurrentHeat + Amount);
	if (CurrentHeat >= MaxHeat)
	{
		bOverheated = true;
		OnOverheatChanged.Broadcast(true);
	}
	return true;
}

float UMFHeatComponent::GetHeatPercent() const
{
	return MaxHeat > 0.f ? CurrentHeat / MaxHeat : 0.f;
}
