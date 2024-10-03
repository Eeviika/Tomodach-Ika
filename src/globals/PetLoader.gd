extends Node

const USERPETSFOLDER: StringName = "user://pets/"

var namespaces: Dictionary = {
	# "internal/dummy" = "res://src/pets/internal/dummy.json"  --- Example of what items in here would look like. 
}

var cached_sprite_frames: Dictionary = {

}

func _ready() -> void:
	if not DirAccess.dir_exists_absolute(USERPETSFOLDER):
		DirAccess.make_dir_absolute(USERPETSFOLDER)
	for file: String in DirAccess.get_files_at("res://src/pets/internal"): # Adds internal pet files first.
		if not file.ends_with("json"): continue
		var namesp: String = "internal/" + file.split(".json")[0]
		namesp.to_lower()
		namespaces[namesp] = "res://src/pets/internal/" + file

## Loads and returns the pet data associated with that data file.
func load_pet(pet_namespace: String) -> Dictionary:
	var json_file: FileAccess
	var json_string: String
	if not namespaces.get(pet_namespace):
		print("[PET_LOADER / WARN]: Tried to load a pet that does not exist (%s), returning Dummy." % pet_namespace)
		pet_namespace = "internal/dummy"
	json_file = FileAccess.open(namespaces.get(pet_namespace), FileAccess.READ)
	json_string = json_file.get_as_text()
	json_file.close()
	return JSON.parse_string(json_string)

func build_sprite_frames(pet_namespace: String) -> SpriteFrames: # I hate the way I programmed this so much
	var new_sprite_frames: SpriteFrames							 # if anyone makes a better way i will pay you $100 /j
	var animations_needed: Array[String] = ["fall_left", "fall_right", "idle_happy", "idle_neutral", "idle_upset", "jump_left", "jump_right", "walk_left", "walk_right"]
	var animations_loop: Array[String] = [
		"idle_happy",
		"idle_neutral",
		"idle_upset",
		"walk_left",
		"walk_right",
	]
	var trimmed_namespace: String = pet_namespace.substr(pet_namespace.find("/")+1)
	if not namespaces.get(pet_namespace): # We return dummy instead of stopping because stopping would be problematic for the game. It'd be better to fallback to dummy.
		print("[PET_LOADER / WARN]: Tried to build SpriteFrames for a pet that does not exist (%s), returning Dummy." % pet_namespace)
		pet_namespace = "internal/dummy"
	
	# Check if we already have sprite frames where the pet is located.
	var file_path_of_sprite_frames: String = namespaces[pet_namespace] # Ignoring internal namespaces (because those typically have .tres files anyways), this would be something like user://pets/dummy/dummy.json
	file_path_of_sprite_frames = file_path_of_sprite_frames.get_base_dir() + trimmed_namespace + ".tres" # Expecting user://pets/dummy/dummy.tres 
	if FileAccess.file_exists(file_path_of_sprite_frames):
		# Use those sprite frames instead and cache them.
		new_sprite_frames = load(file_path_of_sprite_frames)
		cached_sprite_frames[pet_namespace] = new_sprite_frames
		return new_sprite_frames
	# Build our own sprite frames via grabbing any assets we can.
	# First check if we even have an assets folder. If not, we fallback to dummy.
	var file_path_of_assets: String = file_path_of_sprite_frames.get_base_dir() + "/" + trimmed_namespace # Expecting user://pets/dummy/dummy
	if not DirAccess.dir_exists_absolute(file_path_of_assets):
		print("[PET_LOADER / WARN]: No assets folder for pet (%s), fallbacking to Dummy." % pet_namespace)
		new_sprite_frames = load("res://src/pets/internal/dummy.tres")
		return new_sprite_frames
		# I was initially going to have it link to the file path of where the assets of dummy was located.
		# Only thing is, dummy is the only pet that has a sprite sheet and not seperate PNGs.
		# I don't wanna export this again because I'm lazy and that'd take more effort, so I'm just gonna do this instead.
		# Below is the code that was originally here.
		# pet_namespace = "dummy"
		# file_path_of_assets = file_path_of_sprite_frames.get_base_dir() + "/" + pet_namespace
	
	new_sprite_frames = SpriteFrames.new()
	# First create all the necessary animations. We leave them blank for now.
	var animation_table: Dictionary = {}
	for animation_name: String in animations_needed:
		new_sprite_frames.add_animation(animation_name)
		animation_table[animation_name] = []
	# Search for files using the animation names in the animation needed table. Probably not very efficient, but whatever.
	for animation_name: String in animations_needed:
		var i: int = 0 # iterator
		while FileAccess.file_exists(file_path_of_assets + "/" + animation_name + str(i) + ".png"):
			var img: Resource = load(file_path_of_assets + "/" + animation_name + str(i) + ".png")
			animation_table[animation_name].append(img)
			i += 1
	# Finally, compile these loaded sprites into the spriteframes.
	for animation_name: String in animation_table.keys():
		for texture: Texture2D in animation_table[animation_name]:
			new_sprite_frames.add_frame(animation_name, texture)
	# Loop some specific animations...
	for animation_name: String in animations_loop:
		if not new_sprite_frames.has_animation(animation_name):
			continue
		new_sprite_frames.set_animation_loop(animation_name, true)
	
	# And we are done!
	return new_sprite_frames