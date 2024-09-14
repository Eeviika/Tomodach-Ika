extends Control

var tutorial_number: int = 0
var block_input: bool = false

@onready var contentsText: Label = $Contents/ContentsText
@onready var header: Label = $Header
@onready var music: AudioStreamPlayer = $TutorialMusic

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not block_input:
		tutorial_number += 1
		newText()
	if event.is_action_pressed("ui_cancel") and not block_input and not tutorial_number == 0:
		tutorial_number -= 1
		newText()

func newText() -> void:
	block_input = true
	contentsText.create_tween().tween_property(contentsText, "self_modulate", Color.from_hsv(0,0,1,0), .2)
	header.create_tween().tween_property(header, "self_modulate", Color.from_hsv(0,0,1,0), .2)
	await get_tree().create_timer(.2).timeout
	match tutorial_number:
		0: 
			header.text = "Tutorial"
			contentsText.text = """The following controls will be explained in order of their importance.

Make sure you pay attention, because this will only show up once!"""
		1:
			header.text = "Tutorial / Controls (1/2)"
			contentsText.text = """ARROW KEYS
D-PAD                         - Controls the UI.
L-JOYSTICK

Z KEY
A BUTTON (XB)         - Confirms options / actions.
CROSS BUTTON (PS)"""
		2:
			header.text = "Tutorial / Controls (2/2)"
			contentsText.text = """X KEY
B BUTTON (XB)          - Cancels options / actions.
CIRCLE BUTTON (PS)

Controls end here."""
		3:
			header.text = "Tutorial / Time Check"
			var time: Dictionary = Clock.getCurrentTime()
			print("sys",Time.get_unix_time_from_system())
			print("clock",Clock.CurrentTime)
			contentsText.text = "The current time is: {0}:{1}:{2}.\nThe date is: {3}/{4}/{5}.\n\nIf this is not correct, you can always change it later.\n\nThe clock must be correct for some functionality to behave correctly.".format([time.hour, time.minute, time.second, time.month, time.day, time.year])
		4:
			header.text = "About (1/2)"
			contentsText.text = "Tomodach-ika Version {0}\nDeveloped by IKA.\n\nThank you for playing my game!\n\nYou can find details on how to mod and add your own pets on the GitHub's wiki and in the source code's \"docs\" folder.".format([ProjectSettings.get_setting("application/config/version")])
		5:
			header.text = "About (2/2)"
			contentsText.text = "Once you are ready, press CONFIRM again.\n\nThe game will start."
		_:
			tutorial_number = 5
			newText()
			pass
	contentsText.create_tween().tween_property(contentsText, "self_modulate", Color.from_hsv(0,0,1,1), .2)
	header.create_tween().tween_property(header, "self_modulate", Color.from_hsv(0,0,1,1), .2)
	await get_tree().create_timer(.2).timeout
	block_input = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	block_input = true
	modulate = Color.from_hsv(0,0,0,1)
	if not SaveManager.CurrentSave:
		await SaveManager.LoadedData
	if SaveManager.CurrentSave.StartedGame == true:
		pass # TODO: Run some code that puts the player at the start screen.
		return
	create_tween().tween_property(self, "modulate", Color.from_hsv(0,0,1,1), 1)
	music.play()
	music.volume_db = linear_to_db(0.01)
	music.create_tween().tween_property(music, "volume_db", linear_to_db(SaveManager.CurrentSave.Volume), 2.5).set_trans(Tween.TRANS_LINEAR)
	await get_tree().create_timer(1.1).timeout
	block_input = false
