extends Label

@export var config_node: Node;

var fps = 0;

func _handle_config_value_changed(section: String, key: String, value: Variant):
	if(section == Config.SECTION_GRAPHICS && key == Config.KEY_SHOW_FPS):
		visible = value as bool;

func _ready():
	visible = Config.get_value(Config.SECTION_GRAPHICS, Config.KEY_SHOW_FPS) as bool;
	config_node.connect("config_value_changed", _handle_config_value_changed);

func _physics_process(_delta: float) -> void:
	if(!visible):
		return;
	text = "FPS: " + str(int(fps));

func _process(delta: float) -> void:
	if(!visible):
		return;
	var new_fps = 1.0 / delta;
	fps = lerpf(fps, new_fps, delta * 10);
