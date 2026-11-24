class_name CombatSession
extends Node3D
## Owns one fight: waves + turns + OTS camera. Scaffold AI for enemies.

@onready var turn_manager: TurnManager = $TurnManager
@onready var wave_spawner: WaveSpawner = $WaveSpawner
@onready var camera: OTSCombatCamera = $OTSCombatCamera
@onready var player_spawn: Marker3D = $PlayerSpawn
@onready var arena_root: Node3D = $ArenaRoot
@onready var spawn_points_root: Node3D = $EnemySpawnPoints

var _player: CombatUnit
var _encounter: EncounterData
var _running: bool = false


func _ready() -> void:
	visible = false
	set_process_unhandled_input(false)
	wave_spawner.wave_spawned.connect(_on_wave_spawned)
	wave_spawner.all_waves_cleared.connect(_on_all_waves_cleared)
	EventBus.unit_defeated.connect(_on_unit_defeated)


func start_encounter(encounter: EncounterData) -> void:
	_encounter = encounter
	_running = true
	visible = true
	set_process_unhandled_input(true)

	_clear_arena_units()
	_spawn_player()
	camera.activate_from_session()
	if _player:
		camera.set_look_target(_player.global_position + GameSession.combat_anchor_facing * 3.0)

	var points: Array[Marker3D] = []
	for child in spawn_points_root.get_children():
		if child is Marker3D:
			points.append(child)

	wave_spawner.configure(encounter, arena_root, points)
	turn_manager.setup([_player])
	wave_spawner.start_first_wave()
	turn_manager.start()
	EventBus.combat_started.emit(encounter)
	_update_hud_hint()


func _unhandled_input(event: InputEvent) -> void:
	if not _running:
		return
	var active := turn_manager.get_active_unit()
	if active == null or active.team != CombatUnit.Team.PLAYER:
		return

	if event.is_action_pressed("combat_shoot"):
		_player_shoot(active)
	elif event.is_action_pressed("combat_end_turn"):
		turn_manager.notify_action_resolved()
		_maybe_run_enemy_turns()


func _player_shoot(player: CombatUnit) -> void:
	var enemies := turn_manager.living_on_team(CombatUnit.Team.ENEMY)
	if enemies.is_empty():
		EventBus.log_line.emit("No targets.")
		return
	## Scaffold: shoot nearest enemy.
	var target := _nearest(player.global_position, enemies)
	camera.set_look_target(target.global_position)
	player.deal_damage_to(target)
	turn_manager.notify_action_resolved()
	_maybe_run_enemy_turns()


func _maybe_run_enemy_turns() -> void:
	## Simple auto-resolve for enemy turns so the scaffold is playable.
	await get_tree().process_frame
	while _running:
		var active := turn_manager.get_active_unit()
		if active == null:
			break
		if active.team == CombatUnit.Team.PLAYER:
			_update_hud_hint()
			break
		await _enemy_take_turn(active)
		turn_manager.notify_action_resolved()
		await get_tree().create_timer(0.35).timeout


func _enemy_take_turn(enemy: CombatUnit) -> void:
	var players := turn_manager.living_on_team(CombatUnit.Team.PLAYER)
	if players.is_empty():
		_finish(false)
		return
	var target := _nearest(enemy.global_position, players)
	camera.set_look_target(target.global_position)
	enemy.deal_damage_to(target)
	if not _player.is_alive:
		_finish(false)


func _on_wave_spawned(_wave_index: int, units: Array[CombatUnit]) -> void:
	for u in units:
		turn_manager.add_unit(u)
		if _player:
			camera.set_look_target(u.global_position)
	_update_hud_hint()


func _on_all_waves_cleared() -> void:
	_finish(true)


func _on_unit_defeated(unit: CombatUnit) -> void:
	if unit.team == CombatUnit.Team.ENEMY:
		wave_spawner.on_enemy_defeated(unit)
		turn_manager.remove_unit(unit)
	elif unit.team == CombatUnit.Team.PLAYER:
		_finish(false)


func _finish(victory: bool) -> void:
	if not _running:
		return
	_running = false
	turn_manager.stop()
	set_process_unhandled_input(false)
	camera.deactivate()
	EventBus.combat_ended.emit(victory)
	visible = false


func _spawn_player() -> void:
	_player = preload("res://scenes/combat/player_unit.tscn").instantiate() as CombatUnit
	_player.display_name = "Operative"
	_player.team = CombatUnit.Team.PLAYER
	arena_root.add_child(_player)
	if GameSession.combat_anchor_position != Vector3.ZERO:
		_player.global_position = GameSession.combat_anchor_position
	else:
		_player.global_position = player_spawn.global_position


func _clear_arena_units() -> void:
	for child in arena_root.get_children():
		child.queue_free()


func _nearest(from: Vector3, units: Array[CombatUnit]) -> CombatUnit:
	var best: CombatUnit = units[0]
	var best_d := INF
	for u in units:
		var d := from.distance_squared_to(u.global_position)
		if d < best_d:
			best_d = d
			best = u
	return best


func _update_hud_hint() -> void:
	var active := turn_manager.get_active_unit()
	if active and active.team == CombatUnit.Team.PLAYER:
		EventBus.log_line.emit("Your turn — [F] shoot nearest  |  [E] end turn")
