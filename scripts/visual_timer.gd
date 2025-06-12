extends Control

# The frount end for the CountdownTimer class.

signal on_paused
signal on_resumed
signal on_reset

const TIME_TABLE: PackedFloat64Array = [ -1.0, -1.0, -1.0 ]

#TODO: Use TimeDisplay node instead of this garbage.

# Components
@onready var time_text: LineEdit = $"%TimeText"
@onready var reset_button: Button = $"%Reset"
@onready var time_display: Label = $"%TimeDisplay"
@onready var start_button: Button = $"%Start"
@onready var error_line: RichTextLabel = $"%ErrorLine"
@onready var timer: CountdownTimer2 = $"%CountdownTimer"

# Helper functions:
func _to_seconds(time_table: Array) -> float:
	var result: float = time_table[0] * 60 * 60
	result += time_table[1] * 60
	result += time_table[2]
	return result

func _divide(a: float, b: float) -> Array:
	var remainder: float = fmod(a, b)
	var answer: float = (a - remainder) / b
	return [answer, remainder]

func _to_HMS(seconds: float) -> PackedFloat64Array:
	var ret: PackedFloat64Array = TIME_TABLE.duplicate()
	var result: Array = _divide(seconds, 3600)
	ret[0] = result[0]
	var remainder: float = result[1]
	
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
	for data: float in _to_HMS(time):
		var number: int = int(abs(floorf(data)))
		if number < 10:
			result += "0"
		result += str(number)
		if i < 2: result += ":"
		i += 1
	return result

func _str_to_seconds(text: String) -> float:
	#print("text: ", text)
	if text.length() != 8:
		#print("invalid length")
		return -1.0
	if _has_invalid_chars(text):
		#print("invalid_chars")
		return -1.0
	var numbers: Array = Array()
	var parts: PackedStringArray = text.split(":", true, 3)
	if parts.size() != 3:
		return -1.0
	for part: String in parts:
		var number: int = abs(ceili(int(part)))
		numbers.append(number)
	var ret: float = _to_seconds(numbers)
	#print("numbers: ", numbers)
	#print("ret = ", ret)
	return ret

func _has_invalid_chars(string: String) -> bool:
	var chars: PackedStringArray = string.split("", false)
	for s_char: String in chars:
		if s_char in "0123456789" or s_char == ":":
			continue
		else:
			return true
	return false

func _on_time_set(new_text: String) -> void:
	var seconds: float = _str_to_seconds(new_text)
	if seconds < 0.0:
		error_line.text = "[color=Red]Invalid Time: " + new_text
	elif seconds == 0.0:
		time_display.text = "00:00:00"
		error_line.text = "[color=yellow]Please set a time."
	else:
		time_display.text = new_text
		error_line.text = "[color=dark_green]" + new_text + " is valid."

func _update_time() -> void:
	time_display.text = _time_string(timer.get_time())

func start() -> bool:
	var time: float = _str_to_seconds(time_text.text)
	return timer.start(time)

func _reset_pressed() -> void:
	timer.reset()
	#pause_button.text = "Pause"
	start_button.text = "Start"
	time_text.editable = true
	reset_button.disabled = true
	time_display.modulate = Color.WHITE
	emit_signal("on_reset")

func _start_pressed() -> void:
	match timer.get_state():
		timer.state.paused:
			if timer.resume():
				start_button.text = "Pause"
				emit_signal("on_resumed")
			else:
				print("[VisualTimer] Failed to resume timer.")
		timer.state.running:
			if timer.pause():
				start_button.text = "Resume"
				emit_signal("on_paused")
			else:
				print("[VisualTimer] Failed to pause timer.")
		timer.state.idle:
			if start():
				start_button.text = "Pause"
				time_text.editable = false
				reset_button.disabled = false
			else:
				print("[VisualTimer] Failed to start timer.")

func text_flash_effect() -> void:
	while timer.get_state() == timer.state.done:
		if time_display.modulate != Color.RED:
			time_display.modulate = Color.RED
		else:
			time_display.modulate = Color.TRANSPARENT
		await get_tree().create_timer(0.5).timeout

func _on_focus_exited() -> void:
	_on_time_set(time_text.text)

func set_time(time: float = 0.0) -> void:
	var t: float = clampf(time, 0.0, 0xffffffff)
	time_text.text = _time_string(t)
	_on_time_set(time_text.text)

func init() -> void:
	reset_button.pressed.connect(_reset_pressed)
	start_button.pressed.connect(_start_pressed)
	timer.done.connect(text_flash_effect)
	time_text.text_changed.connect(_on_time_set)
	time_text.focus_exited.connect(_on_focus_exited)

func _ready() -> void:
	init()

func _process(_delta: float) -> void:
	_update_time()
