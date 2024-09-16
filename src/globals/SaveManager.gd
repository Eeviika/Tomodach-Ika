extends Node

signal BeforeLoadedData()
signal LoadedData(dataLoaded: Dictionary)
signal BeforeSavedData()
signal SavedData(dataSaved: Dictionary)

const AutoSave: bool = true
const AutoSaveInterval: int = 60
const AutoLoadData: bool = true

const SaveInDebug: bool = false

const EmptySave: Dictionary = {
	"StartedGame": false,							# Indicates if the player has gone past the tutorial. Files will not save if this is false.
	"Name": "",                                     # Name of the player.
	"CurrentPetNamespace": null,                    # Namespace of the pet's data file. If a mod named "Example" added a pet named "Pet", the namespace would be "Example/Pet"
	"ClockOffset": -14400,							# Clock offset. Defaults to EST.
	"Volume": .7,									# Volume of the game. Defaults to 0.5. Should only be between 0 - 1.
	"Difficulty": GlobalEnums.DIFFICULTY.STANDARD,  # The game difficulty.
	"LastSave": 0,                                  # Unix timestamp of when the game was last saved.
	"Money": 0,										# Money that player currently has.
	"Birthdate": {									# Birthdate data of the player.
		"Month": 1,
		"Day": 2,
		"Year": 1970
	},
	"PetData": {
		"Name": "",                                 # Name of the pet. Used as a fallback.
		"Nickname": "",                             # Player-generated nickname of the pet.
		"OriginalOwner": "",                        # Name of the player.
		"State": GlobalEnums.STATE.EGG,             # State of the pet.
		"Gender": GlobalEnums.GENDER.GENDERLESS,    # Gender of the pet.
		"AdoptionTime": 0,                          # Unix timestamp of when the pet was adopted.                            
		"Weight": 0,                                # Weight of the pet. Is not AverageWeight.
		"Height": 0,                                # Height of the pet. Is not AverageHeight.
		"Hunger": 0,                                # How hungry the pet is from 1 - 100, where 100 is full, and 0 is starving.
		"Enjoyment": 0,                             # How much the pet enjoys the player's company.
		"Happiness": 0,                             # How happy the pet is with the player.
		"EvolutionHappiness": 0,                    # How inclined the pet is to evolve (if it can).
		"FlavorPreference": 0,                      # The pet's flavor preference.
	}
}

var SaveSlot: int = 0
var CurrentSave: Dictionary

## Attempts to load data from disk. If data is already loaded and [code]<force: bool>[/code] is off then data will not be loaded from disk.
func loadData(force: bool = false) -> void:
	if CurrentSave and not (force or CurrentSave == EmptySave):
		print("[SAVE_MANAGER / INFO]: Save already loaded, not loading again since param FORCE is off.")
		return
	BeforeLoadedData.emit()
	if not FileAccess.file_exists("user://d_slot%s.sav" % SaveSlot):
		print("[SAVE_MANAGER / INFO]: Generating save data in memory since a save file in slot %s doesn't exist." % SaveSlot)
		CurrentSave = EmptySave
		LoadedData.emit(CurrentSave)
		return
	var SaveFile: FileAccess = FileAccess.open("user://d_slot%s.sav" % SaveSlot, FileAccess.READ)
	if SaveFile == null:
		print("[SAVE_MANAGER / WARN]: Failed to load save! See error below:")
		print(FileAccess.get_open_error())
		return
	CurrentSave = SaveFile.get_var()
	LoadedData.emit(CurrentSave)
	SaveFile.close()
	print("[SAVE_MANAGER / INFO]: Loaded save file at slot %s." % SaveSlot)

func saveData(data: Dictionary) -> void:
	if not CurrentSave:
		print("[SAVE_MANAGER / WARN] No data to save! Not saving data.")
		return
	if not CurrentSave.StartedGame:
		print("[SAVE_MANAGER / WARN: Didn't pass tutorial! Not saving data.")
		return
	if OS.is_debug_build() and not SaveInDebug:
		print("[SAVE_MANAGER / INFO]: SaveInDebug is false, so the current file will not be saved.")
		return
	BeforeSavedData.emit()
	SavedData.emit(data)
	pass

func _ready() -> void:
	print("[SAVE_MANAGER / INFO]: SAVE your games, kids!")
	if AutoSave:
		var save_timer: Timer = Timer.new()
		save_timer.wait_time = AutoSaveInterval
		save_timer.one_shot = false
		save_timer.autostart = true
		save_timer.timeout.connect(func()->void:
			print("[SAVE_MANAGER / INFO] Attempting autosave.")
			saveData(CurrentSave)
		)
		add_child(save_timer)
	if AutoLoadData:
		print("[SAVE_MANAGER / INFO]: Autoloading data.")
		loadData()
		pass
