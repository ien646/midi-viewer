class_name Config extends RefCounted

static var _config_mutex: Mutex = Mutex.new();
static var _config_file: ConfigFile = null;
static var _batching = false;

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

const SECTION_BACKGROUND = "Background";
const SECTION_CAMERA = "Camera";
const SECTION_GRADIENT = "Gradient";
const SECTION_GRAPHICS = "Graphics";
const SECTION_BLOCK_APPEARANCE = "Block-Appearance";
const SECTION_BLOCK_BEHAVIOUR = "Block-Behaviour";
const SECTION_BLOCK_GENERATION = "Block-Generation";
const SECTION_PARTICLES = "Particles";
const SECTION_MIDI = "Midi";

const KEY_COLOR = "color";
const KEY_IMAGE = "image";
const KEY_IMAGE_DARKEN = "image-darken";
const KEY_FXAA = "FXAA";
const KEY_SMAA = "SMAA";
const KEY_FULLSCREEN = "fullscreen";
const KEY_RENDER_SCALE = "render-scale";
const KEY_FSR = "FSR";
const KEY_OFFSETS = "offsets";
const KEY_COLORS = "colors";
const KEY_INTERPOLATE = "interpolate";
const KEY_POSITION = "position";
const KEY_ROTATION = "rotation";
const KEY_ENABLED = "enabled";
const KEY_COLUMN_SEPARATION = "column-separation";
const KEY_ROW_SEPARATION = "row-separation";
const KEY_NOTES_PER_ROW = "notes-per-row";
const KEY_MIN_Y_SCALE = "min-y-scale";
const KEY_MAX_Y_SCALE = "max-y-scale";
const KEY_COLOR_GRAVITY = "color-gravity";
const KEY_MIN_COLOR_VALUE = "min-color-value";
const KEY_GRADIENT_HUE_SHIFT_SPEED = "gradient-hue-shift-speed";
const KEY_GRAVITY = "gravity";
const KEY_ROTATION_SPEED = "rotation-speed";
const KEY_MIN = "min";
const KEY_MAX = "max";
const KEY_VELOCITY_CURVE_POW = "velocity-curve-pow";
const KEY_POOL_SIZE = "pool-size";
const KEY_PORT = "port";
const KEY_VELOCITY_SCALE = "velocity-scale";
const KEY_FIRST_NOTE = "first-note";
const KEY_LAST_NOTE = "last-note";
const KEY_FOV = "fov";
const KEY_BRIGHTNESS = "brightness";
const KEY_CONTRAST = "contrast";
const KEY_SATURATION = "saturation";

const TAG_NEAR = "Near";
const TAG_MIDDLE = "Middle";
const TAG_FAR = "Far";

const TAG_SEPARATOR = "-";

static func tagged(k:String, tag:String):
	return k + TAG_SEPARATOR + tag;

static func _init_config_default_values(config: ConfigFile):
	begin_batch();
	config.set_value(SECTION_GRAPHICS, KEY_FXAA, false);
	config.set_value(SECTION_GRAPHICS, KEY_SMAA, true);
	config.set_value(SECTION_GRAPHICS, KEY_FULLSCREEN, false);
	config.set_value(SECTION_GRAPHICS, KEY_RENDER_SCALE, 100);
	config.set_value(SECTION_GRAPHICS, KEY_FSR, false);
	
	config.set_value(SECTION_BACKGROUND, KEY_COLOR, Color(0.02, 0.02, 0.02));
	config.set_value(SECTION_BACKGROUND, KEY_IMAGE, "");
	config.set_value(SECTION_BACKGROUND, KEY_IMAGE_DARKEN, 0.5);
	
	config.set_value(SECTION_CAMERA, KEY_POSITION, Vector3(0, 22, 55));
	config.set_value(SECTION_CAMERA, KEY_ROTATION, Vector3(-18, 0, 0));
	config.set_value(SECTION_CAMERA, KEY_FOV, 50.0);
	config.set_value(SECTION_CAMERA, KEY_BRIGHTNESS, 1.0);
	config.set_value(SECTION_CAMERA, KEY_CONTRAST, 1.0);
	config.set_value(SECTION_CAMERA, KEY_SATURATION, 1.0);
	
	config.set_value(tagged(SECTION_GRADIENT, TAG_NEAR), KEY_OFFSETS, _DEFAULT_GRADIENT_OFFSETS);
	config.set_value(tagged(SECTION_GRADIENT, TAG_NEAR), KEY_COLORS, _DEFAULT_GRADIENT_COLORS);
	config.set_value(tagged(SECTION_GRADIENT, TAG_NEAR), KEY_INTERPOLATE, true);
	
	config.set_value(tagged(SECTION_GRADIENT, TAG_MIDDLE), KEY_OFFSETS, _DEFAULT_GRADIENT_OFFSETS);
	config.set_value(tagged(SECTION_GRADIENT, TAG_MIDDLE), KEY_COLORS, _DEFAULT_GRADIENT_COLORS);
	config.set_value(tagged(SECTION_GRADIENT, TAG_MIDDLE), KEY_INTERPOLATE, true);
	
	config.set_value(tagged(SECTION_GRADIENT, TAG_FAR), KEY_OFFSETS, _DEFAULT_GRADIENT_OFFSETS);
	config.set_value(tagged(SECTION_GRADIENT, TAG_FAR), KEY_COLORS, _DEFAULT_GRADIENT_COLORS);
	config.set_value(tagged(SECTION_GRADIENT, TAG_FAR), KEY_INTERPOLATE, true);
	
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_NEAR), KEY_ENABLED, true);
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_NEAR), KEY_POSITION, Vector3(0, 0, 16.7));
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_NEAR), KEY_COLUMN_SEPARATION, 1.0);
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_NEAR), KEY_ROW_SEPARATION, 1.0);
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_NEAR), KEY_NOTES_PER_ROW, 22);
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_NEAR), KEY_MIN_Y_SCALE, 0.1);
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_NEAR), KEY_MAX_Y_SCALE, 4);
	
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_MIDDLE), KEY_ENABLED, true);
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_MIDDLE), KEY_POSITION, Vector3(0, 0, -5.5));
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_MIDDLE), KEY_COLUMN_SEPARATION, 1.0);
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_MIDDLE), KEY_ROW_SEPARATION, 1.0);
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_MIDDLE), KEY_NOTES_PER_ROW, 44);
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_MIDDLE), KEY_MIN_Y_SCALE, 0.1);
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_MIDDLE), KEY_MAX_Y_SCALE, 10);
		
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_FAR), KEY_ENABLED, true);
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_FAR), KEY_POSITION, Vector3(0, 0, -44));
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_FAR), KEY_COLUMN_SEPARATION, 1.0);
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_FAR), KEY_ROW_SEPARATION, 1.0);
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_FAR), KEY_NOTES_PER_ROW, 88);
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_FAR), KEY_MIN_Y_SCALE, 0.1);
	config.set_value(tagged(SECTION_BLOCK_GENERATION, TAG_FAR), KEY_MAX_Y_SCALE, 15);
	
	config.set_value(tagged(SECTION_BLOCK_APPEARANCE, TAG_NEAR), KEY_COLOR_GRAVITY, 1.0);
	config.set_value(tagged(SECTION_BLOCK_APPEARANCE, TAG_NEAR), KEY_MIN_COLOR_VALUE, 0.0);
	config.set_value(tagged(SECTION_BLOCK_APPEARANCE, TAG_NEAR), KEY_GRADIENT_HUE_SHIFT_SPEED, 0.3);
	
	config.set_value(tagged(SECTION_BLOCK_APPEARANCE, TAG_MIDDLE), KEY_COLOR_GRAVITY, 1.0);
	config.set_value(tagged(SECTION_BLOCK_APPEARANCE, TAG_MIDDLE), KEY_MIN_COLOR_VALUE, 0.0);
	config.set_value(tagged(SECTION_BLOCK_APPEARANCE, TAG_MIDDLE), KEY_GRADIENT_HUE_SHIFT_SPEED, 0.2);
	
	config.set_value(tagged(SECTION_BLOCK_APPEARANCE, TAG_FAR), KEY_COLOR_GRAVITY, 1.0);
	config.set_value(tagged(SECTION_BLOCK_APPEARANCE, TAG_FAR), KEY_MIN_COLOR_VALUE, 0.0);
	config.set_value(tagged(SECTION_BLOCK_APPEARANCE, TAG_FAR), KEY_GRADIENT_HUE_SHIFT_SPEED, 0.0);
	
	config.set_value(tagged(SECTION_BLOCK_BEHAVIOUR, TAG_NEAR), KEY_GRAVITY, 5);
	config.set_value(tagged(SECTION_BLOCK_BEHAVIOUR, TAG_NEAR), KEY_ROTATION_SPEED, 0);
	
	config.set_value(tagged(SECTION_BLOCK_BEHAVIOUR, TAG_MIDDLE), KEY_GRAVITY, 10);
	config.set_value(tagged(SECTION_BLOCK_BEHAVIOUR, TAG_MIDDLE), KEY_ROTATION_SPEED, 0);
	
	config.set_value(tagged(SECTION_BLOCK_BEHAVIOUR, TAG_FAR), KEY_GRAVITY, 20);
	config.set_value(tagged(SECTION_BLOCK_BEHAVIOUR, TAG_FAR), KEY_ROTATION_SPEED, 0);
	
	config.set_value(tagged(SECTION_PARTICLES, TAG_NEAR), KEY_ENABLED, true);
	config.set_value(tagged(SECTION_PARTICLES, TAG_NEAR), KEY_MIN, 2);
	config.set_value(tagged(SECTION_PARTICLES, TAG_NEAR), KEY_MAX, 15);
	config.set_value(tagged(SECTION_PARTICLES, TAG_NEAR), KEY_VELOCITY_CURVE_POW, 2);
	config.set_value(tagged(SECTION_PARTICLES, TAG_NEAR), KEY_POOL_SIZE, 50);
	
	config.set_value(tagged(SECTION_PARTICLES, TAG_MIDDLE), KEY_ENABLED, true);
	config.set_value(tagged(SECTION_PARTICLES, TAG_MIDDLE), KEY_MIN, 2);
	config.set_value(tagged(SECTION_PARTICLES, TAG_MIDDLE), KEY_MAX, 15);
	config.set_value(tagged(SECTION_PARTICLES, TAG_MIDDLE), KEY_VELOCITY_CURVE_POW, 2);
	config.set_value(tagged(SECTION_PARTICLES, TAG_MIDDLE), KEY_POOL_SIZE, 50);
	
	config.set_value(tagged(SECTION_PARTICLES, TAG_FAR), KEY_ENABLED, true);
	config.set_value(tagged(SECTION_PARTICLES, TAG_FAR), KEY_MIN, 2);
	config.set_value(tagged(SECTION_PARTICLES, TAG_FAR), KEY_MAX, 15);
	config.set_value(tagged(SECTION_PARTICLES, TAG_FAR), KEY_VELOCITY_CURVE_POW, 2);
	config.set_value(tagged(SECTION_PARTICLES, TAG_FAR), KEY_POOL_SIZE, 50);
	
	config.set_value(SECTION_MIDI, KEY_PORT, 16);
	
	config.set_value(tagged(SECTION_MIDI, TAG_NEAR), KEY_VELOCITY_SCALE, 1.0);
	config.set_value(tagged(SECTION_MIDI, TAG_NEAR), KEY_FIRST_NOTE, 21);
	config.set_value(tagged(SECTION_MIDI, TAG_NEAR), KEY_LAST_NOTE, 108);
	
	config.set_value(tagged(SECTION_MIDI, TAG_MIDDLE), KEY_VELOCITY_SCALE, 1.0);
	config.set_value(tagged(SECTION_MIDI, TAG_MIDDLE), KEY_FIRST_NOTE, 21);
	config.set_value(tagged(SECTION_MIDI, TAG_MIDDLE), KEY_LAST_NOTE, 108);
	
	config.set_value(tagged(SECTION_MIDI, TAG_FAR), KEY_VELOCITY_SCALE, 1.0);
	config.set_value(tagged(SECTION_MIDI, TAG_FAR), KEY_FIRST_NOTE, 21);
	config.set_value(tagged(SECTION_MIDI, TAG_FAR), KEY_LAST_NOTE, 108);
	
	end_batch();

static func begin_batch():
	assert(!_batching);
	_batching = true;

static func end_batch():
	_batching = false;
	_config_file.save(CONFIG_FILE);

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

static func set_value(section: String, key: String, value: Variant):
	_init_config();
	_config_file.set_value(section, key, value);
	_config_file.save(CONFIG_FILE);

static func set_tagged_value(section: String, key: String, tag: String, value: Variant):
	_init_config();
	_config_file.set_value(section + "-" + tag, key, value);
	_config_file.save(CONFIG_FILE);
