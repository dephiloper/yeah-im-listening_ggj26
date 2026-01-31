class_name Dialogue extends Node2D

@export var characters_per_second: float = 30.0
@export var delay_between_lines: float = 3.0

@export var max_shake_rate: int = 50
@export var max_shake_offset: int = 10

@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var distraction_manager: DistractionManager = %DistractionManager

var tween: Tween
var main_lines: PackedStringArray
var current_line_index: int = 0

var distracted_lines: Array[PackedStringArray]
var distracted_level: int = 0
var current_distracted_text: String = ""

func _ready() -> void:
	main_lines = load_dialogue_lines()
	distracted_lines = load_distracted_lines()
	current_line_index = 0
	scroll_text(main_lines[current_line_index])

func _process(_delta: float) -> void:
	rich_text_label.text = get_text()

	if Input.is_key_pressed(KEY_L):
		_on_npc_distraction_too_long()

func get_text() -> String:
	var distraction_intesity: float = 0
	if distraction_manager.active_distraction:
		distraction_intesity = distraction_manager.active_distraction.distraction_value

	var shake_rate = max_shake_rate * distraction_intesity
	var shake_offset_lvl = max_shake_offset * distraction_intesity
	var active_text = main_lines[current_line_index]
	if current_distracted_text != "":
		active_text = current_distracted_text

	return "[shake rate=%s level=%s connected=1]%s[/shake]" % [shake_rate, shake_offset_lvl, active_text]

func get_distracted_line() -> String:
	var lines: PackedStringArray
	if (distracted_level < distracted_lines.size()):
		lines = distracted_lines[distracted_level]
	else:
		lines = distracted_lines[distracted_lines.size() - 1]

	var line_index = randf_range(0, lines.size())
	return lines[line_index]

func load_dialogue_lines() -> PackedStringArray:
	var file = FileAccess.open("res://dialogues/test.txt", FileAccess.READ)
	var text = file.get_as_text()
	var split_lines = text.split("\n")
	var non_empty_lines: PackedStringArray = []
	for line in split_lines:
		if line.strip_edges() != "":
			non_empty_lines.append(line)
	return non_empty_lines

func load_distracted_lines() -> Array[PackedStringArray]:
	var file = FileAccess.open("res://dialogues/annoyed.txt", FileAccess.READ)
	var text = file.get_as_text()
	var split_lines = text.split("\n")
	var line_block: PackedStringArray = []
	var lines: Array[PackedStringArray] = []
	for line in split_lines:
		if line.strip_edges() != "":
			line_block.append(line)
		else:
			lines.append(line_block)
			line_block = []
	return lines

func scroll_text(text: String) -> void:
	if tween:
		tween.kill()

	rich_text_label.text = text
	rich_text_label.visible_characters = 0

	var total_characters = rich_text_label.get_total_character_count()
	var duration = total_characters / characters_per_second

	tween = create_tween()
	tween.tween_property(rich_text_label, "visible_characters", total_characters, duration)
	tween.tween_callback(scroll_next_line).set_delay(delay_between_lines)

func scroll_next_line() -> void:
	if current_distracted_text != "":
		current_distracted_text = ""
	else:
		current_line_index += 1

	if current_line_index >= main_lines.size():
		current_line_index = main_lines.size() - 1
		return

	scroll_text(main_lines[current_line_index])

func _on_npc_distraction_too_long() -> void:
	if current_distracted_text == "":
		current_distracted_text = get_distracted_line()
		scroll_text(current_distracted_text)
