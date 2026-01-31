class_name VisualDistraction extends Sprite2D

@export var min_value: int = 90
@export var max_value: int = 270

var _game: Game
@onready var center_value: float = (max_value + min_value) / 2.0


func _ready() -> void:
	_game = find_parent("Game")
	_game.knobs_ready.connect(_on_knobs_ready)


func _on_knobs_ready() -> void:
	for knob: Knob in _game.knobs:
		knob.value_changed.connect(_on_knob_value_changed)


func _on_knob_value_changed(id: int, value: int) -> void:
	if id == 0:
		var value_range := max_value - min_value
		var dist: float = abs(float(value - center_value))

		var normalized_distance := dist / value_range

		modulate.a = normalized_distance
