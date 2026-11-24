# Systems Map (Scaffold)

| System | Primary types | Content home | Status |
|--------|---------------|--------------|--------|
| Session | `UMFGameInstance`, `UMFGameSettings` | Config | Stub |
| Match flow | `AMFGameMode`, `AMFPlayerController` | Blueprints/Game | Stub |
| Frame pawn | `AMFMechPawn`, `UMFFrameDefinition` | Data/Frames, Blueprints/Mech | Stub |
| Movement | `UMFMechMovementComponent` | — | Stub |
| Hull / zones | `UMFHealthComponent` | — | Stub |
| Heat | `UMFHeatComponent` | — | Stub |
| Weapons | `AMFWeaponBase`, `UMFWeaponLoadoutComponent` | Data/Weapons, Blueprints/Combat | Stub |
| Targeting | `UMFTargetingComponent` | — | Stub |
| Mission | `UMFMissionDefinition`, `UMFMissionSubsystem` | Data/Missions | Stub |
| Squad AI | `AMFMechAIController`, `AMFSquadDirector` | Blueprints/AI | Stub |
| HUD | `UMFHUDWidget` | Blueprints/UI | Stub |

## Suggested first vertical slice (after scaffolding)

1. Create `L_DevSandbox` (empty level + PlayerStart + NavMesh).
2. Create BP subclasses: `BP_MF_Mech`, `BP_MF_GameMode`, `WBP_MF_HUD`.
3. Create one `DA_Frame_Scout` and one hitscan `BP_Weapon_Rifle`.
4. Place 2 enemy `BP_MF_Mech` with Enemy faction + AI controller.
5. One Destroy Target mission data asset wired into GameInstance / MissionSubsystem.
6. PIE: move, lock, fire, kill target → mission Success.
