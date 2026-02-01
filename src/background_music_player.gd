extends AudioStreamPlayer

const CUTOFF_DEFAULT := 500
const CUTOFF_APPLIED := 150

var _accumulated_distraction = 0.0

@onready var _game: Game = find_parent("Game")
@onready var _low_pass: AudioEffectLowPassFilter = AudioServer.get_bus_effect(2, 0)


func _process(delta: float) -> void:
	if _game and _game.distraction_manager and _game.distraction_manager.active_distraction:
		if _game.distraction_manager.active_distraction.distraction_value > 0.8:
			_accumulated_distraction = min(1.0, _accumulated_distraction + (0.3 * delta))
		else:
			_accumulated_distraction = max(0.0, _accumulated_distraction - (0.3 * delta))

		# if the accumulated distraction is between 0 and 0.5 the cutoff default should be 2000
		# if it's higher than 0.5 we apply the cutoff by reducing the cutoff frequency
		if _accumulated_distraction > 0.5:
			_low_pass.cutoff_hz = lerp(
				CUTOFF_DEFAULT, CUTOFF_APPLIED, (_accumulated_distraction - 0.5) * 2
			)
		else:
			_low_pass.cutoff_hz = CUTOFF_DEFAULT
