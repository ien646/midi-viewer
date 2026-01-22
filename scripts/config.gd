class_name Config extends RefCounted

static var _config_mutex: Mutex = Mutex.new();
static var _config_file: ConfigFile = null;

const CONFIG_FILE = "config.cfg"

const _DEFAULT_GRADIENT_OFFSETS: Array[float] = [0.0, 0.126, 0.271, 0.424, 0.539, 0.649, 0.779, 0.883, 1.0];
static var _DEFAULT_GRADIENT_COLORS: Array[Color] = [
	Color.from_rgba8(255, 0, 0),
	Color.from_rgba8(189, 125, 0),
	Color.from_rgba8(161, 167, 0),
	Color.from_rgba8(53, 195, 0),
	Color.from_rgba8(0, 144, 110),
	Color.from_rgba8(0, 129, 206),
	Color.from_rgba8(0, 104, 238),
	Color.from_rgba8(187, 0, 185),
	Color.from_rgba8(200, 0, 145)
];

static func _init_config_default_values(config: ConfigFile):
	config.set_value("Graphics", "FXAA", false);
	config.set_value("Graphics", "SMAA", true);
	
	config.set_value("Background", "color", Color(0.02, 0.02, 0.02));
	config.set_value("Background", "image", "");
	config.set_value("Background", "image-darken", 0.5);
	
	config.set_value("Camera", "position", Vector3(0, 22, 55));
	
	config.set_value("Gradient-Near", "offsets", _DEFAULT_GRADIENT_OFFSETS);
	config.set_value("Gradient-Near", "colors", _DEFAULT_GRADIENT_COLORS);
	config.set_value("Gradient-Near", "interpolate", true);
	
	config.set_value("Gradient-Middle", "offsets", _DEFAULT_GRADIENT_OFFSETS);
	config.set_value("Gradient-Middle", "colors", _DEFAULT_GRADIENT_COLORS);
	config.set_value("Gradient-Middle", "interpolate", true);
	
	config.set_value("Gradient-Far", "offsets", _DEFAULT_GRADIENT_OFFSETS);
	config.set_value("Gradient-Far", "colors", _DEFAULT_GRADIENT_COLORS);
	config.set_value("Gradient-Far", "interpolate", true);
	
	config.set_value("Block-Generation-Near", "position", Vector3(0, 0, 16.7));
	config.set_value("Block-Generation-Near", "column-separation", 1.0);
	config.set_value("Block-Generation-Near", "row-separation", 1.0);
	config.set_value("Block-Generation-Near", "notes-per-row", 22);
	config.set_value("Block-Generation-Near", "min-y-scale", 0.1);
	config.set_value("Block-Generation-Near", "max-y-scale", 4);
	
	config.set_value("Block-Generation-Middle", "position", Vector3(0, 0, -5.5));
	config.set_value("Block-Generation-Middle", "column-separation", 1.0);
	config.set_value("Block-Generation-Middle", "row-separation", 1.0);
	config.set_value("Block-Generation-Middle", "notes-per-row", 44);
	config.set_value("Block-Generation-Middle", "min-y-scale", 0.1);
	config.set_value("Block-Generation-Middle", "max-y-scale", 10);
		
	config.set_value("Block-Generation-Far", "position", Vector3(0, 0, -44));
	config.set_value("Block-Generation-Far", "column-separation", 1.0);
	config.set_value("Block-Generation-Far", "row-separation", 1.0);
	config.set_value("Block-Generation-Far", "notes-per-row", 88);
	config.set_value("Block-Generation-Far", "min-y-scale", 0.1);
	config.set_value("Block-Generation-Far", "max-y-scale", 15);
	
	config.set_value("Block-Appearance-Near", "color-gravity", 1.0);
	config.set_value("Block-Appearance-Near", "min-color-value", 0.0);
	config.set_value("Block-Appearance-Near", "gradient-hue-shift-speed", 0.3);
	
	config.set_value("Block-Appearance-Middle", "color-gravity", 1.0);
	config.set_value("Block-Appearance-Middle", "min-color-value", 0.0);
	config.set_value("Block-Appearance-Middle", "gradient-hue-shift-speed", 0.2);
	
	config.set_value("Block-Appearance-Far", "color-gravity", 1.0);
	config.set_value("Block-Appearance-Far", "min-color-value", 0.0);
	config.set_value("Block-Appearance-Far", "gradient-hue-shift-speed", 0.0);
	
	config.set_value("Block-Behaviour-Near", "gravity", 5);
	config.set_value("Block-Behaviour-Near", "rotation-speed", 0);
	
	config.set_value("Block-Behaviour-Middle", "gravity", 10);
	config.set_value("Block-Behaviour-Middle", "rotation-speed", 0);
	
	config.set_value("Block-Behaviour-Far", "gravity", 20);
	config.set_value("Block-Behaviour-Far", "rotation-speed", 0);
	
	config.set_value("Particles-Near", "enabled", true);
	config.set_value("Particles-Near", "min", 2);
	config.set_value("Particles-Near", "max", 15);
	config.set_value("Particles-Near", "velocity-curve-pow", 2);
	config.set_value("Particles-Near", "pool-size", 50);
	
	config.set_value("Particles-Middle", "enabled", true);
	config.set_value("Particles-Middle", "min", 2);
	config.set_value("Particles-Middle", "max", 15);
	config.set_value("Particles-Middle", "velocity-curve-pow", 2);
	config.set_value("Particles-Middle", "pool-size", 50);
	
	config.set_value("Particles-Far", "enabled", true);
	config.set_value("Particles-Far", "min", 2);
	config.set_value("Particles-Far", "max", 15);
	config.set_value("Particles-Far", "velocity-curve-pow", 2);
	config.set_value("Particles-Far", "pool-size", 50);
	
	config.set_value("Midi", "port", 16);
	
	config.set_value("Midi-Near", "velocity-scale", 1.0);
	config.set_value("Midi-Near", "first-note", 21);
	config.set_value("Midi-Near", "last-note", 108);
	
	config.set_value("Midi-Middle", "velocity-scale", 1.0);
	config.set_value("Midi-Middle", "first-note", 21);
	config.set_value("Midi-Middle", "last-note", 108);
	
	config.set_value("Midi-Far", "velocity-scale", 1.0);
	config.set_value("Midi-Far", "first-note", 21);
	config.set_value("Midi-Far", "last-note", 108);

static func _init_config():
	_config_mutex.lock();
	if(_config_file == null):
		_config_file = ConfigFile.new();
		if(!FileAccess.file_exists(CONFIG_FILE)):
			_init_config_default_values(_config_file);
			_config_file.save(CONFIG_FILE);
		_config_file.load(CONFIG_FILE);
	_config_mutex.unlock();

static func get_tagged_value(section: String, key: String, tag: String) -> Variant:
	_init_config();
	return _config_file.get_value(section + "-" + tag, key);
	
static func get_value(section: String, key: String) -> Variant:
	_init_config();
	return _config_file.get_value(section, key);
