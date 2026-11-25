extends Node
## Boots overworld + combat; routes encounter_requested into CombatSession.

@onready var overworld: OverworldController = $World/Overworld
@onready var combat: CombatSession = $World/CombatSession
@onready var log_ui: RichTextLabel = $UI/LogPanel/Log
@onready var banner: Label = $UI/Banner


func _ready() -> void:
	EventBus.log_line.connect(_on_log)
	EventBus.encounter_requested.connect(_on_encounter_requested)
	EventBus.combat_started.connect(_on_combat_started)
	EventBus.combat_ended.connect(_on_combat_ended)
	EventBus.wave_started.connect(_on_wave_started)
	banner.text = "VEIL OPS — overworld"
	_on_log("Imperial intelligence network online.")
	_on_log("Overworld (sprites): WASD walk | near a pin: E/LMB brief | RMB enter 3D combat")
	_on_log("Combat (AP): WASD · LMB shoot · R reload · Q Focus · F stim · C cover · RMB end")


func _on_encounter_requested(encounter: EncounterData, _world_position: Vector3) -> void:
	combat.start_encounter(encounter)


func _on_combat_started(_encounter: EncounterData) -> void:
	banner.text = "COMBAT — OTS turn-based"


func _on_combat_ended(victory: bool) -> void:
	banner.text = "VEIL OPS — %s" % ("VICTORY" if victory else "DEFEAT")


func _on_wave_started(wave_index: int, total_waves: int) -> void:
	banner.text = "WAVE %d / %d" % [wave_index + 1, total_waves]


func _on_log(text: String) -> void:
	log_ui.append_text(text + "\n")
