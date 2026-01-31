class_name Game extends Node2D

signal knobs_ready

@onready var _knob := %Knob

var knobs = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	knobs.append(_knob)

	knobs_ready.emit()
