// Copyright MechFrontline. All rights reserved.

#include "AI/MFSquadDirector.h"
#include "AI/MFMechAIController.h"
#include "Mech/MFMechPawn.h"
#include "Combat/MFTargetingComponent.h"
#include "Kismet/GameplayStatics.h"
#include "EngineUtils.h"

AMFSquadDirector::AMFSquadDirector()
{
	PrimaryActorTick.bCanEverTick = false;
}

AMFSquadDirector* AMFSquadDirector::FindDirector(UWorld* World)
{
	if (!World)
	{
		return nullptr;
	}
	for (TActorIterator<AMFSquadDirector> It(World); It; ++It)
	{
		return *It;
	}
	return nullptr;
}

void AMFSquadDirector::RegisterAlly(AMFMechAIController* Ally)
{
	if (Ally)
	{
		Allies.AddUnique(Ally);
	}
}

void AMFSquadDirector::UnregisterAlly(AMFMechAIController* Ally)
{
	Allies.RemoveAll([Ally](const TWeakObjectPtr<AMFMechAIController>& Ptr)
	{
		return !Ptr.IsValid() || Ptr.Get() == Ally;
	});
}

void AMFSquadDirector::IssueOrder(EMFSquadOrder Order, AMFMechPawn* Issuer)
{
	AActor* Context = nullptr;
	if (Issuer)
	{
		if (UMFTargetingComponent* Targeting = Issuer->FindComponentByClass<UMFTargetingComponent>())
		{
			Context = Targeting->GetLockedTarget();
		}
	}

	for (const TWeakObjectPtr<AMFMechAIController>& Ally : Allies)
	{
		if (AMFMechAIController* AI = Ally.Get())
		{
			AI->ReceiveSquadOrder(Order, Context);
		}
	}
}
