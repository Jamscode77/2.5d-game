# Veil Ops

Godot 4 scaffold for a sci-fi intel game with a **Final Fantasy–style split**:

**Little sprites on the overworld → 3D models in OTS turn-based combat (waves)**

You play an imperial intelligence officer. Walk a tiny operative around sector pins, take briefs, then drop into over-the-shoulder combat with the Tripo officer model.

## Requirements

- [Godot 4.3+](https://godotengine.org/download) (4.3 recommended)

## Run

1. Open Godot → **Import** → select this folder (`project.godot`)
2. Press **F5** / Play
3. Main scene: `scenes/main.tscn`

### Controls

| Context | Input | Action |
|---------|--------|--------|
| Overworld (sprites) | **WASD** | Walk the little operative |
| Overworld | **E** / **LMB** | Accept brief when near a pin |
| Overworld | **RMB** | Enter **3D combat** near a hostile pin |
| Combat (3D + AP) | **WASD** | Move (~1 AP / 1.25 m) |
| Combat | **Mouse** | Look / aim (reticle) |
| Combat | **LMB** | Shoot (−2 AP, needs ammo) |
| Combat | **R** | Reload (−2 AP) |
| Combat | **Q** | Focus skill (−3 AP, next shot +2) |
| Combat | **F** | Field Stim (−2 AP, heal) |
| Combat | **C** | Take / leave cover (−1 AP to take) |
| Combat | **RMB** | End turn (also auto at 0 AP) |
| Combat | **Esc** | Free cursor |

Cover props (half / heavy / full) soak damage from the front; flank to bypass.

Demo encounter **Dock Ambush**: 5 enemies, 2 per wave. Walk to **Dock Spire 4** (red pin) or **Ash Gate**.

## What's scaffolded

- Sprite overworld (`OverworldPlayer` + map pins) with proximity interact
- 3D `CombatSession` with **action points** (move / shoot / reload / skill / gear)
- Enemies spend AP on the same rules
- `TurnManager` + `WaveSpawner` + Tripo officer GLB
- Demo mission: Quiet Dock

## Docs

- `docs/HOW_TO_BUILD.txt` — build steps
- `docs/DESIGN.md` — fantasy lock
- `docs/ARCHITECTURE.md` — system map
- `docs/BEGINNER_GUIDE.txt` — first-run controls

## Art

- Overworld placeholders: `assets/sprites/` (swap for pixel sheets later)
- Combat officer: `assets/characters/` (Tripo GLB)

## Archive

Previous Unreal mech experiment lives in `archive/mechfrontline-ue5/` (not used by this game).
