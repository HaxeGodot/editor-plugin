tool
class_name HaxePluginEditorProperty
extends EditorProperty

var haxe_icon := preload("res://addons/haxe/icons/haxe.svg")
var new_script_dialog := preload("res://addons/haxe/scenes/new_script.tscn")

var base:Control
var object:Object

func setup(base:Control, object:Object) -> void:
	self.base = base
	self.object = object
	label = "Haxe Script"
	
	var script_name := "[empty]"
	var script_path := ""
	
	if object.has_meta("haxe_script"):
		if not object.get_script():
			object.remove_meta("haxe_script")
		else:
			script_path = object.get_meta("haxe_script")
			var p := script_path.find_last("/")
			script_name = script_path.substr(p + 1)
			
	var has_script := script_path != ""
	
	var h := HBoxContainer.new()
	
	# TODO open menu on right click
	# TODO revert icon
	var b := MenuButton.new()
	b.flat = true
	if has_script:
		b.icon = haxe_icon
	b.text = script_name
	b.hint_tooltip = script_path
	b.size_flags_horizontal = MenuButton.SIZE_EXPAND_FILL
	setup_menu(base, b.get_popup(), has_script)
	h.add_child(b)
	
	var b2 := MenuButton.new()
	b2.flat = true
	b2.icon = base.get_icon("GuiDropdown", "EditorIcons")
	setup_menu(base, b2.get_popup(), has_script)
	h.add_child(b2)
	
	add_child(h)
	
func setup_menu(base:Control, menu:Popup, has_script:bool) -> void:
	if not has_script:
		menu.add_icon_item(base.get_icon("ScriptCreate", "EditorIcons"), "New Haxe Script")
	else:
		menu.add_icon_item(base.get_icon("ScriptRemove", "EditorIcons"), "Remove Haxe Script")
	# menu.add_icon_item(base.get_icon("ScriptExtend", "EditorIcons"), "Extends Haxe Script")
	menu.add_separator()
	menu.add_icon_item(base.get_icon("Load", "EditorIcons"), "Load Haxe Script")
	
	if has_script:
		# TODO: edit, clear, show in filesystem
		pass
	
	menu.connect("index_pressed", self, "on_popup_select", [has_script])

func on_popup_select(id:int, has_script:bool) -> void:
	print(id, has_script)
	
	if id == 0: # New/Remove
		if not has_script: # New
			var dialog := new_script_dialog.instance()
			dialog.theme = base.theme
			dialog.get_node("Content").connect("cancel", self, "on_cancel")
			dialog.get_node("Content").connect("create", self, "on_create")
			base.add_child(dialog)
			dialog.popup_centered()
		else: # Remove
			object.set_script(null)
	elif id == 2: # Load
		var dialog := EditorFileDialog.new()
		dialog.access = EditorFileDialog.ACCESS_RESOURCES
		dialog.current_dir = "res://scripts/"
		dialog.mode = EditorFileDialog.MODE_OPEN_FILE
		dialog.theme = base.theme
		dialog.add_filter("*.hx ; Haxe scripts")
		dialog.connect("file_selected", self, "on_load_file")
		base.add_child(dialog)
		dialog.popup_centered_ratio()
	else:
		print("Unknown entry: ", id)

func on_cancel() -> void:
	print("cancel")
	
func on_create() -> void:
	print("create")

func on_load_file(path:String) -> void:
	object.set_meta("haxe_script", path)
	var cs_path := path.replace("res://scripts/", "res://build/src/")
	var p := cs_path.find_last(".hx")
	cs_path = cs_path.substr(0, p) + ".cs"
	print(path, " => ", cs_path)
	var cs_file := File.new()
	if not cs_file.file_exists(cs_path):
		cs_file.open(cs_path, File.WRITE)
		cs_file.store_string("\n")
	cs_file.close()
	object.set_script(load(cs_path))
