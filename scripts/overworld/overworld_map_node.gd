class_name OverworldMapNode
extends Node3D
## Clickable/selectable location on the overworld.

@export var display_name: String = "Sector"
@export var blurb: String = "Quiet."
@export var mission: MissionData
@export var encounter: EncounterData

@onready var combat_anchor: Marker3D = $CombatAnchor
