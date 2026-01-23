extends CheckButton

@export var config_node: Node;

func _toggled(toggled_on: bool) -> void:
	config_node.update_config_value("Block-Generation-Near", "enabled", toggled_on);
