extends Node

signal Tick(CurrentTime: float)

var CurrentTime: float
var TickTime: float
var TicksPassed: int = 0
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
    if CurrentTime >= TickTime + (TickInterval*2.5):
        print("[CLOCK / WARN]: Catching up to regular tick rate!")
    while CurrentTime >= TickTime + TickInterval:
        Tick.emit(CurrentTime)
        TickTime += TickInterval
        TicksPassed += 1

func getCurrentTime() -> Dictionary:
    return Time.get_time_dict_from_unix_time(int(floorf(CurrentTime)))