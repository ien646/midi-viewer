extends WorldEnvironment

func _ready() -> void:
	var bgcolor = Config.get_value("Background", "color") as Color;
	environment.background_color = bgcolor;
