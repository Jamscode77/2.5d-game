# Veil Ops — agent guide

## Stack

- Godot **4.3+**, GDScript
- Sprite overworld → OTS **AP-based** turn combat → waves
- Sci-fi imperial intelligence fantasy (original IP only)

## Do

- Extend existing `CombatSession`, `TurnManager`, `WaveSpawner`, `OTSCombatCamera`, `CombatUnit` AP helpers
- Prefer `MissionData` / `EncounterData` resources for content
- Keep v1 **action-point turn-based** (move / shoot / reload / skill / gear)
- Overworld uses sprites; combat uses 3D models

## Don't

- Port or revive the Unreal mech project unless explicitly requested (`archive/mechfrontline-ue5/`)
- Add multiplayer, open world, or real-time shooter controls
- Invent licensed Final Fantasy names/assets

## Playtest slice

Walk sprite to Dock Spire → RMB combat → spend AP (WASD / LMB / R / Q / F) → RMB end turn → waves → victory returns to overworld.
