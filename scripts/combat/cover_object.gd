class_name CoverObject
extends Node3D
## Arena cover. cover_strength 0.5 ≈ half, 1.0 ≈ full; values in between blend.
## Local −Z faces the threat; units occupy the +Z (safe) side.

@export_range(0.0, 1.0, 0.05) var cover_strength: float = 0.5
@export var display_name: String = "Cover"
@export var interact_radius: float = 1.9
## Where a unit stands relative to this cover (local space, usually +Z).
@export var occupy_local: Vector3 = Vector3(0, 0, 0.85)

var occupied_by: CombatUnit = null

@onready var _label: Label3D = get_node_or_null("Label3D") as Label3D


func _ready() -> void:
	_refresh_label()


func cover_tier_name() -> String:
	if cover_strength >= 0.9:
		return "Full"
	if cover_strength >= 0.7:
		return "Heavy"
	if cover_strength >= 0.45:
		return "Half"
	if cover_strength >= 0.25:
		return "Light"
	return "Sparse"


func is_free() -> bool:
	return occupied_by == null or not is_instance_valid(occupied_by) or not occupied_by.is_alive


func can_unit_take(unit: CombatUnit) -> bool:
	if unit == null or not unit.is_alive:
		return false
	if not is_free() and occupied_by != unit:
		return false
	return unit.global_position.distance_to(occupy_global()) <= interact_radius


func occupy_global() -> Vector3:
	return to_global(occupy_local)


## World-facing direction the cover blocks (threat side).
func threat_normal() -> Vector3:
	var n := -global_transform.basis.z
	n.y = 0.0
	if n.length_squared() < 0.0001:
		return Vector3.FORWARD
	return n.normalized()


func claim(unit: CombatUnit) -> void:
	if occupied_by and occupied_by != unit and is_instance_valid(occupied_by):
		occupied_by.leave_cover(false)
	occupied_by = unit
	_refresh_label()


func release(unit: CombatUnit) -> void:
	if occupied_by == unit:
		occupied_by = null
	_refresh_label()


## 0–1 damage reduction when `defender` is using this cover vs `attacker`.
## Full frontal + full strength ≈ ~0.95 block; half ≈ ~0.5; flank nearly ignores it.
func protection_factor(defender: CombatUnit, attacker: Node3D) -> float:
	if defender == null or attacker == null:
		return 0.0
	if occupied_by != defender:
		return 0.0

	var to_attacker := attacker.global_position - global_position
	to_attacker.y = 0.0
	if to_attacker.length_squared() < 0.0001:
		return cover_strength * 0.5
	to_attacker = to_attacker.normalized()

	## 1 = attacker dead-on threat side; ≤0 = flank / rear.
	var frontal: float = threat_normal().dot(to_attacker)
	if frontal <= 0.05:
		## Flanked — only a scrap of hard cover helps.
		return cover_strength * 0.08

	var angle_quality := clampf((frontal - 0.05) / 0.95, 0.0, 1.0)
	## Soften mid angles so ¾ cover isn't binary.
	var directional := 0.25 + 0.75 * angle_quality
	return clampf(cover_strength * directional, 0.0, 0.95)


func _refresh_label() -> void:
	if _label == null:
		return
	var who := ""
	if occupied_by and is_instance_valid(occupied_by):
		who = " · held"
	_label.text = "%s\n%s%s" % [display_name, cover_tier_name(), who]
