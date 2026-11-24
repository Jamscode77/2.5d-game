// Copyright MechFrontline. All rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/PlayerController.h"
#include "Types/MFTypes.h"
#include "MFPlayerController.generated.h"

class UInputMappingContext;
class UInputAction;
class AMFMechPawn;
class UMFHUDWidget;

/**
 * Possesses AMFMechPawn, routes Enhanced Input, issues squad orders, owns HUD.
 */
UCLASS(Blueprintable)
class MECHFRONTLINE_API AMFPlayerController : public APlayerController
{
	GENERATED_BODY()

public:
	AMFPlayerController();

	virtual void BeginPlay() override;
	virtual void SetupInputComponent() override;
	virtual void OnPossess(APawn* InPawn) override;

	UFUNCTION(BlueprintCallable, Category = "Squad")
	void IssueSquadOrder(EMFSquadOrder Order);

	UFUNCTION(BlueprintPure, Category = "Mech")
	AMFMechPawn* GetControlledMech() const;

protected:
	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Input")
	TObjectPtr<UInputMappingContext> DefaultMappingContext;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Input")
	TObjectPtr<UInputAction> MoveAction;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Input")
	TObjectPtr<UInputAction> LookAction;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Input")
	TObjectPtr<UInputAction> FirePrimaryAction;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Input")
	TObjectPtr<UInputAction> LockTargetAction;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "Input")
	TObjectPtr<UInputAction> BoostAction;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category = "UI")
	TSubclassOf<UMFHUDWidget> HUDWidgetClass;

	UPROPERTY(BlueprintReadOnly, Category = "UI")
	TObjectPtr<UMFHUDWidget> HUDWidget;

	void HandleMove(const struct FInputActionValue& Value);
	void HandleLook(const struct FInputActionValue& Value);
	void HandleFirePrimary(const struct FInputActionValue& Value);
	void HandleLockTarget(const struct FInputActionValue& Value);
	void HandleBoost(const struct FInputActionValue& Value);
};
