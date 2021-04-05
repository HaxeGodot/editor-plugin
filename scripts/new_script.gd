extends WindowDialog

# TODO nothing is called

signal cancel
signal create

func _ready() -> void:
	print("ready")

func _enter_tree() -> void:
	print("enter")
	$Buttons/Cancel.connect("button_down", self, "on_cancel")
	$Buttons/Create.connect("button_down", self, "on_create")

func on_cancel() -> void:
	print("emit cancel")
	emit_signal("cancel")

func on_create() -> void:
	print("emit create")
	emit_signal("create")
