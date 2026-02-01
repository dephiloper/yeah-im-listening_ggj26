class_name Knob extends Control

signal value_changed(id: int, value: int)

@export var id: int = 0
@onready var _main: TextureRect = %Main
@onready var _audio_player: AudioStreamPlayer = %AudioStreamPlayer

var _previous_rotation_value: float = 0.0
var _value_changed_changed_counter = 0

var _midi_value: float = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var axis := Input.get_axis("knob_01_left", "knob_01_right")
	_main.rotation += (_midi_value + axis) * delta * 2.5
	_midi_value = 0

	var rotation_value: int = int(_main.rotation_degrees) % 360

	if _main.rotation_degrees < 0:
		rotation_value += 360
	rotation_value = abs(rotation_value)

	# normalize the rotation value to be between 0 and 360
	value_changed.emit(id, rotation_value)

	if _previous_rotation_value != _main.rotation_degrees:
		_value_changed_changed_counter += 1

	if _value_changed_changed_counter >= 15:
		_audio_player.play()
		_value_changed_changed_counter = 0

	_previous_rotation_value = _main.rotation_degrees


func _ready():
	OS.open_midi_inputs()
	print(OS.get_connected_midi_inputs())


func _input(input_event):
	if input_event is InputEventMIDI:
		_print_midi_info(input_event)


func _print_midi_info(midi_event):
	if midi_event.controller_number > 15 and midi_event.controller_number < 24:
		print("Controller value: ", midi_event.controller_value)

		if midi_event.controller_value == 1:
			_midi_value += 1
		elif midi_event.controller_value == 127:
			_midi_value -= 1
