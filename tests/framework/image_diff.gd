class_name ImageDiff
extends RefCounted
## Image comparison utility for golden-screenshot tests.
##
## Compares two images pixel-by-pixel allowing a small per-pixel RGB delta
## (to absorb font hinting / AA noise) and computes the fraction of pixels
## that differ beyond that threshold.

## Per-channel delta (0..255) allowed before a pixel is considered different.
const DEFAULT_PIXEL_TOLERANCE: int = 4

## Fraction of differing pixels above which the screenshots are considered
## a mismatch. 0.01 = 1% of pixels may diverge.
const DEFAULT_FRACTION_TOLERANCE: float = 0.01


class Result extends RefCounted:
	var matches: bool = false
	var differing_pixels: int = 0
	var total_pixels: int = 0
	var fraction: float = 0.0
	var reason: String = ""
	var diff_image: Image = null


## Compare `actual` vs `expected`. Returns a Result.
## If sizes differ, the images are considered mismatched (you can't diff
## pixels that don't exist). Mode=strict rejects any nonzero diff.
static func compare(actual: Image, expected: Image,
		pixel_tolerance: int = DEFAULT_PIXEL_TOLERANCE,
		fraction_tolerance: float = DEFAULT_FRACTION_TOLERANCE) -> Result:
	var r := Result.new()
	if actual == null or expected == null:
		r.reason = "one image is null"
		return r

	if actual.get_size() != expected.get_size():
		r.reason = "size mismatch: %s vs %s" % [str(actual.get_size()), str(expected.get_size())]
		return r

	var w: int = actual.get_width()
	var h: int = actual.get_height()
	r.total_pixels = w * h

	var diff := Image.create(w, h, false, Image.FORMAT_RGBA8)

	var differing: int = 0
	for y in h:
		for x in w:
			var a := actual.get_pixel(x, y)
			var b := expected.get_pixel(x, y)
			var dr: int = int(abs(a.r - b.r) * 255.0)
			var dg: int = int(abs(a.g - b.g) * 255.0)
			var db: int = int(abs(a.b - b.b) * 255.0)
			if dr > pixel_tolerance or dg > pixel_tolerance or db > pixel_tolerance:
				differing += 1
				diff.set_pixel(x, y, Color(1, 0, 0, 1))  # red = diff
			else:
				# Dim the original as background of the diff image.
				var dimmed := Color(a.r * 0.3, a.g * 0.3, a.b * 0.3, 1.0)
				diff.set_pixel(x, y, dimmed)

	r.differing_pixels = differing
	r.fraction = float(differing) / float(r.total_pixels)
	r.diff_image = diff
	r.matches = r.fraction <= fraction_tolerance
	if not r.matches:
		r.reason = "%.3f%% pixels differ (threshold %.3f%%)" % [
			r.fraction * 100.0, fraction_tolerance * 100.0
		]
	return r


## Save an image to a user:// path, creating parent directories as needed.
static func save_png(img: Image, abs_path: String) -> Error:
	var dir := abs_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir)
	return img.save_png(abs_path)


## Load a PNG from a res:// or user:// path. Returns null on failure.
static func load_png(path: String) -> Image:
	if not FileAccess.file_exists(path):
		return null
	var img := Image.load_from_file(path)
	return img
