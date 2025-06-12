extends Control

# Componenets
@onready var start_label: TimeDisplay = $VBoxContainer/HBoxContainer/StartTime
@onready var end_label: TimeDisplay = $VBoxContainer/HBoxContainer/EndTime
var time_taken: float = 0.0
@onready var timer: VisualTimerCustom = $VBoxContainer/VisualTimer

func run_test() -> void:
	start_label.set_time(Time.get_unix_time_from_system(), true)

func _on_done() -> void:
	end_label.set_time(Time.get_unix_time_from_system(), true)
	time_taken = end_label.time_value - start_label.time_value
	print("V: ", time_taken)
	print("Time Taken: ", start_label._time_to_string(time_taken))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/VisualTimer.timer.done.connect(_on_done)
	$VBoxContainer/VisualTimer/MarginContainer/VBoxContainer/HBoxContainer2/Start.pressed.connect(run_test)
