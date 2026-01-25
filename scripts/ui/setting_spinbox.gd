extends SpinBox

@export var section: String;
@export var key: String;
@export var config_node: Node;
@export var integral: bool = false;

func _ready() -> void:
	value = Config.get_value(section, key);
	connect("value_changed", handle_value_changed);

func handle_value_changed(new_value: float) -> void:
	if(integral):
		config_node.update_config_value(section, key, new_value as int);
	else:
		config_node.update_config_value(section, key, new_value);
