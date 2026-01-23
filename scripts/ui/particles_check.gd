extends CheckButton

@export var group: Utils.Group = Utils.Group.NEAR;
@export var config_node: Node;

func _ready() -> void:
	toggle_mode = Config.get_tagged_value(Config.SECTION_PARTICLES, Config.KEY_ENABLED, Utils.group_tag(group));

func _toggled(toggled_on: bool) -> void:
	Config.set_tagged_value(Config.SECTION_PARTICLES, Config.KEY_ENABLED, Utils.group_tag(group), toggled_on);
