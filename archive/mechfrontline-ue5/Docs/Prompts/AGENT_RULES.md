# Agent / Contributor Rules for Mech Frontline

Use these constraints when asking Cursor (or any agent) to extend this project.

## Fixed parameters

- Engine: **Unreal Engine 5.5+** (C++ + Blueprints)
- Genre: single-player tactical mobile-frame combat
- Perspective: third-person mech
- Networking: **none** for v1
- IP: **original only** — no Gundam / Zeon / Federation names, logos, or assets

## Hard rules

1. Prefer extending existing `MF*` types over inventing parallel systems.
2. Gameplay data goes in `UPrimaryDataAsset` subclasses under `Content/MechFrontline/Data/`.
3. Do not add Steam, EOS, multiplayer, or save-game frameworks unless explicitly requested.
4. Do not import marketplace packs unless the user names one.
5. Keep Blueprint subclasses thin: logic in C++, tuning / VFX / anim in BP.
6. One vertical slice per task (e.g. “hitscan rifle + heat” — not “full campaign”).
7. Never claim Licensed Unreal content or third-party IP was included.

## Good follow-up prompt shape

```text
In MechFrontline (UE5 C++ scaffold), implement ONLY:
- Hitscan primary fire on AMFWeaponBase subclass BP_Weapon_Rifle
- Apply FMFDamageEvent to UMFHealthComponent on hit
- Add heat via UMFHeatComponent

Do not add new modules, multiplayer, or UI beyond logging + existing HUD events.
```
