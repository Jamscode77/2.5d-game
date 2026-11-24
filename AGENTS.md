# Mech Frontline — agent guide

Read `Docs/Prompts/AGENT_RULES.md` and `Docs/Design/DESIGN_PILLARS.md` before changing gameplay.

## Stack

- Unreal Engine 5.5+, C++ module `MechFrontline`, Blueprints for content/tuning
- Prefix new gameplay types with `MF` / `AMF` / `UMF` as appropriate

## Do

- Extend existing systems under `Source/MechFrontline/Public/{Core,Mech,Combat,Mission,AI,UI}`
- Put authorable data in `UMFFrameDefinition` / `UMFMissionDefinition`
- Keep tasks to one vertical slice (`Docs/Prompts/NEXT_SLICES.md`)

## Don’t

- Add multiplayer, online subsystems, or licensed franchise IP
- Replace the module layout without an explicit request
- Commit `Binaries/`, `Intermediate/`, `DerivedDataCache/`, or `Saved/`
