extends Object
class_name Logger

const debug_uses_print_debug: bool = true

enum MessageLevels {DEBUG, INFO, WARN, ERROR}

var owner: Node = null
var focused_message_level: MessageLevels = MessageLevels.INFO

func _to_string() -> String:
	return "Logger"

func _init(_owner: Node) -> void:
	if OS.is_debug_build():
		focused_message_level = MessageLevels.DEBUG
	owner = _owner

func _create_prefix(level: MessageLevels) -> String:
	var time_date_dict: Dictionary = Time.get_datetime_dict_from_system()
	var date_string: String = "%d-%d-%d" % [time_date_dict.year, time_date_dict.month, time_date_dict.day]
	var time_string: String = "%d:%d:%d" % [time_date_dict.hour, time_date_dict.minute, time_date_dict.second]
	var owner_string: String = "%s (%s)/%s" % [owner.name, owner.get_class(), MessageLevels.find_key(level)]
	var prefix: String = "[%s %s][%s]:" % [date_string, time_string, owner_string]
	return prefix

func _log_message(level: MessageLevels, message: String) -> void:
	if not owner:
		push_error("Did not assign owner to Logger object.")
		return
	var prefix: String = _create_prefix(level)
	var full_message: String = "%s %s" % [prefix, message]

	match level:
		MessageLevels.DEBUG:
			if debug_uses_print_debug:
				print_debug(full_message)
			else:
				print(full_message)
		MessageLevels.INFO:
			print(full_message)
		MessageLevels.WARN:
			print(full_message)
			push_warning(full_message)
		MessageLevels.ERROR:
			printerr(full_message)
			push_error(full_message)

func switch_focused_message_level(level: MessageLevels) -> void:
	focused_message_level = level

func debug(message: String) -> void:
	if focused_message_level > MessageLevels.DEBUG:
		return
	_log_message(MessageLevels.DEBUG, message)

func info(message: String) -> void:
	if focused_message_level > MessageLevels.INFO:
		return
	_log_message(MessageLevels.INFO, message)

func warn(message: String) -> void:
	if focused_message_level > MessageLevels.WARN:
		return
	_log_message(MessageLevels.WARN, message)

func error(message: String) -> void:
	_log_message(MessageLevels.ERROR, message)

