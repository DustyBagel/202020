extends Timer
class_name CountdownTimer

## A timer for counting down instead of up.

## I never know what to put into these discriptions.

## emitted once the time_limit provided by start is reached or exceded.
## It is only emitted once.
signal done

enum state {idle, paused, running, done}

## The time in seconds that this timer updates it's internal logic.
@export var percision: float = 1.0

## The current state of the timer.
var current_state: state = state.idle: set = _set_state
## The amount of time left on the timer. This value can be negative
## to keep track of the time passed since done was emitted.
var _time_left: float = 0.0

# Getters and Setters
func _set_state(new_state: state) -> bool:
	match new_state:
		state.idle:
			_time_left = 0.0
			current_state = new_state
			stop()
			return true
		state.paused:
			current_state = new_state
			paused = true
			return true
		state.running:
			current_state = new_state
			paused = false
			return true
		state.done:
			current_state = new_state
			emit_signal("done")
			return true
	return false

## Starts the countdown.
func start_timer(time_limit: float = 0.0) -> bool:
	if time_limit <= 0.0:
		return false
	if current_state != state.idle:
		reset()
	_time_left = time_limit
	start(percision)
	return _set_state(state.running)

## Pauses the countdown
func pause() -> bool:
	if (current_state == state.running or
			current_state == state.done):
		return _set_state(state.paused)
	return false

## Unpauses the countdown.
func resume() -> bool:
	if current_state == state.paused:
		return _set_state(state.running)
	return false

## Resets the timer.
func reset() -> bool:
	return _set_state(state.idle)

## Returns the time that is left. This value can be negative.
func get_time() -> float:
	return _time_left

func _update() -> void:
	if current_state == state.running:
		_time_left -= percision
		if _time_left <= 0.0:
			_set_state(state.done)
	elif current_state == state.done:
		_time_left -= percision

func _ready() -> void:
	timeout.connect(_update)
