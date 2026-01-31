extends Node2D

@export var characters_per_second: float = 30.0

@onready var rich_text_label: RichTextLabel = %RichTextLabel

var tween: Tween

func _ready() -> void:
	var file = FileAccess.open("res://dialogues/test.txt", FileAccess.READ)
	var text = file.get_as_text()
	scroll_text(text)

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_SPACE):
		if tween.is_running():
			tween.stop()
			rich_text_label.visible_characters = rich_text_label.get_total_character_count()

func scroll_text(text: String) -> void:
	if tween:
		tween.kill()

	rich_text_label.text = "[color=black]%s[/color]" % text
	rich_text_label.visible_characters = 0

	var total_characters = rich_text_label.get_total_character_count()
	var duration = total_characters / characters_per_second

	tween = create_tween()
	tween.tween_property(rich_text_label, "visible_characters", total_characters, duration)


func skip_typewriter() -> void:
	if tween and tween.is_running():
		tween.kill()
		rich_text_label.visible_characters = -1
