# Architecture (scaffold)

```
OverworldController
  ├─ OverworldPlayer (Sprite3D, WASD walk)
  └─ nearby OverworldMapNode → E brief / RMB fight
         │
         ▼
GameSession.request_encounter
         │
         ▼
EventBus.encounter_requested
         │
         ▼
CombatSession.start_encounter  (3D models)
  ├─ OTSCombatCamera.activate_from_session()
  ├─ WaveSpawner
  ├─ TurnManager (each unit refreshes AP on begin_turn)
  └─ CombatUnit spends AP: move / shoot / reload / skill / gear
         │
         ▼
EventBus.combat_ended → show overworld sprites again
```

## Action points (v1 defaults)

| Action | Cost | Notes |
|--------|------|-------|
| Move | 1 AP / 1.25 m | Continuous WASD for player; stepped for AI |
| Shoot | 2 AP | Needs ammo in magazine |
| Reload | 2 AP | Fills mag from reserve |
| Focus (skill) | 3 AP | Next shot +2 damage |
| Field Stim (gear) | 2 AP | Heal up to 3 HP |
| End turn | — | RMB, or auto when AP hits 0 after an action |

## Key scripts

| Script | Role |
|--------|------|
| `GameSession` | Phase, mission, combat anchor pose |
| `EventBus` | Decoupled signals |
| `OverworldController` | Sprite travel + proximity contact |
| `OverworldPlayer` | Little overworld sprite mover |
| `OverworldMapNode` | Pin + interact radius |
| `CombatSession` | Fight orchestration (3D + AP input) |
| `TurnManager` | Initiative order |
| `WaveSpawner` | Wave splits |
| `OTSCombatCamera` | Shoulder rig |
| `CombatUnit` | HP, AP, ammo, skills/gear |
| `MissionData` / `EncounterData` | Authorable resources |

## Extension points

- Replace placeholder PNGs in `assets/sprites/` with pixel sheets + walk cycles
- Enrich Tripo combat models / Mixamo clips
- Add cover vaults / AP terrain costs
- More skills & gear as `try_*` methods on `CombatUnit`
- Swap auto-enemy AI for Behavior-style decisions
