extends Node

var fullscreen = false;

func _input(event: InputEvent) -> void:
	if(event is InputEventKey):
		if(event.is_pressed() && event.as_text_keycode() == "F"):
			if (!fullscreen):
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN);
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);
			fullscreen = !fullscreen;
