extends HBoxContainer

@export var config_section: String;
@export var config_key: String;
@export var x_node: SpinBox;
@export var y_node: SpinBox;
@export var z_node: SpinBox;
@export var config_node: Node;

func _handle_config_value_changed(section: String, key: String, value: Variant):
	if(config_section == section && config_key == key):
		var vec = value as Vector3;
		x_node.value = vec.x;
		y_node.value = vec.y;
		z_node.value = vec.z;
	
func _handle_x_value_changed(value: float):
	config_node.update_config_value(config_section, config_key, Vector3(value, y_node.value, z_node.value));
	
func _handle_y_value_changed(value: float):
	config_node.update_config_value(config_section, config_key, Vector3(x_node.value, value, z_node.value));
	
func _handle_z_value_changed(value: float):
	config_node.update_config_value(config_section, config_key, Vector3(x_node.value, y_node.value, value));
	
func _ready() -> void:
	var value = Config.get_value(config_section, config_key) as Vector3;
	x_node.value = value.x;
	y_node.value = value.y;
	z_node.value = value.z;
	
	config_node.connect("config_value_changed", _handle_config_value_changed);
	x_node.connect("value_changed", _handle_x_value_changed);
	y_node.connect("value_changed", _handle_y_value_changed);
	z_node.connect("value_changed", _handle_z_value_changed);
