extends Node

@export var config_node: Node;

var fullscreen = false;
var vsync = false;

func _handle_config_value_changed(section: String, key: String, value: Variant):
	if(section == Config.SECTION_GRAPHICS):
		match key:
			Config.KEY_FULLSCREEN:
				fullscreen = value as bool;
				_update_fullscreen();
			Config.KEY_VSYNC: 
				vsync = value as bool;
				_update_vsync();

func _update_vsync():
	if(vsync):
		DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_ENABLED);
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_DISABLED);
		
func _update_fullscreen():
	if (fullscreen):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN);
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);

func _ready() -> void:
	vsync = Config.get_value(Config.SECTION_GRAPHICS, Config.KEY_VSYNC) as bool;
	fullscreen = Config.get_value(Config.SECTION_GRAPHICS, Config.KEY_FULLSCREEN) as bool;
	
	_update_vsync();
	_update_fullscreen();
		
	config_node.connect("config_value_changed", _handle_config_value_changed);

func _input(event: InputEvent) -> void:
	if(event is InputEventKey && (event as InputEventKey).is_pressed()):
		match (event as InputEventKey).as_text_keycode():
			"F": 
				fullscreen = !fullscreen;
				_update_fullscreen();
			"V": 
				vsync = !vsync;
				_update_vsync();
