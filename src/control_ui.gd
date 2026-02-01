extends Label

@export var input_key: String
var _knob_direction: int = 0
var _timer: Timer


func _ready():
	if input_key == "knob_01_left":
		_knob_direction = 127

	if input_key == "knob_01_right":
		_knob_direction = 1

	_timer = Timer.new()
	add_child(_timer)
	_timer.timeout.connect(_on_timer_timeout)
	_timer.wait_time = 0.2
	_timer.one_shot = true


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed(input_key):
			modulate = Color(1, 1, 0, 1)
		elif event.is_action_released(input_key):
			modulate = Color(1, 1, 1, 1)

	if event is InputEventMIDI:
		_process_midi_info(event)


func _process_midi_info(midi_event: InputEventMIDI):
	if midi_event.controller_number > 15 and midi_event.controller_number < 24:
		if midi_event.controller_value == _knob_direction:
			modulate = Color(1, 1, 0, 1)
			_timer.stop()
			_timer.start()


func _on_timer_timeout():
	modulate = Color(1, 1, 1, 1)
