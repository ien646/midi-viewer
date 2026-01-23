extends OptionButton

@export var config_node: Node;

const INDEX_NONE = 0;
const INDEX_FXAA = 1;
const INDEX_SMAA = 2;

func handle_item_selection(index: int):
	match index:
		0:
			config_node.update_config_value(Config.SECTION_GRAPHICS, Config.KEY_FXAA, false);
			config_node.update_config_value(Config.SECTION_GRAPHICS, Config.KEY_SMAA, false);
		1:
			config_node.update_config_value(Config.SECTION_GRAPHICS, Config.KEY_FXAA, true);
			config_node.update_config_value(Config.SECTION_GRAPHICS, Config.KEY_SMAA, false);
		2:
			config_node.update_config_value(Config.SECTION_GRAPHICS, Config.KEY_FXAA, false);
			config_node.update_config_value(Config.SECTION_GRAPHICS, Config.KEY_SMAA, true);

func _ready():
	var fxaa = Config.get_value(Config.SECTION_GRAPHICS, Config.KEY_FXAA);
	var smaa = Config.get_value(Config.SECTION_GRAPHICS, Config.KEY_SMAA);
	
	if(smaa):
		selected = INDEX_SMAA;
	elif(fxaa):
		selected = INDEX_FXAA;
	else:
		selected = INDEX_NONE;
	
	connect("item_selected", handle_item_selection);
