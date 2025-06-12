extends Node
class_name StopWatch2

## A class for keeping track of the time that has passed.

## TODO: Write desctiption.

enum states {idle, paused, running}
## The time in seconds that the timer updates it's internal logic.
@export var percision: float = 0.5
## The time that has passed in seconds.
var time_passed: float = 0.0
var _state: states = states.idle
var _start_time: int = 0
var _end_time: int = 0

func reset() -> void:
	_state = states.idle
	time_passed = 0
	_start_time = 0
	_end_time = 0

func pause() -> bool:
	if _state == states.running:
		_state = states.paused
		return true
	return false

func resume() -> bool:
	if _state == states.paused:
		_state = states.running
		_start_time = Time.get_ticks_msec()
		_update()
		return true
	return false

func start() -> bool:
	if _state == states.idle:
		_start_time = Time.get_ticks_msec()
		_state = states.running
		_update()
		return true
	return false

func get_time() -> float:
	return time_passed

func get_state() -> states:
	return _state

func _update() -> void:
	while _state == states.running:
		_end_time = Time.get_ticks_msec()
		time_passed += (_end_time - _start_time) / 1000.0
		_start_time = _end_time
		await get_tree().create_timer(percision).timeout
	return
