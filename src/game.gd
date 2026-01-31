class_name Game extends Node2D

signal game_ready

@onready var _knob := %Knob
@onready var _distraction_container: Node = %Distractions

var knobs: Array = []
var visual_distractions: Array = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	knobs.append(_knob)

	for child in _distraction_container.get_children():
		if child is VisualDistraction:
			visual_distractions.append(child)

	game_ready.emit()
