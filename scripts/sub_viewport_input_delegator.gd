extends Node

var subviewport: SubViewport;

func _ready():
	subviewport = get_parent().get_node("SubViewport");

func _input(event: InputEvent) -> void:
	subviewport.push_input(event);

func _unhandled_input(event: InputEvent) -> void:
	subviewport.push_unhandled_input(event);
