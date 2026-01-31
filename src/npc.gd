class_name Npc extends Node

@export var intense_distraction_threshold: float = 0.5
@export var time_spent_intense_distraction_threshold: float = 5

@onready var distraction_manager: DistractionManager = %DistractionManager

signal distraction_too_long

var _intense_distraction_duration: float

func _process(_delta: float) -> void:
    if distraction_manager.active_distraction:
        if distraction_manager.active_distraction.distraction_value >= intense_distraction_threshold:
            _intense_distraction_duration += _delta
            if _intense_distraction_duration >= time_spent_intense_distraction_threshold:
                print("distracted for too long!")
                distraction_too_long.emit()
                _intense_distraction_duration = 0
        else:
            _intense_distraction_duration = 0
    else:
        _intense_distraction_duration = 0