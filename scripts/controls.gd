extends Node

var fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN;
var vsync = DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED;

func _input(event: InputEvent) -> void:
	if(event is InputEventKey && (event as InputEventKey).is_pressed()):
		match (event as InputEventKey).as_text_keycode():
			"F": 
				if (!fullscreen):
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN);
				else:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);
				fullscreen = !fullscreen;
			"V": 
				if(!vsync):
					DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_ENABLED);
				else:
					DisplayServer.window_set_vsync_mode(DisplayServer.VSyncMode.VSYNC_DISABLED);
				vsync = !vsync;
