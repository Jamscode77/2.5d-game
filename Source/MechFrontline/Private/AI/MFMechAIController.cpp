// Copyright MechFrontline. All rights reserved.

#include "AI/MFMechAIController.h"
#include "Mech/MFMechPawn.h"
#include "MechFrontline.h"

AMFMechAIController::AMFMechAIController()
{
	bWantsPlayerState = false;
}

void AMFMechAIController::OnPossess(APawn* InPawn)
{
	Super::OnPossess(InPawn);
	ControlledMech = Cast<AMFMechPawn>(InPawn);
	UE_LOG(LogMechFrontline, Log, TEXT("AI possessed %s"), *GetNameSafe(InPawn));
}

void AMFMechAIController::ReceiveSquadOrder(EMFSquadOrder Order, AActor* ContextActor)
{
	CurrentOrder = Order;
	if (Order == EMFSquadOrder::AttackTarget && ContextActor)
	{
		SetCombatTarget(ContextActor);
	}
	UE_LOG(LogMechFrontline, Verbose, TEXT("%s received order %d"), *GetName(), static_cast<int32>(Order));
}

void AMFMechAIController::SetCombatTarget(AActor* Target)
{
	CombatTarget = Target;
}
