extends Label

func _process(delta: float) -> void:
	var fps = int(1.0 / delta);
	text = "FPS: " + str(fps);

func _input(event: InputEvent):
	if(event is InputEventKey):
		if(event.is_pressed() && event.as_text_keycode() == "D"):
			visible = !visible;
