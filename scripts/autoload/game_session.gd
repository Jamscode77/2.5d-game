extends Node
## Persistent campaign/session state across overworld ↔ combat.

enum Phase { OVERWORLD, COMBAT, BRIEFING, DEBRIEF }

var phase: Phase = Phase.OVERWORLD
var active_mission: MissionData = null
var last_combat_victory: bool = false
var empire_standing: int = 0

## Where the player stood when combat triggered (drives OTS camera).
var combat_anchor_position: Vector3 = Vector3.ZERO
var combat_anchor_facing: Vector3 = Vector3.FORWARD


func _ready() -> void:
	EventBus.combat_started.connect(_on_combat_started)
	EventBus.combat_ended.connect(_on_combat_ended)
	EventBus.mission_started.connect(_on_mission_started)
	EventBus.mission_completed.connect(_on_mission_completed)


func begin_mission(mission: MissionData) -> void:
	active_mission = mission
	phase = Phase.BRIEFING
	EventBus.mission_started.emit(mission.id)
	EventBus.log_line.emit("Mission accepted: %s" % String(mission.display_name))
	phase = Phase.OVERWORLD


func request_encounter(encounter: EncounterData, at_position: Vector3, facing: Vector3 = Vector3.FORWARD) -> void:
	combat_anchor_position = at_position
	combat_anchor_facing = facing.normalized() if facing.length() > 0.001 else Vector3.FORWARD
	phase = Phase.COMBAT
	EventBus.encounter_requested.emit(encounter, at_position)


func return_to_overworld() -> void:
	phase = Phase.OVERWORLD


func _on_combat_started(_encounter: EncounterData) -> void:
	phase = Phase.COMBAT


func _on_combat_ended(victory: bool) -> void:
	last_combat_victory = victory
	phase = Phase.DEBRIEF
	EventBus.log_line.emit("Combat ended — %s" % ("victory" if victory else "defeat"))


func _on_mission_started(_mission_id: StringName) -> void:
	pass


func _on_mission_completed(_mission_id: StringName, success: bool) -> void:
	if success:
		empire_standing += 1
	active_mission = null
	phase = Phase.OVERWORLD
