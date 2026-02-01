class_name Npc extends Node

@export var intense_distraction_threshold: float = 0.5
@export var time_spent_distraction_threshold: float = 4
@export var time_spent_no_distraction_threshold: float = 4
@export var distraction_level_angry_threshold: float = 2

@export var emote: Sprite2D
@export var happy_emote: Texture2D
@export var normal_emote: Texture2D
@export var angry_emote: Texture2D

@onready var distraction_manager: DistractionManager = %DistractionManager

var _intense_distraction_duration: float
var _low_distraction_duration: float
var _emote_tween: Tween
var distraction_level: int = 0

signal distraction_too_long(level: int)
signal distraction_stopped

func _process(delta: float) -> void:
	if distraction_manager.active_distraction:
		if distraction_manager.active_distraction.distraction_value >= intense_distraction_threshold:
			_low_distraction_duration = 0
			_intense_distraction_duration += delta
			
			if _intense_distraction_duration >= time_spent_distraction_threshold:
				distraction_level += 1
				if emote.texture == happy_emote:
					_set_emote(normal_emote)
				elif distraction_level >= distraction_level_angry_threshold:
					distraction_too_long.emit(distraction_level - distraction_level_angry_threshold)
					if emote.texture != angry_emote:
						_set_emote(angry_emote)

				_intense_distraction_duration = 0
		else:
			_increment_low_distraction(delta)

func _set_emote(new_emote: Texture2D) -> void:
	emote.texture = new_emote
	emote.modulate.a = 1.0
	if _emote_tween:
		_emote_tween.kill()
	_emote_tween = create_tween()
	_emote_tween.tween_interval(2.0)
	_emote_tween.tween_property(emote, "modulate:a", 0.0, 0.0)

func _increment_low_distraction(delta: float) -> void:
	_intense_distraction_duration = 0
	_low_distraction_duration += delta
	if _low_distraction_duration >= time_spent_no_distraction_threshold:
		distraction_stopped.emit()

		if emote.texture == angry_emote:
			_set_emote(normal_emote)
		elif emote.texture == normal_emote or emote.texture == null:
			_set_emote(happy_emote)

		distraction_level -= 1
		if distraction_level < 0:
			distraction_level = 0
		_low_distraction_duration = 0

func _set_distraction_level(value: int) -> void:
	distraction_level = value
	Global.distraction_level = distraction_level