extends Label

var fps = 0;

func _physics_process(_delta: float) -> void:	
	text = "FPS: " + str(fps);

func _process(delta: float) -> void:
	fps = int(1.0 / delta);

func _input(event: InputEvent):
	if(event is InputEventKey):
		if(event.is_pressed() && event.as_text_keycode() == "D"):
			visible = !visible;
