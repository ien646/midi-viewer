extends Node

signal config_value_changed(section: String, key: String, value: Variant);

func update_config_value(section: String, key: String, value: Variant):
	Config.set_value(section, key, value);
	emit_signal("config_value_changed", section, key, value);
