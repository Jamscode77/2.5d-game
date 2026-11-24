class_name OTSCombatCamera
extends Camera3D
## Third-person shoulder cam. Mouse orbits yaw/pitch; reticle aims down camera -Z.

@export var shoulder_offset: Vector3 = Vector3(0.85, 1.45, 3.0) ## local (+X right, +Y up, +Z behind)
@export var follow_blend: float = 14.0
@export var mouse_sensitivity: float = 0.18
@export var pitch_min: float = -50.0
@export var pitch_max: float = 35.0

var _anchor: Vector3 = Vector3.ZERO
var _active: bool = false
var _yaw_deg: float = 0.0
var _pitch_deg: float = -8.0
var _follow_unit: Node3D = null


func activate_from_session() -> void:
	var facing := GameSession.combat_anchor_facing
	if facing.length() < 0.001:
		facing = Vector3(0, 0, -1)
	facing.y = 0.0
	facing = facing.normalized()
	## Yaw 0 = camera behind looking toward -Z. Match session facing.
	_yaw_deg = rad_to_deg(atan2(-facing.x, -facing.z))
	_pitch_deg = -8.0
	_anchor = GameSession.combat_anchor_position
	_snap()
	_active = true
	current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func set_follow_unit(unit: Node3D) -> void:
	_follow_unit = unit


func add_mouse_look(relative: Vector2) -> void:
	if not _active:
		return
	_yaw_deg -= relative.x * mouse_sensitivity
	_pitch_deg -= relative.y * mouse_sensitivity
	_pitch_deg = clampf(_pitch_deg, pitch_min, pitch_max)


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
	var yaw := deg_to_rad(_yaw_deg)
	var pitch := deg_to_rad(_pitch_deg)
	## Orbit basis: yaw around world up, then pitch around local right.
	var basis := Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, pitch)
	var pos := _anchor + basis * shoulder_offset
	## Camera looks along local -Z of the same basis.
	var look_target := pos - basis.z * 8.0
	return Transform3D(Basis.looking_at(look_target - pos, Vector3.UP), pos)
