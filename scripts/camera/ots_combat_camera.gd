class_name OTSCombatCamera
extends Camera3D
## Over-the-shoulder camera. Mouse yaw/pitch aims the reticle (camera forward).

@export var shoulder_offset: Vector3 = Vector3(1.15, 1.55, 2.8)
@export var follow_blend: float = 12.0
@export var stage_forward: Vector3 = Vector3(0, 0, -1)
@export var mouse_sensitivity: float = 0.12
@export var pitch_min: float = -40.0
@export var pitch_max: float = 30.0

var _anchor: Vector3 = Vector3.ZERO
var _base_facing: Vector3 = Vector3.FORWARD
var _active: bool = false
var _yaw_offset_deg: float = 0.0
var _pitch_offset_deg: float = 0.0
var _follow_unit: Node3D = null


func activate_from_session() -> void:
	activate(GameSession.combat_anchor_position, GameSession.combat_anchor_facing)


func activate(anchor: Vector3, facing: Vector3) -> void:
	_anchor = anchor
	_base_facing = facing.normalized() if facing.length() > 0.001 else stage_forward.normalized()
	_yaw_offset_deg = 0.0
	_pitch_offset_deg = 0.0
	_snap()
	_active = true
	current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func set_follow_unit(unit: Node3D) -> void:
	_follow_unit = unit


func add_mouse_look(relative: Vector2) -> void:
	if not _active:
		return
	_yaw_offset_deg -= relative.x * mouse_sensitivity
	_pitch_offset_deg = clampf(
		_pitch_offset_deg - relative.y * mouse_sensitivity,
		pitch_min,
		pitch_max
	)


## World-space aim direction through the reticle (camera forward).
func get_aim_forward() -> Vector3:
	return -global_transform.basis.z


func get_aim_origin() -> Vector3:
	return global_position


func deactivate() -> void:
	_active = false
	_follow_unit = null
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(delta: float) -> void:
	if not _active:
		return
	if _follow_unit and is_instance_valid(_follow_unit):
		_anchor = _follow_unit.global_position
	var desired := _desired_pose()
	global_transform = global_transform.interpolate_with(desired, clampf(follow_blend * delta, 0.0, 1.0))


func _snap() -> void:
	global_transform = _desired_pose()


func _desired_pose() -> Transform3D:
	var forward := _base_facing
	forward.y = 0.0
	if forward.length() < 0.001:
		forward = stage_forward
	forward = forward.normalized()

	forward = forward.rotated(Vector3.UP, deg_to_rad(_yaw_offset_deg)).normalized()
	var right := Vector3.UP.cross(forward).normalized()
	if right.length() < 0.001:
		right = Vector3.RIGHT

	var look_dir := forward.rotated(right, deg_to_rad(_pitch_offset_deg)).normalized()
	var up := look_dir.cross(right).normalized()
	## Rebuild orthonormal basis: camera looks along look_dir (-Z).
	right = up.cross(look_dir).normalized()
	up = look_dir.cross(right).normalized()

	var offset := right * shoulder_offset.x + Vector3.UP * shoulder_offset.y - forward * shoulder_offset.z
	var pos := _anchor + offset
	var target := pos + look_dir * 8.0
	return Transform3D(Basis.looking_at(target - pos, Vector3.UP), pos)
