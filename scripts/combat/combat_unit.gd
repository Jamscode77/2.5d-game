class_name CombatUnit
extends Node3D
## Combatant with per-turn action points (move / shoot / reload / skill / gear / cover).

signal defeated(unit: CombatUnit)

enum Team { PLAYER, ENEMY, ALLY }

@export var display_name: String = "Unit"
@export var team: Team = Team.ENEMY
@export var max_hp: int = 10
@export var attack_power: int = 3
@export var move_speed: float = 4.5
@export var apply_team_tint: bool = true
## Tripo/Mixamo meshes usually face +Z at rest. Keep 0 so +Z points along aim.
@export var model_yaw_offset: float = 0.0
@export var face_turn_speed: float = 14.0

@export_group("Action points")
@export var max_ap: int = 6
@export var meters_per_ap: float = 1.25
@export var cost_shoot: int = 2
@export var cost_reload: int = 2
@export var cost_skill: int = 3
@export var cost_equipment: int = 2
@export var cost_take_cover: int = 1

@export_group("Weapon")
@export var magazine_size: int = 3
@export var reserve_ammo: int = 9

var hp: int = 10
var ap: int = 0
var has_acted: bool = false
var is_alive: bool = true
var moved_this_turn: bool = false
var ammo_in_mag: int = 0
var active_cover: CoverObject = null
var _move_accum: float = 0.0
var _focus_bonus: int = 0
var _face_yaw: float = 0.0

@onready var _mesh: MeshInstance3D = get_node_or_null("MeshInstance3D") as MeshInstance3D
@onready var _label: Label3D = get_node_or_null("Label3D") as Label3D
@onready var _model: Node3D = get_node_or_null("Model") as Node3D


func _ready() -> void:
	hp = max_hp
	ap = max_ap
	ammo_in_mag = magazine_size
	_apply_team_color()
	_refresh_label()
	_ensure_pick_body()
	_face_yaw = model_yaw_offset
	if _model:
		_model.rotation.y = _face_yaw


func _process(delta: float) -> void:
	if _model == null:
		return
	_model.rotation.y = lerp_angle(_model.rotation.y, _face_yaw, clampf(face_turn_speed * delta, 0.0, 1.0))


func begin_turn() -> void:
	has_acted = false
	moved_this_turn = false
	_move_accum = 0.0
	ap = max_ap
	_refresh_label()
	EventBus.turn_started.emit(self)
	var cover_bit := ""
	if active_cover:
		cover_bit = " | %s cover" % active_cover.cover_tier_name()
	EventBus.log_line.emit("%s turn — %d AP | mag %d/%d%s" % [
		display_name, ap, ammo_in_mag, magazine_size, cover_bit
	])


func end_turn() -> void:
	has_acted = true
	ap = 0
	_refresh_label()
	EventBus.turn_ended.emit(self)


func can_afford(cost: int) -> bool:
	return is_alive and ap >= cost


func spend_ap(cost: int) -> bool:
	if not can_afford(cost):
		return false
	ap -= cost
	_refresh_label()
	return true


func is_in_cover() -> bool:
	return active_cover != null and is_instance_valid(active_cover)


func take_damage(amount: int, attacker: Node3D = null) -> void:
	if not is_alive:
		return
	var final_amount := amount
	if is_in_cover() and attacker != null:
		var prot := active_cover.protection_factor(self, attacker)
		if prot > 0.01:
			var reduced := int(round(float(amount) * (1.0 - prot)))
			## Full frontal cover can null a weak hit; leave chip only if any damage survives.
			final_amount = maxi(reduced, 0)
			if final_amount < amount:
				EventBus.log_line.emit(
					"%s cover (%s, %.0f%%) soaks %d → %d" % [
						display_name,
						active_cover.cover_tier_name(),
						prot * 100.0,
						amount,
						final_amount,
					]
				)
			if final_amount <= 0:
				EventBus.log_line.emit("%s — shot stopped by cover." % display_name)
				_refresh_label()
				return
	hp = maxi(hp - final_amount, 0)
	_refresh_label()
	EventBus.log_line.emit("%s takes %d damage (%d/%d)" % [display_name, final_amount, hp, max_hp])
	if hp <= 0:
		_die()


## Face the aim direction (mouse / reticle). Mesh +Z aligns with aim.
func face_aim(aim_forward: Vector3) -> void:
	var flat := Vector3(aim_forward.x, 0.0, aim_forward.z)
	if flat.length_squared() < 0.0001:
		return
	flat = flat.normalized()
	_face_yaw = atan2(flat.x, flat.z) + model_yaw_offset


## Continuous move; burns 1 AP every meters_per_ap traveled. Breaks cover.
func apply_move_input(local_dir: Vector3, delta: float) -> void:
	if not is_alive or ap <= 0:
		return
	if local_dir.length() < 0.01:
		return
	if is_in_cover():
		leave_cover(true)
	var flat := Vector3(local_dir.x, 0.0, local_dir.z).normalized()
	var step := move_speed * delta
	var remaining_budget := float(ap) * meters_per_ap - _move_accum
	if remaining_budget <= 0.0:
		return
	step = minf(step, remaining_budget)
	global_position += flat * step
	moved_this_turn = true
	_move_accum += step
	while _move_accum >= meters_per_ap and ap > 0:
		_move_accum -= meters_per_ap
		ap -= 1
		_refresh_label()


## Discrete step used by enemy AI (returns false if no AP left).
func try_move_toward(target_pos: Vector3, distance: float) -> bool:
	if not is_alive or ap <= 0:
		return false
	var flat := Vector3(target_pos.x - global_position.x, 0.0, target_pos.z - global_position.z)
	if flat.length_squared() < 0.0001:
		return false
	flat = flat.normalized()
	if is_in_cover():
		leave_cover(true)
	var step := minf(distance, float(ap) * meters_per_ap)
	var cost := maxi(1, int(ceili(step / meters_per_ap)))
	if not spend_ap(cost):
		return false
	global_position += flat * step
	moved_this_turn = true
	face_aim(flat)
	return true


func try_shoot(target: CombatUnit) -> bool:
	if target == null or not target.is_alive:
		return false
	if ammo_in_mag <= 0:
		EventBus.log_line.emit("%s — magazine empty (R reload)." % display_name)
		return false
	if not spend_ap(cost_shoot):
		EventBus.log_line.emit("%s — need %d AP to shoot (have %d)." % [display_name, cost_shoot, ap])
		return false
	ammo_in_mag -= 1
	var dmg := attack_power + _focus_bonus
	if _focus_bonus > 0:
		EventBus.log_line.emit("%s fires with Focus (+%d)." % [display_name, _focus_bonus])
		_focus_bonus = 0
	target.take_damage(dmg, self)
	_refresh_label()
	return true


func try_reload() -> bool:
	if ammo_in_mag >= magazine_size:
		EventBus.log_line.emit("%s — mag already full." % display_name)
		return false
	if reserve_ammo <= 0:
		EventBus.log_line.emit("%s — no reserve ammo." % display_name)
		return false
	if not spend_ap(cost_reload):
		EventBus.log_line.emit("%s — need %d AP to reload." % [display_name, cost_reload])
		return false
	var need := magazine_size - ammo_in_mag
	var take := mini(need, reserve_ammo)
	ammo_in_mag += take
	reserve_ammo -= take
	EventBus.log_line.emit("%s reloads (−%d AP). Mag %d/%d · reserve %d" % [
		display_name, cost_reload, ammo_in_mag, magazine_size, reserve_ammo
	])
	_refresh_label()
	return true


## Skill: Focus — next shot deals +2 damage.
func try_skill_focus() -> bool:
	if _focus_bonus > 0:
		EventBus.log_line.emit("%s — Focus already primed." % display_name)
		return false
	if not spend_ap(cost_skill):
		EventBus.log_line.emit("%s — need %d AP for Focus." % [display_name, cost_skill])
		return false
	_focus_bonus = 2
	EventBus.log_line.emit("%s primes Focus (−%d AP). Next shot +2." % [display_name, cost_skill])
	return true


## Equipment: Field stim — restore a little HP.
func try_equipment_stim() -> bool:
	if hp >= max_hp:
		EventBus.log_line.emit("%s — already at full HP." % display_name)
		return false
	if not spend_ap(cost_equipment):
		EventBus.log_line.emit("%s — need %d AP for stim." % [display_name, cost_equipment])
		return false
	var healed := mini(3, max_hp - hp)
	hp += healed
	EventBus.log_line.emit("%s uses Field Stim (−%d AP). +%d HP → %d/%d" % [
		display_name, cost_equipment, healed, hp, max_hp
	])
	_refresh_label()
	return true


## Take or leave the nearest usable cover (C). Leaving is free; taking costs AP.
func try_toggle_cover(covers: Array[CoverObject]) -> bool:
	if is_in_cover():
		leave_cover(true)
		return true
	var best: CoverObject = null
	var best_d := INF
	for c in covers:
		if c == null or not c.can_unit_take(self):
			continue
		var d := global_position.distance_to(c.occupy_global())
		if d < best_d:
			best_d = d
			best = c
	if best == null:
		EventBus.log_line.emit("%s — no cover in reach. Move next to a crate/wall." % display_name)
		return false
	return try_take_cover(best)


func try_take_cover(cover: CoverObject) -> bool:
	if cover == null or not cover.can_unit_take(self):
		EventBus.log_line.emit("%s — cannot take that cover." % display_name)
		return false
	if is_in_cover() and active_cover == cover:
		return false
	if not spend_ap(cost_take_cover):
		EventBus.log_line.emit("%s — need %d AP to take cover." % [display_name, cost_take_cover])
		return false
	if is_in_cover():
		leave_cover(false)
	active_cover = cover
	cover.claim(self)
	global_position = cover.occupy_global()
	## Face the threat side of the cover.
	face_aim(cover.threat_normal())
	EventBus.log_line.emit("%s takes %s cover (−%d AP)." % [
		display_name, cover.cover_tier_name(), cost_take_cover
	])
	_refresh_label()
	return true


func leave_cover(announce: bool = true) -> void:
	if not is_in_cover():
		return
	active_cover.release(self)
	active_cover = null
	if announce:
		EventBus.log_line.emit("%s leaves cover." % display_name)
	_refresh_label()


func _die() -> void:
	leave_cover(false)
	is_alive = false
	visible = false
	defeated.emit(self)
	EventBus.unit_defeated.emit(self)
	EventBus.log_line.emit("%s down." % display_name)


func _apply_team_color() -> void:
	if not apply_team_tint or _mesh == null:
		return
	var mat := StandardMaterial3D.new()
	match team:
		Team.PLAYER:
			mat.albedo_color = Color(0.35, 0.55, 0.95)
		Team.ALLY:
			mat.albedo_color = Color(0.35, 0.8, 0.55)
		_:
			mat.albedo_color = Color(0.85, 0.3, 0.3)
	_mesh.material_override = mat


func _refresh_label() -> void:
	if _label == null:
		return
	var cover_line := ""
	if is_in_cover():
		cover_line = "\n[%s cover]" % active_cover.cover_tier_name()
	_label.text = "%s\n%d/%d HP · %d AP\n%d/%d ammo%s" % [
		display_name, hp, max_hp, ap, ammo_in_mag, magazine_size, cover_line
	]


func _ensure_pick_body() -> void:
	if get_node_or_null("PickBody") != null:
		return
	var body := StaticBody3D.new()
	body.name = "PickBody"
	body.collision_layer = 2
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.7
	shape.shape = capsule
	shape.position = Vector3(0, 0.85, 0)
	body.add_child(shape)
	add_child(body)
	body.set_meta("combat_unit", self)
