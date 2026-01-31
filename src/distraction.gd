class_name Distraction extends Sprite2D

@export var distraction_id: String
@export var min_value: int = 90
@export var max_value: int = 270

var distraction_value: float = 0.0

var _game: Game
var _center_value: float


func _ready() -> void:
	_game = find_parent("Game")
	_game.game_ready.connect(_on_knobs_ready)
	_center_value = (max_value + min_value) / 2.0

	_on_knobs_ready()


func _on_knobs_ready() -> void:
	if not _game.is_ready:
		return

	for knob: Knob in _game.knobs:
		knob.value_changed.connect(_on_knob_value_changed)


func _on_knob_value_changed(id: int, value: int) -> void:
	if id == 0:
		var value_range := max_value - min_value
		var dist: float = abs(float(value - _center_value))

		var normalized_distance: float = min(dist / value_range, 1.0)

		# if the normalized distance is smaller than 0.2 you hit a sweet spot
		if normalized_distance < 0.3:
			normalized_distance = 0.0

		distraction_value = normalized_distance
		modulate.a = distraction_value
