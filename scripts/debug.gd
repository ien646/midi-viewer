extends Control

func _input(event: InputEvent):
	if(event is InputEventKey):
		if(event.is_pressed() && event.as_text_keycode() == "D"):
			visible = !visible;
