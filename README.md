# Mech Frontline

Unreal Engine 5 **scaffold** for a single-player, mission-based tactical mobile-frame game.

Inspired by the *structure* of classic mech sorties (briefing → third-person sortie → objectives → squad orders) — **original setting and naming only**. No licensed characters, suits, or factions.

This repo is **scaffolding**, not a finished game: C++ framework, config, content folders, and agent prompts. You compile and author maps/Blueprints in a local Unreal Editor install.

## Requirements

- Unreal Engine **5.5+** (5.4 usually works if you retarget the `.uproject`)
- Visual Studio 2022 (Windows) or Xcode (macOS) / suitable Linux toolchain
- Git LFS optional later when you add large assets

## Quick start

1. Install Unreal Engine 5.5 from the Epic Games Launcher.
2. Clone this repo.
3. Double-click `MechFrontline.uproject` → **Generate** / open.
4. Let the editor compile the `MechFrontline` module.
5. Create `Content/MechFrontline/Maps/L_DevSandbox` (see `Docs/Prompts/NEXT_SLICES.md` Slice A).
6. PIE once you have a PlayerStart and `BP_MF_Mech`.

Helpers:

```powershell
# Windows (set your engine path)
.\Scripts\GenerateProjectFiles.ps1 -EngineRoot "C:\Program Files\Epic Games\UE_5.5"
```

```bash
# macOS / Linux
export UE_ROOT="/path/to/UE_5.5"
chmod +x Scripts/GenerateProjectFiles.sh
./Scripts/GenerateProjectFiles.sh
```

## What’s in the scaffold

| Area | What you get |
|------|----------------|
| **Core** | GameInstance, GameMode, PlayerController, DeveloperSettings |
| **Mech** | Pawn, movement, frame data asset |
| **Combat** | Hull zones, heat, weapon base, loadout, soft lock |
| **Mission** | Mission data asset + world subsystem state machine |
| **AI** | Mech AIController + SquadDirector order fan-out |
| **UI** | HUD widget base with BP events |
| **Docs** | Design pillars, architecture, copy-paste next-slice prompts |

## Controls (planned defaults)

| Input | Action |
|-------|--------|
| WASD | Move |
| Mouse | Look |
| LMB | Fire primary |
| MMB | Acquire / cycle lock |
| Shift | Boost |
| F1 / F2 / F3 | Squad Hold / Attack / Follow |
| Tab | Objectives (HUD) |

Legacy axis/action names are also listed in `Config/DefaultInput.ini`. Prefer **Enhanced Input** assets assigned on the player controller Blueprint.

## Project rules for agents

See `Docs/Prompts/AGENT_RULES.md`. Short version: extend `MF*` types, data-driven frames/missions, no multiplayer, no licensed IP, one vertical slice per change.

## IP note

“Like Zeonic Front” guided **pacing and systems** (tactical mech missions, squad presence, heat/loadout). Do not add names, mecha, or marks from Bandai Namco / Sunrise properties.

## License

Scaffold code is provided for your project use. Add your own license file when you publish.
