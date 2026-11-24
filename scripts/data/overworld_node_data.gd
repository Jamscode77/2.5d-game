class_name OverworldNodeData
extends Resource
## A location on the 2.5D / node overworld map.

@export var id: StringName = &"node_unknown"
@export var display_name: String = "Unknown Sector"
@export var description: String = ""
@export var mission: MissionData
@export var connected_ids: Array[StringName] = []
