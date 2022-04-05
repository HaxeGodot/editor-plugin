tool
class_name HaxePlugin
extends EditorPlugin

var about_dialog := preload("res://addons/haxe/scenes/about.tscn")
var tab := preload("res://addons/haxe/scenes/tab.tscn").instance()
var build_dialog := preload("res://addons/haxe/scenes/building.tscn")

var inspector_plugin:HaxePluginInspectorPlugin

func _enter_tree() -> void:
	var base := get_editor_interface().get_base_control()
	
	# Init
	setup_settings()

	# Inspector plugin
	inspector_plugin = HaxePluginInspectorPlugin.new()
	inspector_plugin.setup(base)
	add_inspector_plugin(inspector_plugin)

	# Tool menu entry
	var menu := PopupMenu.new()
	menu.add_item("About")
	menu.add_item("Setup")
	menu.connect("index_pressed", self, "on_menu")
	add_tool_submenu_item("Haxe", menu)
	
	# Bottom dock tab
	tab.setup(base)
	add_control_to_bottom_panel(tab, "Haxe")

func _exit_tree() -> void:
	# TODO tab.gd still leaks?
	remove_control_from_bottom_panel(tab)
	tab.queue_free()
	remove_tool_menu_item("Haxe")
	remove_inspector_plugin(inspector_plugin)

func setup_settings() -> void:
	if not ProjectSettings.has_setting(HaxePluginConstants.SETTING_HIDE_NATIVE_SCRIPT_FIELD):
		ProjectSettings.set_setting(HaxePluginConstants.SETTING_HIDE_NATIVE_SCRIPT_FIELD, true)

	if not ProjectSettings.has_setting(HaxePluginConstants.SETTING_EXTERNAL_EDITOR):
		ProjectSettings.set_setting(HaxePluginConstants.SETTING_EXTERNAL_EDITOR, "VSCode")
		ProjectSettings.add_property_info({
			"name": HaxePluginConstants.SETTING_EXTERNAL_EDITOR,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "None,VSCode"
		});

	if not ProjectSettings.has_setting(HaxePluginConstants.BUILD_ON_PLAY):
		ProjectSettings.set_setting(HaxePluginConstants.BUILD_ON_PLAY, false)

func on_menu(id:int) -> void:
	var theme := get_editor_interface().get_base_control().theme
	
	if id == 0: # About
		var dialog := about_dialog.instance()
		add_child(dialog)
		dialog.theme = theme
		dialog.popup_centered()
	elif id == 1: # Setup
		var output := []
		OS.execute("haxe", ["--class-path", "addons/haxe/scripts", "--run", "Setup"], true, output, true)
		
		var dialog := AcceptDialog.new()
		add_child(dialog)
		
		if output.size() != 1:
			dialog.dialog_text = "Unknown error:\n" + PoolStringArray(output).join("\n")
		elif "command not found" in output[0].to_lower():
			dialog.dialog_text = "Haxe command not found."
		elif output[0] == "haxelib":
			dialog.dialog_text = "Godot externs not found.\nRun 'haxelib install godot' first."
		elif output[0] == "multiple_csproj":
			dialog.dialog_text = "Multiple C# solutions found.\nCannot setup."
		elif output[0] == "csproj":
			dialog.dialog_text = "C# solution not found (.csproj file).\nYou need to setup Godot Mono first:\nProject -> Tools -> Mono -> Create C# solution."
		elif output[0].begins_with("dirty:"):
			dialog.dialog_text = "Project already contains: " + output[0].substr(6) + "\nTo avoid data loss the setup wasn't run."
		elif output[0] == "ok":
			dialog.dialog_text = "Setup successful."
		else:
			dialog.dialog_text = "Unknown error: " + output[0]
		
		dialog.theme = theme
		dialog.window_title = "Haxe Setup"
		dialog.popup_centered()
	else:
		print("Unknown menu: ", id)

func _input(event):
	if event is InputEventKey and ProjectSettings.get_setting(HaxePluginConstants.BUILD_ON_PLAY):
		if event.scancode == KEY_F5 or event.scancode == KEY_F6 and event.echo:
			var dialog = build_dialog.instance()

			add_child(dialog)

			yield(VisualServer, 'frame_post_draw')

			dialog.call("build_haxe_project")
