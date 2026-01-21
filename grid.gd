extends MultiMeshInstance3D

@export_group("Generation")
@export var block_mesh: Mesh;
@export var gradient: Gradient;
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
@export var midi_channel = 16;
@export var midi_velocity_scale = 1.25;
@export var midi_first_note = 21;
@export var midi_last_note = 108;
@export var midi_port = 16;

var positions: Array[Vector3]
var rotations: Array[Vector3]
var scales: Array[Vector3]
var colors: Array[Color]
var hue_shift = 0;

var note_queue_mutex = Mutex.new();
var note_queue = [];

var note_count = midi_last_note - midi_first_note + 1;

var mux = Mutex.new()

var midi_poll_process_stdio: FileAccess;
var midi_poll_process_pid: int;
var midi_poll_thread: Thread;

var particles_pool: Array[GPUParticles3D];
var particles_pool_index = 0;

var quit_requested = false;

func _poll_midi_events_linux():
	# aseqdump will write a line with every midi event received
	var midi_process = OS.execute_with_pipe("aseqdump", ["-p", str(midi_channel)]);
	midi_poll_process_stdio = midi_process["stdio"];
	midi_poll_process_pid = midi_process["pid"];
	
	midi_poll_thread = Thread.new();
	midi_poll_thread.start(func():
		while(!quit_requested):
			var line = midi_poll_process_stdio.get_line();
			if (line.contains("Note on")):
				line = line.split(" 0, ")[1];
				line = line.replace("note", "").replace("velocity", "");
				var segments = line.split(',');
				var note = int(segments[0]);
				var velocity = int(segments[1]);
				
				note_queue_mutex.lock();
				note_queue.push_back(note);
				note_queue.push_back(velocity);
				note_queue_mutex.unlock();
	)

func poll_midi_events() -> void:	
	if (OS.get_name() == "Linux"):
		_poll_midi_events_linux();
		
	elif (OS.get_name() == "Windows"):
		OS.open_midi_inputs();

func _ready() -> void:
	_process_commandline_args();
	
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
		var y = i / row_size;
		
		var x_pos = (x - (row_size / 2)) * (1 + col_separation);
		var y_pos = (y - (col_size / 2)) * (1 + row_separation);
		
		positions.push_back(Vector3(x_pos, 0, y_pos));
		rotations.push_back(Vector3.ZERO);
		scales.push_back(Vector3(1, min_y_scale, 1));
		colors.push_back(Color.BLACK);
	
	poll_midi_events();
	
	var cam_node: Camera3D = get_parent().get_node("Camera3D") as Camera3D;
	cam_node.environment.background_mode= Environment.BG_COLOR;
	cam_node.environment.background_color = background_color;
	
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
	for i in range(0, note_queue.size() - 1):
		var note = note_queue[i];
		var velocity = note_queue[i+1];
		_process_midi_event(note, velocity);		
		i += 1;		
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
func _input(event: InputEvent) -> void:
	if (event is InputEventMIDI):
		_process_midi_event(event.pitch, event.velocity);
		
func _print_midi_info(midi_event: InputEventMIDI):
	if midi_event.message == MIDIMessage.MIDI_MESSAGE_NOTE_ON || midi_event.message == MIDIMessage.MIDI_MESSAGE_NOTE_OFF:
		print("Pitch:", midi_event.pitch, " | Velocity:", midi_event.velocity);

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_requested = true;
		
		if(OS.get_name() == "Linux"):
			midi_poll_thread.wait_to_finish();
			OS.kill(midi_poll_process_pid);
			OS.execute("killall", ["aseqdump"]);
		
		get_tree().quit();
		
func _process_commandline_args():
	for arg in OS.get_cmdline_args():
		if(arg.begins_with("--bgcolor")):
			var values_rgb = arg.split("=")[1].split(',');
			background_color = Color(float(values_rgb[0]), float(values_rgb[1]), float(values_rgb[2]));
			print("Using user provided background color: [", background_color, "]");
		if(arg == "--noparticles"):
			particles_disabled = true
