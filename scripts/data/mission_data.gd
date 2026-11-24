class_name MissionData
extends Resource
## Authorable mission brief for the empire intel loop.

@export var id: StringName = &"mission_untitled"
@export var display_name: String = "Untitled Op"
@export_multiline var briefing: String = "No briefing filed."
@export var overworld_node_id: StringName = &"node_alpha"
@export var encounter: EncounterData
@export var success_standing: int = 1
