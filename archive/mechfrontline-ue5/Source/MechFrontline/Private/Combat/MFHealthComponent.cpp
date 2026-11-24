// Copyright MechFrontline. All rights reserved.

#include "Combat/MFHealthComponent.h"
#include "MechFrontline.h"

UMFHealthComponent::UMFHealthComponent()
{
	PrimaryComponentTick.bCanEverTick = false;
}

void UMFHealthComponent::InitializeHull(float InMaxHull)
{
	MaxHull = FMath::Max(1.f, InMaxHull);
	CurrentHull = MaxHull;
	bDestroyed = false;

	ZoneIntegrity.Reset();
	for (uint8 i = 0; i <= static_cast<uint8>(EMFArmorZone::Backpack); ++i)
	{
		ZoneIntegrity.Add(static_cast<EMFArmorZone>(i), 1.f);
	}

	OnHullChanged.Broadcast(CurrentHull, MaxHull);
}

float UMFHealthComponent::ApplyDamage(const FMFDamageEvent& DamageEvent)
{
	if (bDestroyed || DamageEvent.Amount <= 0.f)
	{
		return 0.f;
	}

	const float Applied = FMath::Min(CurrentHull, DamageEvent.Amount);
	CurrentHull -= Applied;

	if (float* Zone = ZoneIntegrity.Find(DamageEvent.Zone))
	{
		*Zone = FMath::Clamp(*Zone - (DamageEvent.Amount / MaxHull), 0.f, 1.f);
	}

	OnHullChanged.Broadcast(CurrentHull, MaxHull);

	if (CurrentHull <= 0.f)
	{
		bDestroyed = true;
		OnDestroyed.Broadcast();
		UE_LOG(LogMechFrontline, Log, TEXT("%s destroyed"), *GetNameSafe(GetOwner()));
	}

	return Applied;
}

float UMFHealthComponent::GetHullPercent() const
{
	return MaxHull > 0.f ? CurrentHull / MaxHull : 0.f;
}
