class_name OverworldController
extends Node3D
## FF-style sprite overworld: walk a little operative around, enter 3D combat at pins.

@onready var nodes_root: Node3D = $Nodes
@onready var player: OverworldPlayer = $OverworldPlayer
@onready var traversal_camera: Camera3D = $OverworldPlayer/TraversalCamera
@onready var hint_label: Label3D = $InteractHint

var _node_list: Array[OverworldMapNode] = []
var _nearby: OverworldMapNode = null
var _busy: bool = false


func _ready() -> void:
	visible = true
	for child in nodes_root.get_children():
		if child is OverworldMapNode:
			_node_list.append(child)
	EventBus.combat_ended.connect(_on_combat_ended)
	if hint_label:
		hint_label.visible = false
		hint_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	EventBus.log_line.emit("Overworld — WASD: walk sprite  |  E / LMB: brief  |  RMB: start 3D combat when near a pin")
	_activate_camera()


func _process(_delta: float) -> void:
	if not visible or _busy:
		return
	_update_nearby()
	_update_hint()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _busy:
		return
	if event.is_action_pressed("overworld_accept") or event.is_action_pressed("ui_accept"):
		_accept_mission_nearby()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("overworld_start_combat"):
		_start_contact_nearby()
		get_viewport().set_input_as_handled()


func _update_nearby() -> void:
	_nearby = null
	var best_d := INF
	for node in _node_list:
		if node.is_player_in_range(player):
			var d := player.global_position.distance_to(node.global_position)
			if d < best_d:
				best_d = d
				_nearby = node


func _update_hint() -> void:
	if hint_label == null:
		return
	if _nearby == null:
		hint_label.visible = false
		return
	hint_label.visible = true
	hint_label.global_position = _nearby.global_position + Vector3(0, 1.8, 0)
	var can_fight := _nearby.encounter != null or (_nearby.mission != null and _nearby.mission.encounter != null)
	if can_fight:
		hint_label.text = "%s\nE brief · RMB fight" % _nearby.display_name
	else:
		hint_label.text = "%s\n(no contact)" % _nearby.display_name


## Camera is a child of the player with a fixed local pose — world scrolls under it, FF-style.
func _activate_camera() -> void:
	if traversal_camera:
		traversal_camera.current = true


func _accept_mission_nearby() -> void:
	if _nearby == null:
		EventBus.log_line.emit("Walk to a map pin first.")
		return
	if _nearby.mission == null:
		EventBus.log_line.emit("%s — no active brief." % _nearby.display_name)
		return
	GameSession.begin_mission(_nearby.mission)
	EventBus.log_line.emit("Brief filed: %s. RMB to enter 3D combat." % _nearby.mission.display_name)


func _start_contact_nearby() -> void:
	if _nearby == null:
		EventBus.log_line.emit("Walk to a hostile pin (red) to engage.")
		return
	var encounter: EncounterData = null
	if _nearby.mission and _nearby.mission.encounter:
		encounter = _nearby.mission.encounter
	elif _nearby.encounter:
		encounter = _nearby.encounter
	if encounter == null:
		EventBus.log_line.emit("No hostile signature here.")
		return

	_busy = true
	visible = false
	var facing := Vector3(0, 0, -1)
	GameSession.request_encounter(encounter, _nearby.combat_anchor.global_position, facing)


func _on_combat_ended(victory: bool) -> void:
	_busy = false
	visible = true
	_activate_camera()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GameSession.return_to_overworld()
	if victory and GameSession.active_mission:
		EventBus.mission_completed.emit(GameSession.active_mission.id, true)
		EventBus.log_line.emit("Debrief: empire standing %d" % GameSession.empire_standing)
	elif not victory:
		EventBus.log_line.emit("Extract failed. Back on the overworld map.")
