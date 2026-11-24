// Copyright MechFrontline. All rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "Subsystems/WorldSubsystem.h"
#include "Types/MFTypes.h"
#include "MFMissionSubsystem.generated.h"

class UMFMissionDefinition;

DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FMFOnMissionStateChanged, EMFMissionState, NewState, UMFMissionDefinition*, Mission);
DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FMFOnObjectiveUpdated, FName, ObjectiveId, bool, bComplete);

/**
 * Per-world mission runner. GameMode calls Start*; objectives report completion here.
 */
UCLASS()
class MECHFRONTLINE_API UMFMissionSubsystem : public UWorldSubsystem
{
	GENERATED_BODY()

public:
	virtual void Initialize(FSubsystemCollectionBase& Collection) override;

	UFUNCTION(BlueprintCallable, Category = "Mission")
	void StartSelectedOrDefaultMission();

	UFUNCTION(BlueprintCallable, Category = "Mission")
	void StartMission(UMFMissionDefinition* Mission);

	UFUNCTION(BlueprintCallable, Category = "Mission")
	void AbortMission();

	UFUNCTION(BlueprintCallable, Category = "Mission")
	void CompleteObjective(FName ObjectiveId);

	UFUNCTION(BlueprintCallable, Category = "Mission")
	void FailMission();

	UFUNCTION(BlueprintPure, Category = "Mission")
	EMFMissionState GetMissionState() const { return State; }

	UFUNCTION(BlueprintPure, Category = "Mission")
	UMFMissionDefinition* GetActiveMission() const { return ActiveMission; }

	UPROPERTY(BlueprintAssignable, Category = "Mission")
	FMFOnMissionStateChanged OnMissionStateChanged;

	UPROPERTY(BlueprintAssignable, Category = "Mission")
	FMFOnObjectiveUpdated OnObjectiveUpdated;

	/** Optional fallback when GameInstance has no selected mission (dev sandbox). */
	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Mission")
	TObjectPtr<UMFMissionDefinition> DevDefaultMission;

protected:
	void SetState(EMFMissionState NewState);
	void EvaluateSuccess();

	UPROPERTY()
	TObjectPtr<UMFMissionDefinition> ActiveMission;

	UPROPERTY()
	EMFMissionState State = EMFMissionState::Inactive;

	UPROPERTY()
	TSet<FName> CompletedObjectives;
};
