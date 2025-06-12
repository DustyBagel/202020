extends Node
class_name CountdownTimer2

## A timer for counting down instead of up.

## This is a way more accurate version of the CountDownTimer Class.

## emitted once the time_limit provided by start is reached or exceded.
## It is only emitted once.
signal done

enum state {idle, paused, running, done}

## The time in seconds that this timer updates it's internal logic.
@export var refresh_rate: float = 0.5

## The current state of the timer.
var _state: state = state.idle: get = get_state
## The amount of time left on the timer. This value can be negative
## to keep track of the time passed since done was emitted.
var _time_left: float = 0.0: get = get_time
var _start_time: int = 0
var _end_time: int = 0


func _start() -> void:
	_start_time = Time.get_ticks_msec()
	_end_time = 0
	_internal_logic()

## Starts the countdown.
func start(time_limit: float = 0.0) -> bool:
	if time_limit <= 0.0:
		return false
	_time_left = time_limit
	_state = state.running
	_start()
	return true

## Pauses the countdown
func pause() -> bool:
	if (_state == state.running):
		_state = state.paused
		
		return true
	return false

## Unpauses the countdown.
func resume() -> bool:
	if _state == state.paused:
		_state = state.running
		_start()
		return true
	return false

## Resets the timer.
func reset() -> void:
	_time_left = 0.0
	_start_time = 0.0
	_end_time = 0.0
	_state = state.idle

## Returns the time that is left. This value can be negative.
func get_time() -> float:
	return _time_left

## Returns the current state.
func get_state() -> state:
	return _state

func _update() -> void:
	_end_time = Time.get_ticks_msec()
	_time_left -= (_end_time - _start_time) / 1000.0
	_start_time = _end_time

func _internal_logic() -> void:
	while true:
		if _state == state.running:
			_update()
			if not (_time_left > 0.0):
				_state = state.done
				done.emit()
		elif _state == state.done:
			_update()
		else:
			break
		await get_tree().create_timer(refresh_rate).timeout
