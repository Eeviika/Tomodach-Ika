extends Control

var loop_music: AudioStreamOggVorbis = preload("res://audio/mus_intro_loop.ogg")
var dialogue_number: int = 0 
var input_blocked: bool = true
@onready var music: AudioStreamPlayer = $Music
@onready var dialogue_container: PanelContainer = $DialogueContainer
@onready var dialogue_text: RichTextLabel = $DialogueContainer/VBoxContainer/DialogueText

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate = Color.from_hsv(0,0,0,1)
	create_tween().tween_property(self, "modulate", Color.from_hsv(0,0,1,1), 1.5)
	AudioServer.set_bus_volume_db(0, linear_to_db(SaveManager.CurrentSave.Volume))
	music.volume_db = linear_to_db(0.03)
	music.create_tween().tween_property(music, "volume_db", linear_to_db(1), 1.5)
	loop_music.loop = true
	await get_tree().create_timer(2).timeout
	await create_tween().tween_property(dialogue_container, "position", Vector2(0, 512), 1).finished
	preformDialogueText("Greetings!")
	dialogue_number += 1

func preformDialogueText(text: String)->void:
	if dialogue_text.get_line_count() >= 4:
		var lines: PackedStringArray = dialogue_text.text.split("\n")
		var truelines: PackedStringArray = []
		lines.remove_at(0)
		for line: String in lines:
			if line == "": continue
			lines.remove_at(lines.find(line))
			line = line + "\n"
			truelines.append(line)
			print(truelines)
		dialogue_text.text = "".join(truelines)
	if dialogue_text.get_line_count() != 1:
		input_blocked = true
		for i: int in range(0, text.length()):
			dialogue_text.text = dialogue_text.text + text[i]
			await get_tree().create_timer(.015).timeout
		dialogue_text.text = dialogue_text.text + "\n"
		input_blocked = false
	else:
		input_blocked = true
		dialogue_text.text = ""
		for i: int in range(0, text.length()):
			dialogue_text.text = dialogue_text.text + text[i]
			await get_tree().create_timer(.015).timeout
		dialogue_text.text = dialogue_text.text + "\n"
		input_blocked = false

func nextText()->void:
	match dialogue_number:
		1: preformDialogueText("My name is SPRUCE. Prof. SPRUCE."); dialogue_number += 1
		2: preformDialogueText("People refer to me as the PET PROFESSOR."); dialogue_number += 1
		3: preformDialogueText("This world is inhabited by strange creatures!"); dialogue_number += 1
		4: preformDialogueText("My job is to research and study these creatures."); dialogue_number += 1
		5: preformDialogueText("That's enough from me. Now, tell me, what's your name?"); dialogue_number += 1
		6: pass
		_: preformDialogueText("")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		nextText()

func _on_music_finished() -> void:
	if music.stream.resource_path == "res://audio/mus_intro.ogg":
		music.stream = loop_music
		music.play()
