class_name Distraction extends Sprite2D

@export var distraction_sound: AudioStream

@export var distraction_id: String

const DISTRACTION_WINDOW_SIZE := 90
const MARGIN := 50

var min_value: int = 90
var max_value: int = 270

@onready var distraction_sound_player: AudioStreamPlayer2D = %AudioStreamPlayer2D

var distraction_value: float = 0.0

var _game: Game
var _center_value: float
var _target_position: Vector2 = Vector2.ZERO
var _velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	_game = find_parent("Game")
	_game.game_ready.connect(_on_knobs_ready)

	var new_distraction_window := find_new_distraction_window()
	min_value = new_distraction_window[0]
	max_value = new_distraction_window[1]

	_center_value = (max_value + min_value) / 2.0

	_on_knobs_ready()

	if distraction_sound:
		distraction_sound_player.stream = distraction_sound
		distraction_sound_player.play()

	print(
		"new distraction '%s' with range between %d and %d" % [distraction_id, min_value, max_value]
	)


func _process(delta: float) -> void:
	if _velocity == Vector2.ZERO:
		# create a circle around the distractions global position with a radius of 100 units and get a random point on the circle
		# if the random point is outside of the screen try, again
		var circle_radius := 50.0
		var circle_center := global_position
		var random_angle := randf() * PI * 2.0
		var random_point := (
			circle_center
			+ Vector2(circle_radius * cos(random_angle), circle_radius * sin(random_angle))
		)
		if (
			random_point.x < MARGIN
			or random_point.x > get_viewport().size.x - MARGIN
			or random_point.y < MARGIN
			or random_point.y > get_viewport().size.y - MARGIN
		):
			_velocity = Vector2.ZERO
		else:
			_target_position = random_point
			_velocity = position.direction_to(_target_position) * 32

		return

	position += _velocity * delta

	if position.distance_to(_target_position) < 10:
		_target_position = Vector2.ZERO
		_velocity = Vector2.ZERO


func find_new_distraction_window() -> Array:
	var last_min: float = (
		_game.distraction_manager.last_distraction_window[0]
		if _game.distraction_manager and _game.distraction_manager.last_distraction_window
		else 0
	)

	var searching := true

	var new_max := 0.0
	var new_min := 0.0

	# its enough to check only last_min here
	# if the minimums are too close to each other lets find another minimum
	while searching:
		new_min = randi() % 271

		if abs(last_min - new_min) > DISTRACTION_WINDOW_SIZE:
			searching = false

	new_max = new_min + DISTRACTION_WINDOW_SIZE
	return [new_min, new_max]


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

		# volume: disctraction value 0 = -80db, value 1 = 0db
		distraction_sound_player.volume_db = -80.0 + (normalized_distance * 80.0)
