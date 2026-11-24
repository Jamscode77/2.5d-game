// Copyright MechFrontline. All rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "Engine/DeveloperSettings.h"
#include "MFGameSettings.generated.h"

/**
 * Project-wide defaults. Edit via Project Settings → Game → Mech Frontline
 * or Config/DefaultGame.ini [/Script/MechFrontline.MFGameSettings].
 */
UCLASS(Config = Game, DefaultConfig, meta = (DisplayName = "Mech Frontline"))
class MECHFRONTLINE_API UMFGameSettings : public UDeveloperSettings
{
	GENERATED_BODY()

public:
	UMFGameSettings();

	virtual FName GetCategoryName() const override { return TEXT("Game"); }

	/** Data-asset id / row name for the player's starting mobile frame. */
	UPROPERTY(Config, EditAnywhere, BlueprintReadOnly, Category = "Player")
	FName DefaultPlayerFrameId;

	UPROPERTY(Config, EditAnywhere, BlueprintReadOnly, Category = "Squad")
	bool bEnableSquadCommands = true;

	UPROPERTY(Config, EditAnywhere, BlueprintReadOnly, Category = "Combat")
	bool bEnableHeatSystem = true;

	UPROPERTY(Config, EditAnywhere, BlueprintReadOnly, Category = "Mission", meta = (ClampMin = "1"))
	int32 MaxActiveMissions = 1;
};
