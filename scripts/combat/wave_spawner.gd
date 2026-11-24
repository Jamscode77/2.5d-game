class_name WaveSpawner
extends Node
## Splits EncounterData.enemy_count into waves.

signal all_waves_cleared
signal wave_spawned(wave_index: int, units: Array[CombatUnit])

var encounter: EncounterData
var spawn_parent: Node3D
var spawn_points: Array[Marker3D] = []

var _wave_index: int = 0
var _active_enemies: Array[CombatUnit] = []


func configure(enc: EncounterData, parent: Node3D, points: Array[Marker3D]) -> void:
	encounter = enc
	spawn_parent = parent
	spawn_points = points
	_wave_index = 0
	_active_enemies.clear()


func start_first_wave() -> void:
	_spawn_wave(0)


func on_enemy_defeated(unit: CombatUnit) -> void:
	_active_enemies.erase(unit)
	if _active_enemies.is_empty():
		var next := _wave_index + 1
		if encounter and next < encounter.wave_count():
			_spawn_wave(next)
		else:
			all_waves_cleared.emit()


func _spawn_wave(index: int) -> void:
	_wave_index = index
	_active_enemies.clear()
	if encounter == null or spawn_parent == null:
		return

	var count := encounter.enemies_in_wave(index)
	var spawned: Array[CombatUnit] = []
	EventBus.wave_started.emit(index, encounter.wave_count())
	EventBus.log_line.emit("Wave %d / %d (%d hostiles)" % [index + 1, encounter.wave_count(), count])

	for i in count:
		var unit := _make_enemy(i)
		var point := _point_for(i)
		## Must enter the tree before setting global_position.
		spawn_parent.add_child(unit)
		if point and point.is_inside_tree():
			unit.global_position = point.global_position
		else:
			unit.position = Vector3(i * 2.0, 0.0, 2.0 + index)
		_active_enemies.append(unit)
		spawned.append(unit)

	wave_spawned.emit(index, spawned)


func _make_enemy(index: int) -> CombatUnit:
	var unit: CombatUnit
	if encounter.enemy_scene:
		unit = encounter.enemy_scene.instantiate() as CombatUnit
	else:
		unit = preload("res://scenes/combat/enemy_unit.tscn").instantiate() as CombatUnit
	unit.display_name = "Hostile %d" % (index + 1 + _wave_index * encounter.enemies_per_wave)
	unit.team = CombatUnit.Team.ENEMY
	return unit


func _point_for(index: int) -> Marker3D:
	if spawn_points.is_empty():
		return null
	return spawn_points[index % spawn_points.size()]
