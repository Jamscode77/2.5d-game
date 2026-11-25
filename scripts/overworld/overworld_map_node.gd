class_name OverworldMapNode
extends Node3D
## Location pin on the sprite overworld. Shows a mission/quiet marker sprite.

@export var display_name: String = "Sector"
@export var blurb: String = "Quiet."
@export var mission: MissionData
@export var encounter: EncounterData
@export var interact_radius: float = 1.6

@onready var combat_anchor: Marker3D = $CombatAnchor
@onready var marker: Sprite3D = get_node_or_null("Marker") as Sprite3D
@onready var label: Label3D = get_node_or_null("Label3D") as Label3D


func _ready() -> void:
	if label:
		label.text = display_name
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.font_size = 28
		label.modulate = Color(0.85, 0.9, 1.0)
	if marker:
		marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		marker.pixel_size = 0.05
		marker.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		marker.shaded = false
		var path := (
			"res://assets/sprites/ow_marker_mission.png"
			if mission != null or encounter != null
			else "res://assets/sprites/ow_marker_quiet.png"
		)
		if ResourceLoader.exists(path):
			marker.texture = load(path) as Texture2D


func is_player_in_range(player: Node3D) -> bool:
	if player == null:
		return false
	var d := Vector2(player.global_position.x, player.global_position.z).distance_to(
		Vector2(global_position.x, global_position.z)
	)
	return d <= interact_radius
