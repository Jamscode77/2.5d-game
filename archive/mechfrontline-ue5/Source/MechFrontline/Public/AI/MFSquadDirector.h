// Copyright MechFrontline. All rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Info.h"
#include "Types/MFTypes.h"
#include "MFSquadDirector.generated.h"

class AMFMechAIController;
class AMFMechPawn;

/**
 * Place one in the mission map (or spawn from GameMode).
 * Tracks allied AI frames and fans out player squad orders.
 */
UCLASS(Blueprintable)
class MECHFRONTLINE_API AMFSquadDirector : public AInfo
{
	GENERATED_BODY()

public:
	AMFSquadDirector();

	static AMFSquadDirector* FindDirector(UWorld* World);

	UFUNCTION(BlueprintCallable, Category = "Squad")
	void RegisterAlly(AMFMechAIController* Ally);

	UFUNCTION(BlueprintCallable, Category = "Squad")
	void UnregisterAlly(AMFMechAIController* Ally);

	UFUNCTION(BlueprintCallable, Category = "Squad")
	void IssueOrder(EMFSquadOrder Order, AMFMechPawn* Issuer);

protected:
	UPROPERTY(BlueprintReadOnly, Category = "Squad")
	TArray<TWeakObjectPtr<AMFMechAIController>> Allies;
};
