extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.is_debug_build():
		OS.alert("", "DEBUG WARNING")
	pass # Replace with function body.
