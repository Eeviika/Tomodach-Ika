extends Node

signal Tick(CurrentTime: float)

var ticks_passed: int = 0

var danger_zone: bool = false

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
    current_time = Time.get_unix_time_from_system()
    await SaveManager.LoadedData
    time_offset = SaveManager.current_save.ClockOffset
    last_tick_time = current_time
    print("[CLOCK / INFO]: Clock initialized.")

func _process(delta: float) -> void:
    current_time += delta
    if delta >= 1:
        print("[CLOCK / WARN]: Delta was 1 or higher.  Delta value was: ", delta)
    if delta >= 3 and danger_zone:
        print("[CLOCK / WARN]: Game exceeded 3 seconds of delta time and we attempted to catch up to tick rate last frame! Returning to title screen...")
        # TODO: Player should return to title screen here. For now, we'll just close the game. Since games aren't being saved right now, I'll change this later.
        get_tree().quit(GlobalEnums.ERRORCODES.PREFORMANCE_FAILSAFE)
        return
    if current_time >= last_tick_time + (tick_interval*3):
        print("[CLOCK / WARN]: Last tick took %fs, is the game being slowed down? (Ticks should typically take %fs - %fs for this game...)" % [delta, tick_interval*.8, tick_interval*1.2])
        print("[CLOCK / WARN]: If the game freezes for up to 3 seconds past this, the game will be saved and will return to the title screen.")
        danger_zone = true
    while current_time >= last_tick_time + tick_interval:
        Tick.emit(current_time)
        last_tick_time += tick_interval
        ticks_passed += 1

func get_current_time() -> Dictionary:
    return Time.get_datetime_dict_from_unix_time(int(current_time))