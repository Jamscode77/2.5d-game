class_name CombatSession
extends Node3D
## Owns one fight: waves + turns + OTS camera. WASD move, mouse look/shoot.

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
	set_process(false)
	set_process_unhandled_input(false)
	wave_spawner.wave_spawned.connect(_on_wave_spawned)
	wave_spawner.all_waves_cleared.connect(_on_all_waves_cleared)
	EventBus.unit_defeated.connect(_on_unit_defeated)


func start_encounter(encounter: EncounterData) -> void:
	_encounter = encounter
	_running = true
	visible = true
	set_process(true)
	set_process_unhandled_input(true)

	_clear_arena_units()
	_spawn_player()
	camera.activate_from_session()
	camera.set_follow_unit(_player)
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


func _process(delta: float) -> void:
	if not _running:
		return
	var active := turn_manager.get_active_unit()
	if active == null or active.team != CombatUnit.Team.PLAYER or active != _player:
		return
	var dir := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		dir -= camera.global_transform.basis.z
	if Input.is_action_pressed("move_back"):
		dir += camera.global_transform.basis.z
	if Input.is_action_pressed("move_left"):
		dir -= camera.global_transform.basis.x
	if Input.is_action_pressed("move_right"):
		dir += camera.global_transform.basis.x
	dir.y = 0.0
	_player.set_aim_forward(camera.get_aim_forward())
	if dir.length() > 0.01:
		_player.apply_move_input(dir.normalized(), delta)
		## Keep aim point ahead of movement for OTS feel.
		camera.set_look_target(_player.global_position + camera.get_aim_forward() * 5.0)


func _unhandled_input(event: InputEvent) -> void:
	if not _running:
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera.add_mouse_look(event.relative)
		if _player and turn_manager.get_active_unit() == _player:
			camera.set_look_target(_player.global_position + camera.get_aim_forward() * 5.0)
		return

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return

	var active := turn_manager.get_active_unit()
	if active == null or active.team != CombatUnit.Team.PLAYER:
		return

	if event.is_action_pressed("combat_shoot"):
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			return
		_player_shoot(active)
	elif event.is_action_pressed("combat_end_turn"):
		turn_manager.notify_action_resolved()
		_maybe_run_enemy_turns()


func _player_shoot(player: CombatUnit) -> void:
	var target := _raycast_enemy()
	if target == null:
		## Fallback: shoot along aim at nearest enemy in front cone.
		target = _aimed_or_nearest(player)
	if target == null:
		EventBus.log_line.emit("No target under reticle.")
		return
	camera.set_look_target(target.global_position)
	player.deal_damage_to(target)
	turn_manager.notify_action_resolved()
	_maybe_run_enemy_turns()


func _raycast_enemy() -> CombatUnit:
	var from := camera.global_position
	var to := from + camera.get_aim_forward() * 40.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 2 # units
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return null
	var collider: Object = hit.get("collider")
	if collider is Node and collider.has_meta("combat_unit"):
		var unit: CombatUnit = collider.get_meta("combat_unit")
		if unit and unit.is_alive and unit.team == CombatUnit.Team.ENEMY:
			return unit
	## Walk up in case meta is on parent.
	if collider is Node:
		var n: Node = collider
		while n:
			if n is CombatUnit:
				var u := n as CombatUnit
				if u.is_alive and u.team == CombatUnit.Team.ENEMY:
					return u
			n = n.get_parent()
	return null


func _aimed_or_nearest(player: CombatUnit) -> CombatUnit:
	var enemies := turn_manager.living_on_team(CombatUnit.Team.ENEMY)
	if enemies.is_empty():
		return null
	var aim := camera.get_aim_forward()
	var best: CombatUnit = null
	var best_score := -INF
	for u in enemies:
		var to_u := (u.global_position - camera.global_position).normalized()
		var score := aim.dot(to_u)
		if score > best_score:
			best_score = score
			best = u
	if best_score < 0.55:
		return _nearest(player.global_position, enemies)
	return best


func _maybe_run_enemy_turns() -> void:
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
	set_process(false)
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
		EventBus.log_line.emit("Your turn — WASD move | Mouse look | LMB shoot | RMB end turn | Esc free cursor")
