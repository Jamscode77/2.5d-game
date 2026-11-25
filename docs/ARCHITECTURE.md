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
| Move | 1 AP / 1.25 m | Continuous WASD for player; stepped for AI; breaks cover |
| Shoot | 2 AP | Needs ammo; damage reduced by target cover |
| Reload | 2 AP | Fills mag from reserve |
| Focus (skill) | 3 AP | Next shot +2 damage |
| Field Stim (gear) | 2 AP | Heal up to 3 HP |
| Take / leave cover | 1 AP / free | **C** near a cover prop; leave is free |
| End turn | — | RMB, or auto when AP hits 0 after an action |

### Cover protection

`CoverObject.cover_strength` is continuous (0→1). Tiers: Light / Half (~0.5) / Heavy (~0.75) / Full (1.0).
Protection scales by strength × how frontal the attacker is relative to the cover’s threat face (−Z). Flanking nearly ignores cover; full frontal full-cover can null a shot.

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
| `CombatUnit` | HP, AP, ammo, skills/gear/cover |
| `CoverObject` | Strength, occupancy, directional soak |
| `MissionData` / `EncounterData` | Authorable resources |

## Extension points

- Replace placeholder PNGs in `assets/sprites/` with pixel sheets + walk cycles
- Enrich Tripo combat models / Mixamo clips
- Add cover vaults / AP terrain costs
- More skills & gear as `try_*` methods on `CombatUnit`
- Swap auto-enemy AI for Behavior-style decisions
