extends SpinBox

@export var component_index_rgb = 0;
@export var config_node: Node;

func _ready():
	var color = Config.get_value(Config.SECTION_BACKGROUND, Config.KEY_COLOR) as Color;
	value = color[component_index_rgb] * 100;
	connect("value_changed", handle_value_changed);

func handle_value_changed(new_value: float) -> void:
	var new_color = Config.get_value(Config.SECTION_BACKGROUND, Config.KEY_COLOR) as Color;
	new_color[component_index_rgb] = new_value / 100;
	config_node.update_config_value(Config.SECTION_BACKGROUND, Config.KEY_COLOR, new_color);
