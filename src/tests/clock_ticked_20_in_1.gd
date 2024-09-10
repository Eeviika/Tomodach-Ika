extends Node

var ticks: int = 0
signal completed(success:bool, message:String)
var description: String = "This is a test."

func _init() -> void:
    description = "Checks if 20 ticks have been reached within 1 second."

func main() -> void:
    var on_clock_tick: Callable = func(_time:float) -> void:
        ticks += 1
    Clock.Tick.connect(on_clock_tick)
    await get_tree().create_timer(1).timeout
    if not ticks >= 20:
        completed.emit(false, "20 ticks were not reached. Reached %s ticks in one second." % ticks)
        return
    completed.emit(true, "Reached 20 ticks in one second.")


