extends SubViewport

@export var config_node: Node;

func handle_config_value_changed(section: String, key: String, _value: Variant):
	if(section == Config.SECTION_GRAPHICS):
		match key:
			Config.KEY_FXAA:
				update_aa();
			Config.KEY_SMAA:
				update_aa();
			Config.KEY_RENDER_SCALE:
				update_renderscale();
			Config.KEY_FSR:
				update_fsr();

func update_renderscale():
	var scale: float = Config.get_value(Config.SECTION_GRAPHICS, Config.KEY_RENDER_SCALE) as float;
	scaling_3d_scale = scale / 100;
	
func update_fsr():
	var fsr: bool = Config.get_value(Config.SECTION_GRAPHICS, Config.KEY_FSR) as bool;
	if(fsr):
		scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR;
	else:
		scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR;

func update_aa():	
	if(Config.get_value(Config.SECTION_GRAPHICS, Config.KEY_SMAA) as bool):
		screen_space_aa = Viewport.SCREEN_SPACE_AA_SMAA;
	elif(Config.get_value(Config.SECTION_GRAPHICS, Config.KEY_FXAA) as bool):
		screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA;
	else:
		screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED

func _ready():
	config_node.connect("config_value_changed", handle_config_value_changed);
	update_aa();
	update_renderscale();
	update_fsr();

func _process(_delta: float) -> void:
	if(size != DisplayServer.window_get_size()):
		size = DisplayServer.window_get_size();
