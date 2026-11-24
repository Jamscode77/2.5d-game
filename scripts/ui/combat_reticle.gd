extends Control
## Center-screen placeholder reticle. Turns hot when an enemy is under the aim ray.

@onready var _crosshair: Control = $Crosshair
@onready var _hint: Label = $Hint

var _hot: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	set_hot(false)


func show_reticle() -> void:
	visible = true


func hide_reticle() -> void:
	visible = false
	set_hot(false)


func set_hot(hot: bool) -> void:
	_hot = hot
	var color := Color(1.0, 0.35, 0.25, 0.95) if hot else Color(1.0, 1.0, 1.0, 0.9)
	for child in _crosshair.get_children():
		if child is ColorRect:
			(child as ColorRect).color = color
	_hint.visible = hot
	if hot:
		_hint.text = "TARGET"
