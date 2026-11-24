class_name CombatSession
extends Node3D
## Owns one fight: waves + turns + OTS camera. Reticle ray decides the target.

@onready var turn_manager: TurnManager = $TurnManager
@onready var wave_spawner: WaveSpawner = $WaveSpawner
@onready var camera: OTSCombatCamera = $OTSCombatCamera
@onready var player_spawn: Marker3D = $PlayerSpawn
@onready var arena_root: Node3D = $ArenaRoot
@onready var spawn_points_root: Node3D = $EnemySpawnPoints
@onready var reticle: Control = $CombatUI/CombatReticle

var _player: CombatUnit
var _encounter: EncounterData
var _running: bool = false
var _hovered_enemy: CombatUnit = null


func _ready() -> void:
	visible = false
	set_process(false)
	set_process_unhandled_input(false)
	wave_spawner.wave_spawned.connect(_on_wave_spawned)
	wave_spawner.all_waves_cleared.connect(_on_all_waves_cleared)
	EventBus.unit_defeated.connect(_on_unit_defeated)
	if reticle:
		reticle.hide_reticle()


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

	var points: Array[Marker3D] = []
	for child in spawn_points_root.get_children():
		if child is Marker3D:
			points.append(child)

	wave_spawner.configure(encounter, arena_root, points)
	turn_manager.setup([_player])
	wave_spawner.start_first_wave()
	turn_manager.start()
	EventBus.combat_started.emit(encounter)
	if reticle:
		reticle.show_reticle()
	_update_hud_hint()


func _process(delta: float) -> void:
	if not _running:
		return

	## Always update hover under reticle while fighting.
	_hovered_enemy = _raycast_enemy()
	if reticle:
		reticle.set_hot(_hovered_enemy != null)

	var active := turn_manager.get_active_unit()
	if _player and is_instance_valid(_player) and _player.is_alive:
		_player.face_aim(camera.get_aim_forward())

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
	if dir.length() > 0.01:
		_player.apply_move_input(dir.normalized(), delta)


func _unhandled_input(event: InputEvent) -> void:
	if not _running:
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera.add_mouse_look(event.relative)
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
	## Only the unit under the reticle can be attacked — no nearest fallback.
	var target := _raycast_enemy()
	if target == null:
		EventBus.log_line.emit("No target under reticle.")
		return
	player.face_aim(target.global_position - player.global_position)
	player.deal_damage_to(target)
	turn_manager.notify_action_resolved()
	_maybe_run_enemy_turns()


func _raycast_enemy() -> CombatUnit:
	var from := camera.get_aim_origin()
	var to := from + camera.get_aim_forward() * 50.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 2 # units
	var exclude: Array[RID] = []
	if _player and is_instance_valid(_player):
		var pick := _player.get_node_or_null("PickBody")
		if pick is CollisionObject3D:
			exclude.append((pick as CollisionObject3D).get_rid())
	query.exclude = exclude

	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return null
	return _unit_from_collider(hit.get("collider"))


func _unit_from_collider(collider: Variant) -> CombatUnit:
	if collider == null:
		return null
	if collider is Node and (collider as Node).has_meta("combat_unit"):
		var unit: CombatUnit = (collider as Node).get_meta("combat_unit")
		if unit and unit.is_alive and unit.team == CombatUnit.Team.ENEMY:
			return unit
	if collider is Node:
		var n: Node = collider
		while n:
			if n is CombatUnit:
				var u := n as CombatUnit
				if u.is_alive and u.team == CombatUnit.Team.ENEMY:
					return u
			n = n.get_parent()
	return null


func _maybe_run_enemy_turns() -> void:
	await get_tree().process_frame
	while _running:
		var active := turn_manager.get_active_unit()
		if active == null:
			break
		if active.team == CombatUnit.Team.PLAYER:
			_update_hud_hint()
			break
		_enemy_take_turn(active)
		turn_manager.notify_action_resolved()
		await get_tree().create_timer(0.35).timeout


func _enemy_take_turn(enemy: CombatUnit) -> void:
	var players := turn_manager.living_on_team(CombatUnit.Team.PLAYER)
	if players.is_empty():
		_finish(false)
		return
	var target := _nearest(enemy.global_position, players)
	enemy.deal_damage_to(target)
	if not _player.is_alive:
		_finish(false)


func _on_wave_spawned(_wave_index: int, units: Array[CombatUnit]) -> void:
	for u in units:
		turn_manager.add_unit(u)
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
	if reticle:
		reticle.hide_reticle()
	_hovered_enemy = null
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
		EventBus.log_line.emit("Your turn — WASD move | Mouse aim | LMB shoot reticle target | RMB end turn")
