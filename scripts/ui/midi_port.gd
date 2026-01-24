extends SpinBox

@export var config_node: Node;

func _ready() -> void:
	if(OS.get_name() == "Windows"):
		editable = false;
	else:
		value = Config.get_value(Config.SECTION_MIDI, Config.KEY_PORT);	
	connect("value_changed", handle_value_changed);

func handle_value_changed(new_value: float) -> void:
	config_node.update_config_value(Config.SECTION_MIDI, Config.KEY_PORT, new_value as int);
