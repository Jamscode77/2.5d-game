extends Node
## Global signals so overworld, combat, UI, and waves stay decoupled.

signal mission_started(mission_id: StringName)
signal mission_completed(mission_id: StringName, success: bool)

signal encounter_requested(encounter: EncounterData, world_position: Vector3)
signal combat_started(encounter: EncounterData)
signal combat_ended(victory: bool)

signal turn_started(unit: CombatUnit)
signal turn_ended(unit: CombatUnit)
signal wave_started(wave_index: int, total_waves: int)
signal unit_defeated(unit: CombatUnit)

signal log_line(text: String)
