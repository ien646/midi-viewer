extends Button

@export var config_node: Node;

func _handle_config_value_changed(section: String, key: String, value: Variant):
	if(section == Config.SECTION_BACKGROUND && key == Config.KEY_IMAGE):
		disabled = (value as String).is_empty();

func _ready() -> void:
	var image = Config.get_value(Config.SECTION_BACKGROUND, Config.KEY_IMAGE) as String;
	disabled = image.is_empty();
	config_node.connect("config_value_changed", _handle_config_value_changed);

func _pressed() -> void:
	config_node.update_config_value(Config.SECTION_BACKGROUND, Config.KEY_IMAGE, "");
