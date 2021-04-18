tool
extends WindowDialog

signal create(is_load, class_value, path_value)

var base:Control

var class_valid := true
var path_valid := true
var name_valid := true
var extension_valid := true

var is_load := false
var class_value := ""
var path_value := ""

func _ready() -> void:
	$MarginContainer/VBoxContainer/Buttons/Cancel.connect("button_down", self, "on_cancel")
	$MarginContainer/VBoxContainer/Buttons/Create.connect("button_down", self, "on_create")
	$MarginContainer/VBoxContainer/GridContainer/ClassValue.connect("text_changed", self, "on_class")
	$MarginContainer/VBoxContainer/GridContainer/Path/PathValue.connect("text_changed", self, "on_path")
	
func setup(base:Control, class_value:String, name:String) -> void:
	self.base = base
	
	var path_button := $MarginContainer/VBoxContainer/GridContainer/Path/Load
	path_button.icon = base.get_icon("Folder", "EditorIcons")
	path_button.connect("button_down", self, "on_folder")
	
	on_class(class_value)
	on_path("res://scripts/" + name.substr(0, 1).to_upper() + name.substr(1) + ".hx")

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
	path_valid = path.begins_with("res://") and d.dir_exists(path)
	revalidate()

func revalidate() -> void:
	var create_button := $MarginContainer/VBoxContainer/Buttons/Create
	var text_edit := $MarginContainer/VBoxContainer/TextEdit
	var valid := false
	
	if not class_valid:
		text_edit.text = "- Invalid inherited parent name."
	elif not extension_valid:
		text_edit.text = "- Invalid extension."
	elif not path_valid:
		text_edit.text = "- Invalid path."
	elif not name_valid:
		text_edit.text = "- Invalid filename."
	else:
		text_edit.text = "- Haxe script path is valid."
		if is_load:
			text_edit.text += "\n- Will load an existing Haxe script."
		else:
			text_edit.text += "\n- Will create a new Haxe script."
		valid = true
	
	if valid:
		text_edit.add_color_override("font_color", Color(0.0, 1.0, 0.0))
		create_button.disabled = false
	else:
		text_edit.add_color_override("font_color", Color(1.0, 0.0, 0.0))
		create_button.disabled = true
	
	var class_edit:LineEdit = $MarginContainer/VBoxContainer/GridContainer/ClassValue
	var class_edit_column := class_edit.caret_position
	class_edit.text = class_value
	class_edit.caret_position = class_edit_column if class_edit_column <= class_value.length() else class_value.length()
	
	var path_edit:LineEdit = $MarginContainer/VBoxContainer/GridContainer/Path/PathValue
	var path_edit_column := path_edit.caret_position
	path_edit.text = path_value
	path_edit.caret_position = path_edit_column if path_edit_column <= path_value.length() else path_value.length()
