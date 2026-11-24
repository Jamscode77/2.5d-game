// Copyright MechFrontline. All rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "MFGameMode.generated.h"

class AMFPlayerController;
class AMFMechPawn;
class UMFMissionSubsystem;

/**
 * Mission map GameMode. Spawns the player frame and starts the active mission.
 */
UCLASS(Blueprintable)
class MECHFRONTLINE_API AMFGameMode : public AGameModeBase
{
	GENERATED_BODY()

public:
	AMFGameMode();

	virtual void StartPlay() override;
	virtual void HandleMatchHasStarted(); // scaffold hook for Blueprint / subclasses

	UFUNCTION(BlueprintCallable, Category = "Mission")
	void RequestMissionStart();

	UFUNCTION(BlueprintCallable, Category = "Mission")
	void RequestMissionAbort();

protected:
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Mech")
	TSubclassOf<AMFMechPawn> DefaultMechClass;
};
