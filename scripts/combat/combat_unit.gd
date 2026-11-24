class_name CombatUnit
extends Node3D
## Minimal combatant for turn-based OTS fights. Replace mesh later (Tripo).

signal defeated(unit: CombatUnit)

enum Team { PLAYER, ENEMY, ALLY }

@export var display_name: String = "Unit"
@export var team: Team = Team.ENEMY
@export var max_hp: int = 10
@export var attack_power: int = 3
@export var move_range: float = 3.0
@export var move_speed: float = 4.5
## When false, keep authored materials (Tripo / GLB) instead of flat team tint.
@export var apply_team_tint: bool = true

var hp: int = 10
var has_acted: bool = false
var is_alive: bool = true
var moved_this_turn: bool = false

@onready var _mesh: MeshInstance3D = get_node_or_null("MeshInstance3D") as MeshInstance3D
@onready var _label: Label3D = get_node_or_null("Label3D") as Label3D


func _ready() -> void:
	hp = max_hp
	_apply_team_color()
	_refresh_label()
	_ensure_pick_body()


func begin_turn() -> void:
	has_acted = false
	moved_this_turn = false
	EventBus.turn_started.emit(self)


func end_turn() -> void:
	has_acted = true
	EventBus.turn_ended.emit(self)


func take_damage(amount: int) -> void:
	if not is_alive:
		return
	hp = maxi(hp - amount, 0)
	_refresh_label()
	EventBus.log_line.emit("%s takes %d damage (%d/%d)" % [display_name, amount, hp, max_hp])
	if hp <= 0:
		_die()


func deal_damage_to(target: CombatUnit) -> void:
	if target == null or not target.is_alive:
		return
	target.take_damage(attack_power)
	has_acted = true


func apply_move_input(local_dir: Vector3, delta: float) -> void:
	if not is_alive or has_acted:
		return
	if local_dir.length() < 0.01:
		return
	var flat := Vector3(local_dir.x, 0.0, local_dir.z).normalized()
	global_position += flat * move_speed * delta
	moved_this_turn = true


func _die() -> void:
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
	if _label:
		_label.text = "%s\n%d/%d" % [display_name, hp, max_hp]


func _ensure_pick_body() -> void:
	var body := StaticBody3D.new()
	body.name = "PickBody"
	body.collision_layer = 2 # units
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	shape.shape = capsule
	shape.position = Vector3(0, 0.8, 0)
	body.add_child(shape)
	add_child(body)
	body.set_meta("combat_unit", self)
