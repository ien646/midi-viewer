extends SubViewport

@export var config_node: Node;

func handle_config_value_changed(section: String, key: String, _value: Variant):
	if(section == "Graphics" && (key == "FXAA" || key == "SMAA")):
		update_aa();

func update_aa():
	var fxaa: bool = Config.get_value("Graphics", "FXAA");
	var smaa: bool = Config.get_value("Graphics", "SMAA");
	
	if(smaa):
		screen_space_aa = Viewport.SCREEN_SPACE_AA_SMAA;
	elif(fxaa):
		screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA;
	else:
		screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED

func _ready():
	config_node.connect("config_value_changed", handle_config_value_changed);
	update_aa();

func _process(_delta: float) -> void:
	if(size != DisplayServer.window_get_size()):
		size = DisplayServer.window_get_size();
