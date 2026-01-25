extends SpinBox

@export var config_node: Node;

func _ready() -> void:
	value = Config.get_value(Config.SECTION_CAMERA, Config.KEY_FOV);
	connect("value_changed", handle_value_changed);

func handle_value_changed(new_value: float) -> void:
	config_node.update_config_value(Config.SECTION_CAMERA, Config.KEY_FOV, new_value as int);
