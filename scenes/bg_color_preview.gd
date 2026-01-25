extends ColorRect

@export var config_node: Node;

func _handle_config_value_changed(section: String, key: String, value: Variant):
	if(section == Config.SECTION_BACKGROUND && key == Config.KEY_COLOR):
		color = value as Color;

func _ready() -> void:
	color = Config.get_value(Config.SECTION_BACKGROUND, Config.KEY_COLOR);
	config_node.connect("config_value_changed", _handle_config_value_changed);
