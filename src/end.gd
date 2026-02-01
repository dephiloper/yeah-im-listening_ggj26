extends Node2D

@export var happy_ending: String
@export var sad_ending: String
@export var text: Label

func _ready() -> void:
	if Global.correct_answers_count > Global.incorrect_answers_count:
		text.text = happy_ending
	else:
		text.text = sad_ending
