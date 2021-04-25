tool
class_name HaxePluginEditorProperty
extends EditorProperty

var haxe_icon := preload("res://addons/haxe/icons/haxe.svg")
var new_script_dialog := preload("res://addons/haxe/scenes/new_script.tscn")

var base:Control
var object:Node
var script_path := ""

func setup(base:Control, object:Node) -> void:
	self.base = base
	self.object = object
	label = "Haxe Script"
	
	var script_name := "[empty]"
	
	if object.has_meta("haxe_script"):
		if not object.get_script():
			object.remove_meta("haxe_script")
		else:
			script_path = object.get_meta("haxe_script")
			var p := script_path.find_last("/")
			script_name = script_path.substr(p + 1)
	
	var has_script := script_path != ""
	
	var h := HBoxContainer.new()
	
	# TODO revert icon
	var b := MenuButton.new()
	b.flat = true
	if has_script:
		b.icon = haxe_icon
	b.text = script_name
	b.hint_tooltip = script_path
	b.size_flags_horizontal = MenuButton.SIZE_EXPAND_FILL
	setup_menu(base, b, has_script)
	h.add_child(b)
	
	var b2 := MenuButton.new()
	b2.flat = true
	b2.icon = base.get_icon("GuiDropdown", "EditorIcons")
	setup_menu(base, b2, has_script)
	h.add_child(b2)
	
	add_child(h)

func setup_menu(base:Control, button:MenuButton, has_script:bool) -> void:
	button.connect("gui_input", self, "on_menu_gui")
	
	var menu := button.get_popup()
	
	if not has_script:
		menu.add_icon_item(base.get_icon("ScriptCreate", "EditorIcons"), "New Haxe Script")
	else:
		menu.add_icon_item(base.get_icon("ScriptRemove", "EditorIcons"), "Remove Haxe Script")
	
	menu.add_icon_item(base.get_icon("Load", "EditorIcons"), "Load Haxe Script")
	
	if has_script:
		menu.add_icon_item(base.get_icon("Edit", "EditorIcons"), "Edit")
	
	menu.connect("index_pressed", self, "on_popup_select", [has_script])

func on_menu_gui(event:InputEvent) -> void:
	# If is right click then pretend it's a left click
	if event is InputEventMouseButton and event.pressed and event.button_index == 2:
		event.button_index = 1

func on_popup_select(id:int, has_script:bool) -> void:
	if id == 0: # New/Remove
		if not has_script: # New
			var dialog := new_script_dialog.instance()
			dialog.setup(base, object.get_class(), object.get_path().get_name(object.get_path().get_name_count() - 1))
			dialog.theme = base.theme
			dialog.connect("create", self, "on_create")
			base.add_child(dialog)
			dialog.popup_centered()
		else: # Remove
			object.remove_meta("haxe_script")
			object.set_script(null)
	elif id == 1: # Load
		var dialog := EditorFileDialog.new()
		base.add_child(dialog)
		dialog.access = EditorFileDialog.ACCESS_RESOURCES
		dialog.current_dir = "res://scripts/"
		dialog.mode = EditorFileDialog.MODE_OPEN_FILE
		dialog.theme = base.theme
		dialog.add_filter("*.hx ; Haxe script")
		dialog.connect("file_selected", self, "on_load_file")
		dialog.popup_centered_ratio()
	elif id == 2: # Edit
		open_file(script_path)
	else:
		print("Unknown entry: ", id)

func on_create(is_load:bool, class_value:String, path_value:String) -> void:
	if not is_load:
		var f := path_value.find_last("/")
		var name := path_value.substr(f + 1, path_value.find_last(".hx") - f - 1)
		
		var file := File.new()
		file.open(path_value, File.WRITE)
		file.store_string("class " + name + " extends " + class_value + " {\n}\n")
		file.close()
		
		open_file(path_value)
	
	on_load_file(path_value)

func open_file(path:String) -> void:
	var editor:String = ProjectSettings.get(HaxePluginConstants.SETTING_EXTERNAL_EDITOR)
	if editor == "None":
		pass
	elif editor == "VSCode":
		OS.execute("code", [ProjectSettings.globalize_path(path)], false)
	else:
		print("Unknown external editor: " + editor)

func on_load_file(path:String) -> void:
	object.set_meta("haxe_script", path)
	var cs_path := path.replace("res://scripts/", "res://build/src/")
	var p := cs_path.find_last(".hx")
	cs_path = cs_path.substr(0, p) + ".cs"
	var cs_file := File.new()
	if not cs_file.file_exists(cs_path):
		cs_file.open(cs_path, File.WRITE)
		cs_file.store_string("\n")
	cs_file.close()
	object.set_script(load(cs_path))
