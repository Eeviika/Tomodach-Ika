extends Control

@onready var music_player: AudioStreamPlayer = $Music
@onready var scene_buttons_container: HFlowContainer = %SceneButtons
@onready var callable_buttons_container: HFlowContainer = %CallableButtons

@onready var scene_example_button: Button = %SceneButtons/ExampleButton
@onready var callable_example_button: Button = %CallableButtons/ExampleButton

@export var scenes: Array[PackedScene] = []

var callables: Dictionary = {
	# "QuitGame" = get_tree().quit,
	"LoadGame" = SaveManager.load_data,
	"ClearAllData" = func() -> void: SaveManager.current_save = SaveManager.EmptySave.duplicate(true); SaveManager.save_data(SaveManager.current_save);
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_player.volume_db = linear_to_db(.5)
	music_player.play()

	scene_example_button.visible = false
	callable_example_button.visible = false

	for scene: PackedScene in scenes:
		var new_button: Button = scene_example_button.duplicate()
		new_button.text = scene.resource_path
		new_button.visible = true
		new_button.pressed.connect(func() -> void:
			_switch_to_scene(scene)	
		)
		scene_buttons_container.add_child(new_button)
	
	for callable_name: String in callables.keys():
		var callable: Callable = callables[callable_name]
		var new_button: Button = callable_example_button.duplicate()
		new_button.text = callable_name
		new_button.visible = true
		new_button.pressed.connect(func() -> void:
			callable.call()
		)
		new_button.name = callable_name
		callable_buttons_container.add_child(new_button)

func _switch_to_scene(scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(scene)

