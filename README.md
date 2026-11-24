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
| Overworld | **WASD** | Move between sectors |
| Overworld | **LMB** | Select node + accept brief |
| Overworld | **RMB** | Start contact (enter combat) |
| Combat | **WASD** | Move operative |
| Combat | **Mouse** | Look / aim |
| Combat | **LMB** | Shoot |
| Combat | **RMB** | End turn |
| Combat | **Esc** | Free cursor |

Demo encounter **Dock Ambush**: 5 enemies, 2 per wave.

## What's scaffolded

- `GameSession` + `EventBus` autoloads
- Node overworld with mission/encounter resources
- `CombatSession` with `TurnManager` + `WaveSpawner`
- `OTSCombatCamera` framed from combat-start position
- Demo mission: Quiet Dock

## Docs

- **Interactive guide:** open the *Veil Ops Build Guide* canvas in Cursor (slide deck)
- `docs/HOW_TO_BUILD.txt` — same content as plain text backup
- `docs/DESIGN.md` — fantasy lock
- `docs/ARCHITECTURE.md` — system map
- `docs/BEGINNER_GUIDE.txt` — first-run controls

## Art later

Swap capsule units for **Tripo** GLB/glTF under `assets/`. Keep systems; replace meshes.

## Archive

Previous Unreal mech experiment lives in `archive/mechfrontline-ue5/` (not used by this game).
