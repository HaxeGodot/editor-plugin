tool
class_name HaxePluginInspectorPlugin
extends EditorInspectorPlugin

var base:Control

func setup(base:Control) -> void:
	self.base = base

#warning-ignore:unused_argument
func can_handle(object:Object) -> bool:
	return true

#warning-ignore:unused_argument
func parse_property(object:Object, type:int, path:String, hint:int, hint_text:String, usage:int) -> bool:
	if object is Node and type == TYPE_OBJECT and path == "script":
		var e := HaxePluginEditorProperty.new()
		e.setup(base, object)
		add_custom_control(e)
		return ProjectSettings.get_setting(HaxePluginConstants.SETTING_HIDE_NATIVE_SCRIPT_FIELD)

	return false
