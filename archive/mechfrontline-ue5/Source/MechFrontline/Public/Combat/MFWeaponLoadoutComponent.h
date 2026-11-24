// Copyright MechFrontline. All rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "Types/MFTypes.h"
#include "MFWeaponLoadoutComponent.generated.h"

class AMFWeaponBase;

UCLASS(ClassGroup = (Combat), meta = (BlueprintSpawnableComponent))
class MECHFRONTLINE_API UMFWeaponLoadoutComponent : public UActorComponent
{
	GENERATED_BODY()

public:
	UMFWeaponLoadoutComponent();

	UFUNCTION(BlueprintCallable, Category = "Loadout")
	void ApplyDefaultLoadout(const TMap<EMFWeaponSlot, TSubclassOf<AMFWeaponBase>>& Defaults);

	UFUNCTION(BlueprintCallable, Category = "Loadout")
	bool FireSlot(EMFWeaponSlot Slot, AActor* LockedTarget);

	UFUNCTION(BlueprintCallable, Category = "Loadout")
	void CyclePrimarySecondary();

	UFUNCTION(BlueprintPure, Category = "Loadout")
	AMFWeaponBase* GetWeapon(EMFWeaponSlot Slot) const;

protected:
	UPROPERTY(BlueprintReadOnly, Category = "Loadout")
	TMap<EMFWeaponSlot, TObjectPtr<AMFWeaponBase>> Equipped;

	UPROPERTY(BlueprintReadOnly, Category = "Loadout")
	EMFWeaponSlot ActiveSlot = EMFWeaponSlot::Primary;
};
