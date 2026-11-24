// Copyright MechFrontline. All rights reserved.

#include "Core/MFGameInstance.h"
#include "Core/MFGameSettings.h"
#include "MechFrontline.h"
#include "Mission/MFMissionDefinition.h"

void UMFGameInstance::Init()
{
	Super::Init();

	if (const UMFGameSettings* Settings = GetDefault<UMFGameSettings>())
	{
		SelectedFrameId = Settings->DefaultPlayerFrameId;
	}

	UE_LOG(LogMechFrontline, Log, TEXT("MFGameInstance initialized. Default frame: %s"), *SelectedFrameId.ToString());
}

void UMFGameInstance::SetSelectedMission(UMFMissionDefinition* Mission)
{
	SelectedMission = Mission;
}

void UMFGameInstance::SetSelectedFrameId(FName FrameId)
{
	SelectedFrameId = FrameId;
}
