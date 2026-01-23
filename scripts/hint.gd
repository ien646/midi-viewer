extends Label

@export var lifetime_seconds = 3.0;

var lifetime = 0;

func _process(delta: float) -> void:
	lifetime += delta;
	if(lifetime >= lifetime_seconds):
		queue_free();
	
