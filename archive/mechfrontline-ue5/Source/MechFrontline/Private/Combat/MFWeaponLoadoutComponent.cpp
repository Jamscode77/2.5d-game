// Copyright MechFrontline. All rights reserved.

#include "Combat/MFWeaponLoadoutComponent.h"
#include "Combat/MFWeaponBase.h"
#include "Mech/MFMechPawn.h"

UMFWeaponLoadoutComponent::UMFWeaponLoadoutComponent()
{
	PrimaryComponentTick.bCanEverTick = false;
}

void UMFWeaponLoadoutComponent::ApplyDefaultLoadout(const TMap<EMFWeaponSlot, TSubclassOf<AMFWeaponBase>>& Defaults)
{
	for (auto& Pair : Equipped)
	{
		if (Pair.Value)
		{
			Pair.Value->Destroy();
		}
	}
	Equipped.Reset();

	AActor* Owner = GetOwner();
	AMFMechPawn* Mech = Cast<AMFMechPawn>(Owner);
	if (!Owner)
	{
		return;
	}

	for (const auto& Pair : Defaults)
	{
		if (!Pair.Value)
		{
			continue;
		}
		AMFWeaponBase* Weapon = Owner->GetWorld()->SpawnActor<AMFWeaponBase>(Pair.Value);
		if (Weapon)
		{
			Weapon->AttachToMech(Mech, Pair.Key);
			Equipped.Add(Pair.Key, Weapon);
		}
	}
}

bool UMFWeaponLoadoutComponent::FireSlot(EMFWeaponSlot Slot, AActor* LockedTarget)
{
	if (AMFWeaponBase* Weapon = GetWeapon(Slot))
	{
		return Weapon->Fire(LockedTarget);
	}
	return false;
}

void UMFWeaponLoadoutComponent::CyclePrimarySecondary()
{
	ActiveSlot = (ActiveSlot == EMFWeaponSlot::Primary) ? EMFWeaponSlot::Secondary : EMFWeaponSlot::Primary;
}

AMFWeaponBase* UMFWeaponLoadoutComponent::GetWeapon(EMFWeaponSlot Slot) const
{
	if (const TObjectPtr<AMFWeaponBase>* Found = Equipped.Find(Slot))
	{
		return Found->Get();
	}
	return nullptr;
}
