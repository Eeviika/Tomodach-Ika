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
	"started_game": false,									# Indicates if the player has gone past the tutorial. Files will not save if this is false.
	"name": "Player",                               		# Name of the player.
	"current_pet_namespace": "internal/dummy",      		# Namespace of the pet's data file. If a mod named "Example" added a pet named "Pet", the namespace would be "Example/Pet"
	"clock_offset": -14400,									# Clock offset. Defaults to EST.
	"volume": .7,											# Volume of the game. Defaults to 0.7. Should only be between 0 - 1.
	"difficulty": GlobalEnums.GAME_DIFFICULTY.STANDARD,  	# The game difficulty.
	"last_save": 0,                                 		# Unix timestamp of when the game was last saved.
	"money": 0,												# Money that player currently has.
	"birthdate": {											# Birthdate data of the player.
		"month": 1,
		"day": 1,
		"year": 1970
	},
	"pet_data": {
		"generated": false,									# Flag that determines whether to generate new data. Used when obtaining a new pet.
		"name": "",                                 		# Name of the pet. Used as a fallback.
		"nickname": "",                             		# Player-generated nickname of the pet.
		"original_owner": "",                       		# Name of the player.
		"state": GlobalEnums.PET_STATE.EGG,         		# State of the pet.
		"gender": GlobalEnums.PET_GENDER.GENDERLESS,		# Gender of the pet.
		"adoption_time": 0,                         		# Unix timestamp of when the pet was adopted.                            
		"weight": 0,                                		# Weight of the pet. Is not AverageWeight.
		"height": 0,                                		# Height of the pet. Is not AverageHeight.
		"hunger": 0,                                		# How hungry the pet is from 1 - 100, where 100 is full, and 0 is starving.
		"enjoyment": 0,                             		# How much the pet enjoys the player's company.
		"happiness": 0,                             		# How happy the pet is with the player.
		"evolution_happiness": 0,                   		# How inclined the pet is to evolve (if it can).
		"flavor_preference": 0,                     		# The pet's flavor preference.
	}
}

var save_slot: int = 0
var current_save: Dictionary
var logger: Logger

func update_data() -> void:
	if not current_save:
		logger.warn("Attempted to update save data without loading it first!")
		return
	if current_save.has_all(EmptySave.keys()):
		logger.info("No data to update.")
		return
	logger.info("Updating save data.")
	for key: String in EmptySave.keys():
		current_save.get_or_add(key, EmptySave[key])

## Attempts to load data from disk. If data is already loaded and [code]<force: bool>[/code] is off then data will not be loaded from disk.
func load_data(force: bool = false) -> void:
	if current_save and not (force or current_save == EmptySave):
		logger.info("Save already loaded, not loading again since param FORCE is off.")
		return
	BeforeLoadedData.emit()
	if not FileAccess.file_exists("user://d_slot%s.sav" % save_slot):
		logger.info("Generating save data in memory since a save file in slot %s doesn't exist." % save_slot)
		current_save = EmptySave
		LoadedData.emit(current_save)
		return
	var SaveFile: FileAccess = FileAccess.open("user://d_slot%s.sav" % save_slot, FileAccess.READ)
	if SaveFile == null:
		logger.warn("Failed to load save! See error below:")
		logger.error(error_string(FileAccess.get_open_error()))
		return
	current_save = SaveFile.get_var()
	update_data()
	LoadedData.emit(current_save)
	SaveFile.close()
	logger.info("Loaded save file at slot %s." % save_slot)

## Saves the current data to disk.
func save_data(data: Dictionary) -> void:
	if not current_save:
		logger.warn("No data to save! Not saving data.")
		return
	if not current_save.started_game:
		logger.warn("Didn't pass tutorial! Not saving data.")
		return
	if OS.is_debug_build() and not SaveInDebug:
		logger.info("SaveInDebug is false, so the current file will not be saved.")
		return
	BeforeSavedData.emit()
	SavedData.emit(data)
	pass

func _ready() -> void:
	logger = Logger.new(self)
	if AutoSave:
		var save_timer: Timer = Timer.new()
		save_timer.wait_time = AutoSaveInterval
		save_timer.one_shot = false
		save_timer.autostart = true
		save_timer.timeout.connect(func()->void:
			logger.info("Attempting autosave.")
			save_data(current_save)
		)
		add_child(save_timer)
	if AutoLoadData:
		logger.info("Autoloading data.")
		load_data()
		pass
