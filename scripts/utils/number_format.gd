class_name NumberFormat
## NumberFormat — Display formatting helpers for the HUD.
## v0.1: Simple comma formatting. BigNumber not needed until numbers exceed ~100k.

static func format_number(value: int) -> String:
	## Formats an integer with comma separators: 1234 → "1,234"
	var str_val = str(absi(value))
	var result = ""
	var count = 0
	for i in range(str_val.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = str_val[i] + result
		count += 1
	if value < 0:
		result = "-" + result
	return result


static func format_with_unit(value: int) -> String:
	## Formats with K/M/B suffixes for large numbers: 1500 → "1.5K"
	## Only kicks in above 10,000 to keep small numbers readable.
	if value < 10000:
		return format_number(value)
	elif value < 1000000:
		return "%.1fK" % (value / 1000.0)
	elif value < 1000000000:
		return "%.1fM" % (value / 1000000.0)
	else:
		return "%.1fB" % (value / 1000000000.0)


static func format_storage(current: int, capacity: int) -> String:
	## Formats storage display: "42/50"
	return "%s/%s" % [format_number(current), format_number(capacity)]


static func format_time(seconds: float) -> String:
	## Formats seconds into readable time: 90.0 → "1:30"
	var mins: int = floori(seconds / 60.0)
	var secs = int(seconds) % 60
	if mins > 0:
		return "%d:%02d" % [mins, secs]
	else:
		return "%ds" % secs
