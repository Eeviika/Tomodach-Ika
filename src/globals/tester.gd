extends Node

## Chooses if tests will be handled in Release builds. You should probably keep this off.
@export var RunInRelease: bool = false
var HandleTests: bool = false

func processLaunchArguments()->Dictionary:
    var arguments: Dictionary = {}
    for argument: String in OS.get_cmdline_args():
        if not argument.contains("--"): continue
        if argument.contains("="):
            var key_value: PackedStringArray = argument.split("=")
            arguments[key_value[0].trim_prefix("--")] = key_value[1]
        else:
            arguments[argument.trim_prefix("--")] = ""
    return arguments

func _ready() -> void:
    if processLaunchArguments().has("tests_enabled"):
        RunInRelease = true
    if not OS.is_debug_build() and RunInRelease == false:
        print("[TESTER / INFO]: We are running a Release build, so I won't handle tests. To bypass this, run the game with command argument '--testing_enabled'.")
    print("[TESTER / INFO] Scanning for tests in res://src/tests/.")
    for file: String in DirAccess.get_files_at("res://src/tests/"):
        print("[TESTER / INFO] Found \"%s\". Loading." % file)
        var test: Node = Node.new()
        test.name = file.substr(0, file.find("."))
        var script: GDScript = load("res://src/tests/"+file)
        test.set_script(script)
        add_child(test)
    print("[TESTER / INFO] Tests will run in a few seconds.")
    await get_tree().create_timer(2).timeout
    print("[TESTER / INFO] Running tests.")
    for test: Node in get_children():
        test.completed.connect(func(success: bool, message: String)->void:
            testCompleted(success, message, test)
        )
        test.main()

func testCompleted(success: bool, message: String, node: Node) -> void:
    if success:
        print("[TESTER / PASS] Test \"%s\": %s, %s " % [node.name, success, message])
        node.queue_free()
        return
    print("[TESTER / FAIL] Test \"%s\": %s, %s " % [node.name, success, message])
    push_warning("Test \"%s\": %s, %s" % [node.name, success, message])
    node.queue_free()

