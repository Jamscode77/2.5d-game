class_name EncounterData
extends Resource
## Defines a combat trigger: enemy counts become waves.

@export var id: StringName = &"enc_default"
@export var display_name: String = "Contact"
## Total hostiles in this encounter before wave splitting.
@export_range(1, 24) var enemy_count: int = 3
## Max enemies active at once; remainder arrive as later waves.
@export_range(1, 8) var enemies_per_wave: int = 3
@export var enemy_scene: PackedScene
@export var arena_scene: PackedScene


func wave_count() -> int:
	return int(ceil(float(enemy_count) / float(maxi(enemies_per_wave, 1))))


func enemies_in_wave(wave_index: int) -> int:
	var per := maxi(enemies_per_wave, 1)
	var start := wave_index * per
	return clampi(enemy_count - start, 0, per)
