extends CheckButton

@export var section: String;
@export var key: String;
@export var config_node: Node;

func _ready():
	button_pressed = Config.get_value(section, key);

func _toggled(toggled_on: bool) -> void:
	config_node.update_config_value(section, key, toggled_on);
