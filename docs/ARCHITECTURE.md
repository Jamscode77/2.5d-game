# Architecture (scaffold)

```
OverworldController
  └─ select node → GameSession.begin_mission / request_encounter
         │
         ▼
EventBus.encounter_requested
         │
         ▼
CombatSession.start_encounter
  ├─ OTSCombatCamera.activate_from_session()  (anchor = player/node position)
  ├─ WaveSpawner (enemy_count / enemies_per_wave)
  └─ TurnManager (player ↔ enemies)
         │
         ▼
EventBus.combat_ended → back to overworld
```

## Key scripts

| Script | Role |
|--------|------|
| `GameSession` | Phase, mission, combat anchor pose |
| `EventBus` | Decoupled signals |
| `OverworldController` | Node travel + start contact |
| `CombatSession` | Fight orchestration |
| `TurnManager` | Initiative order |
| `WaveSpawner` | Wave splits |
| `OTSCombatCamera` | Shoulder rig on 2.5D stage |
| `CombatUnit` | HP / damage stub |
| `MissionData` / `EncounterData` | Authorable resources |

## Extension points

- Replace capsule meshes with Tripo characters
- Add cover nodes + AP movement
- Swap auto-enemy AI for Behavior-style decisions
- Add ATB gauges later without replacing TurnManager wholesale
