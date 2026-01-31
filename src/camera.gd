extends Camera2D

const MIN_ZOOM := 1.0
const MAX_ZOOM := 1.05

var _starting_position: Vector2
var _accumulated_distraction = 0.0

@onready var _game: Game = find_parent("Game")


func _ready() -> void:
	_starting_position = global_position


func _process(_delta: float) -> void:
	if _game and _game.distraction_manager and _game.distraction_manager.active_distraction:
		if _game.distraction_manager.active_distraction.distraction_value > 0.8:
			_accumulated_distraction = min(1.0, _accumulated_distraction + (0.3 * _delta))
		else:
			_accumulated_distraction = max(0.0, _accumulated_distraction - (0.3 * _delta))

		zoom = Vector2(
			MIN_ZOOM + (_accumulated_distraction * (MAX_ZOOM - MIN_ZOOM)),
			MIN_ZOOM + (_accumulated_distraction * (MAX_ZOOM - MIN_ZOOM))
		)

		var camera_move_direction := (
			_starting_position
			. direction_to(_game.distraction_manager.active_distraction.global_position)
			. normalized()
		)

		var position_offset: Vector2 = camera_move_direction * _accumulated_distraction * 20.0
		position = _starting_position + position_offset
