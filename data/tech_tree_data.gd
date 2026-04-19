## Tech Tree constants - node definitions with costs and prerequisites.
## Branch 1: Extraction, Branch 2: Processing & Crafting, Branch 3: Expansion

const NODES: Dictionary = {
	# --- Branch 1: Extraction ---
	"1.A": {"name": "Drone Drill I",           "rp_cost": 50,   "cr_cost": 50,   "branch": "Extraction", "requires": []},
	"1.B": {"name": "Drone Drill II",          "rp_cost": 150,  "cr_cost": 100,  "branch": "Extraction", "requires": ["1.A"]},
	"1.C": {"name": "Drone Drill III",         "rp_cost": 300,  "cr_cost": 200,  "branch": "Extraction", "requires": ["1.B"]},
	"1.D": {"name": "Drone Drill IV",          "rp_cost": 600,  "cr_cost": 400,  "branch": "Extraction", "requires": ["1.C"]},

	"1.E": {"name": "Drone Cargo Rack I",      "rp_cost": 50,   "cr_cost": 75,   "branch": "Extraction", "requires": []},
	"1.F": {"name": "Drone Cargo Rack II",     "rp_cost": 150,  "cr_cost": 150,  "branch": "Extraction", "requires": ["1.E"]},
	"1.G": {"name": "Drone Cargo Rack III",    "rp_cost": 300,  "cr_cost": 300,  "branch": "Extraction", "requires": ["1.F"]},
	"1.H": {"name": "Drone Cargo Rack IV",     "rp_cost": 600,  "cr_cost": 600,  "branch": "Extraction", "requires": ["1.G"]},

	"1.P": {"name": "Heavy Drone Unlock",      "rp_cost": 100,  "cr_cost": 0,    "branch": "Extraction", "requires": []},
	"1.Q": {"name": "Refinery Drone Unlock",   "rp_cost": 300,  "cr_cost": 0,    "branch": "Extraction", "requires": ["1.P"]},
	"1.R": {"name": "Survey Drone Unlock",     "rp_cost": 200,  "cr_cost": 0,    "branch": "Extraction", "requires": []},

	"1.S": {"name": "Drone Speed Boost I",     "rp_cost": 80,   "cr_cost": 80,   "branch": "Extraction", "requires": []},
	"1.T": {"name": "Drone Speed Boost II",    "rp_cost": 200,  "cr_cost": 200,  "branch": "Extraction", "requires": ["1.S"]},
	"1.U": {"name": "Drone Speed Boost III",   "rp_cost": 400,  "cr_cost": 400,  "branch": "Extraction", "requires": ["1.T"]},

	"1.X": {"name": "Drone Coordination",      "rp_cost": 500,  "cr_cost": 300,  "branch": "Extraction", "requires": []},
	"1.Y": {"name": "Fleet Automation",        "rp_cost": 1500, "cr_cost": 800,  "branch": "Extraction", "requires": ["1.X"]},

	"1.Z": {"name": "Crystal Bore",            "rp_cost": 400,  "cr_cost": 1500, "branch": "Extraction", "requires": ["1.C"]},

	# --- Branch 2: Processing & Crafting ---
	"2.1": {"name": "Metallurgy I",            "rp_cost": 200,  "cr_cost": 400,  "branch": "Processing", "requires": []},
	"2.2": {"name": "Metallurgy II",           "rp_cost": 500,  "cr_cost": 1000, "branch": "Processing", "requires": ["2.1"]},
	"2.3": {"name": "Advanced Smelting",       "rp_cost": 1500, "cr_cost": 3000, "branch": "Processing", "requires": ["2.2"]},

	"2.A": {"name": "Energy Efficiency I",     "rp_cost": 100,  "cr_cost": 200,  "branch": "Processing", "requires": []},
	"2.B": {"name": "Energy Efficiency II",    "rp_cost": 300,  "cr_cost": 500,  "branch": "Processing", "requires": ["2.A"]},
	"2.C": {"name": "Solar Mastery",           "rp_cost": 1000, "cr_cost": 2000, "branch": "Processing", "requires": ["2.B"]},

	"2.P": {"name": "Automation Core",         "rp_cost": 100,  "cr_cost": 0,    "branch": "Processing", "requires": []},
	"2.Q": {"name": "Trade Algorithms",        "rp_cost": 500,  "cr_cost": 1000, "branch": "Processing", "requires": ["2.P"]},
	"2.R": {"name": "Market Mastery",          "rp_cost": 2000, "cr_cost": 5000, "branch": "Processing", "requires": ["2.Q"]},

	"2.S": {"name": "Crafting Specialization", "rp_cost": 300,  "cr_cost": 600,  "branch": "Processing", "requires": []},
	"2.T": {"name": "Expert Fabrication",      "rp_cost": 800,  "cr_cost": 2000, "branch": "Processing", "requires": ["2.S"]},
	"2.U": {"name": "Master Artisan",          "rp_cost": 2000, "cr_cost": 5000, "branch": "Processing", "requires": ["2.T"]},

	"2.V": {"name": "Sample Analysis I",       "rp_cost": 100,  "cr_cost": 0,    "branch": "Processing", "requires": []},
	"2.W": {"name": "Sample Analysis II",      "rp_cost": 300,  "cr_cost": 300,  "branch": "Processing", "requires": ["2.V"]},

	"2.X": {"name": "Fabricator Unlock",       "rp_cost": 800,  "cr_cost": 0,    "branch": "Processing", "requires": ["2.1"]},
	"2.Y": {"name": "Drone Fabricator Unlock", "rp_cost": 3000, "cr_cost": 0,    "branch": "Processing", "requires": ["2.X"]},
	"2.Z": {"name": "Advanced Fabrication",    "rp_cost": 1200, "cr_cost": 2000, "branch": "Processing", "requires": ["2.X"]},

	# --- Branch 3: Expansion ---
	"3.1": {"name": "Logistics I",             "rp_cost": 100,  "cr_cost": 100,  "branch": "Expansion", "requires": []},
	"3.2": {"name": "Logistics II",            "rp_cost": 300,  "cr_cost": 300,  "branch": "Expansion", "requires": ["3.1"]},
	"3.3": {"name": "Logistics III",           "rp_cost": 800,  "cr_cost": 800,  "branch": "Expansion", "requires": ["3.2"]},
	"3.4": {"name": "Grand Fleet",             "rp_cost": 2000, "cr_cost": 2000, "branch": "Expansion", "requires": ["3.3"]},
	"3.5": {"name": "Armada",                  "rp_cost": 5000, "cr_cost": 5000, "branch": "Expansion", "requires": ["3.4"]},

	"3.A": {"name": "Expanded Storage I",      "rp_cost": 50,   "cr_cost": 100,  "branch": "Expansion", "requires": []},
	"3.B": {"name": "Expanded Storage II",     "rp_cost": 150,  "cr_cost": 250,  "branch": "Expansion", "requires": ["3.A"]},
	"3.C": {"name": "Expanded Storage III",    "rp_cost": 400,  "cr_cost": 600,  "branch": "Expansion", "requires": ["3.B"]},

	"3.P": {"name": "Warp Theory",             "rp_cost": 2000, "cr_cost": 0,    "branch": "Expansion", "requires": []},
	"3.Q": {"name": "Builder Drone Unlock",    "rp_cost": 300,  "cr_cost": 0,    "branch": "Expansion", "requires": []},
	"3.R": {"name": "Cargo Drone Unlock",      "rp_cost": 1000, "cr_cost": 0,    "branch": "Expansion", "requires": ["3.Q"]},

	"3.S": {"name": "Survey Tool Mk.II",       "rp_cost": 400,  "cr_cost": 200,  "branch": "Expansion", "requires": []},
	"3.T": {"name": "Survey Tool Mk.III",      "rp_cost": 1500, "cr_cost": 500,  "branch": "Expansion", "requires": ["3.S"]},
	"3.U": {"name": "Geological Memory",       "rp_cost": 800,  "cr_cost": 400,  "branch": "Expansion", "requires": ["3.S"]},

	"3.X": {"name": "Research Amplifier",      "rp_cost": 500,  "cr_cost": 500,  "branch": "Expansion", "requires": []},
	"3.Y": {"name": "Quantum Research",        "rp_cost": 1500, "cr_cost": 2000, "branch": "Expansion", "requires": ["3.X"]},

	"3.Z": {"name": "Fuel Efficiency I",       "rp_cost": 300,  "cr_cost": 300,  "branch": "Expansion", "requires": []},
	"3.Z2": {"name": "Fuel Efficiency II",      "rp_cost": 800,  "cr_cost": 800,  "branch": "Expansion", "requires": ["3.Z"]},
	"3.Z3": {"name": "Fuel Efficiency III",     "rp_cost": 2000, "cr_cost": 2000, "branch": "Expansion", "requires": ["3.Z2"]},
}
