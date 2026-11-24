// Copyright MechFrontline. All rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "MFHeatComponent.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FMFOnOverheatChanged, bool, bIsOverheated);

/** Weapon / boost heat sink. Overheat locks weapons until cooled below threshold. */
UCLASS(ClassGroup = (Combat), meta = (BlueprintSpawnableComponent))
class MECHFRONTLINE_API UMFHeatComponent : public UActorComponent
{
	GENERATED_BODY()

public:
	UMFHeatComponent();

	virtual void TickComponent(float DeltaTime, ELevelTick TickType, FActorComponentTickFunction* ThisTickFunction) override;

	UFUNCTION(BlueprintCallable, Category = "Heat")
	void InitializeHeat(float InMaxHeat, float InDissipationPerSecond);

	UFUNCTION(BlueprintCallable, Category = "Heat")
	bool TryAddHeat(float Amount);

	UFUNCTION(BlueprintPure, Category = "Heat")
	float GetHeatPercent() const;

	UFUNCTION(BlueprintPure, Category = "Heat")
	bool IsOverheated() const { return bOverheated; }

	UPROPERTY(BlueprintAssignable, Category = "Heat")
	FMFOnOverheatChanged OnOverheatChanged;

protected:
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Heat")
	float MaxHeat = 100.f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Heat")
	float DissipationPerSecond = 15.f;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Heat", meta = (ClampMin = "0.0", ClampMax = "1.0"))
	float OverheatClearThreshold = 0.35f;

	UPROPERTY(BlueprintReadOnly, Category = "Heat")
	float CurrentHeat = 0.f;

	UPROPERTY(BlueprintReadOnly, Category = "Heat")
	bool bOverheated = false;
};
