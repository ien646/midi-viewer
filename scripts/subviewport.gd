extends SubViewport

func _ready():
	var fxaa: bool = Config.get_value("Graphics", "FXAA");
	var smaa: bool = Config.get_value("Graphics", "SMAA");
	
	if(smaa):
		screen_space_aa = Viewport.SCREEN_SPACE_AA_SMAA;
	elif(fxaa):
		screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA;
	else:
		screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED

func _process(_delta: float) -> void:
	if(size != DisplayServer.window_get_size()):
		size = DisplayServer.window_get_size();
