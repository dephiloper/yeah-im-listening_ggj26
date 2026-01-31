extends Node2D

@onready var _main: Sprite2D = %Main


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var axis := Input.get_axis("knob_01_left", "knob_01_right")
	_main.rotation += axis * delta * 10
