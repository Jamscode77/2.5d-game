// Copyright MechFrontline. All rights reserved.

#include "Mission/MFMissionSubsystem.h"
#include "Mission/MFMissionDefinition.h"
#include "Core/MFGameInstance.h"
#include "MechFrontline.h"

void UMFMissionSubsystem::Initialize(FSubsystemCollectionBase& Collection)
{
	Super::Initialize(Collection);
	State = EMFMissionState::Inactive;
}

void UMFMissionSubsystem::StartSelectedOrDefaultMission()
{
	UMFMissionDefinition* Mission = DevDefaultMission;
	if (UWorld* World = GetWorld())
	{
		if (UMFGameInstance* GI = Cast<UMFGameInstance>(World->GetGameInstance()))
		{
			if (UMFMissionDefinition* Selected = GI->GetSelectedMission())
			{
				Mission = Selected;
			}
		}
	}

	if (Mission)
	{
		StartMission(Mission);
	}
	else
	{
		UE_LOG(LogMechFrontline, Warning, TEXT("No mission selected — running free sandbox."));
		SetState(EMFMissionState::Active);
	}
}

void UMFMissionSubsystem::StartMission(UMFMissionDefinition* Mission)
{
	ActiveMission = Mission;
	CompletedObjectives.Reset();
	SetState(EMFMissionState::Briefing);
	SetState(EMFMissionState::Active);
	UE_LOG(LogMechFrontline, Log, TEXT("Mission started: %s"), Mission ? *Mission->MissionId.ToString() : TEXT("None"));
}

void UMFMissionSubsystem::AbortMission()
{
	SetState(EMFMissionState::Aborted);
	ActiveMission = nullptr;
}

void UMFMissionSubsystem::FailMission()
{
	SetState(EMFMissionState::Failed);
}

void UMFMissionSubsystem::CompleteObjective(FName ObjectiveId)
{
	if (State != EMFMissionState::Active || ObjectiveId.IsNone())
	{
		return;
	}

	CompletedObjectives.Add(ObjectiveId);
	OnObjectiveUpdated.Broadcast(ObjectiveId, true);
	EvaluateSuccess();
}

void UMFMissionSubsystem::EvaluateSuccess()
{
	if (!ActiveMission)
	{
		return;
	}

	for (const FMFObjectiveDefinition& Obj : ActiveMission->Objectives)
	{
		if (Obj.bRequiredForSuccess && !CompletedObjectives.Contains(Obj.ObjectiveId))
		{
			return;
		}
	}

	SetState(EMFMissionState::Success);
}

void UMFMissionSubsystem::SetState(EMFMissionState NewState)
{
	if (State == NewState)
	{
		return;
	}
	State = NewState;
	OnMissionStateChanged.Broadcast(State, ActiveMission);
}
