extends Label

@export var lifetime_seconds = 3.0;

var lifetime = 0;

func _ready():
	visible = true;

func _process(delta: float) -> void:
	lifetime += delta;
	if(lifetime >= lifetime_seconds):
		queue_free();
		
func _input(event: InputEvent):
	if(event is InputEventKey && (event as InputEventKey).keycode == KEY_ESCAPE):
		lifetime += lifetime_seconds;
	
