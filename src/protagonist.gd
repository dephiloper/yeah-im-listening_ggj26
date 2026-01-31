class_name Protagonist extends Node

@export var start_distract_duration: float = 1
@export var long_distract_duration: float = 3
@export var intense_distraction_threshold: float = 0.5
@export var start_distract_delay: float = 1

@export var sprite: Sprite2D
@export var normal: Texture2D
@export var start_distracted: Texture2D
@export var long_distracted: Texture2D

@onready var distraction_manager: DistractionManager = %DistractionManager

var _tween: Tween
var _is_start_distracted: bool

func _on_distraction_manager_on_distraction_start() -> void:
	_is_start_distracted = true
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_callback(func(): sprite.texture = start_distracted).set_delay(start_distract_delay)
	_tween.tween_interval(start_distract_duration)
	_tween.tween_callback(func(): _is_start_distracted = false)
	_tween.tween_property(sprite, "texture", long_distracted, 0.0)


func _process(_delta):
	if !_is_start_distracted && distraction_manager.active_distraction:
		if distraction_manager.active_distraction.distraction_value < intense_distraction_threshold:
			sprite.texture = normal
			_tween.kill()
