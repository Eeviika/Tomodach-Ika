extends Node

signal LoadedData(dataSaved: Dictionary)
signal SavedData(dataSaved: Dictionary)

const AutoSave: bool = false
const AutoSaveInterval: int = 30
const AutoLoadData: bool = false

const SaveInDebug: bool = false

const EmptySave: Dictionary = {
	"CurrentPet": null,
	"Evolution": null,
	"Hunger": 0,
	"Enjoyment": 0,
	"Happiness": 0,
	"EvolutionHappiness": 0,
	"Difficulty": GlobalEnums.Difficulty.STANDARD,
	"State": GlobalEnums.State.EGG,
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
