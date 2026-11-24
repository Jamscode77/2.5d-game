// Copyright MechFrontline. All rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "Types/MFTypes.h"
#include "MFHealthComponent.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FMFOnHullChanged, float, CurrentHull, float, MaxHull);
DECLARE_DYNAMIC_MULTICAST_DELEGATE(FMFOnFrameDestroyed);

UCLASS(ClassGroup = (Combat), meta = (BlueprintSpawnableComponent))
class MECHFRONTLINE_API UMFHealthComponent : public UActorComponent
{
	GENERATED_BODY()

public:
	UMFHealthComponent();

	UFUNCTION(BlueprintCallable, Category = "Health")
	void InitializeHull(float InMaxHull);

	UFUNCTION(BlueprintCallable, Category = "Health")
	float ApplyDamage(const FMFDamageEvent& DamageEvent);

	UFUNCTION(BlueprintPure, Category = "Health")
	float GetHullPercent() const;

	UFUNCTION(BlueprintPure, Category = "Health")
	bool IsDestroyed() const { return bDestroyed; }

	UPROPERTY(BlueprintAssignable, Category = "Health")
	FMFOnHullChanged OnHullChanged;

	UPROPERTY(BlueprintAssignable, Category = "Health")
	FMFOnFrameDestroyed OnDestroyed;

protected:
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Health")
	float MaxHull = 1000.f;

	UPROPERTY(BlueprintReadOnly, Category = "Health")
	float CurrentHull = 1000.f;

	UPROPERTY(BlueprintReadOnly, Category = "Health")
	bool bDestroyed = false;

	/** Per-zone remaining integrity 0..1 — scaffold for critical hits / limb loss. */
	UPROPERTY(BlueprintReadOnly, Category = "Health")
	TMap<EMFArmorZone, float> ZoneIntegrity;
};
