class_name TestCase
extends Node
## Base class for all VoidYield tests.
##
## Subclasses declare `test_*` methods. The runner instantiates the subclass,
## calls `before_each()` + test method + `after_each()`, catching assertion
## failures and recording them as failed tests. Any exception (via
## push_error + _failed flag) aborts the current test but not the suite.
##
## Assertions record failures on self and continue; the test is marked failed
## if any assertion failed. This avoids GDScript's lack of exception throwing.

# --- Discovered test methods (populated by runner) ---
var _test_methods: Array[String] = []

# --- Per-test accumulators (reset in before_each) ---
var _assert_failures: Array[String] = []
var _current_test: String = ""

# --- Reporting, set by the runner at construction time ---
var reporter: Object = null  # TestRunner; duck-typed to avoid cycles.


## Override to return a human-readable suite name.
func suite_name() -> String:
	return get_script().resource_path.get_file().get_basename()


## Override. Runs before every test_* method.
func before_each() -> void:
	pass


## Override. Runs after every test_* method (even on failure).
func after_each() -> void:
	pass


## Override. One-time setup for the whole suite.
func before_all() -> void:
	pass


## Override. One-time teardown for the whole suite.
func after_all() -> void:
	pass


## Override. Return false to skip the suite (e.g. if running headless and
## the suite needs a viewport).
func should_run() -> bool:
	return true


# --- Assertion helpers ---
# All assertions append to _assert_failures and return a bool indicating
# pass/fail so tests can short-circuit if they want to.

func assert_eq(actual, expected, msg: String = "") -> bool:
	if actual == expected:
		return true
	_record("expected %s  got %s" % [str(expected), str(actual)], msg)
	return false


func assert_ne(actual, expected, msg: String = "") -> bool:
	if actual != expected:
		return true
	_record("did not expect %s" % [str(expected)], msg)
	return false


func assert_true(cond: bool, msg: String = "") -> bool:
	if cond:
		return true
	_record("expected true  got false", msg)
	return false


func assert_false(cond: bool, msg: String = "") -> bool:
	if not cond:
		return true
	_record("expected false  got true", msg)
	return false


func assert_gt(a, b, msg: String = "") -> bool:
	if a > b:
		return true
	_record("expected %s > %s" % [str(a), str(b)], msg)
	return false


func assert_ge(a, b, msg: String = "") -> bool:
	if a >= b:
		return true
	_record("expected %s >= %s" % [str(a), str(b)], msg)
	return false


func assert_lt(a, b, msg: String = "") -> bool:
	if a < b:
		return true
	_record("expected %s < %s" % [str(a), str(b)], msg)
	return false


func assert_near(a: float, b: float, tolerance: float = 0.001, msg: String = "") -> bool:
	if abs(a - b) <= tolerance:
		return true
	_record("expected %f ~= %f (±%f)" % [a, b, tolerance], msg)
	return false


func assert_not_null(v, msg: String = "") -> bool:
	if v != null:
		return true
	_record("expected non-null", msg)
	return false


func assert_null(v, msg: String = "") -> bool:
	if v == null:
		return true
	_record("expected null  got %s" % str(v), msg)
	return false


func assert_has(container, key, msg: String = "") -> bool:
	var ok: bool = false
	if container is Dictionary:
		ok = container.has(key)
	elif container is Array or container is PackedStringArray:
		ok = key in container
	if ok:
		return true
	_record("container missing key %s" % str(key), msg)
	return false


func fail(msg: String) -> void:
	_record(msg, "")


func _record(detail: String, msg: String) -> void:
	var line := detail
	if msg != "":
		line = "%s — %s" % [msg, detail]
	_assert_failures.append(line)


# --- State reset ---
#
# Tests should call this in before_each to get a clean autoload snapshot.
# Save files are cleared by the test entry script; this only mutates the
# live singleton.
func reset_game_state() -> void:
	## Delegates to GameState.reset_to_defaults() then clears runtime-only fields
	## (current_interaction_target) that are not part of persisted save data.
	if GameState == null:
		# In headless test mode, GameState might not auto-initialize; fetch it from the tree.
		GameState = get_tree().root.get_node_or_null("GameState")
	if GameState != null:
		GameState.reset_to_defaults()
		GameState.current_interaction_target = null
		GameState.interaction_target_changed.emit(null)


# --- Wait helpers (for E2E tests) ---

## Await N physics frames so input/state has time to propagate.
func wait_frames(n: int = 1) -> void:
	for i in n:
		await get_tree().process_frame


## Await real-time seconds.
func wait_seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds, true, false, true).timeout


# --- Result access (used by the runner) ---

func consume_failures() -> Array[String]:
	var out: Array[String] = _assert_failures.duplicate()
	_assert_failures.clear()
	return out
