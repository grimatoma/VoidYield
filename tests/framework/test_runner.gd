class_name TestRunner
extends Node
## Test runner.
##
## Discovers test scripts under res://tests/unit/ and res://tests/e2e/,
## instantiates them, invokes every `test_*` method, and reports pass/fail
## counts. Supports CLI flags:
##   --filter=<substr>   Only run suites whose file name contains <substr>.
##   --update-golden     Write actual screenshots to tests/golden/ on mismatch
##                       (use sparingly — inspect first).
##   --unit-only         Skip e2e suites.
##   --e2e-only          Skip unit suites.
##
## Exits with code 0 on full pass, 1 on any failure. Prints a machine-readable
## summary line "[SUMMARY] passed=N failed=M suites=S" last.

const UNIT_DIR := "res://tests/unit"
const E2E_DIR  := "res://tests/e2e"

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0
var suites_run: int = 0

var update_golden: bool = false
var filter_substr: String = ""
var run_unit: bool = true
var run_e2e: bool = true

signal finished(exit_code: int)


func run() -> void:
	_parse_args()
	_log_header()

	var suites: Array[String] = []
	if run_unit:
		suites.append_array(_discover_tests(UNIT_DIR))
	if run_e2e:
		suites.append_array(_discover_tests(E2E_DIR))

	suites.sort()

	for suite_path in suites:
		if filter_substr != "" and suite_path.find(filter_substr) == -1:
			continue
		await _run_suite(suite_path)

	print("")
	print("[SUMMARY] passed=%d failed=%d suites=%d" % [passed_tests, failed_tests, suites_run])
	var code: int = 0 if failed_tests == 0 else 1
	finished.emit(code)


func _parse_args() -> void:
	var args := OS.get_cmdline_user_args()
	for a in args:
		if a == "--update-golden":
			update_golden = true
		elif a == "--unit-only":
			run_e2e = false
		elif a == "--e2e-only":
			run_unit = false
		elif a.begins_with("--filter="):
			filter_substr = a.substr("--filter=".length())


func _log_header() -> void:
	print("==================================================")
	print(" VoidYield Test Runner")
	print("  update_golden = %s" % str(update_golden))
	print("  filter        = '%s'" % filter_substr)
	print("  unit / e2e    = %s / %s" % [str(run_unit), str(run_e2e)])
	print("==================================================")


func _discover_tests(dir_path: String) -> Array[String]:
	var out: Array[String] = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_warning("[TestRunner] cannot open %s" % dir_path)
		return out
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if not dir.current_is_dir() and fname.ends_with(".gd"):
			out.append("%s/%s" % [dir_path, fname])
		fname = dir.get_next()
	dir.list_dir_end()
	return out


func _run_suite(script_path: String) -> void:
	var script: Script = load(script_path)
	if script == null:
		print("  [SKIP] %s — failed to load" % script_path)
		return
	var inst: Object = script.new()
	if not inst is Node:
		print("  [SKIP] %s — not a Node" % script_path)
		return
	var suite: Node = inst

	# Provide references for E2E suites.
	if suite.has_method("set_runner_flags"):
		suite.set_runner_flags(update_golden)
	add_child(suite)
	await get_tree().process_frame

	if suite.has_method("should_run") and not suite.should_run():
		print("  [SKIP-SUITE] %s" % script_path)
		suite.queue_free()
		return

	suites_run += 1
	var suite_label := script_path.get_file().get_basename()
	print("")
	print("▶ %s" % suite_label)

	# Discover test methods.
	var method_names: Array[String] = []
	for m in suite.get_method_list():
		var mn: String = m["name"]
		if mn.begins_with("test_"):
			method_names.append(mn)
	method_names.sort()

	if suite.has_method("before_all"):
		await suite.before_all()

	for mname in method_names:
		total_tests += 1
		if suite.has_method("before_each"):
			await suite.before_each()

		# Clear failures before this test.
		if suite.has_method("consume_failures"):
			suite.consume_failures()

		await suite.call(mname)

		if suite.has_method("after_each"):
			await suite.after_each()

		var failures: Array = []
		if suite.has_method("consume_failures"):
			failures = suite.consume_failures()

		if failures.is_empty():
			passed_tests += 1
			print("  ✓ %s" % mname)
		else:
			failed_tests += 1
			print("  ✗ %s" % mname)
			for f in failures:
				print("      └ %s" % str(f))

	if suite.has_method("after_all"):
		await suite.after_all()

	suite.queue_free()
