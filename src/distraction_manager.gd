class_name DistractionManager extends Node

var distraction_pool: Array = []

var _active_distraction: Distraction = null
var _last_distraction_id: String = ""

@onready var distraction_timer: Timer = %Timer


func _ready() -> void:
	var children := get_children()

	for child in children:
		if child is Distraction:
			distraction_pool.append(child.duplicate())

	for i in len(children):
		var child := children[i]
		if child is Distraction:
			child.queue_free()

	distraction_timer.timeout.connect(_on_distraction_timer_timeout)


func _process(_delta: float) -> void:
	if not _active_distraction:
		var no_duplicate_distraction_pool := distraction_pool.filter(
			func(dist): return dist.distraction_id != _last_distraction_id
		)

		var distraction: Distraction = no_duplicate_distraction_pool.pick_random().duplicate()
		add_child(distraction)
		_active_distraction = distraction
		distraction_timer.start()
		print("new distraction started '%s'" % distraction.distraction_id)


func _on_distraction_timer_timeout() -> void:
	if _active_distraction:
		_last_distraction_id = _active_distraction.distraction_id
		print("last distraction id:", _last_distraction_id)
		_active_distraction.queue_free()
		_active_distraction = null
