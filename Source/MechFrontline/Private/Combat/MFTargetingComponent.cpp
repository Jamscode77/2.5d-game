// Copyright MechFrontline. All rights reserved.

#include "Combat/MFTargetingComponent.h"
#include "Mech/MFMechPawn.h"
#include "Kismet/GameplayStatics.h"

UMFTargetingComponent::UMFTargetingComponent()
{
	PrimaryComponentTick.bCanEverTick = false;
}

TArray<TWeakObjectPtr<AActor>> UMFTargetingComponent::GatherCandidates(EMFFaction OwnerFaction) const
{
	TArray<TWeakObjectPtr<AActor>> Result;
	UWorld* World = GetWorld();
	AActor* Owner = GetOwner();
	if (!World || !Owner)
	{
		return Result;
	}

	TArray<AActor*> Found;
	UGameplayStatics::GetAllActorsOfClass(World, AMFMechPawn::StaticClass(), Found);

	const FVector Origin = Owner->GetActorLocation();
	for (AActor* Actor : Found)
	{
		AMFMechPawn* Mech = Cast<AMFMechPawn>(Actor);
		if (!Mech || Mech == Owner)
		{
			continue;
		}
		if (Mech->GetFaction() == OwnerFaction || Mech->GetFaction() == EMFFaction::Ally)
		{
			continue;
		}
		if (FVector::DistSquared(Origin, Mech->GetActorLocation()) > FMath::Square(LockRadius))
		{
			continue;
		}
		Result.Add(Mech);
	}

	Result.Sort([Origin](const TWeakObjectPtr<AActor>& A, const TWeakObjectPtr<AActor>& B)
	{
		const float DA = A.IsValid() ? FVector::DistSquared(Origin, A->GetActorLocation()) : TNumericLimits<float>::Max();
		const float DB = B.IsValid() ? FVector::DistSquared(Origin, B->GetActorLocation()) : TNumericLimits<float>::Max();
		return DA < DB;
	});

	return Result;
}

void UMFTargetingComponent::AcquireOrCycleLock(EMFFaction OwnerFaction)
{
	const TArray<TWeakObjectPtr<AActor>> Candidates = GatherCandidates(OwnerFaction);
	if (Candidates.Num() == 0)
	{
		ClearLock();
		return;
	}

	int32 NextIndex = 0;
	if (LockedTarget.IsValid())
	{
		for (int32 i = 0; i < Candidates.Num(); ++i)
		{
			if (Candidates[i] == LockedTarget)
			{
				NextIndex = (i + 1) % Candidates.Num();
				break;
			}
		}
	}

	LockedTarget = Candidates[NextIndex];
	OnLockChanged.Broadcast(LockedTarget.Get());
}

void UMFTargetingComponent::ClearLock()
{
	if (LockedTarget.IsValid())
	{
		LockedTarget.Reset();
		OnLockChanged.Broadcast(nullptr);
	}
}
