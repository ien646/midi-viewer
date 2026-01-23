extends Node

var linux_midi: LinuxMidi = null;

signal note_pressed(note: int, velocity: int);

func _handle_linux_midi_event(note: int, velocity: int):
	emit_signal("note_pressed", note, velocity);

func _ready() -> void:
	if(OS.get_name() == "Windows"):
		Win32Midi.init();
		set_process_input(true);
	elif(OS.get_name() == "Linux"):
		linux_midi = LinuxMidi.new();
		linux_midi.init(Config.get_value("Midi", "port") as int);
		set_process_input(false);
		linux_midi.connect("note_on_received", _handle_linux_midi_event);
	
func _process(_delta: float):
	if(OS.get_name() == "Linux"):
		linux_midi.push_events();

# Windows only
func _input(event: InputEvent):
	if(event is InputEventMIDI):
		if(event.message == MIDIMessage.MIDI_MESSAGE_NOTE_ON):
			emit_signal("note_pressed", event.pitch, event.velocity);
			
func _notification(what: int):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:		
		if(OS.get_name() == "Linux"):
			linux_midi.shutdown();
		if(OS.get_name() == "Windows"):
			Win32Midi.shutdown();
