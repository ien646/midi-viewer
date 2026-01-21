extends Sprite3D

func _ready() -> void:
	var bgimage = Config.get_value("Background", "image") as String;
	var bgimage_darken = Config.get_value("Background", "image-darken") as float;
	
	if(FileAccess.file_exists(bgimage)):
		var image = Image.load_from_file(bgimage);
		texture = ImageTexture.create_from_image(image);
		modulate = Color(1.0 - bgimage_darken, 1.0 - bgimage_darken, 1.0 - bgimage_darken);
