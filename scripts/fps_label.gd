extends Label

var fps = 0;

func _physics_process(_delta: float) -> void:	
	text = "FPS: " + str(fps);

func _process(delta: float) -> void:
	fps = int(1.0 / delta);
