extends Camera3D

func _ready() -> void:
	position = Config.get_value("Camera", "position") as Vector3;
