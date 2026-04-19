extends Resource
class_name OreQualityLot
## Resource class representing a batch of ore with quality attributes.
## Used for storage tracking and harvester output calculations.

## Quality attributes (1-1000 range)
var er: float = 500  # Extraction Rate
var cr: float = 500  # Crystal Resonance
var cd: float = 500  # Charge Density
var dr: float = 500  # Density Rating
var fl: float = 500  # Fragment Load
var hr: float = 500  # Heat Resistance
var ma: float = 500  # Malleability
var pe: float = 500  # Potential Energy
var sr: float = 500  # Shock Resistance
var ut: float = 500  # Unit Toughness


## Grade computed from ER: A (≥800), B (≥600), C (≥400), D (≥200), F (<200)
var grade: String:
	get:
		if er >= 800:
			return "A"
		elif er >= 600:
			return "B"
		elif er >= 400:
			return "C"
		elif er >= 200:
			return "D"
		else:
			return "F"


## Generate a randomised ore quality lot based on deposit tier.
static func generate(tier: String) -> OreQualityLot:
	var mean: float
	var std_dev: float

	match tier:
		"poor":
			mean = 250.0
			std_dev = 80.0
		"average":
			mean = 500.0
			std_dev = 120.0
		"rich":
			mean = 750.0
			std_dev = 100.0
		"motherlode":
			mean = 900.0
			std_dev = 60.0
		_:
			mean = 500.0
			std_dev = 100.0

	var lot = _create_lot()
	lot.er = _clamp_attribute(_randn_normal(mean, std_dev))
	lot.cr = _clamp_attribute(_randn_normal(mean, std_dev))
	lot.cd = _clamp_attribute(_randn_normal(mean, std_dev))
	lot.dr = _clamp_attribute(_randn_normal(mean, std_dev))
	lot.fl = _clamp_attribute(_randn_normal(mean, std_dev))
	lot.hr = _clamp_attribute(_randn_normal(mean, std_dev))
	lot.ma = _clamp_attribute(_randn_normal(mean, std_dev))
	lot.pe = _clamp_attribute(_randn_normal(mean, std_dev))
	lot.sr = _clamp_attribute(_randn_normal(mean, std_dev))
	lot.ut = _clamp_attribute(_randn_normal(mean, std_dev))
	return lot


## Calculate BER output using the harvester formula.
## Formula: base_ber × (concentration/100) × (er/1000) × upgrade_mult
##          + (fl/1000 × base_ber × 0.5)
func ber_output(base_ber: float, concentration: float, upgrade_mult: float) -> float:
	var multiplier_chain = base_ber * (concentration / 100.0) * (er / 1000.0) * upgrade_mult
	var fl_bonus = (fl / 1000.0) * base_ber * 0.5
	return multiplier_chain + fl_bonus


## Serialize to dictionary for save persistence.
func to_dict() -> Dictionary:
	return {
		"er": str(er),
		"cr": str(cr),
		"cd": str(cd),
		"dr": str(dr),
		"fl": str(fl),
		"hr": str(hr),
		"ma": str(ma),
		"pe": str(pe),
		"sr": str(sr),
		"ut": str(ut),
		"grade": grade,
	}


## Deserialize from dictionary.
static func from_dict(d: Dictionary) -> OreQualityLot:
	var lot = _create_lot()
	lot.er = float(d.get("er", "500"))
	lot.cr = float(d.get("cr", "500"))
	lot.cd = float(d.get("cd", "500"))
	lot.dr = float(d.get("dr", "500"))
	lot.fl = float(d.get("fl", "500"))
	lot.hr = float(d.get("hr", "500"))
	lot.ma = float(d.get("ma", "500"))
	lot.pe = float(d.get("pe", "500"))
	lot.sr = float(d.get("sr", "500"))
	lot.ut = float(d.get("ut", "500"))
	return lot


## Create a new lot instance.
static func _create_lot() -> Object:
	var lot = Resource.new()
	lot.set_script(load("res://data/ore_quality_lot.gd"))
	return lot


## Generate normally distributed random value with Box-Muller transform.
static func _randn_normal(mean: float, std_dev: float) -> float:
	var u1 = randf()
	var u2 = randf()
	var z = sqrt(-2.0 * log(u1)) * cos(2.0 * PI * u2)
	return mean + z * std_dev


## Clamp attribute to valid range [1, 1000].
static func _clamp_attribute(value: float) -> float:
	return clamp(value, 1.0, 1000.0)
