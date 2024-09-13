extends Node

const UserPetsFolder: StringName = "user://pets/"

var NameSpaces: Dictionary = {
	# "internal/dummy" = "res://src/pets/internal/dummy.json"  --- Example of what items in here would look like. 
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not DirAccess.dir_exists_absolute(UserPetsFolder):
		DirAccess.make_dir_absolute(UserPetsFolder)
	for file: String in DirAccess.get_files_at("res://src/pets/internal"):
		var Namespace: String = "internal/" + file.split(".json")[0]
		NameSpaces[Namespace] = file
