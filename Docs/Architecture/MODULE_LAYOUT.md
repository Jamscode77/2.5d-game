# Module & Folder Layout

```
MechFrontline.uproject
Config/                          # DefaultEngine / Game / Input / Editor
Content/MechFrontline/
  Maps/                          # L_DevSandbox, mission maps
  Mechs/                         # Meshes, skeletons, anim BP
  Weapons/
  Characters/                    # Pilots / non-frame if needed later
  UI/
  Audio/
  VFX/
  Materials/
  Data/
    Frames/                      # UMFFrameDefinition assets
    Weapons/
    Missions/                    # UMFMissionDefinition assets
  Blueprints/
    Game/                        # BP_MF_GameMode, BP_MF_PlayerController
    Mech/
    Combat/
    Mission/
    AI/
    UI/
Source/MechFrontline/
  Public|Private/
    Core/                        # GameInstance, GameMode, PC, Settings
    Mech/                        # Pawn, movement, frame DA
    Combat/                      # Health, heat, weapons, targeting
    Mission/                     # Definitions + world subsystem
    AI/                          # AIController + SquadDirector
    UI/                          # HUD widget base
    Types/                       # Shared enums / structs
Docs/                            # Design, architecture, agent prompts
Scripts/                         # Generate project files helpers
```

## Engine association

`.uproject` targets **UE 5.5**. Retarget in the Epic Launcher if you use 5.4 / 5.6.

## Future module split (optional)

If the Runtime module grows past ~50k LOC, split into `MFCore`, `MFMech`, `MFCombat`, `MFMission` Runtime modules with clear Public API boundaries. Do not split until pain is real.
