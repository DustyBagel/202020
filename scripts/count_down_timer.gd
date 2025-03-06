extends Timer
class_name NegativeTimer # Naming stuff isn't easy.

## A Timer derived class that can go into the nagatives.
##
## I need to write a discription but the title seems perfict other than my spelling.

## This class's eqivalent to Timer's 'timeout' signal
signal on_time_reached

## Weather or not on_time_reached has been emited.
var _done: bool = false
## The time that has passed sense the start() was called.
## Note: Time can be less than zero.
var _time: float = 0.0: get = get_time
## The timer's current state.
## Note: When the timer is paused this is still true.
var _is_active: bool = false: get = is_active
## The time in secounds that this timer update's it's own logic.
## lower values are more precise but more resource intensive. The
## invers is also true.
@export var refresh_rate: float = 1.0: set = _set_refresh


# Setters and Getters
func _set_refresh(rate: float) -> bool:
	if rate > 0.0:
		refresh_rate = rate
		return true
	else:
		return false

## Returns the time. Time is the amount of time left.
## Note: Time can be less than zero.
func get_time() -> float:
	return _time

func is_active() -> bool:
	return _is_active

# Methods
## This class's equivalent to start(). We assume that if you want to reset
## the timer then you will just call this function again.
func start_count(time: float) -> bool:
	if time <= 0.0:
		return false
	_time = time
	wait_time = refresh_rate
	_is_active = true
	start(wait_time)
	return true

## Pauses the stopwatch. 
## Note: Pausing is not emidiat
func pause() -> void:
	if _is_active:
		# Wait for the timer to finish it's next cycle.
		# This is to ensure the time is correct.
		await timeout
		timeout.disconnect(_on_timeout)

func resume() -> void:
	if _is_active:
		timeout.connect(_on_timeout)

## Resets the timer to it's inital state so start_count() can be called again.
func reset() -> void:
	stop()
	_is_active = false
	_done = false
	_time = 0.0

# Callback Functions
func _on_timeout() -> void:
	if _is_active:
		start(wait_time)
		_time -= wait_time
		if _time <= 0.0 and not _done:
			_done = true
			emit_signal("on_time_reached")
		

func _ready() -> void:
	timeout.connect(_on_timeout)
