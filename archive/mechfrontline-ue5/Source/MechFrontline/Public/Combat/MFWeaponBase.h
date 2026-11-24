// Copyright MechFrontline. All rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "Types/MFTypes.h"
#include "MFWeaponBase.generated.h"

class AMFMechPawn;

/** Base hardpoint weapon. Scaffold: implement Fire_Implementation in BP or C++ subclasses. */
UCLASS(Abstract, Blueprintable)
class MECHFRONTLINE_API AMFWeaponBase : public AActor
{
	GENERATED_BODY()

public:
	AMFWeaponBase();

	UFUNCTION(BlueprintCallable, Category = "Weapon")
	void AttachToMech(AMFMechPawn* Mech, EMFWeaponSlot Slot);

	UFUNCTION(BlueprintCallable, Category = "Weapon")
	virtual bool Fire(AActor* LockedTarget);

	UFUNCTION(BlueprintNativeEvent, Category = "Weapon")
	void OnFired(AActor* LockedTarget);
	virtual void OnFired_Implementation(AActor* LockedTarget);

	UFUNCTION(BlueprintPure, Category = "Weapon")
	float GetHeatCost() const { return HeatCostPerShot; }

protected:
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Weapon")
	FText WeaponName;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Weapon")
	EMFWeaponSlot Slot = EMFWeaponSlot::Primary;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Weapon")
	float Damage = 50.f;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Weapon")
	float HeatCostPerShot = 8.f;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Weapon")
	float FireInterval = 0.25f;

	UPROPERTY(BlueprintReadOnly, Category = "Weapon")
	TWeakObjectPtr<AMFMechPawn> OwningMech;

	float LastFireTime = -1000.f;
};
