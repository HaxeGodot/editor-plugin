tool
extends Control

onready var button := $VBoxContainer/Button
onready var text_log := $VBoxContainer/TextLog

var base:Control
var icon := 0
var icons := []
var mutex := Mutex.new()
var output := []
var time := 0.0
var thread:Thread = null

func setup(base:Control) -> void:
	self.base = base
	
	for i in range(8):
		icons.append(base.get_icon("Progress%s"%(i + 1), "EditorIcons"))
	
func _ready() -> void:
	button.connect("button_down", self, "build_haxe_project")

func build_haxe_project() -> void:
	if thread != null:
		return
	
	thread = Thread.new()
	
	button.icon = icons[0]
	button.text = "Building Haxe Project ..."
	icon = 0
	text_log.text = ""
	time = 0.0
	output = []
	
	thread.start(self, "run_thread")

func _process(delta:float) -> void:
	if thread != null:
		update_log()
		time += delta
		if time > 0.1:
			time = 0
			icon = (icon + 1) % 8
			button.icon = icons[icon]

func run_thread(userdata) -> void:
	var ret := OS.execute("haxe", ["build.hxml"], true, output, true)
	update_log()
	button.icon = base.get_icon("StatusSuccess" if ret == 0 else "StatusError", "EditorIcons")
	button.text = "Build Haxe Project"
	call_deferred("end_thread")

func end_thread() -> void:
	thread.wait_to_finish()
	thread = null

func update_log() -> void:
	mutex.lock()
	text_log.text = PoolStringArray(output).join("\n")
	mutex.unlock()

func _exit_tree():
	if thread != null:
		thread.wait_to_finish()
		thread = null
