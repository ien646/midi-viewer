extends Control

func _input(event: InputEvent) -> void:
	if(event is InputEventKey && (event as InputEventKey).is_pressed()):
		if(event.keycode == Key.KEY_ESCAPE):
			if(visible):
				visible = false;
			else:
				visible = true;
