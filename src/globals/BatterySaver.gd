extends Node

const ENABLE_ON_DEBUG: bool = false
const IDLE_TIME: int = 0

var IdleTimer: Timer
var logger: Logger
var max_fps: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	logger = Logger.new(self)
	
	if OS.is_debug_build() and not ENABLE_ON_DEBUG:
		logger.info("Battery Saver is disabled on debug builds.")
		queue_free()
		return
	
	IdleTimer = Timer.new()
	add_child(IdleTimer)
	
	IdleTimer.wait_time = IDLE_TIME


# func _process(delta: float) -> void:
# 	pass
