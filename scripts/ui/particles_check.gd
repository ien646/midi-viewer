extends CheckButton

@export var group: Utils.Group = Utils.Group.NEAR;
@export var config_node: Node;

func _ready() -> void:
	button_pressed = Config.get_tagged_value(Config.SECTION_PARTICLES, Config.KEY_ENABLED, Utils.group_tag(group));

func _toggled(toggled_on: bool) -> void:
	config_node.update_config_value_tagged(Config.SECTION_PARTICLES, Utils.group_tag(group), Config.KEY_ENABLED, toggled_on);
