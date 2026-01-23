extends OptionButton

const INDEX_NONE = 0;
const INDEX_FXAA = 1;
const INDEX_SMAA = 2;

func handle_item_selection(index: int):
	match index:
		0:
			Config.set_value("Graphics", "FXAA", false);
			Config.set_value("Graphics", "SMAA", false);
		1:
			Config.set_value("Graphics", "FXAA", true);
			Config.set_value("Graphics", "SMAA", false);
		2:
			Config.set_value("Graphics", "FXAA", false);
			Config.set_value("Graphics", "SMAA", true);

func _ready():
	var fxaa = Config.get_value("Graphics", "FXAA");
	var smaa = Config.get_value("Graphics", "SMAA");
	
	if(smaa):
		selected = INDEX_SMAA;
	elif(fxaa):
		selected = INDEX_FXAA;
	else:
		selected = INDEX_NONE;
	
	connect("item_selected", handle_item_selection);
