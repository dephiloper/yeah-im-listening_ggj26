extends Node2D

@export var characters_per_second: float = 30.0
@export var delay_between_lines: float = 3.0

@onready var rich_text_label: RichTextLabel = %RichTextLabel

var tween: Tween
var lines: PackedStringArray
var current_line_index: int = 0

func _ready() -> void:
	lines = get_dialogue_lines()
	current_line_index = 0
	scroll_next_line()

func get_dialogue_lines() -> PackedStringArray:
	var file = FileAccess.open("res://dialogues/test.txt", FileAccess.READ)
	var text = file.get_as_text()
	lines = text.split("\n")
	var non_empty_lines: PackedStringArray = []
	for line in lines:
		if line.strip_edges() != "":
			non_empty_lines.append(line)
	return non_empty_lines

func scroll_next_line() -> void:
	if current_line_index >= lines.size():
		return

	scroll_text(lines[current_line_index])
	current_line_index += 1

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
