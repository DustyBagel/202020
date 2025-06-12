extends Label
class_name TimeDisplay

## A simple Node for displaying a time value in HH:MM:SS Format.

## TODO: Write desctiption......

const ZERO: String = "00:00:00"
const SEPERATOR: String = ":"
@export var allow_negative_values: bool = true
var time_str: String = ZERO: set = _set_time_str
## The integer value that time_str represents.
var time_value: float = 0.0

func _to_seconds(hours: float = 0.0, minutes: float = 0.0, seconds: float = 0.0) -> float:
	var ret: float = hours * 3600
	ret += minutes * 60
	ret += seconds
	return ret

func _time_to_string(seconds: float) -> String:
	var ret: String = ""
	var parts: Dictionary[String, float] = {
		hours = 0.0,
		minutes = 0.0,
		seconds = 0.0,
	}
	
	parts.hours = (seconds - (int(seconds) % 3600)) / 3600.0
	seconds -= parts.hours * 3600.0
	parts.minutes = (seconds - (int(seconds) % 60)) / 60.0
	seconds -= parts.minutes * 60.0
	parts.seconds = seconds
	
	if seconds < 0.0:
		ret += "-"
	
	var i: int = 0
	for part: float in parts.values():
		var value: int = abs(roundi(part))
		if value < 10:
			ret += "0"
		ret += str(value)
		if i < 2:
			ret += SEPERATOR
			i += 1
	
	return ret

func _set_time_str(string: String) -> bool:
	var expected_length: int = 8
	if string.begins_with("-"):
		if allow_negative_values:
			expected_length = 9
		else:
			return false
		
	if string.length() != expected_length or string.countn(SEPERATOR) != 2:
		return false
	var parts: PackedStringArray = string.split(SEPERATOR, false, 2)
	var seconds: float = _to_seconds(float(parts[0]), float(parts[1]), float(parts[2]))
	time_value = seconds
	text = string
	return true

func set_time(seconds: float, forch: bool = false) -> bool:
	if not allow_negative_values and seconds < 0.0:
		return false
	if forch:
		text = _time_to_string(seconds)
		time_value = seconds
	else:
		time_str = _time_to_string(seconds)
	return true

func get_time() -> float:
	return time_value

func _init() -> void:
	text = ZERO
