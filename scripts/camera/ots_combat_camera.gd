class_name OTSCombatCamera
extends Camera3D
## 2.5D over-the-shoulder framing; mouse look adds yaw/pitch on top of the shoulder rig.

@export var shoulder_offset: Vector3 = Vector3(1.1, 1.6, 3.2)
@export var look_height: float = 1.2
@export var follow_blend: float = 6.0
@export var stage_forward: Vector3 = Vector3(0, 0, -1)
@export var mouse_sensitivity: float = 0.12
@export var pitch_min: float = -35.0
@export var pitch_max: float = 25.0

var _anchor: Vector3 = Vector3.ZERO
var _facing: Vector3 = Vector3.FORWARD
var _look_target: Vector3 = Vector3.ZERO
var _active: bool = false
var _yaw_offset_deg: float = 0.0
var _pitch_offset_deg: float = 0.0
var _follow_unit: Node3D = null


func activate_from_session() -> void:
	activate(GameSession.combat_anchor_position, GameSession.combat_anchor_facing)


func activate(anchor: Vector3, facing: Vector3) -> void:
	_anchor = anchor
	_facing = facing.normalized() if facing.length() > 0.001 else stage_forward.normalized()
	_yaw_offset_deg = 0.0
	_pitch_offset_deg = 0.0
	_look_target = _anchor + _facing * 4.0 + Vector3.UP * look_height
	_snap()
	_active = true
	current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func set_follow_unit(unit: Node3D) -> void:
	_follow_unit = unit


func set_look_target(world_pos: Vector3) -> void:
	_look_target = world_pos + Vector3.UP * look_height


func add_mouse_look(relative: Vector2) -> void:
	if not _active:
		return
	_yaw_offset_deg -= relative.x * mouse_sensitivity
	_pitch_offset_deg = clampf(
		_pitch_offset_deg - relative.y * mouse_sensitivity,
		pitch_min,
		pitch_max
	)


func get_aim_forward() -> Vector3:
	var basis := global_transform.basis
	return -basis.z


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
	var forward := _facing
	forward.y = 0.0
	if forward.length() < 0.001:
		forward = stage_forward
	forward = forward.normalized()

	var yaw := deg_to_rad(_yaw_offset_deg)
	forward = forward.rotated(Vector3.UP, yaw).normalized()

	var right := Vector3.UP.cross(forward).normalized()
	if right.length() < 0.001:
		right = Vector3.RIGHT
	var up := forward.cross(right).normalized()

	var offset := right * shoulder_offset.x + up * shoulder_offset.y - forward * shoulder_offset.z
	var pos := _anchor + offset

	var look_dir := forward.rotated(right, deg_to_rad(_pitch_offset_deg))
	var target := pos + look_dir * 6.0 + Vector3.UP * (look_height * 0.15)
	## Prefer explicit look target when set far from default (e.g. aiming at enemy).
	if _look_target.distance_to(_anchor) > 0.5:
		target = _look_target

	return Transform3D(Basis.looking_at(target - pos, Vector3.UP), pos)
