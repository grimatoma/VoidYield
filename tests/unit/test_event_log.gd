extends "res://tests/framework/test_case.gd"
## TDD unit tests for EventLog.

const EventLogScript = preload("res://autoloads/event_log.gd")

var log


func before_each() -> void:
	log = EventLogScript.new()
	add_child(log)


func after_each() -> void:
	if log and log.is_inside_tree():
		log.queue_free()


func test_initial_empty() -> void:
	assert_eq(log.entries.size(), 0, "Should start empty")


func test_add_entry_stores_it() -> void:
	log.add("Test message", "test")
	assert_eq(log.entries.size(), 1, "Should have one entry")
	assert_eq(log.entries[0].message, "Test message")
	assert_eq(log.entries[0].category, "test")


func test_add_trims_to_max() -> void:
	for i in range(EventLogScript.MAX_ENTRIES + 50):
		log.add("Message %d" % i)

	assert_eq(log.entries.size(), EventLogScript.MAX_ENTRIES, "Should trim to max")


func test_get_recent_returns_count() -> void:
	for i in range(30):
		log.add("Message %d" % i)

	var recent = log.get_recent(10)
	assert_eq(recent.size(), 10, "Should return 10 recent")
	assert_eq(recent[0].message, "Message 29", "Most recent first")


func test_filter_by_category() -> void:
	log.add("Error 1", "error")
	log.add("Info 1", "info")
	log.add("Error 2", "error")
	log.add("Info 2", "info")

	var errors = log.filter_by_category("error")
	assert_eq(errors.size(), 2, "Should filter to 2 errors")
	assert_eq(errors[0].message, "Error 2", "Should be in order")


func test_entry_added_signal_fires() -> void:
	var signal_received = []
	log.entry_added.connect(func(msg, cat):
		signal_received.append({"message": msg, "category": cat})
	)

	log.add("Test", "general")

	assert_eq(signal_received.size(), 1, "Signal should fire")
	assert_eq(signal_received[0].message, "Test")


func test_clear_empties_log() -> void:
	log.add("Message 1")
	log.add("Message 2")
	assert_eq(log.entries.size(), 2)

	log.clear()

	assert_eq(log.entries.size(), 0, "Should be empty after clear")
