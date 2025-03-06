extends Control


# Components
@onready var timer: NegativeTimer = $NegativeTimer

const TIME_TABLE: Array = [ -1, -1, -1.0 ]
const audio_file: String = "res://sounds/beep.ogg"
@export var min_window_size: Vector2i = Vector2i(484, 144)
var file = preload(audio_file)
var _text: String = ""
var _time: float = 0.0


# Private
func _to_seconds(time_table: Array) -> float:
	var result: float = time_table[0] * 60 * 60
	result += time_table[1] * 60
	result += time_table[2]
	return result

func _divide(a: float, b: float) -> Array:
	var remainder: float = fmod(a, b)
	var answer: float = (a - remainder) / b
	return [answer, remainder]

func _to_HMS(seconds: float) -> Array:
	var ret: Array = TIME_TABLE.duplicate()
	var result: Array = _divide(seconds, 3600)
	ret[0] = result[0]
	var remainder = result[1]
	
	result = _divide(remainder, 60)
	ret[1] = result[0]
	ret[2] = result[1]
	return ret

func _time_to_string(time_data: Array, is_negative: bool = false) -> String:
	var result: String = ""
	var i: int = 0
	if is_negative:
		result += "-"
	for data in time_data:
		data = abs(data)
		if data < 10:
			result += "0"
		result += str(data)
		if i < 2: result += ":"
		i += 1
	return result

func _time_string(time: float) -> String:
	var result: String = ""
	var i: int = 0
	if time < 0.0:
		result += "-"
	for data in _to_HMS(time):
		data = abs(roundi(data))
		if data < 10:
			result += "0"
		result += str(data)
		if i < 2: result += ":"
		i += 1
	return result

func _str_to_seconds(text: String) -> float:
	print("text: ", text)
	var numbers: Array = Array()
	var parts: PackedStringArray = text.split(":", true, 3)
	if parts.size() != 3:
		return -1.0
	for part in parts:
		var number: int = abs(int(part))
		numbers.append(number)
	var ret: float = _to_seconds(numbers)
	print("numbers: ", numbers)
	print("ret = ", ret)
	return ret

# Callback Functions
func _logic() -> void:
	if timer.is_active():
		$%TimeDisplay.text = _time_string(timer.get_time())
	else:
		if _str_to_seconds($%TimeText.text) > 0.0:
			$%TimeDisplay.text = $%TimeText.text
		else:
			$%TimeDisplay.text = "00:00:00"

func _on_new_pressed() -> void:
	match $%New.text:
		"Reset":
			$%Audio.stop()
			timer.reset()
			if _str_to_seconds($%TimeText.text) > 0.0:
				$%TimeDisplay.text = $%TimeText.text
			else:
				$%TimeDisplay.text = "00:00:00"
			$%Paused.text = "Start"

func _on_play_pressed() -> void:
	match $%Paused.text:
		"Start":
			var time: float = _str_to_seconds($%TimeText.text)
			print("time is: ", time)
			if time <= 0.0:
				print_debug("[TimeText] time is: ", time)
				return
			var error: bool = not timer.start_count(time)
			if error:
				print_debug("[Timer] the timer didn't start. ", error)
				return
			$%Paused.text = "Pause"
			return
		"Resume":
			timer.resume()
			$%Paused.text = "Pause"
			return
		"Pause":
			timer.pause()
			$%Paused.text = "Resume"
			return
	print_debug("[Main] Pause button text is invalid.")
	$%Paused.text = "Start"

func _on_time_set(new_text: String) -> void:
	var seconds: float = _str_to_seconds(new_text)
	if seconds < 0.0:
		$%ErrorLine.text = "[color=Red]Invalid Time: " + new_text
	elif seconds == 0.0:
		$%TimeText.text = "00:00:00"
		$%TimeDisplay.text = "00:00:00"
		$%ErrorLine.text = "[color=dark_green]00:00:00 is valid."
	else:
		$%TimeDisplay.text = new_text
		$%ErrorLine.text = "[color=dark_green]" + new_text + " is valid."

func _ready() -> void:
	var window: Window = get_viewport().get_window()
	window.min_size = min_window_size
	$%Audio.stream = file
	$%Audio.stream.loop = true
	$%New.pressed.connect(_on_new_pressed)
	$%Paused.pressed.connect(_on_play_pressed)
	$%TimeText.text_submitted.connect(_on_time_set)
	timer.timeout.connect(_logic)
	timer.on_time_reached.connect(func():
		$%Audio.play()
	)
	timer.refresh_rate = 1.0
