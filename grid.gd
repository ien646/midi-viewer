extends MultiMeshInstance3D

# Near / Middle / Far
@export var config_tag = "Near";

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
@export var midi_velocity_scale = 1.25;
@export var midi_first_note = 21;
@export var midi_last_note = 108;
@export var midi_port = 16;

const CONFIG_FILE = "config.cfg";

var positions: Array[Vector3] = [];
var rotations: Array[Vector3] = [];
var scales: Array[Vector3] = [];
var colors: Array[Color] = [];
var hue_shift = 0;

var note_queue_mutex = Mutex.new();
var note_queue: Array[Vector2i] = [];

var note_count = midi_last_note - midi_first_note + 1;

var linux_midi_poll_process_stdio: FileAccess;
var linux_midi_poll_process_pid: int;
var linux_midi_poll_thread: Thread;

var particles_pool: Array[GPUParticles3D];
var particles_pool_index = 0;

var quit_requested = false;

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
	max_particle_systems = get_config_value("Particles", "pool-size") as int;

func linux_enqueue_note(note: Vector2i):
	note_queue_mutex.lock();
	note_queue.push_back(note);
	note_queue_mutex.unlock();
	
func linux_aseqdump_line_to_note(line: String) -> Vector2i:
	line = line.split(" 0, ")[1];
	line = line.replace("note", "").replace("velocity", "");
	var segments = line.split(',');
	return Vector2i(int(segments[0]), int(segments[1]));
	
func linux_midi_poll_thread_routine():
	while(!quit_requested):
		var line = linux_midi_poll_process_stdio.get_line();
		if (line.contains("Note on")):
			linux_enqueue_note(linux_aseqdump_line_to_note(line));

func linux_poll_midi_events():
	# aseqdump will write a line with every midi event received
	var midi_process = OS.execute_with_pipe("aseqdump", ["-p", str(midi_port)]);
	linux_midi_poll_process_stdio = midi_process["stdio"];
	linux_midi_poll_process_pid = midi_process["pid"];
	
	linux_midi_poll_thread = Thread.new();
	linux_midi_poll_thread.start(linux_midi_poll_thread_routine);

func poll_midi_events() -> void:
	if (OS.get_name() == "Linux"):
		linux_poll_midi_events();
	elif (OS.get_name() == "Windows"):
		MIDI.init_midi();
		
func _ready() -> void:	
	set_process_input(true);
	init_config_values();
	
	multimesh = MultiMesh.new();
	multimesh.transform_format = MultiMesh.TRANSFORM_3D;
	multimesh.use_colors = true;
	multimesh.instance_count = note_count;
	multimesh.visible_instance_count = note_count;
	
	multimesh.mesh = block_mesh;
	multimesh.mesh.surface_set_material(0, material);
	
	var col_size = int(float(note_count) / row_size);
	
	if (!particles_disabled):
		for i in range(0, max_particle_systems):
			var copy = particles_instance.duplicate();
			particles_pool.push_back(copy);
			add_child(copy);
	
	for i in range(0, note_count):
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
		colors.push_back(Color.BLACK);
	
	poll_midi_events();
	
func _process(delta: float) -> void:	
	for i in range(0, note_count):
		multimesh.set_instance_transform(i, Transform3D(Basis.from_euler(rotations[i]), positions[i]).scaled(scales[i]));
		multimesh.set_instance_color(i, colors[i]);
		
		scales[i].y -= gravity * delta;
		scales[i].y = max(scales[i].y, min_y_scale);
		
		colors[i] = (colors[i] * (1 - (color_gravity * delta))).clamp(
			Color(min_color_value, min_color_value, min_color_value, min_color_value)
		);
	
	rotate_y(rotation_speed * delta);
	hue_shift += gradient_hue_shift_speed * delta;
	hue_shift = fmod(hue_shift, 1);
	
	note_queue_mutex.lock();
	for n in note_queue:
		_process_midi_event(n[0], n[1]);
	note_queue.clear();
	note_queue_mutex.unlock();

func _process_midi_event(note: int, vel: int) -> void:
	var i = note - midi_first_note;
	var v = vel * midi_velocity_scale;
	
	scales[i].y += remap(v, 0, 127, min_y_scale, max_y_scale);
	var y_position = clamp(scales[i].y, min_y_scale, max_y_scale);
	scales[i].y = y_position;
	var color_sample_point = remap(i, 0, note_count, 0, 1) + hue_shift;
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

# Windows only
func _input(event: InputEvent):
	if (event is InputEventMIDI):
		if(event.message == MIDI_MESSAGE_NOTE_ON):
			_process_midi_event(event.pitch, event.velocity);
		
func _unhandled_input(event: InputEvent):
	if (event is InputEventMIDI):
		if(event.message == MIDI_MESSAGE_NOTE_ON):
			_process_midi_event(event.pitch, event.velocity);

func _print_midi_info(midi_event: InputEventMIDI):
	if midi_event.message == MIDIMessage.MIDI_MESSAGE_NOTE_ON || midi_event.message == MIDIMessage.MIDI_MESSAGE_NOTE_OFF:
		print("Pitch:", midi_event.pitch, " | Velocity:", midi_event.velocity);

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_requested = true;
		
		if(OS.get_name() == "Linux"):
			linux_midi_poll_thread.wait_to_finish();
			OS.kill(linux_midi_poll_process_pid);
			OS.execute("killall", ["aseqdump"]);
			OS.close_midi_inputs();
		
		get_tree().quit();
