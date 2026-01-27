extends MultiMeshInstance3D

@export var config_tag = "Near";
@export var config_node: Node;

@export_group("Generation")
@export var block_mesh: Mesh;
@export var row_size = 12
@export var col_separation = 0.2;
@export var row_separation = 0.5;
@export var min_y_scale = 0.1;
@export var max_y_scale = 5;
# --

@export_group("Behaviour")
@export var gravity = 5;
@export var rotation_speed = 0;
# --

@export_group("Appearance")
@export var material: Material = StandardMaterial3D.new();
@export var gradient: Gradient;
@export var color_gravity = 0.2;
@export var min_color_value = 0.02;
@export var gradient_hue_shift_speed = 0.2;
@export_subgroup("Particles")
@export var particles_instance: GPUParticles3D;
@export var particles_disabled = false;
@export var min_particles_hit = 2;
@export var max_particles_hit = 15;
@export var particle_count_curve = 2;
@export var max_particle_systems = 32;
@export var background_color = Color(0.02, 0.02, 0.02, 1.0);
# --

@export_group("Midi")
@export var midi_control_node: Node;
@export var midi_velocity_scale = 1.25;
@export var midi_first_note = 21;
@export var midi_last_note = 108;
@export var midi_port = 16;

const CONFIG_FILE = "config.cfg";
const SKIP_CONFIG = false;

var positions: Array[Vector3] = [];
var rotations: Array[Vector3] = [];
var scales: Array[Vector3] = [];
var colors: Array[Color] = [];
var hue_shift = 0;

func note_count() -> int:
	return midi_last_note - midi_first_note + 1;

var particles_pool: Array[GPUParticles3D];
var particles_pool_index = 0;

var alive_particle_systems = 0;
signal alive_particle_systems_changed(int);

func handle_particle_system_finished():
	alive_particle_systems -= 1;
	emit_signal("alive_particle_systems_changed", alive_particle_systems);

func get_config_value(section: String, key: String) -> Variant:
	return Config.get_tagged_value(section, key, config_tag);
	
func init_config_values():
	# -- Block Gradient --
	var gradient_offsets = get_config_value("Gradient", "offsets") as Array[float];
	var gradient_colors = get_config_value("Gradient", "colors") as Array[Color];
	var gradient_interp = get_config_value("Gradient", "interpolate") as bool;
	var imported_gradient = Gradient.new();
	imported_gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_LINEAR if gradient_interp else Gradient.GRADIENT_INTERPOLATE_CONSTANT;
	imported_gradient.offsets = gradient_offsets;
	imported_gradient.colors = gradient_colors;
	self.gradient = imported_gradient;
	
	# -- Block Generation --
	if(!get_config_value("Block-Generation", "enabled") as bool):
		visible = false;
		
	position = get_config_value("Block-Generation", "position") as Vector3;
	col_separation = get_config_value("Block-Generation", "column-separation") as float;
	row_separation = get_config_value("Block-Generation", "row-separation") as float;
	row_size = get_config_value("Block-Generation", "notes-per-row") as int;
	min_y_scale =  get_config_value("Block-Generation", "min-y-scale") as float;
	max_y_scale = get_config_value("Block-Generation", "max-y-scale") as float;
	
	# -- Block Behaviour --
	gravity = get_config_value("Block-Behaviour", "gravity") as float;
	rotation_speed = get_config_value("Block-Behaviour", "rotation-speed") as float;
	
	# -- Block Appearance --
	color_gravity = get_config_value("Block-Appearance", "color-gravity") as float;
	min_color_value = get_config_value("Block-Appearance", "min-color-value") as float;
	gradient_hue_shift_speed = get_config_value("Block-Appearance", "gradient-hue-shift-speed") as float;
	
	# -- Particles --
	particles_disabled = !get_config_value("Particles", "enabled") as bool;
	min_particles_hit = get_config_value("Particles", "min") as int;
	max_particles_hit = get_config_value("Particles", "max") as int;
	particle_count_curve = get_config_value("Particles", "velocity-curve-pow") as float;
	max_particle_systems = get_config_value("Particles", "pool-size") as int
	
func handle_config_value_changed(section: String, key: String, value: Variant):
	if(section.ends_with(config_tag)):		
		if(section.begins_with(Config.SECTION_BLOCK_APPEARANCE)):
			match key:
				Config.KEY_COLOR_GRAVITY:
					color_gravity = value as float;
				Config.KEY_MIN_COLOR_VALUE:
					min_color_value = value as float;
				Config.KEY_GRADIENT_HUE_SHIFT_SPEED:
					gradient_hue_shift_speed = value as float;
		if(section.begins_with(Config.SECTION_BLOCK_BEHAVIOUR)):
			match key:
				Config.KEY_MIN_Y_SCALE:
					min_y_scale = value as float;
				Config.KEY_MAX_Y_SCALE:
					max_y_scale = value as float;
				Config.KEY_ROTATION_SPEED:
					rotation_speed = value as float;
				Config.KEY_GRAVITY:
					gravity = value as float;
		if(section.begins_with(Config.SECTION_BLOCK_GENERATION)):
			match key:
				Config.KEY_ENABLED:
					visible = value as bool;
				Config.KEY_NOTES_PER_ROW:
					row_size = value as int;
					generate_block_data();
				Config.KEY_ROW_SEPARATION:
					row_separation = value as float;
					generate_block_data();
				Config.KEY_COLUMN_SEPARATION:
					col_separation = value as float;
					generate_block_data();
				Config.KEY_POSITION:
					position = value as Vector3;
		if(section.begins_with(Config.SECTION_PARTICLES)):
			match key:
				Config.KEY_ENABLED:
					particles_disabled = !(value as bool);
					if(!particles_disabled):
						generate_particle_data();
				Config.KEY_MIN:
					min_particles_hit = value as int;
					if(!particles_disabled):
						generate_block_data();
				Config.KEY_MAX:
					max_particles_hit = value as int;
					if(!particles_disabled):
						generate_block_data();
				Config.KEY_VELOCITY_CURVE_POW:
					particle_count_curve = value as float;
					if(!particles_disabled):
						generate_block_data();
				Config.KEY_POOL_SIZE:
					max_particle_systems = value as int;
					if(!particles_disabled):
						generate_block_data();
		if(section.begins_with(Config.SECTION_MIDI)):
			match key:
				Config.KEY_FIRST_NOTE:
					midi_first_note = value as int;
					generate_block_data();
				Config.KEY_LAST_NOTE:
					midi_last_note = value as int;
					generate_block_data();
				Config.KEY_VELOCITY_SCALE:
					midi_velocity_scale = value as float;
					
func generate_block_data():
	positions.clear();
	rotations.clear();
	scales.clear();
	colors.clear();
	
	multimesh.instance_count = note_count();
	multimesh.visible_instance_count = note_count();
	
	var col_size = int(float(note_count()) / row_size);
	
	for i in range(0, note_count()):
		var x = i % row_size;
		
		@warning_ignore("integer_division")
		var y = i / row_size;
		
		@warning_ignore("integer_division")
		var x_pos = (x - (row_size / 2)) * (1 + col_separation);
		@warning_ignore("integer_division")
		var y_pos = (y - (col_size / 2)) * (1 + row_separation);
		
		positions.push_back(Vector3(x_pos, 0, y_pos));
		rotations.push_back(Vector3.ZERO);
		scales.push_back(Vector3(1, min_y_scale, 1));
		colors.push_back(Color(0, 0, 0, 0));
		
func generate_particle_data():
	var particle_systems = find_children("", "GPUParticles3D");
	for s in particle_systems:
		s.queue_free();
		
	for i in range(0, max_particle_systems):
		var copy = particles_instance.duplicate();
		copy.connect("finished", handle_particle_system_finished);
		particles_pool.push_back(copy);
		add_child(copy);
		
func _ready() -> void:
	if(!SKIP_CONFIG):
		init_config_values();
		
	config_node.connect("config_value_changed", handle_config_value_changed);
		
	if(midi_control_node == null):
		print("No midi control node assigned to: ", name);
	else:
		midi_control_node.connect("note_pressed", _process_midi_event);
	
	multimesh = MultiMesh.new();
	multimesh.transform_format = MultiMesh.TRANSFORM_3D;
	multimesh.use_colors = true;
	multimesh.instance_count = note_count();
	multimesh.visible_instance_count = note_count();
	
	multimesh.mesh = block_mesh;
	multimesh.mesh.surface_set_material(0, material);
	
	if(!particles_disabled):
		generate_particle_data();
	
	generate_block_data();
	
func _physics_process(delta: float) -> void:
	for i in range(0, note_count()):
		multimesh.set_instance_transform(i, Transform3D(Basis.from_euler(rotations[i]), positions[i]).scaled(scales[i]));
		multimesh.set_instance_color(i, colors[i]);
		
		scales[i].y -= gravity * delta;
		scales[i].y = max(scales[i].y, min_y_scale);
		
		colors[i] = (colors[i] * (1 - (color_gravity * delta))).clamp(
			Color(min_color_value, min_color_value, min_color_value, min_color_value)
		);
	
func _process(delta: float) -> void:
	if(abs(rotation_speed) > 0):
		rotate_y(rotation_speed * delta);
		
	hue_shift += gradient_hue_shift_speed * delta;
	hue_shift = fmod(hue_shift, 1);

func _process_midi_event(note: int, vel: int) -> void:
	if(note < midi_first_note || note > midi_last_note):
		return;
		
	var i = note - midi_first_note;
	var v = vel * midi_velocity_scale;
	
	scales[i].y += remap(v, 0, 127, min_y_scale, max_y_scale);
	var y_position = clamp(scales[i].y, min_y_scale, max_y_scale);
	scales[i].y = y_position;
	var color_sample_point = remap(i, 0, note_count(), 0, 1) + hue_shift;
	colors[i] = gradient.sample(fmod(color_sample_point, 1));

	if (!particles_disabled):
		var particles = particles_pool[particles_pool_index];
		particles.emitting = false;
		
		var particle_count = remap(v, 0, 127, 0, 1);
		particle_count = pow(particle_count, particle_count_curve);
		particle_count = remap(particle_count, 0, 1, min_particles_hit, max_particles_hit);
		
		particles.amount = particle_count;
		particles.visible = true;
		particles_pool_index += 1;
		particles_pool_index = particles_pool_index % max_particle_systems;
		particles.position = positions[i] + Vector3(0, y_position*2, 0);
		particles.emitting = true;
		alive_particle_systems += 1;
		emit_signal("alive_particle_systems_changed", alive_particle_systems);
