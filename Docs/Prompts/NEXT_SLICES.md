# Suggested Implementation Prompts (copy/paste)

## Slice A — Dev map + PIE pawn

```text
Open MechFrontline in UE5. Create map L_DevSandbox under Content/MechFrontline/Maps
with PlayerStart, flat ground, sky, NavMeshBoundsVolume. Create BP_MF_Mech subclassing
AMFMechPawn with a placeholder skeletal or static mesh scaled to ~18m tall, and
BP_MF_GameMode using that pawn. Set map GameMode override. Do not implement combat yet.
```

## Slice B — Enhanced Input assets

```text
Create IMC_MF_Default and IA_* actions matching AMFPlayerController properties
(Move, Look, FirePrimary, LockTarget, Boost). Assign them on BP_MF_PlayerController.
Keep bindings WASD / mouse / LMB / MMB / Shift.
```

## Slice C — Heat + hull feedback

```text
Wire AMFMechPawn tick or timer to push GetFrameStatus() into UMFHUDWidget::PushFrameStatus.
Add a minimal WBP_MF_HUD with hull and heat progress bars. No art polish.
```

## Slice D — First weapon

```text
Create BP_Weapon_HeavyRifle : AMFWeaponBase. OnFired: line trace from camera/muzzle,
build FMFDamageEvent (Hull zone), call Health on hit mech. HeatCost 10, interval 40.
```

## Slice E — Mission kill target

```text
Create DA_Mission_SandboxSweep with one DestroyTarget objective. Place tagged enemy
mech. On enemy OnDestroyed, MissionSubsystem.CompleteObjective. Show Success on HUD.
```

## Slice F — Squad orders

```text
Place AMFSquadDirector. Spawn 2 ally BP_MF_Mech with AMFMechAIController, register
them. Bind F1/F2/F3 on player controller to Hold / AttackTarget / Follow.
Allies only need stub MoveTo behavior.
```
