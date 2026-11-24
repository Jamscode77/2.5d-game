# Veil Ops

Godot 4 **scaffold** for a 2.5D sci-fi intel game:

**FF-style overworld → over-the-shoulder turn-based combat → waves**

You play an imperial intelligence officer running missions for the empire. This repo is a playable skeleton (capsules, one demo op), not a finished game.

## Requirements

- [Godot 4.3+](https://godotengine.org/download) (4.3 recommended)

## Run

1. Open Godot → **Import** → select this folder (`project.godot`)
2. Press **F5** / Play
3. Main scene: `scenes/main.tscn`

### Controls

| Context | Input | Action |
|---------|--------|--------|
| Overworld | Arrows | Move between sectors |
| Overworld | Enter | Accept mission brief |
| Overworld | Space | Start contact (enter combat) |
| Combat | **F** | Shoot nearest enemy |
| Combat | **E** | End turn |

Demo encounter **Dock Ambush**: 5 enemies, 2 per wave.

## What's scaffolded

- `GameSession` + `EventBus` autoloads
- Node overworld with mission/encounter resources
- `CombatSession` with `TurnManager` + `WaveSpawner`
- `OTSCombatCamera` framed from combat-start position
- Demo mission: Quiet Dock

## Docs

- `docs/HOW_TO_BUILD.txt` — **start here**: tools, resources, full build roadmap
- `docs/DESIGN.md` — fantasy lock
- `docs/ARCHITECTURE.md` — system map
- `docs/BEGINNER_GUIDE.txt` — first-run controls

## Art later

Swap capsule units for **Tripo** GLB/glTF under `assets/`. Keep systems; replace meshes.

## Archive

Previous Unreal mech experiment lives in `archive/mechfrontline-ue5/` (not used by this game).
