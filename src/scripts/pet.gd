extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $Hitbox
var current_pet_data: Dictionary
var collision_shape: CircleShape2D

func _ready() -> void:
    # First, get the current pet data and save it in memory.
    if not SaveManager.current_save:
        await SaveManager.LoadedData
    var current_pet_namespace: String = SaveManager.current_save.get("CurrentPetNamespace", "internal/dummy")
    current_pet_data = PetLoader.load_pet(current_pet_namespace)
    # Create the hitbox using the pet_data info.
    collision_shape = CircleShape2D.new()
    collision_shape.radius = current_pet_data.biology.collision_shape_radius * current_pet_data.biology.scale
    hitbox.shape = collision_shape
    hitbox.position = Vector2(current_pet_data.biology.collision_shape_offset.x, current_pet_data.biology.collision_shape_offset.y)
    # Load the sprites.
    var sprite_frames: SpriteFrames = PetLoader.build_sprite_frames(current_pet_namespace)
    animated_sprite.sprite_frames = sprite_frames