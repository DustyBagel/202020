extends Control

const audio_file: String = "res://sounds/beep.ogg"
@export var min_window_size: Vector2i = Vector2i(484, 144)
var file = preload(audio_file)

var time: float = 0.0
var limiter: float = 0.5

func to_seconds(time_table: Array) -> float:
	var result: float = 0.0
	result = time_table[0] * 60 * 60
	result += time_table[1] * 60
	result += time_table[2]
	return result

func devide(a: float, b: float) -> Array:
	var remainder: float = fmod(a, b)
	var answer: float = (a - remainder) / b
	return [answer, remainder]

func to_HMS(seconds: float) -> Array:
	var result = devide(seconds, 3600)
	var h = result[0]
	var remainder = result[1]
	
	result = devide(remainder, 60)
	var m = result[0]
	var s = result[1]
	
	return [h, m, s]

func time_to_string(time_array: Array) -> String:
	var result: String = ""
	for value in time_array:
		var value_int: int = int(value)
		var new_str: String = ""
		if value_int < 10: new_str = "0"+ str(value_int)
		else: new_str = str(value_int)
		result += new_str + ":"
	return result.trim_suffix(":")

func new_timer() -> void:
	if $Timer.time_left > 0:
		$%Audio.stream_paused = true
	$Timer.stop()
	var new_timer_time: float = to_seconds([$%Hour.value, $%Minute.value, $%Secound.value])
	if new_timer_time > 0:
		$Timer.start(new_timer_time)

func pause() -> void:
	if $%Audio.stream_paused:
		if $Timer.is_paused():
			$Timer.paused = false
			$%Paused.text = "Start"
		else:
			$Timer.paused = true
			$%Paused.text = "Stop"
	else:
		$Audio.stream_paused = true

func _ready() -> void:
	var window = get_viewport().get_window()
	window.min_size = min_window_size
	$%Audio.stream = file
	$%Audio.stream.loop = true
	$%New.pressed.connect(new_timer)
	$%Paused.pressed.connect(pause)
	$Timer.timeout.connect(func():
		$%Audio.play()
	)

func _process(delta) -> void:
	if time >= limiter:
		if $Timer.time_left > 0 or $%Audio.playing:
			var time_left = to_HMS($Timer.time_left)
			$%Label.text = time_to_string(time_left)
		else:
			$%Label.text = time_to_string([$%Hour.value, $%Minute.value, $%Secound.value])
		time -= limiter
	time += delta
