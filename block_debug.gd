extends RichTextLabel

@export var node: Node3D;
@export var tag: String;
@export var font: Font;

var alive_particles = 0;
var gradient_view = true;

func handle_alive_changed(count: int):
	alive_particles = count;

func _ready() -> void:
	node.connect("alive_particle_systems_changed", handle_alive_changed);

func _process(_delta: float) -> void:
	if(visible):
		clear();
		push_font(font);
		add_text("[" + tag + "] " + "PS:" + str(alive_particles) + "\n");
		if(gradient_view):
			var gradient: Gradient = node.gradient;
			var note_count: int = node.note_count;
			var hue_shift: float = node.hue_shift;
			for i in range(0, note_count):
				var sample_point = fmod((float(i) / note_count) + hue_shift, 1.0);
				var color = gradient.sample(sample_point);
				push_color(color);
				add_text("*");
				pop();
	
func _input(event: InputEvent):
	if(event is InputEventKey):
		if(event.is_pressed() && event.as_text_keycode() == "D"):
			visible = !visible;
		if(event.is_pressed() && event.as_text_keycode() == "G"):
			gradient_view = !gradient_view;
