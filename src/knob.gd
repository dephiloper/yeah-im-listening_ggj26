class_name Knob extends Node2D

signal value_changed(id: int, value: int)

@export var id: int = 0
@onready var _main: Sprite2D = %Main


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var axis := Input.get_axis("knob_01_left", "knob_01_right")
	_main.rotation += axis * delta * 10

	var rotation_value: int = int(_main.rotation_degrees) % 360

	if _main.rotation_degrees < 0:
		rotation_value += 360
	rotation_value = abs(rotation_value)

	# normalize the rotation value to be between 0 and 360
	value_changed.emit(id, rotation_value)
