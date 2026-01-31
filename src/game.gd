class_name Game extends Node2D

signal game_ready

@onready var _knob := %Knob
@onready var _distraction_manager: DistractionManager = %DistractionManager

var knobs: Array = []
var is_ready: bool = false


func _ready() -> void:
	knobs.append(_knob)

	is_ready = true
	game_ready.emit()


func _process(_delta: float) -> void:
	if _distraction_manager and _distraction_manager.active_distraction:
		print("distraction_value %s" % _distraction_manager.active_distraction.distraction_value)
