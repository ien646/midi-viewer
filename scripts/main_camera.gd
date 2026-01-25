extends Camera3D

@export var config_node: Node;

func _handle_config_value_changed(section: String, key: String, value: Variant):
	if(section == Config.SECTION_CAMERA):
		match key:
			Config.KEY_POSITION:
				position = value as Vector3;
			Config.KEY_FOV: 
				fov = value as float;

func _ready() -> void:
	position = Config.get_value(Config.SECTION_CAMERA, Config.KEY_POSITION) as Vector3;
	fov = Config.get_value(Config.SECTION_CAMERA, Config.KEY_FOV);
	config_node.connect("config_value_changed", _handle_config_value_changed);
