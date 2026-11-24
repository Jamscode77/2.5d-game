# Class Responsibilities

## Core

- **`UMFGameSettings`** — Config defaults (starting frame, feature flags).
- **`UMFGameInstance`** — Campaign selection: mission + frame id across maps.
- **`AMFGameMode`** — Mission map rules; kicks `UMFMissionSubsystem`.
- **`AMFPlayerController`** — Enhanced Input → pawn; squad orders; HUD ownership.

## Mech

- **`UMFFrameDefinition`** — Data asset: stats, mesh, default loadout.
- **`AMFMechPawn`** — Possable frame; owns components; faction.
- **`UMFMechMovementComponent`** — Speed / boost (FloatingPawnMovement base).

## Combat

- **`UMFHealthComponent`** — Hull + armor zones + destroy event.
- **`UMFHeatComponent`** — Heat sink / overheat gate.
- **`AMFWeaponBase`** — Per-hardpoint actor; `Fire` + heat cost.
- **`UMFWeaponLoadoutComponent`** — Spawns / fires slot weapons.
- **`UMFTargetingComponent`** — Soft lock cycle among hostile frames.

## Mission

- **`UMFMissionDefinition`** — Authorable brief + objectives.
- **`UMFMissionSubsystem`** — Runtime state machine + objective completion.

## AI

- **`AMFMechAIController`** — Ally/enemy brain stub; receives squad orders.
- **`AMFSquadDirector`** — Map-placed fan-out for F1–F3 style orders.

## UI

- **`UMFHUDWidget`** — C++ base with BlueprintImplementableEvents for status.
