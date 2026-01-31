extends Node2D

@onready var _knob := %Knob


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_knob.value_changed.connect(_on_knob_value_changed)


func _on_knob_value_changed(id: int, value: int) -> void:
	print("Knob %d value changed to: %d" % [id, value])
