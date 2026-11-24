// Copyright MechFrontline. All rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "AIController.h"
#include "Types/MFTypes.h"
#include "MFMechAIController.generated.h"

class AMFMechPawn;

/**
 * Enemy / ally frame brain scaffold.
 * Hook Behavior Trees later; orders from AMFSquadDirector override local goals.
 */
UCLASS(Blueprintable)
class MECHFRONTLINE_API AMFMechAIController : public AAIController
{
	GENERATED_BODY()

public:
	AMFMechAIController();

	virtual void OnPossess(APawn* InPawn) override;

	UFUNCTION(BlueprintCallable, Category = "Squad")
	void ReceiveSquadOrder(EMFSquadOrder Order, AActor* ContextActor);

	UFUNCTION(BlueprintCallable, Category = "Combat")
	void SetCombatTarget(AActor* Target);

protected:
	UPROPERTY(BlueprintReadOnly, Category = "Squad")
	EMFSquadOrder CurrentOrder = EMFSquadOrder::Follow;

	UPROPERTY(BlueprintReadOnly, Category = "Combat")
	TWeakObjectPtr<AActor> CombatTarget;

	UPROPERTY(BlueprintReadOnly, Category = "Mech")
	TWeakObjectPtr<AMFMechPawn> ControlledMech;
};
