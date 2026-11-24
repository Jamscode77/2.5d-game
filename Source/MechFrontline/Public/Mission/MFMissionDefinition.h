// Copyright MechFrontline. All rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "Engine/DataAsset.h"
#include "Types/MFTypes.h"
#include "MFMissionDefinition.generated.h"

USTRUCT(BlueprintType)
struct MECHFRONTLINE_API FMFObjectiveDefinition
{
	GENERATED_BODY()

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Objective")
	FName ObjectiveId;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Objective")
	FText Title;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Objective")
	EMFObjectiveType Type = EMFObjectiveType::DestroyTarget;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Objective")
	bool bOptional = false;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Objective")
	bool bRequiredForSuccess = true;

	/** Soft reference to a map actor tag / target id resolved at runtime. */
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Objective")
	FName TargetTag;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Objective", meta = (ClampMin = "0.0"))
	float TimerSeconds = 0.f;
};

/**
 * Authorable mission brief. Create under Content/MechFrontline/Data/Missions/.
 */
UCLASS(BlueprintType)
class MECHFRONTLINE_API UMFMissionDefinition : public UPrimaryDataAsset
{
	GENERATED_BODY()

public:
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Mission")
	FName MissionId;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Mission")
	FText DisplayName;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Mission", meta = (MultiLine = "true"))
	FText Briefing;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Mission")
	TSoftObjectPtr<UWorld> MissionMap;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Mission")
	TArray<FMFObjectiveDefinition> Objectives;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Mission")
	int32 RecommendedSquadSize = 3;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Mission")
	TArray<FName> AllowedFrameIds;

	virtual FPrimaryAssetId GetPrimaryAssetId() const override
	{
		return FPrimaryAssetId(TEXT("MFMission"), MissionId.IsNone() ? GetFName() : MissionId);
	}
};
