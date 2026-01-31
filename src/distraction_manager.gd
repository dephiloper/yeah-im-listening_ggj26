class_name DistractionManager extends Node

var distraction_pool: Array = []

var active_distraction: Distraction = null
var _last_distraction_id: String = ""
var last_distraction_window: Array = []

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
	if not active_distraction:
		var no_duplicate_distraction_pool := distraction_pool.filter(
			func(dist): return dist.distraction_id != _last_distraction_id
		)

		var distraction: Distraction = no_duplicate_distraction_pool.pick_random().duplicate()
		if not distraction:
			printerr("error: no available distractions")
			return

		add_child(distraction)

		# wait for one frame so distraction is initialized
		await get_tree().process_frame

		# making the last distraction window available
		last_distraction_window = [distraction.min_value, distraction.max_value]

		# last_distraction_window
		active_distraction = distraction
		distraction_timer.start()


func _on_distraction_timer_timeout() -> void:
	if active_distraction:
		_last_distraction_id = active_distraction.distraction_id
		active_distraction.queue_free()
		active_distraction = null
