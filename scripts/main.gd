extends Control


# Components
@onready var timers: GridContainer = $"%Timers"
@onready var add_timer_button: Button = $"%AddTimer"

@export var min_window_size: Vector2i = Vector2i(484, 144)
var visual_timer_scene: PackedScene = preload("res://scenes/visual_timer_custom.tscn")

func add_timer() -> void:
	var timer: Panel = visual_timer_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	timer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	timers.add_child(timer)

func remove_timer(timer: Panel) -> void:
	timers.remove_child(timer)

func _ready() -> void:
	var window: Window = get_viewport().get_window()
	window.min_size = min_window_size
	add_timer_button.pressed.connect(add_timer)
	timers.size.x = timers.get_child(0).size.x * 2
	timers.size.y = timers.get_child(0).size.y
	timers.get_child(0).set_time(1220)
	timers.get_child(1).set_time(3720)
	var options := timers.get_child(1).options as OptionButton
	timers.get_child(1).options.select(1)
	timers.get_child(1).decode_selected_option(1)
