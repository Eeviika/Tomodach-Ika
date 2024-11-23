extends Node

signal Tick(CurrentTime: float)

var ticks_passed: int = 0

var danger_zone: bool = false

var logger: Logger

var current_time: float = 0.0
var last_tick_time: float = 0.0
var tick_interval: float = 0.05
var time_offset: float = 0:
	get:
		return time_offset
	set(value):
		current_time -= time_offset
		time_offset = value
		current_time += time_offset
		last_tick_time = current_time

func _ready() -> void:
	logger = Logger.new(self)
	current_time = Time.get_unix_time_from_system()
	await SaveManager.LoadedData
	time_offset = SaveManager.current_save.clock_offset
	last_tick_time = current_time
	logger.info("Clock initialized.")

func _process(delta: float) -> void:
	current_time += delta
	if delta >= 1:
		logger.warn("Tick took one second or longer. Delta was %f." % delta)
	if delta >= 3 and danger_zone:
		logger.warn("Tick took three seconds or longer constantly. Returning to title screen...")
		# TODO: Player should return to title screen here. For now, we'll just close the game. Since games aren't being saved right now, I'll change this later.
		get_tree().quit(GlobalEnums.ERROR_CODES.PREFORMANCE_FAILSAFE)
		return
	if current_time >= last_tick_time + (tick_interval*3):
		logger.warn("Last tick took %f, is the game being slowed down?" % delta)
		danger_zone = true
	while current_time >= last_tick_time + tick_interval:
		Tick.emit(current_time)
		last_tick_time += tick_interval
		ticks_passed += 1

func get_current_time() -> Dictionary:
	return Time.get_datetime_dict_from_unix_time(int(current_time))
