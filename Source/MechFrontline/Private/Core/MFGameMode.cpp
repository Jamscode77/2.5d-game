// Copyright MechFrontline. All rights reserved.

#include "Core/MFGameMode.h"
#include "Core/MFPlayerController.h"
#include "Mech/MFMechPawn.h"
#include "Mission/MFMissionSubsystem.h"
#include "MechFrontline.h"
#include "UObject/ConstructorHelpers.h"

AMFGameMode::AMFGameMode()
{
	PlayerControllerClass = AMFPlayerController::StaticClass();
	DefaultPawnClass = AMFMechPawn::StaticClass();
}

void AMFGameMode::StartPlay()
{
	Super::StartPlay();
	UE_LOG(LogMechFrontline, Log, TEXT("MFGameMode::StartPlay — sandbox / mission map ready."));
	RequestMissionStart();
}

void AMFGameMode::HandleMatchHasStarted()
{
	// Intentionally empty scaffold hook.
}

void AMFGameMode::RequestMissionStart()
{
	if (UWorld* World = GetWorld())
	{
		if (UMFMissionSubsystem* Missions = World->GetSubsystem<UMFMissionSubsystem>())
		{
			Missions->StartSelectedOrDefaultMission();
		}
	}
}

void AMFGameMode::RequestMissionAbort()
{
	if (UWorld* World = GetWorld())
	{
		if (UMFMissionSubsystem* Missions = World->GetSubsystem<UMFMissionSubsystem>())
		{
			Missions->AbortMission();
		}
	}
}
