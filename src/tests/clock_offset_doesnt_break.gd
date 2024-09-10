extends Node

var ticks: int = 0
signal completed(success:bool, message:String)
var description: String = "This is a test."

func _init() -> void:
    description = "Checks if adjusting the clock offset breaks the clock."

func main() -> void:
    var expectedClockTime: float = Clock.CurrentTime + 1
    Clock.Offset = 1
    if not (Clock.CurrentTime == expectedClockTime):
        completed.emit(false, "Clock may be unstable, doesn't match the expected offseted clock time.\nExpected %f VS %f" % [expectedClockTime, Clock.CurrentTime])
    if not (Clock.CurrentTime == Clock.TickTime):
        completed.emit(false, "Didn't update TickTime.")
    await get_tree().create_timer(5).timeout
    Clock.Offset = 0
    completed.emit(true, "Clock appears to be functional.")