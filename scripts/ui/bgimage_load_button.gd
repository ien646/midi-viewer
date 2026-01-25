extends Button

@export var config_node: Node;
@export var file_dialog: FileDialog;

func _handle_config_value_changed(section: String, key: String, value: Variant):
	if(section == Config.SECTION_BACKGROUND && key == Config.KEY_IMAGE):
		disabled = !(value as String).is_empty();

func _handle_file_selected(path: String):
	config_node.update_config_value(Config.SECTION_BACKGROUND, Config.KEY_IMAGE, path);

func _ready() -> void:
	var image = Config.get_value(Config.SECTION_BACKGROUND, Config.KEY_IMAGE) as String;
	disabled = !image.is_empty() && FileAccess.file_exists(image);
	config_node.connect("config_value_changed", _handle_config_value_changed);
	file_dialog.connect("file_selected", _handle_file_selected);

func _pressed() -> void:
	file_dialog.visible = true;
