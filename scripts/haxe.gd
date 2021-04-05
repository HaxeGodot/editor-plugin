tool
class_name HaxePlugin
extends EditorPlugin

var about_dialog := preload("res://addons/haxe/scenes/about.tscn")

var inspector_plugin:HaxePluginInspectorPlugin

func _enter_tree() -> void:
	# Init
	setup_settings()

	# Inspector plugin
	inspector_plugin = HaxePluginInspectorPlugin.new()
	inspector_plugin.setup(get_editor_interface().get_base_control())
	add_inspector_plugin(inspector_plugin)

	# Tool menu entry
	var menu := PopupMenu.new()
	menu.add_item("About")
	menu.add_item("Setup")
	menu.connect("index_pressed", self, "on_menu")
	add_tool_submenu_item("Haxe", menu)

func _exit_tree() -> void:
	remove_tool_menu_item("Haxe")
	remove_inspector_plugin(inspector_plugin)

func setup_settings() -> void:
	if not ProjectSettings.has_setting(HaxePluginConstants.SETTING_HIDE_NATIVE_SCRIPT_FIELD):
		ProjectSettings.set_setting(HaxePluginConstants.SETTING_HIDE_NATIVE_SCRIPT_FIELD, true)

func on_menu(id:int) -> void:
	if id == 0: # About
		var dialog := about_dialog.instance()
		dialog.theme = get_editor_interface().get_base_control().theme
		add_child(dialog)
		dialog.popup_centered()
	elif id == 1: # Setup
		print("TODO: Setup Haxe")
		pass
	else:
		print("Unknown menu: ", id)
