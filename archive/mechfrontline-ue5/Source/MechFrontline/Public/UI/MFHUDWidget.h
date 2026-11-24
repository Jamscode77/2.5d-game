// Copyright MechFrontline. All rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "Blueprint/UserWidget.h"
#include "Types/MFTypes.h"
#include "MFHUDWidget.generated.h"

/**
 * Base combat HUD. Subclass in UMG (WBP_MF_HUD) and bind to frame status / mission state.
 */
UCLASS(Abstract, Blueprintable)
class MECHFRONTLINE_API UMFHUDWidget : public UUserWidget
{
	GENERATED_BODY()

public:
	UFUNCTION(BlueprintImplementableEvent, Category = "HUD")
	void OnFrameStatusUpdated(const FMFFrameStatus& Status);

	UFUNCTION(BlueprintImplementableEvent, Category = "HUD")
	void OnMissionStateUpdated(EMFMissionState State, const FText& MissionName);

	UFUNCTION(BlueprintImplementableEvent, Category = "HUD")
	void OnLockUpdated(AActor* LockedTarget);

	UFUNCTION(BlueprintCallable, Category = "HUD")
	void PushFrameStatus(const FMFFrameStatus& Status);
};
