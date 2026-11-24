# Veil Ops — agent guide

## Stack

- Godot **4.3+**, GDScript
- 2.5D overworld → OTS turn-based combat → waves
- Sci-fi imperial intelligence fantasy (original IP only)

## Do

- Extend existing `CombatSession`, `TurnManager`, `WaveSpawner`, `OTSCombatCamera`
- Prefer `MissionData` / `EncounterData` resources for content
- Keep v1 **full turn-based** unless asked for ATB

## Don't

- Port or revive the Unreal mech project unless explicitly requested (`archive/mechfrontline-ue5/`)
- Add multiplayer, open world, or real-time shooter controls
- Invent licensed Final Fantasy names/assets

## Playtest slice

Overworld select → Space → waves → F to shoot → return on victory.
