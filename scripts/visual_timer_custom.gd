extends "res://scripts/visual_timer.gd"
class_name VisualTimerCustom

@onready var audio: AudioStreamPlayer = $"%Audio"
@onready var visual_timer := self
@onready var options: OptionButton = %Options
@onready var delete: Button = $%Delete

var output: Array = []

var timeout_action_f: Callable = get_shutdown_cmd()
#TODO: Make this changeable.
const audio_file: String = "res://sounds/beep.ogg"
const file := preload(audio_file)

const test_mode: bool = false

var option_id_table: PackedStringArray = [
	"none",
	"shutdown",
	"test",
]

func _null() -> void:
	return

func get_shutdown_cmd() -> Callable:
	if test_mode:
		return OS.execute.bind("echo", ["Timer End Action Completed."], output)
	match OS.get_name():
		"Linux":
			return OS.execute.bind("poweroff", [])
		_:
			push_warning("Unspported OS: ", OS.get_name())
			return _null

func decode_selected_option(id: int) -> void:
	if test_mode:
		return
	if id > option_id_table.size() - 1:
		return
	match id:
		1:
			visual_timer.timer.done.connect(timeout_action_f)
		_:
			if visual_timer.timer.done.is_connected(timeout_action_f):
				visual_timer.timer.done.disconnect(timeout_action_f)

func _remove_timer() -> void:
	queue_free()

func _ready() -> void:
	visual_timer.init()
	audio.stream = file
	audio.stream.loop = true
	visual_timer.on_reset.connect(audio.stop)
	visual_timer.timer.done.connect(audio.play)
	options.item_selected.connect(decode_selected_option)
	delete.pressed.connect(_remove_timer)
	if test_mode:
		options.add_item(option_id_table[2], 2)
		options.select(2)
		timer.done.connect(timeout_action_f)

func _physics_process(_delta: float) -> void:
	if output.is_empty():
		return
	for line: String in output:
		print(line)
	output.clear()
