// Copyright MechFrontline. All rights reserved.

#include "Combat/MFWeaponBase.h"
#include "Mech/MFMechPawn.h"
#include "Combat/MFHeatComponent.h"
#include "MechFrontline.h"

AMFWeaponBase::AMFWeaponBase()
{
	PrimaryActorTick.bCanEverTick = false;
}

void AMFWeaponBase::AttachToMech(AMFMechPawn* Mech, EMFWeaponSlot InSlot)
{
	OwningMech = Mech;
	Slot = InSlot;
	if (Mech)
	{
		AttachToActor(Mech, FAttachmentTransformRules::SnapToTargetNotIncludingScale);
	}
}

bool AMFWeaponBase::Fire(AActor* LockedTarget)
{
	const float Now = GetWorld() ? GetWorld()->GetTimeSeconds() : 0.f;
	if (Now - LastFireTime < FireInterval)
	{
		return false;
	}

	if (AMFMechPawn* Mech = OwningMech.Get())
	{
		if (UMFHeatComponent* Heat = Mech->FindComponentByClass<UMFHeatComponent>())
		{
			if (!Heat->TryAddHeat(HeatCostPerShot))
			{
				return false;
			}
		}
	}

	LastFireTime = Now;
	OnFired(LockedTarget);
	return true;
}

void AMFWeaponBase::OnFired_Implementation(AActor* LockedTarget)
{
	UE_LOG(LogMechFrontline, Verbose, TEXT("%s fired at %s"), *GetName(), *GetNameSafe(LockedTarget));
	// Scaffold: spawn projectile / line trace in subclasses.
}
