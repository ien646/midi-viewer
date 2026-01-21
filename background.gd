extends Sprite3D

func _ready() -> void:
	for arg in OS.get_cmdline_args():
		if(arg.begins_with("--bgimagedarken")):
			var darken_value = float(arg.split("=")[1]);
			modulate = Color(1.0 - darken_value, 1.0 - darken_value, 1.0 - darken_value);
		elif(arg.begins_with("--bgimage")):
			var image_path_segments = arg.split("=");
			image_path_segments.remove_at(0);	
			var image_path = "=".join(image_path_segments);
			print("Using custom background image: ", image_path);
			
			if(image_path.begins_with("\"")):
				image_path = image_path.substr(1);
			if(image_path.ends_with("\"")):
				image_path = image_path.substr(0, image_path.length() - 1);
			
			var image = Image.load_from_file(image_path);
			
			self.texture = ImageTexture.create_from_image(image);	
