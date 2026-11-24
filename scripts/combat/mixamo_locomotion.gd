class_name MixamoLocomotion
extends Node
## Procedural idle/walk for Mixamo-named skeletons (Tripo often exports these with no clips).
## Attach as a child of the unit; point skeleton_path at the Skeleton3D.

@export var skeleton_path: NodePath
@export var model_root_path: NodePath
## Extra yaw so the mesh faces the unit's forward (-Z). Flip to PI if the model is backward.
@export var model_yaw_offset: float = PI
@export var turn_speed: float = 10.0
@export var walk_speed_threshold: float = 0.15
@export var stride_hz: float = 2.2
@export var leg_swing_deg: float = 28.0
@export var arm_swing_deg: float = 22.0
@export var idle_bob_deg: float = 2.5

var _skeleton: Skeleton3D
var _model: Node3D
var _phase: float = 0.0
var _moving: bool = false
var _desired_yaw: float = 0.0
var _bone_rest: Dictionary = {} # name -> rest Basis (local pose basis)


func _ready() -> void:
	_skeleton = get_node_or_null(skeleton_path) as Skeleton3D
	_model = get_node_or_null(model_root_path) as Node3D
	if _skeleton == null:
		_skeleton = _find_skeleton(get_parent())
	if _model == null and get_parent() != null:
		_model = get_parent().get_node_or_null("Model") as Node3D
	if _skeleton:
		_cache_rest_poses()
	# Default: face combat forward (-Z).
	_desired_yaw = model_yaw_offset


func set_locomotion(velocity: Vector3, aim_forward: Vector3) -> void:
	var flat_vel := Vector3(velocity.x, 0.0, velocity.z)
	_moving = flat_vel.length() > walk_speed_threshold
	var face := flat_vel
	if face.length() < 0.05:
		face = Vector3(aim_forward.x, 0.0, aim_forward.z)
	if face.length() > 0.05:
		## Godot look: yaw 0 faces -Z. atan2(x, z) with -Z forward uses atan2(-x, -z)... 
		## yaw that rotates +Z toward face: atan2(face.x, face.z)
		_desired_yaw = atan2(face.x, face.z) + model_yaw_offset


func _process(delta: float) -> void:
	if _model:
		var cur := _model.rotation.y
		_model.rotation.y = lerp_angle(cur, _desired_yaw, clampf(turn_speed * delta, 0.0, 1.0))
		# Keep authored scale.
	if _skeleton == null:
		return
	if _moving:
		_phase += delta * TAU * stride_hz
		_apply_walk()
	else:
		_phase += delta * 1.5
		_apply_idle()


func _cache_rest_poses() -> void:
	_bone_rest.clear()
	for name in [
		"mixamorig_Hips",
		"mixamorig_LeftUpLeg", "mixamorig_RightUpLeg",
		"mixamorig_LeftLeg", "mixamorig_RightLeg",
		"mixamorig_LeftArm", "mixamorig_RightArm",
		"mixamorig_LeftForeArm", "mixamorig_RightForeArm",
		"mixamorig_Spine",
	]:
		var idx := _skeleton.find_bone(name)
		if idx >= 0:
			_bone_rest[name] = _skeleton.get_bone_rest(idx).basis


func _apply_idle() -> void:
	var sway := sin(_phase) * deg_to_rad(idle_bob_deg)
	_set_bone_rot("mixamorig_Hips", Basis.from_euler(Vector3(0, sway * 0.35, sway)))
	_set_bone_rot("mixamorig_Spine", Basis.from_euler(Vector3(sway * 0.4, 0, 0)))
	_set_bone_rot("mixamorig_LeftArm", Basis.from_euler(Vector3(0, 0, deg_to_rad(6.0))))
	_set_bone_rot("mixamorig_RightArm", Basis.from_euler(Vector3(0, 0, deg_to_rad(-6.0))))
	_set_bone_rot("mixamorig_LeftUpLeg", Basis.IDENTITY)
	_set_bone_rot("mixamorig_RightUpLeg", Basis.IDENTITY)
	_set_bone_rot("mixamorig_LeftLeg", Basis.IDENTITY)
	_set_bone_rot("mixamorig_RightLeg", Basis.IDENTITY)


func _apply_walk() -> void:
	var swing := sin(_phase) * deg_to_rad(leg_swing_deg)
	var arm := sin(_phase) * deg_to_rad(arm_swing_deg)
	_set_bone_rot("mixamorig_Hips", Basis.from_euler(Vector3(0, 0, sin(_phase * 0.5) * deg_to_rad(3.0))))
	_set_bone_rot("mixamorig_LeftUpLeg", Basis.from_euler(Vector3(swing, 0, 0)))
	_set_bone_rot("mixamorig_RightUpLeg", Basis.from_euler(Vector3(-swing, 0, 0)))
	_set_bone_rot("mixamorig_LeftLeg", Basis.from_euler(Vector3(-absf(swing) * 0.45, 0, 0)))
	_set_bone_rot("mixamorig_RightLeg", Basis.from_euler(Vector3(-absf(-swing) * 0.45, 0, 0)))
	_set_bone_rot("mixamorig_LeftArm", Basis.from_euler(Vector3(-arm, 0, deg_to_rad(8.0))))
	_set_bone_rot("mixamorig_RightArm", Basis.from_euler(Vector3(arm, 0, deg_to_rad(-8.0))))
	_set_bone_rot("mixamorig_LeftForeArm", Basis.from_euler(Vector3(-absf(arm) * 0.35, 0, 0)))
	_set_bone_rot("mixamorig_RightForeArm", Basis.from_euler(Vector3(-absf(arm) * 0.35, 0, 0)))
	_set_bone_rot("mixamorig_Spine", Basis.from_euler(Vector3(deg_to_rad(4.0), 0, 0)))


func _set_bone_rot(bone_name: String, delta_basis: Basis) -> void:
	if _skeleton == null or not _bone_rest.has(bone_name):
		return
	var idx := _skeleton.find_bone(bone_name)
	if idx < 0:
		return
	var rest_b: Basis = _bone_rest[bone_name]
	var posed: Basis = rest_b * delta_basis
	_skeleton.set_bone_pose_rotation(idx, posed.get_rotation_quaternion())
	_skeleton.set_bone_pose_position(idx, _skeleton.get_bone_rest(idx).origin)


func _find_skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n
	for c in n.get_children():
		var found := _find_skeleton(c)
		if found:
			return found
	return null
