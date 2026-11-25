# Overworld sprites

Placeholder nearest-neighbor PNGs for the FF-style overworld:

| File | Use |
|------|-----|
| `ow_player.png` | Player operative (32×32) |
| `ow_npc.png` | Decorative civilians |
| `ow_marker_mission.png` | Hostile / mission pin |
| `ow_marker_quiet.png` | Quiet sector pin |

Swap these for your own pixel sheets. Keep `texture_filter` nearest on `Sprite3D` nodes so they stay crisp. Combat still uses 3D models under `assets/characters/`.
