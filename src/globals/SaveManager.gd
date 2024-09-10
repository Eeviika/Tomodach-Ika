extends Node

signal LoadedData(dataSaved: Dictionary)
signal SavedData(dataSaved: Dictionary)

const AutoSave: bool = false
const AutoSaveInterval: int = 30
const AutoLoadData: bool = false

const SaveInDebug: bool = false

const EmptySave: Dictionary = {
    "Name": "",                                     # Name of the player.
	"CurrentPetNamespace": null,                    # Namespace of the pet's data file. If a mod named "Example" added a pet named "Pet", the namespace would be "Example/Pet"
    "Difficulty": GlobalEnums.DIFFICULTY.STANDARD,  # The game difficulty.
    "LastSave": 0,                                  # Unix timestamp of when the game was last saved.
    "Birthday": 0,                                  # Unix timestamp of the player's birthday.
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
        "EvolutionHappiness": 0,                    # How inclined the pet is to evolve.
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
	if not FileAccess.file_exists("user://d_slot%s.sav" % SaveSlot):
		print("[SAVE_MANAGER / INFO]: Generating save file since it doesn't exist.")
		var TempSave: FileAccess = FileAccess.open("user://d_slot%s.sav" % SaveSlot, FileAccess.WRITE)
		TempSave.store_var(EmptySave)
		TempSave.close()
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
	if OS.is_debug_build() and not SaveInDebug:
		print("[SAVE_MANAGER / INFO]: SaveInDebug is false, so the current file will not be saved.")
		return
	SavedData.emit(data)
	pass

func _ready() -> void:
	EmptySave.make_read_only()
	print("[SAVE_MANAGER / INFO]: acknowledge my existence please :(")
	if AutoLoadData:
		print("[SAVE_MANAGER / INFO]: Autoloading data.")
		loadData()
		pass
