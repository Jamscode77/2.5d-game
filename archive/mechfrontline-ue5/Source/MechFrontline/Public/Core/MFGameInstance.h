// Copyright MechFrontline. All rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "Engine/GameInstance.h"
#include "MFGameInstance.generated.h"

class UMFMissionDefinition;

/**
 * Persistent session state across map loads (campaign progress, selected frame).
 * Scaffold: wire save/load later; keep mission selection here.
 */
UCLASS(Blueprintable)
class MECHFRONTLINE_API UMFGameInstance : public UGameInstance
{
	GENERATED_BODY()

public:
	virtual void Init() override;

	UFUNCTION(BlueprintCallable, Category = "Campaign")
	void SetSelectedMission(UMFMissionDefinition* Mission);

	UFUNCTION(BlueprintPure, Category = "Campaign")
	UMFMissionDefinition* GetSelectedMission() const { return SelectedMission; }

	UFUNCTION(BlueprintCallable, Category = "Campaign")
	void SetSelectedFrameId(FName FrameId);

	UFUNCTION(BlueprintPure, Category = "Campaign")
	FName GetSelectedFrameId() const { return SelectedFrameId; }

protected:
	UPROPERTY(BlueprintReadOnly, Category = "Campaign")
	TObjectPtr<UMFMissionDefinition> SelectedMission;

	UPROPERTY(BlueprintReadOnly, Category = "Campaign")
	FName SelectedFrameId;
};
