extends Node
## Central event log for game messages. Stores recent events and emits on new entries.

const MAX_ENTRIES: int = 200

var entries: Array = []

signal entry_added(message: String, category: String)


func add(message: String, category: String = "general") -> void:
	var timestamp = Time.get_ticks_msec() / 1000.0
	var entry = {
		"message": message,
		"category": category,
		"timestamp": timestamp,
	}
	entries.insert(0, entry)

	if entries.size() > MAX_ENTRIES:
		entries.resize(MAX_ENTRIES)

	entry_added.emit(message, category)


func get_recent(count: int = 20) -> Array:
	var result = []
	for i in range(mini(count, entries.size())):
		result.append(entries[i])
	return result


func clear() -> void:
	entries.clear()


func filter_by_category(cat: String) -> Array:
	var result = []
	for entry in entries:
		if entry.get("category") == cat:
			result.append(entry)
	return result
