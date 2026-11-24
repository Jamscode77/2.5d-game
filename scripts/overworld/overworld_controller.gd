class_name OverworldController
extends Node3D
## FF-style node overworld: WASD travel, mouse select / accept / start combat.

@onready var nodes_root: Node3D = $Nodes
@onready var traversal_camera: Camera3D = $TraversalCamera
@onready var cursor: MeshInstance3D = $Cursor

var _node_list: Array[OverworldMapNode] = []
var _selected: int = 0
var _busy: bool = false


func _ready() -> void:
	visible = true
	for child in nodes_root.get_children():
		if child is OverworldMapNode:
			_node_list.append(child)
	_select(0)
	EventBus.combat_ended.connect(_on_combat_ended)
	EventBus.log_line.emit("Overworld — WASD: move  |  LMB: accept brief  |  RMB: start contact  |  Click node: select")


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _busy:
		return

	if event.is_action_pressed("move_left") or event.is_action_pressed("move_back"):
		_select(_selected - 1)
	elif event.is_action_pressed("move_right") or event.is_action_pressed("move_forward"):
		_select(_selected + 1)
	elif event.is_action_pressed("overworld_accept"):
		## Click near a node to select it, then accept the brief on that sector.
		_try_select_node_under_mouse()
		_accept_mission_at_selection()
	elif event.is_action_pressed("overworld_start_combat"):
		_start_contact_at_selection()


func _try_select_node_under_mouse() -> bool:
	var hit := _ray_to_ground()
	if hit == null:
		return false
	var best_i := -1
	var best_d := 2.5 # meters
	for i in _node_list.size():
		var d: float = hit.distance_to(_node_list[i].global_position)
		if d < best_d:
			best_d = d
			best_i = i
	if best_i >= 0:
		_select(best_i)
		return true
	return false


func _ray_to_ground() -> Variant:
	var mouse := get_viewport().get_mouse_position()
	var from := traversal_camera.project_ray_origin(mouse)
	var dir := traversal_camera.project_ray_normal(mouse)
	if absf(dir.y) < 0.0001:
		return null
	var t := -from.y / dir.y
	if t < 0.0:
		return null
	return from + dir * t


func _select(index: int) -> void:
	if _node_list.is_empty():
		return
	_selected = wrapi(index, 0, _node_list.size())
	var node := _node_list[_selected]
	cursor.global_position = node.global_position + Vector3(0, 1.2, 0)
	EventBus.log_line.emit("Sector: %s — %s" % [node.display_name, node.blurb])


func _accept_mission_at_selection() -> void:
	var node := _node_list[_selected]
	if node.mission == null:
		EventBus.log_line.emit("No active brief at this node.")
		return
	GameSession.begin_mission(node.mission)
	EventBus.log_line.emit("Brief filed. RMB when ready to engage.")


func _start_contact_at_selection() -> void:
	var node := _node_list[_selected]
	var encounter: EncounterData = null
	if node.mission and node.mission.encounter:
		encounter = node.mission.encounter
	elif node.encounter:
		encounter = node.encounter
	if encounter == null:
		EventBus.log_line.emit("No hostile signature.")
		return

	_busy = true
	visible = false
	var facing := Vector3(0, 0, -1)
	GameSession.request_encounter(encounter, node.combat_anchor.global_position, facing)


func _on_combat_ended(victory: bool) -> void:
	_busy = false
	visible = true
	traversal_camera.current = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GameSession.return_to_overworld()
	if victory and GameSession.active_mission:
		EventBus.mission_completed.emit(GameSession.active_mission.id, true)
		EventBus.log_line.emit("Debrief: empire standing %d" % GameSession.empire_standing)
	elif not victory:
		EventBus.log_line.emit("Extract failed. Regroup on the overworld.")
