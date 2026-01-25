extends CheckButton

@export var group: Utils.Group = Utils.Group.NEAR;
@export var section: String;
@export var key: String;
@export var config_node: Node;

func _ready():
	button_pressed = Config.get_tagged_value(section, key, Utils.group_tag(group));

func _toggled(toggled_on: bool) -> void:
	config_node.update_config_value_tagged(section, Utils.group_tag(group), key, toggled_on);
