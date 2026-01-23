extends CheckButton

@export var group: Utils.Group = Utils.Group.NEAR;
@export var config_node: Node;

func _toggled(toggled_on: bool) -> void:
	config_node.update_config_value_tagged(
		Config.SECTION_BLOCK_GENERATION, Utils.group_tag(group), Config.KEY_ENABLED, toggled_on
	);
