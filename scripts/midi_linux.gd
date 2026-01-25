class_name LinuxMidi

var midi_poll_process_stdio: FileAccess = null;
var midi_poll_process_pid: int = 0;
var midi_poll_thread: Thread = null;

var quit_requested: bool = false;

var note_queue: Array[Vector2i] = [];
var note_queue_mutex: Mutex = Mutex.new();

signal note_on_received(note: int, velocity: int);

func _enqueue_note(note: Vector2i):
	note_queue_mutex.lock();
	note_queue.push_back(note);
	note_queue_mutex.unlock();
	
func _aseqdump_line_to_note(line: String) -> Vector2i:
	line = line.split(" 0, ")[1];
	line = line.replace("note", "").replace("velocity", "");
	var segments = line.split(',');
	return Vector2i(int(segments[0]), int(segments[1]));

func _poll_thread_routine():
	while(!quit_requested):
		var line = midi_poll_process_stdio.get_line();
		if (line.contains("Note on")):
			_enqueue_note(_aseqdump_line_to_note(line));

func _poll_midi_events(midi_port: int):
	# aseqdump will write a line with every midi event received
	var midi_process = OS.execute_with_pipe("aseqdump", ["-p", str(midi_port)]);
	midi_poll_process_stdio = midi_process["stdio"];
	midi_poll_process_pid = midi_process["pid"];
	
	midi_poll_thread = Thread.new();
	midi_poll_thread.start(_poll_thread_routine);

func init(midi_port: int):
	_poll_midi_events(midi_port);
	
func push_events():
	note_queue_mutex.lock();
	for n in note_queue:
		emit_signal("note_on_received", n[0], n[1]);
	note_queue.clear();
	note_queue_mutex.unlock();
	
func shutdown():
	# Kill process first so that aseqdump's stdio doesn't block forever
	# on get_line() without additional MIDI inputs
	OS.kill(midi_poll_process_pid);
	
	quit_requested = true;
	midi_poll_process_stdio.close();
	midi_poll_thread.wait_to_finish();
