extends CharacterBody2D
class_name Pet

const interpolation: bool = true

@export var movement_speed: int = 30
@export var jump_height: int = 500

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $Hitbox

var pet_stats: Dictionary = {
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
		# "happiness": 0,                               # How happy the pet is.
		# "evolution_happiness": 0,                     # How inclined the pet is to evolve (if it can).
		# "flavor_preference": 0,                       # The pet's flavor preference.
}
var pet_data: Dictionary
var movement_cooldown: Timer
var collision_shape: CircleShape2D
var goal_destination: Vector2

var logger: Logger = Logger.new(self)

var reached_destination: bool = true

var GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _is_moving() -> bool:
	return velocity.y != 0.0 or velocity.x != 0.0

func _is_close_to_destination() -> bool:
	var x_range: Array = range(goal_destination.x - 10, goal_destination.x + 11)
	var y_range: Array = range(goal_destination.y - 10, goal_destination.y + 11)

	return (int(global_position.x) in x_range) and (int(global_position.y) in y_range)

func _move_towards_destination() -> void:
	if reached_destination: return;
	if _is_close_to_destination(): reached_destination = true; return;
	draw_line(global_position, goal_destination, Color.RED)
	if goal_destination.x < global_position.x:
		velocity.x -= movement_speed
	else:
		velocity.x += movement_speed
	

func _ready() -> void:

	movement_cooldown = Timer.new()
	movement_cooldown.autostart = false
	movement_cooldown.wait_time = 2
	movement_cooldown.one_shot = true
	add_child(movement_cooldown)
	movement_cooldown.start()
	
	# Connect the tick function
	Clock.Tick.connect(_tick_event)
	# First, get the current pet data and save it in memory.
	if not SaveManager.current_save:
		await SaveManager.LoadedData
	var current_pet_namespace: String = SaveManager.current_save.get("current_pet_namespace", "internal/dummy")
	pet_data = PetLoader.load_pet(current_pet_namespace)
	pet_stats = SaveManager.current_save.pet_data.duplicate()
	# If we don't have a name set, then generate data for save.
	if not pet_stats.generated:
		_create_data()
	# Create the hitbox using the pet_data info.
	collision_shape = CircleShape2D.new()
	collision_shape.radius = pet_data.biology.collision_shape_radius
	hitbox.shape = collision_shape
	hitbox.position = Vector2(pet_data.biology.collision_shape_offset.x, pet_data.biology.collision_shape_offset.y)
	# Load the sprites.
	var sprite_frames: SpriteFrames = PetLoader.build_sprite_frames(current_pet_namespace)
	animated_sprite.sprite_frames = sprite_frames
	animated_sprite.play("idle_neutral")
	# Scale the pet.
	scale *= pet_data.biology.scale

func _create_data() -> void:
	pet_stats.generated = true
	pet_stats.name = pet_data.name
	pet_stats.nickname = ""
	pet_stats.original_owner = SaveManager.current_save.name
	pet_stats.state = GlobalEnums.PET_STATE.EGG
	pet_stats.gender = GlobalEnums.PET_GENDER.GENDERLESS
	pet_stats.adoption_time = Clock.current_time
	pet_stats.weight = pet_data.biology.average_weight + randf_range(-pet_data.biology.weight_mutation, pet_data.biology.weight_mutation)
	pet_stats.height = pet_data.biology.average_height + randf_range(-pet_data.biology.height_mutation, pet_data.biology.height_mutation)
	pet_stats.hunger = 50
	pet_stats.enjoyment = 50
	pet_stats.happiness = pet_data.preferences.neutral_happiness + 1
	pet_stats.evolution_happiness = 0
	pet_stats.flavor_preference = pet_data.preferences.flavor_preference

func _physics_process(delta: float) -> void:
	# Handle destination goals
	if goal_destination and !_is_close_to_destination():
		_move_towards_destination()
	# Handle gravity
	if not is_on_floor():
		velocity.y += delta * GRAVITY
	elif not velocity.y < 0:
		velocity.y = 0

	# Handle sideways movement.
	if is_on_floor():
		velocity.x /= 1.1
	if velocity.x > -1 and velocity.x < 1:
		velocity.x = 0


func _animate() -> void:
	var normalized_velocity: Vector2 = velocity.normalized()
	if pet_stats.state == GlobalEnums.PET_STATE.EGG:
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
	reached_destination = true
	velocity.y -= jump_height
	velocity.x += [-movement_speed*5, movement_speed*5].pick_random()

func move_randomly() -> void:
	movement_cooldown.start()
	if randi_range(1,2) == 1:
		goal_destination = global_position
		goal_destination.x += randi_range(-200, 200)
		logger.info("Goal Location: (%f, %f)" % [int(goal_destination.x), int(goal_destination.y)])
		logger.info("My Location: (%f, %f)" % [int(global_position.x), int(global_position.y)])
		reached_destination = false;
	else:
		jump()

func _tick_event(_current_time: float) -> void:
	if movement_cooldown.is_stopped():
		move_randomly()
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
