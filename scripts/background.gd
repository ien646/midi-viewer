extends Sprite2D

@export var config_node: Node;

func _handle_config_value_changed(section: String, key: String, _value: Variant):
	if(section == Config.SECTION_BACKGROUND):
		match key:
			Config.KEY_IMAGE:
				update_background();
			Config.KEY_IMAGE_DARKEN:
				update_background();

func update_background():
	var bgimage = Config.get_value(Config.SECTION_BACKGROUND, Config.KEY_IMAGE) as String;
	var bgimage_darken = Config.get_value(Config.SECTION_BACKGROUND, Config.KEY_IMAGE_DARKEN) as float;
	
	if(FileAccess.file_exists(bgimage)):
		var image = Image.load_from_file(bgimage);
		texture = ImageTexture.create_from_image(image);
		modulate = Color(1.0 - bgimage_darken, 1.0 - bgimage_darken, 1.0 - bgimage_darken);
	else:
		texture = null;
		modulate = Color.WHITE;

func _ready() -> void:
	config_node.connect("config_value_changed", _handle_config_value_changed);
	update_background();
		
func _process(_delta):
	if(texture != null):
		var vp_size = get_viewport_rect().size
		var tex_size = texture.get_size();
		scale = vp_size / tex_size;
		position = vp_size / 2;
