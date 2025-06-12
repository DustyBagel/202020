extends Timer
class_name StopWatch

## A class for keeping track of the time that has passed.

## TODO: Write desctiption.

enum state {idle, paused, running}
## The time in seconds that the timer updates it's internal logic.
@export var persicion: float = 1.0
var _time_passed: float = 0.0
var _current_state: state = state.idle

func reset() -> void:
	_current_state = state.idle
	_time_passed = 0.0
	stop()

func pause() -> bool:
	if _current_state != state.running:
		return false
	_current_state = state.paused
	paused = false
	return true

func resume() -> bool:
	if _current_state != state.paused:
		return false
	_current_state = state.running
	paused = false
	return true

func start_timer() -> bool:
	if _current_state != state.idle:
		return false
	_current_state = state.running
	start(persicion)
	return true

func get_time() -> float:
	return _time_passed

func get_state() -> state:
	return _current_state

func _update() -> void:
	if _current_state == state.running:
		_time_passed += persicion

func _ready() -> void:
	timeout.connect(_update)
