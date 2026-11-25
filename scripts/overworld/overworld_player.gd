class_name OverworldPlayer
extends Node3D
## Little FF-style sprite that walks the overworld. Combat uses 3D models separately.

@export var move_speed: float = 5.5
@export var bounds: Vector2 = Vector2(9.0, 5.0) ## half-extents on XZ plate

@onready var sprite: Sprite3D = $Sprite3D

var velocity_xz: Vector3 = Vector3.ZERO


func _ready() -> void:
	if sprite:
		sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		sprite.pixel_size = 0.06
		sprite.shaded = false
		sprite.double_sided = true
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		sprite.position = Vector3(0, 0.55, 0)


func _physics_process(delta: float) -> void:
	## Skip while overworld is hidden (combat active).
	var root := get_parent()
	if root and not root.visible:
		velocity_xz = Vector3.ZERO
		return

	var input := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		input.z -= 1.0
	if Input.is_action_pressed("move_back"):
		input.z += 1.0
	if Input.is_action_pressed("move_left"):
		input.x -= 1.0
	if Input.is_action_pressed("move_right"):
		input.x += 1.0
	if input.length() > 0.01:
		input = input.normalized()
		velocity_xz = input * move_speed
		global_position += velocity_xz * delta
		global_position.x = clampf(global_position.x, -bounds.x, bounds.x)
		global_position.z = clampf(global_position.z, -bounds.y, bounds.y)
		global_position.y = 0.0
		## Flip sprite for left/right facing.
		if sprite and absf(input.x) > 0.1:
			sprite.flip_h = input.x < 0.0
	else:
		velocity_xz = Vector3.ZERO
