// Copyright MechFrontline. All rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "Types/MFTypes.h"
#include "MFTargetingComponent.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FMFOnLockChanged, AActor*, NewTarget);

UCLASS(ClassGroup = (Combat), meta = (BlueprintSpawnableComponent))
class MECHFRONTLINE_API UMFTargetingComponent : public UActorComponent
{
	GENERATED_BODY()

public:
	UMFTargetingComponent();

	UFUNCTION(BlueprintCallable, Category = "Targeting")
	void AcquireOrCycleLock(EMFFaction OwnerFaction);

	UFUNCTION(BlueprintCallable, Category = "Targeting")
	void ClearLock();

	UFUNCTION(BlueprintPure, Category = "Targeting")
	AActor* GetLockedTarget() const { return LockedTarget.Get(); }

	UPROPERTY(BlueprintAssignable, Category = "Targeting")
	FMFOnLockChanged OnLockChanged;

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Targeting")
	float LockRadius = 15000.f;

protected:
	UPROPERTY(BlueprintReadOnly, Category = "Targeting")
	TWeakObjectPtr<AActor> LockedTarget;

	TArray<TWeakObjectPtr<AActor>> GatherCandidates(EMFFaction OwnerFaction) const;
};
