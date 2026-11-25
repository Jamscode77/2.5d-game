class_name CombatSession
extends Node3D
## Owns one fight: AP turns + cover + waves + OTS camera. Reticle ray decides the target.

@onready var turn_manager: TurnManager = $TurnManager
@onready var wave_spawner: WaveSpawner = $WaveSpawner
@onready var camera: OTSCombatCamera = $OTSCombatCamera
@onready var player_spawn: Marker3D = $PlayerSpawn
@onready var arena_root: Node3D = $ArenaRoot
@onready var spawn_points_root: Node3D = $EnemySpawnPoints
@onready var covers_root: Node3D = $Covers
@onready var reticle: Control = $CombatUI/CombatReticle

const ENGAGE_RANGE := 9.0

var _player: CombatUnit
var _encounter: EncounterData
var _running: bool = false
var _hovered_enemy: CombatUnit = null
var _enemy_busy: bool = false
var _covers: Array[CoverObject] = []


func _ready() -> void:
	visible = false
	set_process(false)
	set_process_input(false)
	wave_spawner.wave_spawned.connect(_on_wave_spawned)
	wave_spawner.all_waves_cleared.connect(_on_all_waves_cleared)
	EventBus.unit_defeated.connect(_on_unit_defeated)
	_cache_covers()
	if reticle:
		reticle.hide_reticle()


func _cache_covers() -> void:
	_covers.clear()
	if covers_root == null:
		return
	for child in covers_root.get_children():
		if child is CoverObject:
			_covers.append(child)


func start_encounter(encounter: EncounterData) -> void:
	_encounter = encounter
	_running = true
	_enemy_busy = false
	visible = true
	set_process(true)
	set_process_input(true)

	_clear_arena_units()
	_reset_covers()
	_spawn_player()
	camera.activate_from_session()
	camera.set_follow_unit(_player)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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
	EventBus.log_line.emit("Cover on the field — walk up and press C (1 AP). Half / Heavy / Full soak differently; flank to bypass.")
	_update_hud_hint()


func _reset_covers() -> void:
	for c in _covers:
		if c.occupied_by:
			c.release(c.occupied_by)
		c.occupied_by = null


func _process(delta: float) -> void:
	if not _running:
		return

	_hovered_enemy = _raycast_enemy()
	if reticle:
		reticle.set_hot(_hovered_enemy != null)

	var active := turn_manager.get_active_unit()
	if _player and is_instance_valid(_player) and _player.is_alive:
		_player.face_aim(camera.get_aim_forward())

	if active == null or active.team != CombatUnit.Team.PLAYER or active != _player:
		return
	if _player.ap <= 0:
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


func _input(event: InputEvent) -> void:
	if not _running:
		return

	if event is InputEventMouseMotion:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		camera.add_mouse_look(event.relative)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_viewport().set_input_as_handled()
		return

	var active := turn_manager.get_active_unit()
	if active == null or active.team != CombatUnit.Team.PLAYER:
		return

	if event.is_action_pressed("combat_shoot"):
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			get_viewport().set_input_as_handled()
			return
		_player_shoot(active)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("combat_reload"):
		active.try_reload()
		_after_player_action(active)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("combat_skill"):
		active.try_skill_focus()
		_after_player_action(active)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("combat_equipment"):
		active.try_equipment_stim()
		_after_player_action(active)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("combat_cover"):
		active.try_toggle_cover(_covers)
		_after_player_action(active)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("combat_end_turn"):
		_end_player_turn()
		get_viewport().set_input_as_handled()


func _player_shoot(player: CombatUnit) -> void:
	var target := _raycast_enemy()
	if target == null:
		EventBus.log_line.emit("No target under reticle.")
		return
	player.face_aim(target.global_position - player.global_position)
	if player.try_shoot(target):
		_after_player_action(player)


func _after_player_action(player: CombatUnit) -> void:
	_update_hud_hint()
	if not _running:
		return
	if player.ammo_in_mag <= 0 and player.reserve_ammo > 0 and player.ap >= player.cost_reload:
		EventBus.log_line.emit("Mag empty — R to reload (%d AP)." % player.cost_reload)
	if player.ap <= 0:
		EventBus.log_line.emit("AP spent — ending turn.")
		_end_player_turn()


func _end_player_turn() -> void:
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
	if _enemy_busy:
		return
	_enemy_busy = true
	await get_tree().process_frame
	while _running:
		var active := turn_manager.get_active_unit()
		if active == null:
			break
		if active.team == CombatUnit.Team.PLAYER:
			_update_hud_hint()
			break
		await _enemy_spend_ap(active)
		if not _running:
			break
		turn_manager.notify_action_resolved()
		await get_tree().create_timer(0.25).timeout
	_enemy_busy = false


func _enemy_spend_ap(enemy: CombatUnit) -> void:
	var safety := 14
	while _running and enemy.is_alive and enemy.ap > 0 and safety > 0:
		safety -= 1
		var players := turn_manager.living_on_team(CombatUnit.Team.PLAYER)
		if players.is_empty():
			_finish(false)
			return
		var target := _nearest(enemy.global_position, players)
		var dist := enemy.global_position.distance_to(target.global_position)

		## Seek cover when exposed and hurt, or before first shot if free cover is close.
		if not enemy.is_in_cover():
			var cover := _best_cover_for(enemy, target)
			if cover and enemy.can_afford(enemy.cost_take_cover):
				var need_cover := enemy.hp <= enemy.max_hp - 2 or dist <= ENGAGE_RANGE
				if need_cover:
					var to_cover := enemy.global_position.distance_to(cover.occupy_global())
					if to_cover > cover.interact_radius * 0.85:
						if not enemy.try_move_toward(cover.occupy_global(), mini(2.8, to_cover)):
							## Can't reach — fall through to fight.
							pass
						else:
							await get_tree().create_timer(0.12).timeout
							continue
					if cover.can_unit_take(enemy) and enemy.try_take_cover(cover):
						await get_tree().create_timer(0.2).timeout
						continue

		## Reload if dry.
		if enemy.ammo_in_mag <= 0:
			if enemy.can_afford(enemy.cost_reload) and enemy.reserve_ammo > 0:
				enemy.try_reload()
				await get_tree().create_timer(0.2).timeout
				continue
			break

		## Shoot if in range.
		if dist <= ENGAGE_RANGE and enemy.can_afford(enemy.cost_shoot):
			enemy.face_aim(target.global_position - enemy.global_position)
			enemy.try_shoot(target)
			await get_tree().create_timer(0.3).timeout
			if _player and not _player.is_alive:
				_finish(false)
				return
			continue

		## Close distance (leave cover if needed).
		if dist > ENGAGE_RANGE and enemy.ap > 0:
			var step := mini(2.5, dist - ENGAGE_RANGE + 0.5)
			if not enemy.try_move_toward(target.global_position, step):
				break
			await get_tree().create_timer(0.15).timeout
			continue

		if enemy.hp <= enemy.max_hp / 2 and enemy.can_afford(enemy.cost_equipment):
			enemy.try_equipment_stim()
			await get_tree().create_timer(0.2).timeout
			continue

		break


func _best_cover_for(unit: CombatUnit, threat: CombatUnit) -> CoverObject:
	var best: CoverObject = null
	var best_score := -INF
	for c in _covers:
		if c == null or (not c.is_free() and c.occupied_by != unit):
			continue
		var occupy := c.occupy_global()
		var dist := unit.global_position.distance_to(occupy)
		if dist > 7.0:
			continue
		## Prefer cover that faces the threat and is closer / stronger.
		var to_threat := threat.global_position - c.global_position
		to_threat.y = 0.0
		var face := 0.0
		if to_threat.length_squared() > 0.0001:
			face = c.threat_normal().dot(to_threat.normalized())
		var score := c.cover_strength * 4.0 + face * 3.0 - dist * 0.35
		if score > best_score:
			best_score = score
			best = c
	return best


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
	set_process_input(false)
	camera.deactivate()
	if reticle:
		reticle.hide_reticle()
	_hovered_enemy = null
	if _player and is_instance_valid(_player):
		_player.leave_cover(false)
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
		var cover_hint := "C cover(%d)" % active.cost_take_cover
		if active.is_in_cover():
			cover_hint = "C leave · %s" % active.active_cover.cover_tier_name()
		EventBus.log_line.emit(
			"AP %d/%d — WASD · LMB shoot · R reload · Q Focus · F stim · %s · RMB end" % [
				active.ap,
				active.max_ap,
				cover_hint,
			]
		)
