class_name Win32Midi

static var midi_initialized = false;

static func init_midi():
	if(OS.get_name() == "Windows" && !midi_initialized):
		OS.open_midi_inputs();
		print("Initialized MIDI with devices: ", OS.get_connected_midi_inputs());
		midi_initialized = true;

static func close_midi():
	if(OS.get_name() == "Windows" && midi_initialized):
		OS.close_midi_inputs();
		midi_initialized = false;
