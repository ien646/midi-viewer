extends SubViewport

func _process(_delta: float) -> void:
	if(size != DisplayServer.window_get_size()):
		size = DisplayServer.window_get_size();
