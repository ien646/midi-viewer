extends Sprite2D

func _process(_delta):
	var vp_size = get_viewport_rect().size
	var tex_size = texture.get_size();
	
	scale = vp_size / tex_size;
	position = vp_size / 2;
