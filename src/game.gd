class_name Game extends Node2D

signal game_ready

@onready var _knob := %Knob
@onready var distraction_manager := %DistractionManager

var knobs: Array = []
var is_ready: bool = false


func _ready() -> void:
	knobs.append(_knob)

	is_ready = true
	game_ready.emit()
