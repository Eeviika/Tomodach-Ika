extends Node

signal Tick(CurrentTime: float)

var TicksPassed: int = 0

var DangerZone: bool = false

var CurrentTime: float = 0.0
var TickTime: float = 0.0
var TickInterval: float = 0.05
var Offset: float = 0.0:
    get:
        return Offset
    set(value):
        CurrentTime -= Offset
        Offset = value
        CurrentTime += Offset
        TickTime = CurrentTime

func _ready() -> void:
    CurrentTime = Time.get_unix_time_from_system()
    TickTime = CurrentTime
    print("[CLOCK / INFO]: Clock initialized.")

func _process(delta: float) -> void:
    CurrentTime += delta
    if delta >= 1:
        print("[CLOCK / WARN]: Delta was 1 or higher.  Delta value was: ", delta)
    if delta >= 3 and DangerZone:
        print("[CLOCK / WARN]: Game exceeded 3 seconds of delta time and we attempted to catch up to tick rate last frame! Returning to title screen...")
        # TODO: Player should return to title screen here. For now, we'll just close the game. Since games aren't being saved right now, I'll change this later.
        get_tree().quit(GlobalEnums.ERRORCODES.PREFORMANCE_FAILSAFE)
        return
    if CurrentTime >= TickTime + (TickInterval*3):
        print("[CLOCK / WARN]: Last tick took %fs, is the game being slowed down? (Ticks should typically take %fs - %fs for this game...)" % [delta, TickInterval*.8, TickInterval*1.2])
        print("[CLOCK / WARN]: If the game freezes for up to 3 seconds past this, the game will be saved and will return to the title screen.")
        DangerZone = true
    while CurrentTime >= TickTime + TickInterval:
        Tick.emit(CurrentTime)
        TickTime += TickInterval
        TicksPassed += 1

func getCurrentTime() -> Dictionary:
    return Time.get_time_dict_from_unix_time(int(floorf(CurrentTime)))