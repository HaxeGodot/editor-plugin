tool
extends WindowDialog

signal create(is_load, class_value, path_value)

var base:Control

var cancel_button:Button
var create_button:Button

var class_valid := true
var path_valid := true
var name_valid := true
var name_warning := false
var extension_valid := true

var is_load := false
var class_value := ""
var path_value := ""

func setup(base:Control, class_value:String, name:String) -> void:
	self.base = base
	
	var left := $MarginContainer/VBoxContainer/Buttons/Left
	var right := $MarginContainer/VBoxContainer/Buttons/Right
	
	if OS.get_name() == "Windows" or OS.get_name() == "UWP":
		setup_buttons(right, left)
	else:
		setup_buttons(left, right)
	
	$MarginContainer/VBoxContainer/GridContainer/ClassValue.connect("text_changed", self, "on_class")
	$MarginContainer/VBoxContainer/GridContainer/Path/PathValue.connect("text_changed", self, "on_path")
	
	var path_button := $MarginContainer/VBoxContainer/GridContainer/Path/Load
	path_button.icon = base.get_icon("Folder", "EditorIcons")
	path_button.connect("button_down", self, "on_folder")
	
	on_class(class_value)
	on_path("res://scripts/" + name.substr(0, 1).to_upper() + name.substr(1) + ".hx")

func setup_buttons(cancel:Button, create:Button) -> void:
	cancel.text = "Cancel"
	cancel.connect("button_down", self, "on_cancel")
	cancel_button = cancel
	
	create.text = "Create"
	create.connect("button_down", self, "on_create")
	create_button = create

func on_cancel() -> void:
	hide()

func on_create() -> void:
	hide()
	emit_signal("create", is_load, class_value, path_value)

func on_class(value:String) -> void:
	class_value = value
	class_valid = ClassDB.class_exists(value) and ClassDB.can_instance(value)
	revalidate()

func on_folder() -> void:
	var file := path_value
	file = file.substr(file.find_last("/") + 1)
	
	var dialog := EditorFileDialog.new()
	base.add_child(dialog)
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.current_dir = "res://scripts/"
	dialog.current_file = file
	dialog.disable_overwrite_warning = true
	dialog.theme = base.theme
	dialog.window_title = "Open Haxe Script / Choose Location"
	dialog.add_filter("*.hx ; Haxe script")
	dialog.connect("file_selected", self, "on_path")
	dialog.get_ok().text = "Open"
	dialog.popup_centered_ratio()

func on_path(fullpath:String) -> void:
	path_value = fullpath
	
	var dir_p := fullpath.find_last("/")
	var ext_p := fullpath.find_last(".")
	
	var path := ""
	var file := ""
	
	if dir_p < ext_p:
		path = fullpath.substr(0, dir_p)
		file = fullpath.substr(dir_p + 1)
	else:
		path = fullpath
	
	var d := Directory.new()
	var f := File.new()
	
	is_load = f.file_exists(path_value)
	extension_valid = file.ends_with(".hx")
	name_valid = ext_p < fullpath.length() - 1 and ext_p > dir_p + 1
	name_warning = name_valid && extension_valid && isBuiltin(file.substr(0, file.length() - 3))
	path_valid = path.begins_with("res://") and d.dir_exists(path)
	revalidate()

func isBuiltin(name:String) -> bool:
	var haxeGodotBuiltins = ["Action", "CustomSignal", "CustomSignalUsings", "Godot", "Nullable1", "Signal", "SignalUsings", "Utils"]
	return ClassDB.class_exists(name) or haxeGodotBuiltins.has(name)

func revalidate() -> void:
	var text_edit := $MarginContainer/VBoxContainer/TextEdit
	text_edit.bbcode_text = ""
	
	var valid_color := Color(0.062775, 0.730469, 0.062775)
	var error_color := Color(0.820312, 0.028839, 0.028839)
	var warning_color := Color(0.9375, 0.537443, 0.06958)
	
	if not class_valid:
		text_edit.push_color(error_color)
		text_edit.append_bbcode("- Invalid inherited parent name.\n\n")
		text_edit.pop()
	elif not extension_valid:
		text_edit.push_color(error_color)
		text_edit.append_bbcode("- Invalid extension.\n\n")
		text_edit.pop()
	elif not path_valid:
		text_edit.push_color(error_color)
		text_edit.append_bbcode("- Invalid path.\n\n")
		text_edit.pop()
	elif not name_valid:
		text_edit.push_color(error_color)
		text_edit.append_bbcode("- Invalid filename.\n\n")
		text_edit.pop()
	else:
		text_edit.push_color(valid_color)
		text_edit.append_bbcode("- Haxe script path is valid.\n\n")
		
		if is_load:
			text_edit.append_bbcode("- Will load an existing Haxe script.\n\n")
		else:
			text_edit.append_bbcode("- Will create a new Haxe script.\n\n")
		
		text_edit.pop()
		
		if name_warning:
			text_edit.push_color(warning_color)
			text_edit.append_bbcode("Warning: Having the script name be the same as a built-in type is usually not desired.\n\n")
			text_edit.pop()
	
	var class_edit:LineEdit = $MarginContainer/VBoxContainer/GridContainer/ClassValue
	var class_edit_column := class_edit.caret_position
	class_edit.text = class_value
	class_edit.caret_position = class_edit_column if class_edit_column <= class_value.length() else class_value.length()
	
	var path_edit:LineEdit = $MarginContainer/VBoxContainer/GridContainer/Path/PathValue
	var path_edit_column := path_edit.caret_position
	path_edit.text = path_value
	path_edit.caret_position = path_edit_column if path_edit_column <= path_value.length() else path_value.length()
