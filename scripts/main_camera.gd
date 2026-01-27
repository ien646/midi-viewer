extends Camera3D

@export var config_node: Node;

func _handle_config_value_changed(section: String, key: String, value: Variant):
	if(section == Config.SECTION_CAMERA):
		match key:
			Config.KEY_POSITION:
				position = value as Vector3;
			Config.KEY_ROTATION:
				rotation_degrees = value as Vector3;
			Config.KEY_FOV:
				fov = value as float;
			Config.KEY_BRIGHTNESS:
				environment.adjustment_brightness = value as float;
			Config.KEY_CONTRAST: 
				environment.adjustment_contrast = value as float;
			Config.KEY_SATURATION:
				environment.adjustment_saturation = value as float;
	elif(section == Config.SECTION_BACKGROUND):
		match key:
			Config.KEY_COLOR:
				environment.background_color = value as Color;

func _ready() -> void:
	position = Config.get_value(Config.SECTION_CAMERA, Config.KEY_POSITION) as Vector3;
	fov = Config.get_value(Config.SECTION_CAMERA, Config.KEY_FOV) as float;
	environment.background_color = Config.get_value(Config.SECTION_BACKGROUND, Config.KEY_COLOR) as Color;
	environment.adjustment_brightness = Config.get_value(Config.SECTION_CAMERA, Config.KEY_BRIGHTNESS) as float;
	environment.adjustment_contrast = Config.get_value(Config.SECTION_CAMERA, Config.KEY_CONTRAST) as float;
	environment.adjustment_saturation = Config.get_value(Config.SECTION_CAMERA, Config.KEY_SATURATION) as float;
	config_node.connect("config_value_changed", _handle_config_value_changed);
