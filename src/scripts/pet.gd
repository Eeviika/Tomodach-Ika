extends CharacterBody2D

const interpolation: bool = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $Hitbox

var current_pet_stats: Dictionary = {
		# "generated": false,                           # Flag that determines whether to generate new data. Used when obtaining a new pet.
		# "name": "",                                   # Name of the pet. Used as a fallback.
		# "nickname": "",                               # Player-generated nickname of the pet.
		# "original_owner": "",                         # Name of the player.
		# "state": GlobalEnums.STATE.EGG,               # State of the pet.
		# "gender": GlobalEnums.GENDER.GENDERLESS,      # Gender of the pet.
		# "adoption_time": 0,                           # Unix timestamp of when the pet was adopted.
		# "weight": 0,                                  # Weight of the pet. Is not AverageWeight.
		# "height": 0,                                  # Height of the pet. Is not AverageHeight.
		# "hunger": 0,                                  # How hungry the pet is from 1 - 100, where 100 is full, and 0 is starving.
		# "enjoyment": 0,                               # How much the pet enjoys the player's company.
		# "happiness": 0,                               # How happy the pet is with the player.
		# "evolution_happiness": 0,                     # How inclined the pet is to evolve (if it can).
		# "flavor_preference": 0,                       # The pet's flavor preference.
}

var current_pet_data: Dictionary
var collision_shape: CircleShape2D

var GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	# Connect the tick function
	Clock.Tick.connect(_tick_event)
	# First, get the current pet data and save it in memory.
	if not SaveManager.current_save:
		await SaveManager.LoadedData
	var current_pet_namespace: String = SaveManager.current_save.get("current_pet_namespace", "internal/dummy")
	current_pet_data = PetLoader.load_pet(current_pet_namespace)
	current_pet_stats = SaveManager.current_save.pet_data.duplicate()
	# If we don't have a name set, then generate data for save.
	if not current_pet_stats.generated:
		_create_data()
	# Create the hitbox using the pet_data info.
	collision_shape = CircleShape2D.new()
	collision_shape.radius = current_pet_data.biology.collision_shape_radius
	hitbox.shape = collision_shape
	hitbox.position = Vector2(current_pet_data.biology.collision_shape_offset.x, current_pet_data.biology.collision_shape_offset.y)
	# Load the sprites.
	var sprite_frames: SpriteFrames = PetLoader.build_sprite_frames(current_pet_namespace)
	animated_sprite.sprite_frames = sprite_frames
	animated_sprite.play("idle_neutral")
	# Scale the pet.
	scale *= current_pet_data.biology.scale

func _create_data() -> void:
	current_pet_stats.generated = true
	current_pet_stats.name = current_pet_data.name
	current_pet_stats.nickname = ""
	current_pet_stats.original_owner = SaveManager.current_save.name
	current_pet_stats.state = GlobalEnums.PET_STATE.EGG
	current_pet_stats.gender = GlobalEnums.PET_GENDER.GENDERLESS
	current_pet_stats.adoption_time = Clock.current_time
	current_pet_stats.weight = current_pet_data.biology.average_weight + randf_range(-current_pet_data.biology.weight_mutation, current_pet_data.biology.weight_mutation)
	current_pet_stats.height = current_pet_data.biology.average_height + randf_range(-current_pet_data.biology.height_mutation, current_pet_data.biology.height_mutation)
	current_pet_stats.hunger = 50
	current_pet_stats.enjoyment = 50
	current_pet_stats.happiness = current_pet_data.preferences.neutral_happiness + 1
	current_pet_stats.evolution_happiness = 0
	current_pet_stats.flavor_preference = current_pet_data.preferences.flavor_preference

func _physics_process(delta: float) -> void:
	# Handle gravity
	if not is_on_floor():
		velocity.y += delta * GRAVITY
	elif not velocity.y < 0:
		velocity.y = 0

	# Handle sideways movement.


func _animate() -> void:
	var normalized_velocity: Vector2 = velocity.normalized()
	if current_pet_stats.state == GlobalEnums.PET_STATE.EGG:
		animated_sprite.play("egg")
		return
	if normalized_velocity == Vector2(0, 0):
		animated_sprite.play("idle_neutral")
		return
	if normalized_velocity.x > 0 and is_on_floor():
		animated_sprite.play("walk_right")
		return
	if normalized_velocity.x < 0 and is_on_floor():
		animated_sprite.play("walk_left")
		return
	if normalized_velocity.y < 0 and normalized_velocity.x > 0:
		animated_sprite.play("jump_right")
		return
	if normalized_velocity.y < 0 and normalized_velocity.x < 0:
		animated_sprite.play("jump_left")
		return
	if normalized_velocity.y >= 0 and normalized_velocity.x > 0:
		animated_sprite.play("fall_right")
		return
	if normalized_velocity.y >= 0 and normalized_velocity.x < 0:
		animated_sprite.play("fall_left")
		return

func jump() -> void:
	if current_pet_stats.state == GlobalEnums.PET_STATE.EGG:
		return
	velocity.y -= 500
	velocity.x += randf_range(-2.50, 2.50)

func _tick_event(_current_time: float) -> void:
	_animate()
	# If interpolation is on, we tween.
	if interpolation:
		var last_location: Vector2 = position
		var new_location: Vector2
		move_and_slide()
		new_location = position
		position = last_location
		if not new_location == last_location:
			create_tween().tween_property(self, "position", new_location, Clock.tick_interval)
	else: # Else, we simply move and slide.
		move_and_slide()
