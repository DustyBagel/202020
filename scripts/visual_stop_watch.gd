extends HBoxContainer
class_name VisualStopWatch

## ???

# Components
var stop_watch: StopWatch2
var time_display: TimeDisplay
var reset: Button
var start: Button

func _update_time() -> void:
	time_display.set_time(stop_watch.get_time())
	await get_tree().create_timer(0.5).timeout
	_update_time()

func _on_reset_pressed() -> void:
	var state: StopWatch2.states = stop_watch.get_state()
	if state != stop_watch.states.idle:
		stop_watch.reset()
		reset.disabled = true
		start.text = "Start"

func _on_start_pressed() -> void:
	var state: StopWatch2.states = stop_watch.get_state()
	if state == stop_watch.states.idle:
		if stop_watch.start():
			start.text = "Pause"
			reset.disabled = false
	elif state == stop_watch.states.running:
		if stop_watch.pause():
			start.text = "Resume"
	else:
		if stop_watch.resume():
			start.text = "Pause"

func initalize_components() -> void:
	stop_watch = $StopWatch2
	time_display = $TimeDisplay
	reset = $HBoxContainer/Reset
	start = $HBoxContainer/Start

func _ready() -> void:
	initalize_components()
	reset.pressed.connect(_on_reset_pressed)
	start.pressed.connect(_on_start_pressed)
	_update_time()
