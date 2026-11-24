// Copyright MechFrontline. All rights reserved.

#pragma once

#include "CoreMinimal.h"
#include "MFTypes.generated.h"

/** High-level allegiance for mission scripting and targeting. */
UENUM(BlueprintType)
enum class EMFFaction : uint8
{
	Neutral		UMETA(DisplayName = "Neutral"),
	Player		UMETA(DisplayName = "Player Force"),
	Ally		UMETA(DisplayName = "Allied Force"),
	Enemy		UMETA(DisplayName = "Hostile Force")
};

/** Coarse armor regions for tactical damage routing (scaffold). */
UENUM(BlueprintType)
enum class EMFArmorZone : uint8
{
	Hull		UMETA(DisplayName = "Hull"),
	Head		UMETA(DisplayName = "Sensors / Head"),
	LeftArm		UMETA(DisplayName = "Left Arm"),
	RightArm	UMETA(DisplayName = "Right Arm"),
	LeftLeg		UMETA(DisplayName = "Left Leg"),
	RightLeg	UMETA(DisplayName = "Right Leg"),
	Backpack	UMETA(DisplayName = "Thruster Pack")
};

UENUM(BlueprintType)
enum class EMFWeaponSlot : uint8
{
	Primary		UMETA(DisplayName = "Primary"),
	Secondary	UMETA(DisplayName = "Secondary"),
	Melee		UMETA(DisplayName = "Melee"),
	Special		UMETA(DisplayName = "Special")
};

UENUM(BlueprintType)
enum class EMFSquadOrder : uint8
{
	Follow		UMETA(DisplayName = "Follow"),
	Hold		UMETA(DisplayName = "Hold Position"),
	AttackTarget	UMETA(DisplayName = "Attack My Target"),
	Rally		UMETA(DisplayName = "Rally on Me")
};

UENUM(BlueprintType)
enum class EMFMissionState : uint8
{
	Inactive	UMETA(DisplayName = "Inactive"),
	Briefing	UMETA(DisplayName = "Briefing"),
	Active		UMETA(DisplayName = "Active"),
	Success		UMETA(DisplayName = "Success"),
	Failed		UMETA(DisplayName = "Failed"),
	Aborted		UMETA(DisplayName = "Aborted")
};

UENUM(BlueprintType)
enum class EMFObjectiveType : uint8
{
	DestroyTarget	UMETA(DisplayName = "Destroy Target"),
	DefendZone		UMETA(DisplayName = "Defend Zone"),
	ReachLocation	UMETA(DisplayName = "Reach Location"),
	SurviveTimer	UMETA(DisplayName = "Survive Timer"),
	Escort			UMETA(DisplayName = "Escort")
};

/** Runtime snapshot of frame vitals for HUD / AI. */
USTRUCT(BlueprintType)
struct MECHFRONTLINE_API FMFFrameStatus
{
	GENERATED_BODY()

	UPROPERTY(BlueprintReadOnly, Category = "Frame")
	float HullPercent = 1.f;

	UPROPERTY(BlueprintReadOnly, Category = "Frame")
	float HeatPercent = 0.f;

	UPROPERTY(BlueprintReadOnly, Category = "Frame")
	float BoostPercent = 1.f;

	UPROPERTY(BlueprintReadOnly, Category = "Frame")
	bool bIsOverheated = false;

	UPROPERTY(BlueprintReadOnly, Category = "Frame")
	bool bIsDestroyed = false;
};

USTRUCT(BlueprintType)
struct MECHFRONTLINE_API FMFDamageEvent
{
	GENERATED_BODY()

	UPROPERTY(BlueprintReadWrite, Category = "Combat")
	float Amount = 0.f;

	UPROPERTY(BlueprintReadWrite, Category = "Combat")
	EMFArmorZone Zone = EMFArmorZone::Hull;

	UPROPERTY(BlueprintReadWrite, Category = "Combat")
	TWeakObjectPtr<AActor> Instigator;

	UPROPERTY(BlueprintReadWrite, Category = "Combat")
	FVector HitLocation = FVector::ZeroVector;
};
