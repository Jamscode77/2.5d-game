class_name OTSCombatCamera
extends Camera3D
## 2.5D over-the-shoulder framing from the combat anchor (player position at trigger).

@export var shoulder_offset: Vector3 = Vector3(1.1, 1.6, 3.2)
@export var look_height: float = 1.2
@export var follow_blend: float = 6.0
@export var stage_forward: Vector3 = Vector3(0, 0, -1)

var _anchor: Vector3 = Vector3.ZERO
var _facing: Vector3 = Vector3.FORWARD
var _look_target: Vector3 = Vector3.ZERO
var _active: bool = false


func activate_from_session() -> void:
	activate(GameSession.combat_anchor_position, GameSession.combat_anchor_facing)


func activate(anchor: Vector3, facing: Vector3) -> void:
	_anchor = anchor
	_facing = facing.normalized() if facing.length() > 0.001 else stage_forward.normalized()
	_look_target = _anchor + _facing * 4.0 + Vector3.UP * look_height
	_snap()
	_active = true
	current = true


func set_look_target(world_pos: Vector3) -> void:
	_look_target = world_pos + Vector3.UP * look_height


func deactivate() -> void:
	_active = false


func _process(delta: float) -> void:
	if not _active:
		return
	var desired := _desired_pose()
	global_transform = global_transform.interpolate_with(desired, clampf(follow_blend * delta, 0.0, 1.0))


func _snap() -> void:
	global_transform = _desired_pose()


func _desired_pose() -> Transform3D:
	## Build a shoulder rig on the 2.5D stage: offset in local shoulder space.
	var forward := _facing
	forward.y = 0.0
	if forward.length() < 0.001:
		forward = stage_forward
	forward = forward.normalized()
	var right := Vector3.UP.cross(forward).normalized()
	if right.length() < 0.001:
		right = Vector3.RIGHT
	var up := forward.cross(right).normalized()

	var offset := right * shoulder_offset.x + up * shoulder_offset.y - forward * shoulder_offset.z
	var pos := _anchor + offset
	return Transform3D(Basis.looking_at(_look_target - pos, Vector3.UP), pos)
