extends Node

const ENABLE_ON_DEBUG: bool = false
const IDLE_TIME: int = 60

var IdleTimer: Timer

var logger: Logger
var max_fps: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	logger = Logger.new(self)
	
	if OS.is_debug_build() and not ENABLE_ON_DEBUG:
		logger.info("Battery Saver is disabled on debug builds.")
		queue_free()
		return
	
	logger.info("Battery Saver is enabled.")

	max_fps = Engine.max_fps
	
	IdleTimer = Timer.new()
	IdleTimer.wait_time = IDLE_TIME
	IdleTimer.one_shot = true
	IdleTimer.autostart = true
	add_child(IdleTimer)

	IdleTimer.timeout.connect(_idle_timeout)
	
func _idle_timeout() -> void:
	var new_fps: int = int(max_fps / 2.0)
	logger.info("Idle timeout reached. Setting max FPS to %f." %  new_fps)
	Engine.max_fps = new_fps

func _input(event: InputEvent) -> void:
	if not IdleTimer: return;
	if event is InputEventMouseMotion or event is InputEventScreenTouch or event is InputEventKey:
		IdleTimer.start()
		if ProjectSettings.get_setting("application/run/max_fps") != max_fps:
			logger.info("User input detected. Setting max FPS to %f." % max_fps)
			Engine.max_fps = max_fps

func _process(_delta: float) -> void:
	if not DisplayServer.window_is_focused() and not ProjectSettings.get_setting("application/run/low_processor_mode"):
		logger.info("Window is not focused. Beginning low processor mode.")
		ProjectSettings.set_setting("application/run/low_processor_mode", true)
	elif DisplayServer.window_is_focused() and ProjectSettings.get_setting("application/run/low_processor_mode"):
		logger.info("Window is focused. Ending low processor mode.")
		ProjectSettings.set_setting("application/run/low_processor_mode", false)
