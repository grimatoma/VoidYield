# VoidYield — Game Design Document
**Version:** 0.2 (Major Revision — Survey/Harvest/Swarm/Craft systems added)
**Date:** 2026-04-18
**Based on:** Full codebase review + SWG resource/harvester research

---

## Table of Contents

1. [Vision & Philosophy](#1-vision--philosophy)
2. [Core Loop](#2-core-loop)
3. [Automation Progression](#3-automation-progression)
4. [Resource Systems & Quality Attributes](#4-resource-systems--quality-attributes)
5. [Surveying System](#5-surveying-system)
6. [Harvester System](#6-harvester-system)
7. [Buildings & Machines](#7-buildings--machines)
8. [Drone Swarm Management](#8-drone-swarm-management)
9. [Vehicle System](#9-vehicle-system)
10. [Factory Production System](#10-factory-production-system)
11. [Spacecraft Construction](#11-spacecraft-construction)
12. [Planet Stranding](#12-planet-stranding)
13. [Tech Tree & Upgrades](#13-tech-tree--upgrades)
14. [Prestige & Sector System](#14-prestige--sector-system)
15. [Galaxy & Multi-Planet Expansion](#15-galaxy--multi-planet-expansion)
16. [Logistics System](#16-logistics-system)
17. [Scaffolding Assessment](#17-scaffolding-assessment)
18. [Economy Model & Key Numbers](#18-economy-model--key-numbers)
19. [Feel & Feedback Design](#19-feel--feedback-design)
20. [Consumption & Crew System](#21-consumption--crew-system)
21. [Industrial Sites & Planet Constraints](#22-industrial-sites--planet-constraints)
22. [Production Dashboard & UI Systems](#23-production-dashboard--ui-systems)
23. [Art Direction](#24-art-direction)
24. [Planet Specialization Meta](#25-planet-specialization-meta)
25. [Implementation Priorities](#26-implementation-priorities)
26. [Visual Mockups](#visual-mockups)
---

## 1. Vision & Philosophy

VoidYield is an **automation incremental game** set in space. The player begins as a lone miner swinging a drill at surface rocks — and ends as the architect of a self-sustaining galactic mining empire operating across multiple planets without a single button press from its creator.

The core emotional arc: **discovery** → **relief** → **mastery** → **awe**.

- *Discovery* when the survey tool reveals a vein of Krysite with an Overall Quality of 847 in an unmapped corner of the asteroid field.
- *Relief* when the first harvester drone circuit runs automatically — fueling rigs, emptying hoppers, depositing to storage — while you're doing something else.
- *Mastery* when you build an avionics core from high-CD Crystal Lattice and the rocket's navigation system hits 94% precision.
- *Awe* when you open the galaxy map and see cargo routes, harvester networks, and drone swarms operating simultaneously across three worlds.

**Design pillars:**

**1. Exploration earns automation.** You don't buy better ore — you find it. The survey tool is the player's most important instrument. A discovered high-quality deposit is a trophy that drives the entire economy.

**2. Every machine needs tending, until it doesn't.** Harvesters run out of gas. Hoppers fill up. Drones wear paths into the ground. The automation loop is not about making maintenance disappear — it's about making maintenance someone else's problem. Your drones handle it so you can go discover the next deposit.

**3. Resources have jobs, not just prices.** Each ore type and quality attribute unlocks things that others cannot. A high-PE Krysite deposit is worth more than its sell price because it makes better engine fuel cells. Hunting for the right quality for the right schematic is the game's deepest loop.

**4. The swarm is the spectacle.** The ultimate visual payoff of VoidYield is watching dozens of drones executing overlapping task queues simultaneously — some fueling harvesters, some carrying ore, some building structures, some flying cargo routes between planets. The drone swarm is both the mechanism and the reward.

**5. Each planet is a commitment.** Landing on a new world is exciting but not reversible without effort. You arrive with limited fuel, no established infrastructure, and unknown resource quality. The pressure to build before you can leave makes exploration feel consequential.

**6. Quality cascades through everything.** When a crafter in SWG found a metal with exceptional malleability, every tool made from it was demonstrably better. VoidYield uses the same principle: ore quality attributes flow from deposit → refined material → crafted component → finished machine. Players hunt specific attribute combinations for specific builds.

---

## 2. Core Loop

### 2.1 The Three-Level Loop

#### Moment-to-Moment (the heartbeat)
At any given moment, the player is doing one of five things:

**Surveying** — walking an area with the Survey Tool active, reading concentration readouts, marking waypoints for promising deposits.

**Mining manually** — using the held-interaction on surface OreNodes, the direct loop from early game that never entirely goes away (some nodes contain unique high-quality samples worth collecting by hand).

**Managing harvesters** — physically visiting a harvester to check fuel level, empty the hopper, inspect extraction rate, or repair degradation.

**Tasking drones** — opening the Fleet Command panel, assigning drones to zones or individual tasks, watching the swarm spin up and begin executing.

**Crafting** — sitting at a Crafting Station, selecting a schematic, loading material ingredients, watching the quality calculation, confirming production.

The critical insight: **none of these are passive waits**. The player always has something to do. The automation loop is not about reducing player choices — it's about elevating them. You stop personally emptying hoppers so you can personally survey for the best deposit on the planet.

#### Session-to-Session (the progress arc)

Each session should end with the player having crossed at least one meaningful threshold. The progression chain:

```
Find new deposit (survey) 
  → Place harvester 
    → Establish drone maintenance circuit 
      → Analyze sample (Research Lab) 
        → Match deposit quality to a schematic need 
          → Craft better component 
            → Expand fleet/speed/capacity 
              → Survey more efficiently 
                → Find better deposit → (repeat, larger scale)
```

The outer loop: each cycle of this chain should produce infrastructure that makes the next cycle faster or easier.

#### Long-Term (the empire arc)

The long-term satisfaction is a galaxy map showing harvester networks on three planets, cargo ships crossing routes, drone swarm traffic visible as colored motion lines on each world, and a credit accumulation rate that dwarfs any individual manual action. The player is now directing, not doing.

### 2.2 The Exploration Sub-loop

A critical new sub-loop introduced in this version:

```
Survey grid → find high concentration point → mark waypoint
  → send sample to Research Lab (or analyze manually)
    → compare attribute profile to schematic needs
      → place harvester at ideal concentration point
        → check deposit yield estimate (how long before exhaustion)
          → decide: invest in Heavy Harvester or just a Personal one?
```

This loop is never fully automated — it requires player judgment. No drone can decide whether a Krysite deposit with OQ 612, CR 843, CD 290 is better suited for engine components or avionics parts. That's a *design decision*, and making good ones is how skilled players pull ahead.

### 2.3 The Maintenance Sub-loop (before automation)

Early-to-mid game, before drone swarms handle it:

```
Harvester is running → gas level falling → drone/player brings gas canister → harvester refueled
Harvester hopper filling → drone/player empties hopper → ore deposited to Storage Depot → harvester resumes
```

This maintenance cadence is intentionally a little annoying in Phase 1-2. It creates the friction that makes drone swarm automation feel like liberation.

### 2.4 The Consumption Loop (mid-to-late game)

A fourth loop emerges once colonists arrive — the demand side of the economy:

```
Population tier grows (Colonists, Technicians, Engineers…)
  → tier's Basic Needs must be supplied continuously
    → Processing Plants convert raw inputs to consumables
      → Fabricators assemble intermediate goods consumed by higher tiers
        → If supply drops, that tier's productivity drops proportionally
          → Drone efficiency falls → harvesters slow → less ore → less production
            → Fix the supply chain before the cascade compounds
```

The consumption loop binds together every other loop: a harvester stall causes a factory stall causes a crew shortage causes lower harvester efficiency, which deepens the stall. Understanding the chain — and designing supply buffers that break it — is the core intellectual challenge of mid-to-late VoidYield.

---

## 3. Automation Progression

### Phase 0: Bootstrapping (0 – 150 CR)
**Duration:** First 10–15 minutes

The player has no harvesters, no drones, no Survey Tool. They mine surface OreNodes by hand, carry ore to the depot, sell it, and immediately feel the friction of doing everything manually. They receive a basic Survey Tool in the starting equipment.

**Phase activities:**
- Manual mining (held interaction, 1.5s base)
- First survey: walk around with Survey Tool, find their first Vorax deposit — concentration shows as 34%, deposit grade C. Not exciting, but it introduces the mechanic.
- Carry, deposit, sell loop
- Buy: Drill Bit Mk.II (50 CR), Cargo Pockets (75 CR), Thruster Boots (60 CR)

**Key friction:** Everything is manual. The survey result just sits there because they can't afford a harvester yet.
**Graduation event:** First Personal Mineral Harvester placed at surveyed deposit and producing ore autonomously.

### Phase 1: First Harvesters (150 – 1,000 CR)
**Duration:** 15–60 minutes

The player has 1–3 harvesters running. They personally refuel them and empty hoppers. The harvester loop is running but the player is the maintenance crew. They begin to feel the appeal of not being the maintenance crew.

**Phase activities:**
- Place first harvester over surveyed Vorax deposit
- Carry gas canisters from Gas Collector or buy from Trade Terminal (gas is cheap early)
- Empty hoppers manually (carry deposited ore to Storage Depot)
- Survey for Krysite — rare, higher concentration points are valuable
- Deploy first Scout Drone: "MINE" task on a surface node (still useful alongside harvester for rare ore)
- Discover that high-concentration deposits extract faster: surveying for the best spot matters

**Key friction:** The maintenance loop is the player's job. Harvesters run out of gas while they're doing other things. The hopper fills and the harvester stops.
**Graduation event:** First Refinery Drone assigned to a circuit: fuel harvester → empty hopper → carry to depot → loop. The player realizes they never have to check that harvester again.

### Phase 2: The Drone Circuit (1,000 – 5,000 CR)
**Duration:** 1–3 hours

The maintenance loop is handed to drones. The player now focuses on survey work and expanding the harvester network. They begin using the zone management system. The Research Lab is built; the tech tree opens.

**Phase activities:**
- Assign Refinery Drones to FUEL and EMPTY harvester circuits
- Zone management: draw a mining zone, assign 5 Scout Drones to AUTO-MINE within it
- Survey systematically: walk the full map grid, mark all deposit locations and grades
- Identify best available deposit per ore type for crafting
- Build Research Lab (requires Crystal Lattices from Krysite refining)
- First crafting: Drill Bit from Vorax Steel Plates + Krysite Alloy Rods (simple schematic, quality matters even here)

**Key friction:** Research Lab requires Crystal Lattices — first time Aethite from Planet B is needed as an ingredient (Crystal Lattices can also be bought at high markup until Planet B is visited). First crafting quality decisions arise.
**Graduation event:** Harvester network fully drone-maintained. Player steps back and watches swarm work without touching anything.

### Phase 3: Quality Hunting (5,000 – 30,000 CR)
**Duration:** 3–8 hours

The player's base automation is running. Now the game becomes about *quality*. Standard Vorax Steel Plates are fine, but a rocket hull made from high-MA, high-SR Steel Plates withstands re-entry heat better. The player hunts for specific deposit quality profiles. This phase introduces the spacecraft construction project.

**Phase activities:**
- Systematic quality survey: the player now cares about attribute values, not just concentration
- Research Lab analysis: send samples for full attribute breakdown (not just grade)
- Match deposit qualities to schematic requirements for rocket components
- Place Harvesters specifically at high-quality deposits for critical components
- Begin Spacecraft Construction project: build Launchpad, start crafting rocket components
- Heavy Harvesters come online for mass extraction of bulk materials

**Key friction:** The rocket requires specific attribute thresholds. A mediocre deposit won't meet the Navigation Core schematic's CD requirement. The player must survey more aggressively.
**Graduation event:** Spacecraft fully assembled and launched. Planet B (Vortex Drift) unlocked. First experience of planet stranding.

### Phase 4: Multi-Planet Operations (30,000 – 200,000 CR)
**Duration:** 8–20 hours

The player manages two planets simultaneously, each with their own surveyed deposit network, harvester grid, and drone swarm. Planet B's unique ore attributes open new crafting possibilities. Cargo Ships ferry materials between worlds. The drone fleet numbers in the dozens.

**Phase activities:**
- Systematic survey of Planet B: different ore types, different quality ranges
- Build second outpost: Refinery, Research Lab, Gas Collector, Harvester network
- Cargo Ship Bay established: inter-planet ore logistics automated
- Craft advanced components only possible with Planet B materials (Void Cores for Warp Gate)
- A3 unlock: visit A2 AND have produced 10 Void Cores
- Drone fleet reaches 20–50 active units

**Graduation event:** Both planets fully automated. No manual maintenance on either world. A3 survey begins.

### Phase 5: Galactic Automation (200,000+ CR)
**Duration:** 20+ hours

Three planets, each with a fully surveyed deposit map, harvester network, and drone swarm. The player's job is macro: which deposits are worth upgrading to Heavy Harvesters? Which planets should export what to which? When to trigger prestige? The Galactic Hub on A3 enables the sector completion sequence.

**Graduation event:** Sector Complete triggered. Permanent bonus selected. New sector begins with bonuses stacked.

---

## 4. Resource Systems & Quality Attributes

### 4.1 The Core Problem (Solved)

All existing ore types sell for different amounts but serve no unique industrial purpose. A high-value deposit is strictly better, with no trade-off. This section redesigns resources from the ground up so that **every deposit is unique, every ore type has a job, and quality attributes drive meaningful decisions**.

### 4.2 VoidYield Quality Attributes

Inspired directly by Star Wars Galaxies' resource attribute system. Each deposit instance has a random value (1–1000) for each applicable attribute, within class-specific caps. Not all attributes apply to all ore types.

| Abbrev | Name | Meaning in VoidYield | Primary Uses |
|---|---|---|---|
| **OQ** | Overall Quality | General material purity and integrity | Almost all schematics — the baseline |
| **CR** | Crystal Resonance | Energy conduction potential; how well the material channels power | Power cells, engines, electronics, energy conduits |
| **CD** | Charge Density | Electrical conductivity at the molecular level | Avionics, navigation cores, sensor arrays |
| **DR** | Density Rating | Mass-to-volume structural ratio | Hull framing, pressure vessels, structural members |
| **FL** | Fragment Load | Ore yield per extraction cycle; how efficiently the deposit releases material | Directly boosts Harvester output units/cycle |
| **HR** | Heat Resistance | Thermal tolerance under sustained heat | Engine casings, thruster nozzles, re-entry shields |
| **MA** | Malleability | Workability and ductility; how easily shaped under fabrication | Any component requiring precise shaping |
| **PE** | Potential Energy | Energy density per unit mass | Fuel cells, batteries, power cores, rocket propellant |
| **SR** | Shock Resistance | Impact and vibration resistance | Hull plating, landing gear, impact-rated components |
| **UT** | Unit Toughness | Hardness and wear resistance | Drill bits, cutting surfaces, bearing races |
| **ER** | Extraction Rate | How readily the deposit yields to mechanical extraction | Multiplies Harvester BER directly |

**Attribute value rules:**
- All values 1–1000 (as in SWG)
- Each ore class has caps: minimum and maximum possible values per attribute
- A deposit's values are fixed on world generation (or planet arrival for new planets) and do not change
- Missing attributes (e.g., FL on Voidstone) are not present on the deposit card — schematics that call for FL and receive Voidstone without FL treat the missing attribute as 1000 (irrelevant / not limiting)

**Quality grades (player-facing abstraction):**

The raw numerical value is revealed by Research Lab analysis. Before analysis, the Survey Tool shows only a letter grade derived from OQ:

| Grade | OQ Range | Meaning |
|---|---|---|
| F | 1–199 | Poor — workable for bulk needs, not for precision crafting |
| D | 200–399 | Below average — useful for early structures |
| C | 400–599 | Average — the baseline for most functional items |
| B | 600–799 | Good — noticeably better results in most schematics |
| A | 800–949 | Excellent — premium quality, highly sought |
| S | 950–1000 | Near-perfect — extremely rare, drive the economy |

**Important:** OQ grade is the first indicator, but specific schematics care about specific attributes. A deposit graded B on OQ might have SR 950 (S-tier for hull plating) but PE 120 (F-tier for fuel). You can't know until you analyze.

### 4.3 Ore Types — Revised with Attribute Profiles

#### Vorax (Common Mineral, A1)
- **Sell price:** 1 CR/unit raw, 5 CR/unit refined to Steel Plate (3 Vorax → 1 Plate)
- **Relevant attributes:** OQ, MA, SR, DR, UT, FL
- **Unique role:** Steel Plates are the **construction material**. Buildings, structural frames, and drone chassis all require them. High-MA Vorax makes more workable Steel Plates (components crafted from them get a fabrication quality bonus). High-FL Vorax yields more Steel Plates per batch.
- **OQ caps:** 50–900 (always available in some quality)
- **Availability:** ~70% of mineral deposits on A1

#### Krysite (Rare Crystal, A1)
- **Sell price:** 5 CR/unit raw, 20 CR/unit refined to Alloy Rod (2 Krysite → 1 Rod)
- **Relevant attributes:** OQ, CR, CD, PE, HR
- **Unique role:** Alloy Rods gate ship construction AND advanced buildings. High-CR Krysite makes Alloy Rods that conduct energy more efficiently — engines using these rods produce more thrust per unit fuel. High-CD Krysite produces better avionics. High-PE Krysite improves fuel cell energy density.
- **OQ caps:** 100–850
- **Availability:** ~20% of mineral deposits on A1, slow respawn (60s surface nodes, 5-day deposit lifespan)

#### Aethite (Common Crystal, Planet B)
- **Sell price:** 8 CR/unit raw, 30 CR/unit refined to Crystal Lattice (2 Aethite → 1 Lattice)
- **Relevant attributes:** OQ, CR, MA, PE, CD
- **Unique role:** Crystal Lattices fuel Research (consume for +10 RP) and are required for advanced computing components. High-CR Aethite Crystal Lattices make better navigation cores (higher flight precision). High-PE Aethite improves power cores.
- **OQ caps:** 80–920
- **Availability:** ~65% of mineral deposits on Planet B

#### Voidstone (Rare Crystal, Planet B)
- **Sell price:** 15 CR/unit raw, 60 CR/unit refined to Void Core (1 Voidstone → 1 Core)
- **Relevant attributes:** OQ, PE, HR, SR, ER
- **Unique role:** Void Cores are required for Warp Gates, Cargo Ship Bays, and the prestige trigger. High-PE Voidstone makes Void Cores with more raw energy — essential for Warp Gate efficiency. High-SR Voidstone produces more durable structural components for harsh environments.
- **OQ caps:** 200–980 (can be very high quality — deposits are rare but rewarding)
- **Availability:** 3–5 fixed deposit locations on Planet B only, very slow deposit depletion

#### Gas (Atmospheric Resource, all planets)
- **Sell price:** 0.5 CR/unit raw (primarily used, not sold)
- **Relevant attributes:** PE, FL, CR
- **Unique role:** **Harvester fuel.** Every mineral/crystal harvester consumes gas over time. Without gas, harvesters stop. Gas deposits are everywhere, but high-PE gas burns more efficiently (same energy from fewer units). This makes a good gas deposit almost as valuable as a good ore deposit.
- **OQ caps:** 20–700 (gas quality is generally lower — it's a utility resource)
- **Availability:** ~40% of all deposits are gas — plentiful, but must be actively managed

#### Scrap Metal (Drop from Vorax, ~70% chance per mine)
- **Not tradeable**
- **Uses:** Building maintenance (1 Scrap/building/repair) + emergency Steel Plate (2 Scrap → 1 Plate at Refinery)

#### Shards (Drop from Krysite/Aethite mining, ~50–60% chance)
- **Sell price:** 3 CR/unit, or process to Energy Cell (3 Shards → 1 Cell, 10 CR)
- **Uses:** Energy Cells power buildings and Battery Banks. A constant supply of Shards → Energy Cells is needed to run an advanced base.

### 4.4 Deposit System — The Core Difference from OreNodes

The existing OreNode system (surface rocks, fixed locations, fast respawn) **is kept** for early-game manual mining. But the primary extraction system is now **Deposits** — hidden resource concentrations found by surveying.

**How deposits differ from OreNodes:**

| | OreNode (surface) | Deposit (subsurface) |
|---|---|---|
| Visibility | Always visible in world | Invisible — found by survey only |
| Access method | Player walk-up + held interaction | Harvester building placed over it |
| Respawn | Fast (30–120s) | Slow to never (limited total yield) |
| Attributes | None (just an ore type) | Full 11-attribute quality profile |
| Concentration | Not applicable | 1–100% at any given location |
| Spatial variation | Fixed node positions | Random concentration peaks across planet |
| Depletes? | No (respawns forever) | Yes — each deposit has a total yield cap |

**Deposit yield cap:** Each deposit has a total unit count before exhaustion. Typical ranges:
- Small deposit: 500–2,000 units total
- Medium deposit: 2,000–8,000 units total
- Large deposit: 8,000–30,000 units total
- Massive deposit: 30,000–100,000 units total (very rare, found via Elite Survey Tool)

When a deposit exhausts, it's gone. A new deposit of the same ore class will eventually appear elsewhere on the planet (random location, fresh attributes), but the specific quality profile is never repeated.

**The temporal pressure:** A deposit with OQ 920 will not last forever. The player must decide: build an Elite Harvester to maximize extraction speed before it runs out, or milk it slowly with a Personal Harvester? This is one of the game's most interesting resource management decisions.

---

## 5. Surveying System

### 5.1 The Survey Tool

The Survey Tool is an equippable item — the player equips it from the inventory (replaces the current "nearest interactable" prompt with a survey readout UI). Three tiers:

| Tier | Name | Cost | Range | Precision | Special |
|---|---|---|---|---|---|
| I | Field Scanner | Starting equipment | 30px radius | ±15% concentration | Shows ore type + rough concentration |
| II | Geological Scanner | 800 CR + 10 Alloy Rods | 60px radius | ±5% concentration | Shows grade + estimated yield size |
| III | Quantum Survey Array | 4,000 CR + 20 Crystal Lattices + 5 Void Cores | 120px radius | ±1% concentration | Full attribute readout (same as Research Lab) |

### 5.2 The Survey Process

**Step 1: Equip the Survey Tool**
Player opens inventory, selects Survey Tool. The HUD switches to Survey Mode: the interaction prompt disappears, replaced by a proximity readout showing nearby deposit signals.

**Step 2: Walk the Area**
As the player moves, the Survey Tool continuously samples. The readout shows:
- Ore types detected in range (e.g., "VORAX ● KRYSITE ●")
- Concentration % for nearest deposit of each type (e.g., "VORAX: 24%" → "VORAX: 31%" → "VORAX: 44%" as the player moves toward a peak)
- Signal strength indicator (arrows pointing toward highest concentration)

**Step 3: Find the Peak**
The player follows the signal toward the concentration peak — the point with the highest % value. At the peak, the readout stabilizes. With Tier I scanner: the player sees concentration (e.g., 67%) and ore type. With Tier II: they also see deposit grade (e.g., "Grade B") and size estimate (e.g., "LARGE DEPOSIT").

**Step 4: Mark the Waypoint**
Player presses [M] to place a survey marker at the current location. The marker is visible on the minimap and in-world as a floating icon. Markers can be labeled (text entry). The marker stores: ore type, concentration %, grade (if Tier II+), date surveyed.

**Step 5: Sample Analysis (optional, requires Research Lab)**
The player can collect a physical sample at the deposit location: press [E] to take a sample. This gives a Sample Item in inventory. Bring the sample to a Research Lab and interact to begin analysis. Analysis takes 2 minutes (real time). Results: full 11-attribute profile of the deposit. Without a Research Lab, or without a Tier III scanner, the full attribute breakdown is never revealed by surveying alone.

**Survey strategy guidance (in-game tip):** "Walk a grid pattern. Every 40 steps, check the concentration reading. When it rises, turn toward it."

### 5.3 The Scan — Time-Based, Not Instant

Surveying is not a button press. The Survey Tool requires the player to **hold still** (or move very slowly) while it completes a scan cycle. This is intentional — it creates a loop of "scout roughly → slow down at signal → hold for full scan → decide → move on."

**Scan stages:**
1. **Quick Read (0.5s, always active while equipping tool):** Shows ore types present within range. No concentration %, no quality. Used while walking.
2. **Passive Scan (2s hold still):** Concentration % appears for detected ores, ±15% accuracy (Tier I). Survey tone stabilizes.
3. **Full Scan (6s hold still):** Deposit grade letter (F through S) appears. Tier II+ also shows estimated size category and lifetime range.
4. **Deep Scan (15s hold still, Tier II+ only):** Reveals 3 highest attributes by name and approximate value ("CR: ~740", "PE: ~380"). Tier III reveals all 11 attributes precisely.

**Why this creates a good loop:** Walking through the field feels like exploration — the quick read pings as you pass concentrations. When you get a strong signal, you stop. You hold for a full scan. If the grade is promising, you mark it and hold for a deep scan to plan your schematic use. The ritual feels deliberate.

**Scan UI:** A circular reticle appears around the player when the tool is equipped. It pulses outward once per second (passive scan rate). When a full scan completes, the reticle flashes amber and the result card appears at screen-right.

### 5.4 The Survey Result Card

When a Full Scan (6s) completes, a result card appears in the upper-right HUD:

```
┌─────────────────────────────────────┐
│  ◆ KRYSITE VEIN DETECTED            │
│  Concentration: 71%                 │
│  Grade: B   Size: LARGE             │
│  Est. Lifetime: 6–9 hrs (standard)  │
│                                     │
│  [M] Mark Waypoint  [J] Add Journal │
└─────────────────────────────────────┘
```

After a Deep Scan (15s), the card expands:
```
┌─────────────────────────────────────┐
│  ◆ KRYSITE VEIN DETECTED            │
│  Concentration: 71% at this point   │
│  Grade: B   Size: LARGE             │
│  Est. Lifetime: 6–9 hrs             │
│                                     │
│  STANDOUT ATTRIBUTES:               │
│  CR (Crystal Resonance): ~740 ████░ │
│  PE (Potential Energy):  ~610 ███░░ │
│  CD (Charge Density):    ~290 ██░░░ │
│                                     │
│  [M] Mark Waypoint  [J] Add Journal │
└─────────────────────────────────────┘
```

The Research Lab full analysis adds the remaining 8 attributes and precise values.

### 5.5 The Survey Journal

The player maintains a **Survey Journal** — a persistent log of all surveyed deposits accessible from the HUD [J] key. Each journal entry shows:
- Deposit type and survey date
- Waypoint coordinates
- Grade + size + lifetime estimate
- Standout attributes (from Deep Scan, if performed)
- Status: UNSURVEYED / SURVEYED / ANALYZED / HARVESTER PLACED / DEPLETED

The journal is the player's planning tool. Before deciding which harvester to build, a skilled player reviews the journal: "I have a Grade A Krysite at 68% with CR 820 — that's my engine schematic deposit. I have a Grade B Vorax at 82% with MA 740 — that's where I put the Heavy Harvester for Steel Plates."

**Journal strategy view:** A top-down minimap overlay (separate from the world minimap) shows all waymarked deposits as icons, color-coded by ore type, with grade letter overlaid. This is the player's "deposit management board."

### 5.6 Concentration and Spatial Distribution

Each planet has a semi-random distribution of concentration peaks. A deposit doesn't have a single point — it has a bell-curve distribution, with a peak concentration at the center and lower concentrations radiating outward.

**Concentration falloff:** At the exact peak, concentration might be 78%. 30px away, it might be 55%. 60px away, 28%. The player must survey within 15px of the peak to get an accurate reading for Harvester placement.

**Why this matters for gameplay:** Placing a Harvester even slightly off-peak loses extraction efficiency. A 78% peak misread as 55% and the harvester placed at the 55% point loses ~29% extraction rate compared to optimal placement. With a Tier III scanner and precise placement, that's a permanent efficiency advantage for the life of the deposit.

### 5.4 Survey Drone (Late-Game)

After Research node 3.Q (Builder Drone Unlock), a **Survey Drone** becomes available:
- Cost: 150 CR + 5 Alloy Rods
- Behavior: When deployed, walks a programmed grid path, records all concentration peaks above a threshold (player-set), drops survey markers automatically
- Speed: slow (survey quality takes time)
- Output: populated minimap with all deposit locations, types, and rough grades
- Limitation: only reveals concentration and ore type — full attribute analysis still requires physical sample + Research Lab

This is the first fully passive survey system. Pair with Research Lab automation (drones carry samples) and the player can survey an entire new planet's deposit map within one play session.

---

## 6. Harvester System

### 6.1 Overview and Design Intent

Harvesters are stationary extraction buildings placed directly over deposit peaks. They are the backbone of the mid-to-late game economy. Their maintenance loop (fuel, hopper emptying) is intentionally active before drones take it over — and satisfying to watch drones handle automatically.

**Core formula:**

```
Units per minute = BER × (Concentration / 100) × (ER / 1000) × Upgrade_Multiplier
```

Where:
- **BER** = Base Extraction Rate (set by harvester tier)
- **Concentration** = % at placement point (from survey, 1–100)
- **ER** = Extraction Rate attribute of the target deposit (1–1000; higher = faster mining)
- **Upgrade_Multiplier** = from tech tree or harvester upgrades (default 1.0)

**Example:** A Medium Mineral Harvester (BER 11) placed at a 72% concentration Vorax deposit with ER 640:
`11 × 0.72 × (640/1000) = 11 × 0.72 × 0.64 = 5.07 units/min`

**Example at peak** — same harvester at 95% concentration, ER 850:
`11 × 0.95 × 0.85 = 8.87 units/min`

The contrast illustrates why survey precision and deposit quality both matter — the second placement produces 75% more ore than the first.

### 6.2 Harvester Types

#### Mineral Harvester (extracts Vorax, Krysite, mixed mineral deposits)

| Tier | Name | BER | Hopper | Gas/hr | Cost |
|---|---|---|---|---|---|
| Personal | Personal Mineral Extractor | 5 | 500 units | 3 gas/hr | 150 CR + 10 Steel Plates |
| Medium | Mineral Mining Installation | 11 | 1,500 units | 8 gas/hr | 500 CR + 25 Steel Plates + 5 Alloy Rods |
| Heavy | Heavy Mining Installation | 20 | 4,000 units | 18 gas/hr | 1,500 CR + 60 Steel Plates + 15 Alloy Rods |
| Elite | Elite Mining Installation | 44 | 12,000 units | 45 gas/hr | 6,000 CR + 150 Steel Plates + 50 Alloy Rods |

#### Crystal Harvester (extracts Krysite, Aethite, Voidstone — crystal-type deposits)

| Tier | Name | BER | Hopper | Gas/hr | Cost |
|---|---|---|---|---|---|
| Personal | Crystal Core Extractor | 4 | 400 units | 4 gas/hr | 200 CR + 10 Steel Plates + 5 Alloy Rods |
| Medium | Crystal Mining Array | 9 | 1,200 units | 10 gas/hr | 700 CR + 30 Steel Plates + 10 Alloy Rods |
| Heavy | Deep Crystal Array | 18 | 3,500 units | 22 gas/hr | 2,200 CR + 80 Steel Plates + 25 Alloy Rods |
| Elite | Elite Crystal Array | 40 | 10,000 units | 50 gas/hr | 8,000 CR + 200 Steel Plates + 60 Alloy Rods + 10 Void Cores |

#### Gas Collector (extracts Gas deposits — the harvester for harvester fuel)

| Tier | Name | BER | Tank Capacity | Self-powered? | Cost |
|---|---|---|---|---|---|
| Personal | Atmospheric Collector | 6 | 200 gas units | Yes (wind-powered) | 100 CR + 8 Steel Plates |
| Medium | Gas Processing Station | 14 | 600 gas units | Yes (wind-powered) | 400 CR + 20 Steel Plates + 5 Alloy Rods |
| Heavy | Deep Gas Platform | 28 | 2,000 gas units | Yes + 5 solar backup | 1,200 CR + 50 Steel Plates + 15 Alloy Rods |

**Important:** Gas Collectors are self-powered (wind and solar). They do NOT consume gas. They are the only self-sustaining harvester type. Place one near a gas deposit and it runs indefinitely (only needs hopper emptying). This is the foundation of the fuel supply chain.

### 6.3 The Fuel System

Every mineral and crystal harvester consumes **gas** continuously while running. Gas is stored in the harvester's **fuel tank** (separate from the ore hopper).

**Fuel tank capacities:**
- Personal: 50 gas units (lasts ~17 hrs at base consumption, less with higher BER usage)
- Medium: 150 gas units (lasts ~19 hrs)
- Heavy: 400 gas units (lasts ~22 hrs)
- Elite: 1,000 gas units (lasts ~22 hrs)

**What happens when fuel runs out:** The harvester halts. The hopper retains all ore already extracted. A warning icon appears above the harvester in-world. The harvester does not resume until refueled.

**Refueling:**
- Manual: player carries a Gas Canister (crafted item, holds 50 gas units) and interacts with harvester
- Drone: Refinery Drone assigned to FUEL task carries gas from Gas Collector hopper to target harvester

**Gas Canister:** Craftable at Crafting Station (5 Steel Plates + 2 Alloy Rods). Holds 50 gas units. Player carries up to 3 in inventory.

### 6.4 The Hopper System

Every harvester has a hopper — an internal storage for extracted ore. When the hopper fills, extraction halts (the machine has nowhere to put new ore).

**What happens when hopper fills:** Extraction halts. Warning icon appears. Ore already in hopper is not lost.

**Emptying the hopper:**
- Manual: player interacts with harvester → "Retrieve [N] units of [Ore Type]" → ore added to player's carried inventory → player carries to Storage Depot
- Drone: Refinery Drone assigned to EMPTY task hauls hopper contents directly to Storage Depot (no player involvement)

**Hopper strategy:** Harvesters extract at different rates. A high-BER Elite Harvester at a good deposit fills its 12,000-unit hopper in roughly 22 hours at full speed. A Personal Harvester might fill in 6–12 hours. Players in early game must check hoppers more frequently.

### 6.5 Harvester Placement Rules

1. The player must have previously surveyed the location (a survey marker must exist within 20px)
2. The player selects the harvester building from the Trade Terminal's BUILDINGS tab, enters placement mode
3. The harvester ghost highlights green when positioned over a valid deposit, red otherwise
4. Placement must be within 15px of the concentration peak for optimal rate (a placement indicator shows current placement efficiency: "87% efficiency — move closer to survey marker")
5. Harvesters cannot overlap with other buildings or be placed in blocked terrain

### 6.6 Harvester Degradation (Optional Complexity)

At full complexity, harvesters lose 1% extraction efficiency per 12 hours of operation (simulating wear on drill heads). This is visible as a declining efficiency stat on the harvester UI.

**Repair:** Interact with harvester + 2 Scrap Metal → restore to 100% efficiency.

**Drone repair:** A future drone task type (REPAIR) can automate this. In Phase 1-2, this is a manual check. In Phase 3+, Builder Drones handle it.

**Player toggle:** This mechanic can be disabled in settings for players who find it tedious rather than interesting.

### 6.7 Unique Harvesting Methods

Standard harvesters (Mineral, Crystal, Gas Collector) work only on standard deposit types. Planet-specific resources require specialized extraction structures or drone behaviors.

#### Cave Drill (Planet B — Voidstone)

Voidstone deposits sit below Planet B's cave networks, unreachable by a surface harvester. The Cave Drill anchors at a cave entrance and extends a drill assembly into the deep formation below.

- **Placement**: Must be placed at a confirmed cave entrance (dark terrain features). Use the Speeder's Survey Mount at full scan to detect the subsurface concentration below
- **BER**: 8 (lower than mineral harvesters — difficult access geometry)
- **Hopper**: 800 Voidstone units
- **Fuel**: Standard gas works; Dark Gas gives +20% BER bonus
- **Cost**: 1,800 CR + 60 Steel Plates + 20 Alloy Rods + 10 Crystal Lattices
- **Unlock**: Tech Tree Extraction branch — node "Deep Excavation" (Phase 3)

#### Gas Trap (Planet C — Dark Gas)

Dark Gas geysers vent intermittently from unstable fractures. A Gas Trap positioned over an active vent captures each eruption burst in a pressurized storage cylinder. Unlike a Gas Collector, it fills in pulses rather than continuously.

- **Placement**: Must be within 8px of an active geyser vent. Locating vents requires Full Scan or better — geyser signal is a distinct low rhythmic pulse rather than the steady rising tone of a static deposit
- **Cycle**: ~1 eruption per 8 minutes; 50–80 Dark Gas units per burst
- **Average yield**: ~50–60 units/hr (eruption-dependent, not constant)
- **Tank capacity**: 500 Dark Gas units
- **No fuel cost**: the geyser provides the pressure; the trap is entirely passive
- **Cost**: 2,400 CR + 80 Steel Plates + 30 Alloy Rods + 15 Shards
- **Unlock**: Tech Tree Extraction branch — node "Geyser Capture" (Phase 4)

#### Resonance Charge Cracking (Planet C — Resonance Crystals)

Resonance Crystals cannot be mined with any harvester. They must be fractured with a controlled charge detonation.

**Process:**
1. Craft Resonance Charges at the Fabricator (2 Shards + 1 Void Core → 1 Charge; 5 min craft time)
2. Travel to a Resonance Crystal formation (tall pale formations visible on Planet C's surface)
3. Place 2 charges at the crystal base with [E] — charges must be placed simultaneously (one drone trip does not work; requires two drones or the player placing both)
4. Wait 90 seconds for the fracture sequence to complete (audio and visual cues mark progress)
5. Harvest Resonance Shards with [E] from the broken pieces

**Output**: 40–80 Resonance Shards per crack event (CD 780–980, SR 700–950).

**Automation**: Builder Drones can carry and place charges autonomously when assigned a CRACK CRYSTAL task targeting a specific formation. A second drone (or the same drone on a second pass) handles the HARVEST task after fracture. Full automation requires two drones per formation to avoid idle time.

**Supply is finite**: Each crystal formation supports 3–5 crack cycles before depleting permanently. Formations do not respawn. Total Resonance Shard supply per Sector run is limited — plan allocations across warp tech and research upgrades carefully.

#### HARVEST FLORA Drone Behavior (Planet B — Bio-Resin)

Bio-Resin is secreted by Aethon Flora — alien plant organisms distributed across Planet B's surface. No harvester can extract it. Drones assigned the HARVEST FLORA behavior collect resin from living plants on a timed cycle.

**Setup**: The player designates a Flora Zone polygon (same zone tool used for mining zones). Any Aethon Flora organisms within the zone become harvest targets. The system scans automatically for organisms at zone creation.

**Drone behavior**: Drone travels to each flora organism in sequence, waits ~3 seconds for the resin draw animation, then moves to the next organism. On completing the zone, drone returns to Storage Depot to offload, then loops.

**Yield**: 2–5 Bio-Resin units per organism per collection cycle (~12 in-game minutes between collections). A well-populated zone of 20 organisms yields approximately 60–100 Bio-Resin units/hr.

**Flora health mechanic**: Building footprints placed inside a Flora Zone reduce organism density — the displaced plants don't return. The game warns in build mode if a placed building overlaps a Flora Zone. Players who pack buildings too densely near flora regions permanently reduce Bio-Resin capacity.

---

## 7. Buildings & Machines

Buildings are **placed objects** on the world map — purchased from the Trade Terminal's BUILDINGS tab, then placed in a valid zone via blueprint mode. Builder Drones can construct them autonomously once the player places the blueprint.

**Industrial Site slots:** Most production buildings occupy one or more Industrial Site slots — a fixed resource tied to planet size (see Section 22 for full slot rules). Slot costs are noted per building below. Harvesters placed at ore deposits are an exception — they use Deposit Slots, not Industrial Site slots.

**Slot costs at a glance:**

| Building | Slots |
|---|---|
| Processing Plant | 1 |
| Fabricator | 2 |
| Assembly Complex | 3 |
| Research Lab | 2 |
| Drone Bay | 1 |
| Gas Collector (installed) | 1 |
| Heavy Harvester | 1 |
| Cargo Ship Bay | 2 |
| Launchpad | 3 |
| Habitation Module | 1 |

### 7.1 Tier 1 — Infrastructure (Phase 0–1)

#### Gas Canister Rack
- **Cost:** 60 CR + 5 Steel Plates
- **Function:** Storage rack for 10 Gas Canisters. Drones assigned to FUEL tasks will draw from the nearest Canister Rack, not individual Gas Collector hoppers. This is the logistics node for gas distribution.

#### Storage Silo
- **Cost:** 200 CR + 15 Steel Plates
- **Function:** +100 ore storage capacity. Now tracks by resource type AND quality lot (a lot = a batch of ore from a specific deposit, preserving its quality attributes for crafting use).
- **Upgrade — Pressurized Silo:** 600 CR + 30 Steel Plates → +200 capacity
- **Upgrade — Industrial Silo:** 2,000 CR + 80 Steel Plates + 20 Alloy Rods → +500 capacity

#### Crafting Station
- **Cost:** 400 CR + 20 Steel Plates + 10 Alloy Rods
- **Function:** The primary crafting interface. Player selects a schematic, loads ingredients (pulling from quality-tracked Storage Silos), and initiates production. Base crafting time: 30s–5min depending on schematic complexity. Output quality is calculated from ingredient quality (see Section 9).
- **Replaces:** Manual "craft ship part" interaction at Spaceship node

#### Solar Panel
- **Cost:** 80 CR + 5 Steel Plates + 3 Energy Cells
- **Function:** Generates 2 Power/sec. Powers refineries and advanced buildings.
- **Max per zone:** 10

#### Battery Bank
- **Cost:** 250 CR + 10 Steel Plates
- **Function:** Stores 300 Power. Buffers supply/demand. Load Energy Cells for +50 Power each.

### 7.2 Tier 2 — Processing (Phase 2–3)

#### Ore Refinery
- **Cost:** 800 CR + 25 Steel Plates + 10 Alloy Rods
- **Power draw:** 5 Power/sec
- **Function:** Converts raw ore → refined materials per the production chain. Throughput: 1 batch per 12–20 seconds. Critically: the refinery **preserves quality attributes** from input ore into output material. A Steel Plate refined from high-MA Vorax retains the MA value for crafting purposes.
- **Batch UI:** Shows which quality lot is being processed. Player can set priority (process high-OQ lots first).

#### Research Lab
- **Cost:** 1,500 CR + 30 Crystal Lattices
- **Power draw:** 3 Power/sec
- **Function:** Generates 1 RP/min. Also handles **sample analysis**: player brings physical sample → full 11-attribute breakdown in 2 minutes. Crystal Lattices consumed: +10 RP instantly.

#### Fuel Synthesizer
- **Cost:** 600 CR + 15 Steel Plates + 8 Alloy Rods
- **Power draw:** 3 Power/sec
- **Function:** Converts Gas units into Rocket Fuel (the propellant needed for spacecraft launch and inter-planet travel). Conversion rate: 3 Gas → 1 Rocket Fuel unit. Essential on any planet where the player needs to build or refuel a rocket (see Planet Stranding, Section 11).

#### Fabricator
- **Cost:** 2,000 CR + 50 Steel Plates + 25 Alloy Rods
- **Power draw:** 8 Power/sec
- **Function:** Queue-based production of components. Handles complex multi-step schematics that the Crafting Station cannot (rocket components, advanced drone types). Quality-preserving.

### 7.3 Tier 3 — Logistics (Phase 3–4)

#### Launchpad
- **Cost:** 500 CR + 80 Steel Plates + 30 Alloy Rods + 20 Energy Cells
- **Power draw:** 2 Power/sec (standby), 0 (active — uses internal power)
- **Function:** The physical assembly point for the spacecraft. Rocket components must be carried here and assembled in sequence. Once fully assembled and fueled, the player can launch. The Launchpad replaces the current Spaceship node as the progression milestone.
- **Prerequisite:** Must be built before any rocket components can be assembled

#### Cargo Ship Bay
- **Cost:** 5,000 CR + 100 Steel Plates + 30 Void Cores
- **Power draw:** 10 Power/sec (active)
- **Function:** Automated inter-planet ore/material transport every 5 minutes (configurable manifest). Ships visible on Galaxy Map during transit.
- **Upgrade — Expanded Hold:** +50 capacity per level, max 3, 2,000 CR + 20 Alloy Rods each

#### Trade Hub
- **Cost:** 3,000 CR + 40 Alloy Rods + 20 Crystal Lattices
- **Power draw:** 4 Power/sec
- **Function:** Auto-sells configured ore types at market rate every 60 seconds. Configurable per-resource thresholds.

#### Relay Station
- **Cost:** 500 CR + 15 Alloy Rods
- **Power draw:** 1 Power/sec
- **Function:** Extends drone operating radius by 50%. Max 3 per zone.

### 7.4 Tier 4 — Empire (Phase 4–5)

#### Drone Fabricator
- **Cost:** 8,000 CR + 60 Steel Plates + 40 Alloy Rods + 20 Crystal Lattices
- **Power draw:** 6 Power/sec
- **Function:** Produces drones from materials (no CR cost). Build times use Fabricator queue.

#### Warp Gate
- **Cost:** 20,000 CR + 50 Void Cores + 100 Alloy Rods
- **Function:** Instant inter-planet travel on connected route. Requires one gate on each end.

#### Galactic Hub (A3 Only)
- **Cost:** 30,000 CR + 200 Steel Plates + 100 Alloy Rods + 50 Void Cores + 30 Crystal Lattices
- **Function:** Combined Trade Hub + Research Lab + Warp Gate. Enables Sector Complete prestige trigger.

### 7.5 Building Proximity & Range System

Some buildings have a radius of effect that creates spatial planning interest without conveyor-belt complexity.

**Gas Collectors** must be placed within 30px of a natural gas vent or confirmed gas deposit concentration peak. They cannot be placed arbitrarily and then connected via pipes — proximity IS the connection.

**Drone Bays** have a service radius (default 400px). Drones from a given Bay can only service buildings within range. Larger planets require multiple Drone Bays placed strategically — a bay near the harvesters, another near the factory cluster. The Coverage Overlay (press [O]) shows each bay's radius circle color-coded by load.

**Research Lab** has a sample intake radius (200px). Harvesters within range automatically send ore samples to the Lab at configurable intervals, triggering analysis without manual delivery. Harvesters outside the radius require a drone SAMPLE COURIER task assignment.

**Assembly Complex** receives a throughput efficiency bonus (+10%) if all three of its input-source Fabricators are placed within 80px. The game shows a "PROXIMITY BONUS: ACTIVE" indicator on the Complex when this is satisfied. This rewards tight, deliberate layouts without mandating them.

**Habitation Modules** project a comfort radius (150px). Crew in range receive a +5% productivity bonus from proximity to amenities — a small but meaningful nudge toward building crew quarters near the factory core rather than off in a corner.

---

## 8. Drone Swarm Management

### 8.1 Philosophy: The Swarm Is the Game

The drone system must scale from 1 drone (early Phase 1) to hundreds (late Phase 4-5). Managing hundreds of individual drones by hand is impossible — the system must provide tools that let the player set policy, not pick targets. But early-game, direct tasking should feel satisfying and tactile.

**Visual goal:** At peak empire scale, opening the drone traffic overlay (T key) should show dozens of colored motion lines crisscrossing each planet — mining circuits, fuel circuits, cargo routes, construction crews — all operating simultaneously. This is the visual climax of VoidYield.

### 8.2 Drone Types (Full Roster)

| Type | Cost | Speed | Carry | Role |
|---|---|---|---|---|
| Scout Drone | 25 CR | 60 | 3 | General miner — surface OreNodes and shallow deposits |
| Heavy Drone | 150 CR | 40 | 10 | High-throughput miner — dense fields |
| Refinery Drone | 75 CR | 50 | 8 | Logistics — hauls between Storage, Refineries, Harvesters |
| Survey Drone | 150 CR + 5 Alloy Rods | 35 | 0 | Surveys grid patterns, marks deposits |
| Builder Drone | 200 CR + 5 Steel Plates | 45 | 15 (materials) | Constructs buildings from blueprints |
| Cargo Drone | 500 CR + 10 Alloy Rods | 35 | 20 | Inter-planet transport (via Cargo Ship Bay) |

### 8.3 Three-Tier Control System

#### Tier 1: Direct Tasking (early game, precision control)

The player clicks an individual drone to select it (shift-click for multi-select). Then they right-click a target in the world to assign a task. Available tasks:

| Task | Target | Description |
|---|---|---|
| **MINE** | OreNode or Deposit location | Mine until full, then carry to depot |
| **CARRY** | Storage Depot or Harvester | Pick up materials from target A, deliver to target B |
| **FUEL** | Harvester | Fetch gas from nearest Gas Collector, refuel target harvester |
| **EMPTY** | Harvester | Empty hopper, carry contents to Storage Depot |
| **BUILD** | Blueprint | Fetch required materials, construct building |
| **SAMPLE** | Deposit location | Collect a physical ore sample and bring to Research Lab |
| **REPAIR** | Harvester or Building | Fetch Scrap Metal, repair target to 100% efficiency |
| **IDLE** | — | Return to Drone Bay, await orders |

**Task queue:** Each drone holds up to 5 queued tasks. Tasks execute in order. The **LOOP** checkbox makes the queue repeat indefinitely (e.g., FUEL Harvester → EMPTY Harvester → LOOP creates a permanent maintenance drone for that harvester).

**Drag-to-queue:** Drag tasks from a task palette onto the drone's task bar — or right-click targets to append tasks to the queue.

#### Tier 2: Zone Management (mid-game, area automation)

The player draws a zone polygon on the minimap (hold Z + drag). The zone is assigned N drones from the fleet. Within that zone, drones execute the assigned zone behavior autonomously.

**Zone behaviors:**

| Behavior | What drones in zone do |
|---|---|
| **AUTO-MINE** | Find nearest unclaimed OreNode or deposit signal, mine until full, carry to nearest Storage Depot, repeat |
| **AUTO-HARVEST-SUPPORT** | Monitor all harvesters in zone; FUEL any harvester below 20% fuel; EMPTY any harvester above 80% hopper fill |
| **AUTO-BUILD** | Process all construction blueprints in zone in order of priority |
| **AUTO-SURVEY** | Walk survey grid pattern over zone, mark all deposits found above player-set threshold |
| **AUTO-SAMPLE** | Collect samples from all un-analyzed deposits in zone, deliver to Research Lab |

**Zone stats overlay:** Each zone shows: drones assigned, drones active, tasks/hour (rolling average), efficiency score.

**Zone priority:** Zones can be given priority 1–5. When a new drone is added to the fleet, it automatically joins the highest-priority zone that has fewer drones than its target count.

#### Tier 3: Fleet Strategy (late game, global direction)

**Fleet Presets** — one-button global reassignment:

| Preset | Effect |
|---|---|
| **MINING FORMATION** | All available drones assigned to AUTO-MINE in mining zones |
| **HARVESTER SUPPORT** | All Refinery Drones reassigned to AUTO-HARVEST-SUPPORT across all zones |
| **CONSTRUCTION PUSH** | All Builder Drones reassigned to AUTO-BUILD; clears all pending blueprints |
| **SURVEY SWEEP** | All Survey Drones dispatched to survey unmapped areas; other drones maintain current tasks |
| **EMERGENCY FUEL** | ALL drones drop current tasks and FUEL every harvester below 50% fuel (for when you've been away and harvesters are all running dry) |

**Priority Matrix:** The player sets a global priority order for automatic drone dispatching:
```
Example: Mining > Harvester Support > Construction > Survey
```
When drones complete tasks and look for new assignments, they pull from the highest-priority category that needs workers.

**Drone count targets:** The player sets a target count per zone (e.g., "Zone A: 8 drones", "Zone B: 4 drones"). The system auto-balances as drones finish tasks.

### 8.4 Swarm Scale and Economy

**Starting fleet:** 1 Scout Drone (after first purchase at 25 CR)
**Fleet size progression:**

| Phase | Target fleet size | Primary composition |
|---|---|---|
| Phase 0-1 | 1–3 | Scout Drones |
| Phase 2 | 5–10 | Scout + 2–3 Refinery Drones |
| Phase 3 | 10–20 | Scout + Heavy + Refinery + Survey |
| Phase 4 | 20–50 | Full roster, multi-planet |
| Phase 5 | 50–200+ | All types, Drone Fabricator producing continuously |

**Fleet size cap:** Raised through tech tree (Branch 3, Logistics nodes). Base cap: 3. Each Logistics node: +1, +2, +3, +5. Drone Fabricator on each planet produces drones locally, so the cap is per-planet.

**Drone Fabricator output (materials-based, no CR cost):**
- Scout Drone: 10 Steel Plates + 5 Alloy Rods, 8 min
- Heavy Drone: 20 Steel Plates + 10 Alloy Rods, 20 min
- Refinery Drone: 15 Steel Plates + 8 Alloy Rods, 12 min
- Survey Drone: 12 Steel Plates + 5 Alloy Rods, 10 min
- Builder Drone: 25 Steel Plates + 12 Alloy Rods + 5 Crystal Lattices, 25 min

### 8.5 Drone Fleet Command UI (Redesigned)

The Fleet Command panel (renamed from Drone Bay) is a full-featured swarm management interface:

**Tab 1: FLEET** — Table view of all drones. Columns: Type, Current Task, Queue, Zone, Priority, Fuel/Durability. Click any row to select drone and edit task queue.

**Tab 2: ZONES** — Zone list with drone allocation sliders and behavior dropdowns. Map overlay toggle.

**Tab 3: DEPLOY** — Buy/fabricate new drones. Shows fleet capacity vs. current count.

**Tab 4: ASSIGNMENTS** — Legacy direct assignment (ore type preference, zone restriction). Retained from v0.1 but now also has Priority column.

**Tab 5: PRESETS** — One-button fleet presets and Priority Matrix settings.

---

## 9. Vehicle System

### 9.1 Why Vehicles Exist

The asteroid field and planets are not small. Walking everywhere is fine early — when your operation is a handful of nearby deposits. But as the player discovers deposits across the full map, and as the planet becomes dotted with harvesters, a player on foot spending 45 seconds walking to check on a distant harvester becomes a pacing problem.

Vehicles solve three things: **traversal speed**, **cargo hauling**, and **region access**. Some deposits are marked REGION-LOCKED — located in a zone that requires a vehicle to cross (a deep crevasse, a high ridge, an atmosphere-gated zone). Vehicles are also the platform for vehicle-mounted survey tools — faster coverage at the cost of slower scan depth.

### 9.2 Vehicle Roster

| | Rover | Speeder | Shuttle |
|---|---|---|---|
| **Speed** | 280 px/sec | 520 px/sec | 200 px/sec |
| **Carry Bonus** | +15 units | +10 units | +40 units |
| **Fuel Type** | Gas | Gas | Rocket Fuel |
| **Fuel Tank** | 30 gas units | 20 gas units | 15 RF units |
| **Range** | All ground terrain | All ground terrain | All terrain incl. restricted zones |
| **Unlock** | Phase 1 | Phase 2 | Phase 3 |
| **Purchase Cost** | 300 CR | 1,200 CR | — |
| **Craft Cost** | 30 Steel Plates + 10 Alloy Rods | 20 Steel + 15 Alloy + 5 Crystal Lattices | 50 Steel + 30 Alloy + 15 Crystal Lattices + 10 Void Cores |
| **Crafted at** | Crafting Station | Fabricator | Fabricator |

**Rover:** The first vehicle. Slow enough that the player doesn't feel the world shrink, fast enough to meaningfully reduce travel to distant harvesters. Workmanlike. Feels like a mining truck — that's intentional.

**Speeder:** The exploration vehicle. High speed makes systematic survey grids practical. The speeder is how the player maps a whole planet's deposit network in one focused session. Vehicle-mounted Survey Tool is most effective here.

**Shuttle:** Not faster than the speeder for ground travel, but crosses terrain that ground vehicles cannot — elevated zones, protected atmospheric regions on Planet B, and the region boundary to A3's far continent. The Shuttle's large cargo capacity makes it the preferred vehicle for hauling assembled rocket components to the Launchpad.

### 9.3 Driving and Interaction

**Entering/Exiting:** Walk to vehicle, press [E]. Camera shifts to a slightly elevated follow angle. Player's normal carry inventory is accessible; vehicle cargo hold is additional.

**Fuel consumption:** Vehicles consume gas (or Rocket Fuel for Shuttle) while moving. Stationary vehicles do not consume fuel. The vehicle's fuel gauge is visible on the HUD when driving.

**Refueling:** Drive near a Gas Collector hopper or a Gas Canister Rack and interact. Drones will NOT refuel player vehicles (the player manages their own vehicle fuel — this is intentional; it keeps vehicle ownership personal).

**Survey while driving:** When the Survey Tool is equipped while in a Rover or Speeder, the Quick Read (passive ping) is active. The player cannot hold still for a Full Scan while in a vehicle (the engine vibration interferes). To perform a Full Scan: exit vehicle, stand still, scan. The survey result is tied to the player's position, not the vehicle's.

**Exception — Vehicle Survey Mount (upgrade):** After Research node 3.S (Survey Tool Mk.II), a Vehicle Survey Mount can be installed on the Speeder. This enables Full Scans while driving at reduced speed (move at ≤50 px/sec). Deep Scans still require stopping. This is the mid-game survey optimization — covering ground quickly while passively getting full concentration readings.

### 9.4 Region-Locked Deposits

Each planet has a small number of deposits (5–10%) that are marked REGION-LOCKED on the Survey Journal. These cannot be reached on foot — they appear on the survey minimap but show a lock icon. The journal entry shows which vehicle tier unlocks access.

| Region Type | Required Vehicle | What's There |
|---|---|---|
| Rocky Ravine | Rover (can navigate rough terrain) | Often high-DR Vorax deposits |
| High-Altitude Zone | Speeder (enough speed to maintain momentum) | Often high-PE Krysite |
| Atmospheric Pocket (Planet B) | Shuttle only | Highest-OQ Voidstone deposits |
| Far Continent (A3) | Shuttle only | Ferrovoid deposits + S-tier anything |

This creates a natural pull toward vehicle upgrades: "I can see there's a Grade A Voidstone deposit in the atmospheric pocket — I need a Shuttle to get there."

### 9.5 Vehicle Garage Building

Vehicles are stored in a **Garage** — a small, cheap building.
- **Cost:** 80 CR + 10 Steel Plates
- **Function:** Stores up to 2 vehicles. Vehicles "park" here when not in use (they persist in the world but the Garage tracks ownership and enables fuel topping-off from connected Gas Canister Rack)
- **Upgrade — Multi-Bay Garage:** 300 CR + 25 Steel Plates → stores up to 5 vehicles

### 9.6 Vehicle Upgrades

Each vehicle has two upgrade slots:

| Upgrade | Effect | Cost | Vehicle |
|---|---|---|---|
| Cargo Expansion Mk.I | +5 carry capacity | 200 CR + 5 Alloy Rods | Rover, Speeder |
| Cargo Expansion Mk.II | +10 carry capacity | 500 CR + 10 Alloy Rods | Rover, Speeder, Shuttle |
| Speed Boost Mk.I | +15% speed | 300 CR + 5 Crystal Lattices | Rover, Speeder |
| Speed Boost Mk.II | +20% speed | 800 CR + 10 Crystal Lattices | Speeder only |
| Vehicle Survey Mount | Enables Full Scan while moving ≤50px/s | 600 CR + 5 Alloy Rods | Speeder |
| Extended Fuel Tank | +50% fuel capacity | 400 CR + 8 Alloy Rods | All |
| Jump Jets | Rover can traverse Ravine terrain | 500 CR + 8 Crystal Lattices | Rover |

### 9.7 Vehicle-Deposit Connection

The core design intent: vehicles are not luxury — they gate content. A player who skips the Rover cannot efficiently survey the outer field. A player without a Shuttle cannot access the highest-tier deposits on Planet B. This creates a natural pull toward vehicle investment without making vehicles feel mandatory for basic play.

The connection to surveying: once the player has a Speeder with a Vehicle Survey Mount, surveying a full planet's deposit map goes from an hour of careful footwork to a 15-minute sweep. This is a meaningful quality-of-life upgrade that still requires intentional investment to unlock.

---

## 10. Factory Production System

### 10.1 Philosophy

Production in VoidYield is not a single crafting bench — it is a tiered industrial network of buildings that transform raw ore into finished goods, crew consumables, and spaceship components. Each tier requires the outputs of the tier below it. Quality flows from deposit through every stage and emerges in the final product's stats. The factory floor is where good surveying decisions become a measurable gameplay advantage.

Three factory tiers exist, each occupying a different number of Industrial Site slots (see Section 22). Every planet is a planning puzzle: slots are scarce, so players must choose which buildings to run on which world.

### 10.2 Tier 1 — Processing Plants (1 Industrial Site slot)

Processing Plants run a single conversion recipe continuously. One input stream, one output stream. No operator input required once placed and supplied.

**Available recipes (one active per plant, retooling free):**

| Plant Name | Input | Output | Rate | Notes |
|---|---|---|---|---|
| Ore Smelter | Vorax Ore | Steel Bars | 12/min | Foundation of all construction |
| Plate Press | Steel Bars | Steel Plates | 8/min | Finished structural material |
| Alloy Refinery | Krysite | Alloy Rods | 6/min | Precision components |
| Gas Compressor | Raw Gas | Compressed Gas Canisters | 10/min | Crew heating + harvester fuel |
| Crystal Processor | Aethite | Crystal Lattice | 4/min | Research + electronics |
| Bio-Extractor | Bio-Resin | Processed Resin | 5/min | Insulation + bio-circuits |
| Food Processor | Raw Crops | Processed Rations | 8/min | Colonist basic need |
| Ice Melter | Ice Ore | Water | 15/min | Pioneer basic need |

**Quality passthrough:** Processing Plants preserve ore lot quality attributes in their output. Steel Bars from a high-MA Vorax deposit retain that MA value in the batch metadata. Quality is never lost — only transformed.

**Power consumption:** 3 Power/sec while running.

### 10.3 Tier 2 — Fabricators (2 Industrial Site slots)

Fabricators accept two inputs and produce one output. Recipe is selectable; retooling costs 500 CR and 30 minutes of downtime. The player must think carefully about which recipe each Fabricator runs on a given planet, since slot pressure prevents running all recipes everywhere.

**Available recipes:**

| Fabricator Recipe | Input A | Input B | Output | Rate |
|---|---|---|---|---|
| Drill Head | Steel Bars | Alloy Rods | Drill Head | 3/hr |
| Sensor Array | Alloy Rods | Crystal Lattice | Sensor Array | 2/hr |
| Hull Plating | Steel Bars | Processed Resin | Hull Plating | 4/hr |
| Power Cell | Energy Shards | Crystal Lattice | Power Cell | 5/hr |
| Fuel Injector | Compressed Gas | Alloy Rods | Fuel Injector | 4/hr |
| Bio-Circuit Board | Alloy Rods | Processed Resin | Bio-Circuit Board | 3/hr |
| Combustion Housing | Steel Plates | Alloy Rods | Combustion Housing | 2/hr |
| Refined Alloy | Alloy Rods | Crystal Lattice | Refined Alloy | 6/hr |

**Quality in Fabricators:** Each recipe specifies which attributes it draws from each input. A Drill Head schematic weighs UT from the Alloy Rod input (60%), MA from Steel Bars (25%), and OQ from both (15%). The lot with the best matching attribute profile produces the strongest output. Players who route high-UT Krysite ore specifically to the Drill Head Fabricator — rather than mixing into general storage — get measurably better Drill Heads.

**Power consumption:** 8 Power/sec while running.

### 10.4 Tier 3 — Assembly Complexes (3 Industrial Site slots)

Assembly Complexes produce finished high-value goods requiring multiple Fabricator outputs plus Processing Plant outputs. They are the apex of the production chain and require *all upstream factories to be running*. One supply gap stalls the entire complex.

**Available recipes:**

| Assembly Recipe | Input A | Input B | Input C | Output |
|---|---|---|---|---|
| Rocket Engine | Combustion Housing | Fuel Injector | Refined Alloy | Rocket Engine |
| Navigation Core | Sensor Array | Crystal Lattice | Void Core | Navigation Core |
| Warp Capacitor | Void Core | Power Cell | Resonance Shard | Warp Capacitor |
| Advanced Drone Frame | Hull Plating | Sensor Array | Power Cell | Elite Drone Frame |
| Jump Relay Module | Warp Capacitor | Sensor Array | Refined Alloy | Jump Relay Module |

**Quality in Assembly Complexes:** Output stat quality is the weighted composite of all three inputs' relevant attributes. A Rocket Engine with high thrust requires the Combustion Housing to have high HR (heat resistance from good Steel Plates), the Fuel Injector to have high PE (potential energy from good Alloy Rods), and the Refined Alloy to have high UT and MA. Chasing that perfect engine means optimizing the ore deposits feeding every factory upstream of the Complex.

**Power consumption:** 15 Power/sec while running.

### 10.5 Quality Flow Through the Chain

The same quality propagation formula applies at every stage:

```
Deposit attribute (e.g. UT: 880 on Krysite deposit)
  → Processing Plant output: Alloy Rods carry UT:880 in lot metadata
    → Fabricator: Drill Head schematic reads UT(60%) × 880 = 528 contribution
      → Output Drill Head: mine_speed_bonus = f(528/600_max) → +35% mine speed
```

The chain makes every deposit survey decision visible in the final output. A player who surveys well and routes deliberately will always outperform one who mixes everything into undifferentiated storage.

### 10.6 Power Cell Loop

Power Cells are produced by Fabricators (Energy Shards + Crystal Lattice) and consumed by the factory network itself. This creates an internal supply chain tension: factories consume Power Cells to run, which means your production rate is partly self-limiting.

**Factory Power Cell consumption (daily):**
- Processing Plant: 1 Power Cell/day
- Fabricator: 3 Power Cells/day
- Assembly Complex: 8 Power Cells/day

A planet running 4 Processing Plants + 3 Fabricators + 1 Assembly Complex needs 4 + 9 + 8 = **21 Power Cells/day** to stay running. If the Power Cell Fabricator is one of those 3 Fabricators, it must be producing faster than the network consumes. Sizing this correctly is a mid-game optimization challenge.

**Power Cells also fulfill a crew need** (see Section 21). Total Power Cell demand = factory consumption + crew consumption. Players who undersupply face a double stall: factories slow and crew productivity drops simultaneously.

### 10.7 The Three Decisions for Every Factory Placement

Every time a player places a factory, they make three decisions:

**1. What recipe** — Which of this factory's recipes to run. Retooling costs time and credits. Fabricators especially require commitment; don't retool constantly.

**2. What quality inputs** — Which deposit's ore feeds this factory. High-OQ ore to the Sensor Array Fabricator. High-UT ore to the Drill Head Fabricator. Route deliberately, not randomly.

**3. Where** — Which planet's Industrial Site slots to spend. A slot on A1 (6 slots total) is much more precious than a slot on Planet C (18 slots). Every Processing Plant on A1 is a Fabricator you're not building.

### 10.8 Replacing the Old Crafting Station

The manual Crafting Station (player-operated, single-item production) is retired as the primary production system. It remains available as a **personal workbench** for one-off crafts and early-game equipment upgrades, but all bulk production — components for the rocket, consumer goods for crew, factory intermediates — flows through the factory tier system.

The Crafting Station's quality preview mechanic (selecting lots, seeing predicted output stats) is preserved inside the Fabricator and Assembly Complex UI — but now the factory runs automatically rather than requiring the player to click "craft" each time.

---

## 11. Spacecraft Construction

### 10.1 Philosophy

Getting to space is not a cost gate — it is a construction project. The player builds every component, carries it to the Launchpad, and assembles the rocket piece by piece. The rocket should be **visible** in the world throughout, partially assembled and growing. Every component added is a milestone moment.

The target scope: a focused player should spend 30–60 minutes on spacecraft construction. This is a meaningful investment, not a checkbox.

### 10.2 Prerequisite: Build the Launchpad

The Launchpad is the first step. It's a building — not a pre-existing object in the world. The player must place it themselves.

- **Cost:** 500 CR + 80 Steel Plates + 30 Alloy Rods + 20 Energy Cells
- **Placement:** Requires a flat open zone (a designated area on the asteroid field map, clearly visible as a viable landing pad location)
- **Construction:** Builder Drone or manual (interact with blueprint)
- **Build time:** 2 minutes

Once built, the Launchpad shows a rocket silhouette in the world — a ghost outline of the fully assembled spacecraft. As components are added, the ghost fills in with real assets. This ghost is visible from a distance; the player can glance at it from across the map and see their progress.

### 10.3 Rocket Components

Five components, each a separate crafting project. All must be physically carried to the Launchpad and assembled there.

#### Component 1: Hull Assembly
- **Schematic:** 120 Steel Plates + 10 Alloy Rods
- **Craft time:** 3 minutes at Fabricator
- **Carry weight:** Heavy — player can only carry 1 Hull Assembly (it takes full inventory)
- **Assembly at Launchpad:** Interact to attach. Visual: hull plates appear on the ghost silhouette.
- **Quality impact:** Hull quality determines re-entry heat tolerance and structural integrity (see Section 9.3)
- **Minimum quality requirement for safe launch:** SR ≥ 300 effective (poor hull = chance of launch failure)

#### Component 2: Engine Assembly
- **Schematic:** 50 Steel Plates + 20 Alloy Rods + 10 Crystal Lattices (requires Planet B Aethite)
- **Craft time:** 4 minutes at Fabricator
- **Carry weight:** Medium — player carries 1 Engine Assembly (takes 5 carry slots)
- **Assembly at Launchpad:** Interact to attach. Visual: engine nozzles appear, glow faintly.
- **Quality impact:** Thrust power determines launch window speed; fuel efficiency determines how much Rocket Fuel the trip consumes

#### Component 3: Fuel Tank
- **Schematic:** 40 Steel Plates + 15 Alloy Rods + 5 Energy Cells
- **Craft time:** 2 minutes at Crafting Station
- **Carry weight:** Medium (4 carry slots)
- **Assembly:** Attach, then **fill with Rocket Fuel** (100 units needed for launch to Planet B). Fuel is produced by Fuel Synthesizer: 3 Gas → 1 Rocket Fuel unit.
- **Quality impact:** Tank PE attribute increases fuel capacity (more PE ore → more fuel per unit volume → longer range or more efficient return)

#### Component 4: Avionics Core
- **Schematic:** 15 Crystal Lattices + 10 Alloy Rods + 5 Void Cores (requires Voidstone from Planet B)
- **Craft time:** 5 minutes at Fabricator
- **Note:** This is the component that creates a dependency on Planet B materials BEFORE first launch. Solution: Crystal Lattices can be bought from Trade Terminal at 4× markup (expensive but possible). Void Cores cannot be bought — they must be crafted. But the Avionics Core quality requirement is low for a first launch (CD ≥ 200 effective is enough to get to Planet B, just with poor landing precision).
- **Carry weight:** Light (1 carry slot)
- **Assembly:** Attach. Visual: antenna array rises from the ship.
- **Quality impact:** Navigation precision (landing accuracy on arrival), sensor range

#### Component 5: Landing Gear
- **Schematic:** 20 Steel Plates + 8 Alloy Rods
- **Craft time:** 90 seconds at Crafting Station
- **Carry weight:** Medium (3 carry slots)
- **Assembly:** Final component. Visual: landing struts fold out. The rocket is now complete. It fully illuminates — color, glow, launch indicator activates.
- **Quality impact:** Landing shock absorption (high-SR gear = safe landings on rough terrain; low-SR = chance of damage on landing)

### 10.4 Fueling and Launch

**Fueling:**
After all 5 components are assembled, the Launchpad shows the Fuel Gauge. The player needs 100 units of Rocket Fuel in the launchpad's tank (separate from the Fuel Tank component — the component affects efficiency; the launchpad's tank holds the actual propellant).

Filling the tank: interact with Launchpad → "Load Fuel" → transfers Rocket Fuel from Storage Depot.

**Pre-launch checklist (shown on Launchpad UI):**
```
✓ Hull Assembly .............. INSTALLED (SR: 724)
✓ Engine Assembly ............ INSTALLED (Thrust: 1.6×, Efficiency: 81%)
✓ Fuel Tank ................. INSTALLED (Capacity: 140 units)
✓ Avionics Core ............. INSTALLED (Precision: ±8km, Sensors: 180km)
✓ Landing Gear .............. INSTALLED (Shock Rating: Good)
◐ Rocket Fuel ............... 87/100 units
□ Launch Destination ........ NOT SET
```

When all boxes are checked: **LAUNCH** button activates.

**The launch moment:** Camera pulls back to show the Launchpad. Launch SFX (countdown, ignition, blast). Rocket rises off the pad with particle effects. Galaxy Map opens. Player selects destination. Transition to new planet.

### 10.5 Quality Consequences

A minimum-quality rocket (all components at C-grade or below) will reach Planet B, but:
- Fuel consumption is 30% higher (fuel may run short on longer trips)
- Landing precision is poor (lands 10–40km from target outpost)
- Hull may suffer minor damage on re-entry (requires Scrap Metal repair on landing)

A high-quality rocket (A-grade or above across all components):
- Fuel consumption at 80% base rate (more efficient)
- Landing precision within 2km of target
- No damage on standard re-entry

This makes building quality components worthwhile beyond bragging rights — it genuinely changes the travel experience.

---

## 12. Planet Stranding

### 11.1 The Commitment Mechanic

Every landing on a new planet is a commitment. The rocket burns fuel to enter atmosphere, and you cannot leave until you have enough fuel to launch again. This is not a survival game — there is no health drain, no hostile environment, no death. But you are **stuck** until you build your way out.

This is the "Astroneer feeling": the first minutes on a new world are exciting and slightly vertiginous. You have tools, a small supply cache, and a blank planet to read.

### 11.2 First Landing on Planet B

**Arrival conditions:**
- Player lands with 100 units of Rocket Fuel in the Fuel Tank (consumed during transit)
- Atmospheric entry burns 80 units — leaving 20 units in the tank
- Launch back to A1 requires 100 units (or 75 with high-PE Fuel Tank)
- The player is stranded until they can produce ≥100 units of Rocket Fuel from local resources

**Starting supplies (in personal inventory on arrival):**
- 1 Survey Tool (Tier I)
- 5 Gas Canisters (pre-filled from A1, 250 gas units total)
- 1 Personal Gas Collector deed (buildable immediately)
- 1 Personal Mineral Extractor deed
- 1 Crafting Station deed (small portable version)
- 50 Steel Plates (pre-carried)
- 10 Alloy Rods (pre-carried)
- 200 CR

**The immediate goal:** Find a Gas deposit, place the Gas Collector, wait for it to fill, convert gas to Rocket Fuel at the portable Crafting Station (Fuel Synthesizer recipe: 3 Gas → 1 Rocket Fuel, requires 300 Gas units for 100 Rocket Fuel).

**Timeline of first landing (typical):**
- 0:00 — Land. Survey tool reveals nearby gas deposit at 52% concentration.
- 2:00 — Walk to deposit, place Personal Gas Collector.
- 5:00 — First 20 gas units collected. Begin scouting for ore.
- 15:00 — Gas Collector hopper at 100 units. Deploy Mineral Extractor on nearby Aethite deposit.
- 30:00 — 300 gas units accumulated. Craft 100 Rocket Fuel at portable station.
- 30:00 — **Stranding resolved.** Can return to A1 any time.
- 30:00+ — Begin proper survey of Planet B. Discover Voidstone deposits. Start building permanent outpost.

**Key design beat:** The 30-minute stranding window is not a punishment — it's an exploration motivator. The player *has to* survey immediately to find gas. While they're looking for gas, they discover the Aethite and Voidstone deposit map. They arrive at the Fuel Synthesizer with a surveyed planet rather than an unexplored one.

### 11.3 Planet-Specific Unique Ores

Each planet has ores not found elsewhere, which creates genuine reasons to operate on multiple planets simultaneously.

**Planet B (Vortex Drift) unique characteristics:**
- Aethite and Voidstone are exclusive here
- Deposits tend toward higher OQ caps (up to 920 vs A1's 900 cap for common ore)
- Gas deposits on Planet B have notably higher PE values (85th percentile PE ~600–750 vs A1's ~400–550) — Planet B gas burns hotter, making it more efficient fuel
- Voidstone is the only source of Void Cores, required for Warp Gates and the prestige trigger

**Planet A3 (Void Nexus) unique characteristics:**
- All five ore types spawn in moderate quantities
- The quality distribution is wider — both very low and very high attribute values are more common (more variance = more hunting required, more rewards)
- A unique ore type: **Ferrovoid** (A3 exclusive) — combines properties of Vorax and Voidstone, used only in the Galactic Hub construction schematic

### 11.4 Return Trip Logistics

**Return to A1 from B:**
- Requires 100 Rocket Fuel in the Launchpad tank
- Player builds Launchpad on Planet B (same process as A1, same cost)
- Or: uses the original rocket if it landed safely (it remains at the landing site as a reusable vehicle — refuel and relaunch)

**After first return:** Planet B Launchpad is established. Subsequent trips are quick: arrive, fuel already waiting (if drones maintained the Fuel Synthesizer), launch within minutes.

**Long-term stranding mechanics:** Once per-planet infrastructure is established, the stranding feeling disappears. The point is only the *first* visit — committing to exploration, not punishing permanent operations.

---

## 13. Tech Tree & Upgrades

Three branches, each requiring Research Points (from Research Lab) plus credits. Before the Research Lab is built, three direct-purchase early upgrades remain available.

**Early direct-purchase upgrades (no RP required):**

| Upgrade | Cost | Effect |
|---|---|---|
| Drill Bit Mk.II | 50 CR | Player mine time: 1.5s → 0.75s (pure purchase; a crafted Drill Bit Mk.III is better) |
| Cargo Pockets × 3 | 75 / 75 / 75 CR | +5 carry per level |
| Thruster Boots | 60 CR | +20% move speed |

### Branch 1: Extraction

```
1.1 Advanced Mining I        50 RP + 75 CR       → Player mine time -25%
1.2 Advanced Mining II       150 RP + 200 CR      → Player mine time -25% more   [req: 1.1]
1.3 Power Mining             500 RP + 800 CR      → Mining shockwave: adjacent nodes +100% yield for 10s   [req: 1.2]
1.4 Extraction Mastery       2,000 RP + 3,000 CR  → Harvester BER +15% for all placed harvesters   [req: 1.3]

1.A Drone Drill I            50 RP + 50 CR        → Drone mine time -20%
1.B Drone Drill II           150 RP + 100 CR      → -20% more   [req: 1.A]
1.C Drone Drill III          300 RP + 200 CR      → -15% more   [req: 1.B]
1.D Drone Drill IV           600 RP + 400 CR      → -10% more   [req: 1.C]

1.E Drone Cargo Rack I       50 RP + 75 CR        → +2 carry per drone
1.F Drone Cargo Rack II      150 RP + 150 CR      → +2 more   [req: 1.E]
1.G Drone Cargo Rack III     300 RP + 300 CR      → +2 more   [req: 1.F]
1.H Drone Cargo Rack IV      600 RP + 600 CR      → +3 more   [req: 1.G]

1.P Heavy Drone Unlock       100 RP + 0 CR        → Heavy Drone available
1.Q Refinery Drone Unlock    300 RP + 0 CR        → Refinery Drone available   [req: 1.P]
1.R Survey Drone Unlock      200 RP + 0 CR        → Survey Drone available
1.S Drone Speed Boost I      80 RP + 80 CR        → +15% drone speed
1.T Drone Speed Boost II     200 RP + 200 CR      → +15% more   [req: 1.S]
1.U Drone Speed Boost III    400 RP + 400 CR      → +15% more   [req: 1.T]

1.X Drone Coordination       500 RP + 300 CR      → Drones share target data; no double-mining
1.Y Fleet Automation         1,500 RP + 800 CR    → Drones auto-reassign based on Priority Matrix   [req: 1.X]

1.Z Harvester BER Upgrade I  200 RP + 500 CR      → All harvesters +10% BER
1.Z2 Harvester BER Upgrade II 600 RP + 1,500 CR   → +10% more   [req: 1.Z]
```

### Branch 2: Processing & Crafting

```
2.1 Metallurgy I             200 RP + 400 CR      → Refinery processes 20% faster
2.2 Metallurgy II            500 RP + 1,000 CR    → 20% more   [req: 2.1]
2.3 Advanced Smelting        1,500 RP + 3,000 CR  → Refineries +1 output per batch   [req: 2.2]

2.A Energy Efficiency I      100 RP + 200 CR      → All buildings use 15% less power
2.B Energy Efficiency II     300 RP + 500 CR      → 15% more   [req: 2.A]
2.C Solar Mastery            1,000 RP + 2,000 CR  → Solar Panels generate 2× power   [req: 2.B]

2.P Automation Core          100 RP + 0 CR        → Enables Auto-Sell at depot
2.Q Trade Algorithms         500 RP + 1,000 CR    → +5% sell price all ores   [req: 2.P]
2.R Market Mastery           2,000 RP + 5,000 CR  → +10% more; rare ore prices fluctuate ±20%   [req: 2.Q]

2.S Crafting Specialization  300 RP + 600 CR      → Crafting quality +5% effective (attributes weighted higher)
2.T Expert Fabrication       800 RP + 2,000 CR    → Crafting quality +10%; unlock Mk.III schematics   [req: 2.S]
2.U Master Artisan           2,000 RP + 5,000 CR  → Crafting quality +15%; unlock S-tier component schematics   [req: 2.T]

2.V Sample Analysis I        100 RP + 0 CR        → Research Lab analysis time: 2 min → 1 min
2.W Sample Analysis II       300 RP + 300 CR      → 1 min → 30s; reveals 2 top attributes before full analysis   [req: 2.V]

2.X Fabricator Unlock        800 RP + 0 CR        → Fabricator building available   [req: 2.1]
2.Y Drone Fabricator Unlock  3,000 RP + 0 CR      → Drone Fabricator available   [req: 2.X]
```

### Branch 3: Expansion

```
3.1 Logistics I              100 RP + 100 CR      → +1 max fleet size
3.2 Logistics II             300 RP + 300 CR      → +2 fleet size   [req: 3.1]
3.3 Logistics III            800 RP + 800 CR      → +3 fleet size   [req: 3.2]
3.4 Grand Fleet              2,000 RP + 2,000 CR  → +5 fleet size   [req: 3.3]
3.5 Armada                   5,000 RP + 5,000 CR  → +10 fleet size per planet   [req: 3.4]

3.A Expanded Storage I       50 RP + 100 CR       → +50 ore storage
3.B Expanded Storage II      150 RP + 250 CR      → +100 more   [req: 3.A]
3.C Expanded Storage III     400 RP + 600 CR      → +200 more   [req: 3.B]

3.P Warp Theory              2,000 RP + 0 CR      → Warp Gate building unlocked   [req: 10 Void Cores produced]
3.Q Builder Drone Unlock     300 RP + 0 CR        → Builder Drone available
3.R Cargo Drone Unlock       1,000 RP + 0 CR      → Cargo Drone available   [req: 3.Q]

3.S Survey Tool Mk.II        400 RP + 200 CR      → Upgrade Survey Tool: ±5% precision, grade + size readout
3.T Survey Tool Mk.III       1,500 RP + 500 CR    → Full attribute readout without Research Lab   [req: 3.S]
3.U Geological Memory        800 RP + 400 CR      → Survey markers persist between sessions; minimap shows deposit outlines   [req: 3.S]

3.X Research Amplifier       500 RP + 500 CR      → Research Labs +25% RP
3.Y Quantum Research         1,500 RP + 2,000 CR  → +50% more   [req: 3.X]

3.Z Fuel Efficiency I        300 RP + 300 CR      → Harvesters use 15% less gas
3.Z2 Fuel Efficiency II      800 RP + 800 CR      → 15% more   [req: 3.Z]
3.Z3 Fuel Efficiency III     2,000 RP + 2,000 CR  → 15% more; harvesters can run 25% longer on same tank   [req: 3.Z2]
```

**Research Point income:**

| Setup | RP/min |
|---|---|
| No Research Lab | 0 |
| 1 Research Lab | 1.0 |
| 2 Research Labs | 1.5 |
| 3 Research Labs (max effective per planet) | 1.75 |
| With Research Amplifier | ×1.25 |
| With Quantum Research | ×1.75 |
| Per Crystal Lattice consumed | +10 instant |

---

## 14. Prestige & Sector System

### 13.1 Sector Complete

When all three planets are automated AND the Galactic Hub is built on A3, the player unlocks **Sector Complete**. A transmission arrives: *"Survey complete. All deposits catalogued. Sector extraction at maximum efficiency. Reassignment coordinates locked."*

**What resets:**
- All credits, ore, materials in storage
- All buildings (except Galactic Hub ruins — give 10% build cost discount next run)
- All tech tree progress (except retained node)
- Drone fleet

**What persists:**
- Sector Bonuses (stackable, chosen at each prestige)
- Survey data (deposit maps carry over — skip re-surveying on prestige)
- Crafting schematics (once learned, always known)
- Sector Records

### 13.2 Sector Bonuses (choose 1 per prestige)

| Bonus | Effect |
|---|---|
| Veteran Miner | Start with Drill Bit Mk.II unlocked |
| Fleet Commander | Start with 2 Scout Drones already deployed |
| Survey Expert | Start with Tier II Survey Tool and all deposit locations pre-marked on minimap |
| Trade Connections | +10% sell price permanently (stacks) |
| Refined Tastes | Refinery ratios improve by 10% |
| Research Heritage | Research Labs +50% RP (stacks additively) |
| Harvester Legacy | All harvesters start at 110% BER (from "field-tested equipment") |
| Fuel Surplus | Start with 200 Rocket Fuel and pre-built Fuel Synthesizer |
| Pioneer Spirit | A3 unlocked immediately on visiting A2 |
| Void Walker | Voidstone deposits 30% more frequent |

### 13.3 New Sector per Prestige

Each prestige places the player in a new named sector with fresh deposit quality profiles (the maps may be the same but quality attributes re-randomize):
- Sector 1: 3 planets, standard distribution
- Sector 2: 4 planets, slightly higher quality caps (+5%), building costs +5%
- Sector 3: 5 planets, wider quality variance, building costs +10%
- Sector 4+: 6 planets, exotic ore variants, building costs +15%

---

## 15. Galaxy & Multi-Planet Expansion

### 14.1 Planet Resource Identities

Each planet has a distinct resource vocabulary — a biome identity that determines what you can extract, how you extract it, and what you need from other planets to make use of it. No planet is self-sufficient for endgame crafting.

---

#### A1 — Iron Rock (Asteroid Field, Starting Zone)

| Resource | Rarity | Deposit Depth | Harvester Type |
|---|---|---|---|
| Vorax Ore | Common | Surface / Shallow | Mineral Harvester |
| Krysite | Uncommon | Shallow / Mid | Crystal Harvester |
| Raw Crystal Formations | Rare | Surface clusters | Hand-harvest only (until Crystal Harvester Upgrade) |

**Vorax Ore** — the backbone of the industrial chain. Typical OQ 400–700, MA 450–750. Steel Plates refined from Vorax are the most-consumed material in the game. Deposit density is higher on A1 than anywhere else — bulk extraction is this planet's defining strength.

**Krysite** — alloy-grade mineral with high MA and SR values. Found in vein clusters extending deeper than Vorax seams. Yield is slower but quality is consistent. The primary source of Alloy Rods.

**Raw Crystal Formations** — small clusters of exposed crystal jutting from rock faces. In Phase 1–2, players chisel these by hand (5–20 Crystal Shards per node, no quality attributes). A Crystal Harvester Upgrade (Tech Tree: Extraction branch, node 1.I "Crystal Bore") is required to place automated extractors on these formations. Without the upgrade, no harvester can lock onto a crystal-type deposit on A1.

**Surface Characteristics:**
- Lowest gravity → fastest player movement on foot
- Full Survey Tool range — no atmospheric interference; 100% scan range
- Shallow deposits exhaust in 6–20 hrs at medium BER (fastest depletion of any planet)
- Excellent ER values (ER 550–850 typical) — what A1 deposits lack in longevity they make up in speed
- Concentration peaks usually within 30px of the initial reading — easiest planet to survey precisely

**What only exists here:** Vorax in bulk. Other planets have trace Vorax deposits but nowhere near sufficient density for Steel Plate production at scale. A1 remains a critical export source throughout the entire game.

**Cross-planet dependency created:** Alloy Rods (refined from Krysite) are needed on every other planet for construction and crafting. A1 must keep running for the supply chain to function.

---

#### Planet B — Vortex Drift (First Destination)

| Resource | Rarity | Deposit Depth | Harvester Type |
|---|---|---|---|
| Shards | Common | Mid-depth | Mineral Harvester |
| Aethite | Uncommon | Deep | Crystal Harvester |
| Voidstone | Rare | Deep cave systems | Cave Drill (required — see § 6.7) |
| Bio-Resin | Unique | Living flora (surface) | HARVEST FLORA drone behavior (§ 6.7) |

**Shards** — energy-conductive mineral with naturally high CR and CD values (typical CR 600–900, CD 550–850). No other planet produces Shards in usable quantity. Refined into Crystal Lattices and Energy Cells (battery-like components for advanced machines and the Spacecraft fuel system).

**Aethite** — crystalline ore with extreme CD and high OQ. The primary research material. Crystal Lattices from Aethite feed the Quantum Array for 3× RP generation. Deposits are deep and long-lived (40–80 hrs at medium BER) — the tradeoff for the harder survey work.

**Voidstone** — dark matter-infused ore found only in Vortex Drift's cave networks. The Survey Tool behaves strangely near caves: signal oscillates rather than climbing steadily — a deliberate "something is different here" cue. Requires a Cave Drill placed at a cave entrance to access the deep deposits below. Produces Void Cores — essential for the Avionics Core and late-game warp technology.

**Bio-Resin** — not mined, not extracted. Secreted by Aethon Flora: alien plant organisms that glow faintly in Planet B's dim light. Players discover that drones assigned the HARVEST FLORA behavior collect resin passively as the plants cycle. Used in insulation components and bio-circuits. Cannot be synthesized — no Bio-Resin means no bio-circuits. Supply depends on keeping flora zones intact; the player is disincentivized from bulldozing them for building space.

**Surface Characteristics:**
- Atmospheric interference reduces Survey Tool range by 40% (Speeder's upgraded Survey Mount partially compensates — restores 20%)
- Deposits are substantially deeper and longer-lived than A1 (30–80 hrs at medium BER)
- Gas deposits here have significantly higher PE (PE 650–900 typical vs. A1's PE 400–650) — Rocket Fuel produced from Planet B gas is 20–35% more efficient per unit
- Low-light surface environment — drones have 15% reduced pathfinding speed without a Sensor Array upgrade

**What only exists here:** Bio-Resin (planet-exclusive, no substitute); Voidstone in useful quantities; high-PE gas for efficient Rocket Fuel production.

**Cross-planet dependency created:** Void Cores needed on A1 (Warp Gates) and A3 (Galactic Hub construction); Crystal Lattices exported to all planets; high-PE gas fuels the entire fleet.

---

#### Planet C — The Shattered Ring (Endgame)

| Resource | Rarity | Deposit Depth | Harvester Type |
|---|---|---|---|
| Void-Touched Ore | Common | Variable | Mineral or Crystal Harvester |
| Resonance Crystals | Unique | Surface formations | Resonance Charge cracking (§ 6.7) |
| Dark Gas | Unique | Geyser vents | Gas Trap structure (§ 6.7) |

**Void-Touched Ore** — corrupted versions of basic ores (Vorax, Krysite, and even Aethite, all warped by the Shattered Ring's void radiation). The corruption causes extreme quality variance: the same deposit yields batches with OQ 150 or OQ 950 with no predictable pattern. Survey readings are accurate for concentration and ER, but attribute quality is scrambled — you don't know what you're getting until you refine it. Planet C feels like gambling on premium ore: high ceiling, real risk of waste, impossible to pre-optimize.

**Resonance Crystals** — massive mineral formations rising from the shattered terrain. Cannot be mined with any harvester. The process: craft Resonance Charges at the Fabricator, carry charges to a crystal formation, place with [E], wait 90 seconds for controlled fracture, then harvest Resonance Shards with extreme CD (780–980) and SR (700–950). Each crystal formation supports only 3–5 crack cycles before depleting. Formations do not respawn. The supply of Resonance Crystal Shards is finite — manage it carefully.

**Dark Gas** — erupts from unstable geyser vents rather than sitting in static underground deposits. A Gas Trap structure must be placed at an active geyser vent. Standard Gas Collectors don't function here (Planet C's fractured atmosphere provides no reliable wind). Dark Gas is required to fuel Elite-tier harvesters, Cave Drills, and the Warp Drive.

**Surface Characteristics:**
- Unstable terrain — deposits shift location over time. Survey markers go stale every 2–4 in-game hours. Resurveying is mandatory and ongoing. This is the defining challenge of Planet C.
- Highest potential reward deposits in the game (Void-Touched Ore quality ceiling, Resonance Crystal CD/SR)
- Geyser fields are the only gas source on this planet
- High radiation interference — Shuttle is required to land (Cargo Ships offload to a Shuttle relay)

**What only exists here:** Resonance Crystals; Dark Gas; the high-quality ceiling of Void-Touched Ore.

**Cross-planet dependency created:** Resonance Crystal Shards needed for Warp Gates and the Galactic Hub; Dark Gas fuels the endgame fleet.

---

#### Cross-Planet Crafting Dependencies

The best items always require materials from at least two planets:

| Item | From A1 | From Planet B | From Planet C |
|---|---|---|---|
| Avionics Core | Alloy Rods | Void Cores | — |
| Warp Gate Module | Steel Plates | Void Cores | Resonance Shards |
| Advanced Research Array | Alloy Rods | Aethite Crystal Lattices | — |
| Bio-Circuit Board | Alloy Rods | Bio-Resin | — |
| Elite Drone (Tier 5) | Steel Plates | Crystal Lattices | Void-Touched Ore (high OQ) |
| Dark Fuel Cell | — | High-PE Gas | Dark Gas |

This forces active inter-planet logistics — no planet can be "set and forget" because the receiving planet always needs something from the others.

### 14.2 Galaxy Map Visual Upgrade

The Galaxy Map communicates empire status at a glance:
- **Active Cargo Ship routes:** Animated dotted lines between planets when a ship is in transit
- **Planet automation status:** Color-coded icons (gray = manual, yellow = partial, green = full)
- **Per-planet stats overlay:** Hover for CR/min, active drone count, harvester count, fuel level
- **A3 discovery animation:** Scans in from static noise when unlocked
- **Route efficiency:** Shows travel time and cargo capacity on each route

### 14.3 Inter-Planet Resource Flow (Endgame Target)

```
A1: Vorax deposits → Steel Plates → [export 40% to A2/A3 for construction]
A1: Krysite deposits → Alloy Rods → [export to A3 Galactic Hub]

A2: Aethite deposits → Crystal Lattices → [export to A3 for Hub + keep for Research]
A2: Voidstone deposits → Void Cores → [export to A1 for Warp Gates + A3 for Hub]
A2: High-PE Gas → Rocket Fuel → [export to all planets for inter-planet travel]

A3: All materials → Galactic Hub → maximum sell price (+20%) on everything
A3: Research passively completing all remaining tech nodes
```

---

## 16. Logistics System

### 15.1 Design Intent

The Logistics System is the connective tissue of the multi-planet empire. In the endgame, the player is not just mining ore on three planets — they are managing a supply network where materials flow between planets on a schedule, stockpiles buffer against delays, and a broken route causes a cascade of production stalls on the receiving end.

Logistics should feel like a satisfying third layer of management that emerges naturally from the need to move resources between planets — not a background abstraction, but a designed system the player actively builds, monitors, and repairs. The emotional loop mirrors the harvester loop: satisfying when it runs smoothly, genuinely tense when it breaks, and rewarding when you diagnose and fix the stall.

### 16.2 Three Tiers of Inter-Planet Logistics

Inter-planet logistics is not a single system — it is a progression unlocked across three phases, each offering different trade-offs between speed, throughput, crew requirements, and cost.

#### Tier 1 — Cargo Ships (Phase 3 unlock)

Physical craft built at the Launchpad and assigned to trade routes. Slow but high-capacity. Require crew to operate and carry breakdown risk. The workhorse of mid-game inter-planet supply.

**Cargo class distinctions — wrong ship for wrong cargo cannot load:**

| Ship Type | Cargo Class | Hold | Fuel/Trip | Build Cost |
|---|---|---|---|---|
| Bulk Freighter | Dry goods (ore, bars, plates) | 1,200 units | 50 RF | 2,000 CR + 100 Steel + 30 Alloy |
| Liquid Tanker | Liquid cargo (gas, Bio-Resin, chemicals) | 800 units | 45 RF | 2,400 CR + 80 Steel + 20 Alloy + 10 Crystal |
| Container Ship | Finished components, electronics, high-value goods | 600 units | 55 RF | 3,500 CR + 120 Steel + 40 Alloy + 15 Void Cores |
| Heavy Transport | Dry goods only | 3,600 units | 90 RF | 6,500 CR + 250 Steel + 80 Alloy + 20 Void Cores |

**Cargo class rules:**
- Liquid cargo (gas canisters, Bio-Resin, compressed chemicals): requires Liquid Tanker or pressurized drone pods
- Bulk dry cargo (ore, steel bars, alloy rods, plates): Bulk Freighter or standard drone crates
- Containerized goods (Fabricator outputs, Assembly Complex outputs, rocket components): Container Ships only

Wrong ship type = cannot load manifest. Players must build a fleet with the right composition for their actual cargo mix.

#### Tier 2 — Automated Drone Freight Lanes (Phase 4 unlock)

Medium-speed, continuous-flow inter-planet logistics. No crew required. Set up a lane between two planets, assign drones, and they run indefinitely. Better for steady-state supply (ore, gas, processed bars) than for bulk one-time shipments.

- **Setup**: Open Logistics Panel → New Lane → set source planet, destination planet, cargo class, drone count
- **Throughput**: Each drone carries ~50 units/trip, makes a trip every 4–8 min depending on planet distance
- **Crew**: None required — drones are autonomous
- **Downside**: Lower per-trip capacity than Cargo Ships; not suitable for large burst deliveries
- **Best for**: Continuous ore flow from A1 to Planet B factories; gas supply from Planet B to A3

#### Tier 3 — Jump Relays (Phase 5 unlock)

Instant inter-planet transfer with limited throughput. Expensive to build (requires Warp Capacitor from Assembly Complex). Best for high-value goods that bottleneck late-game chains — Void Cores, Resonance Shards, finished Assembly Complex outputs.

- **Build cost**: 2 Jump Relay Modules (one per planet end) + 500 CR/relay installation
- **Throughput**: 200 units/min maximum, regardless of cargo class
- **Latency**: Instant — goods appear at destination the moment they enter the source relay
- **Restriction**: Cannot relay liquid cargo (use Liquid Tankers for that even at Phase 5)
- **Power draw**: 20 Power/sec per relay while active

**The logistics progression mirrors the drone arc**: players earn automation and efficiency by first managing shipments manually (Phase 3 Cargo Ships), then optimizing toward continuous automated flow (Lanes), and finally solving bottlenecks with precision instant transfer (Relays).

### 16.3 Cargo Ships (Tier 1 Detail)

Cargo Ships are built at the Launchpad using the Ship Assembly panel (separate from Rocket Assembly). They operate autonomously on assigned routes once built.

Key properties:
- Fuel consumed **per trip** — docked ships burn nothing
- Ships are **physical objects in transit**: visible as animated icons on the Galaxy Map with progress bars
- Multiple ships can work the same route in parallel
- Ships run on Rocket Fuel — this creates a deliberate dependency: inter-planet logistics requires sustaining Rocket Fuel production. Planet B's high-PE gas becomes critically valuable at scale.

### 15.4 Trade Routes

A Trade Route is a player-defined supply link between two planets with a specified cargo manifest.

**Defining a route (via Logistics Panel — accessible from Galaxy Map [L]):**
1. Select SOURCE planet and DESTINATION planet
2. Define the **Outbound Manifest**: which materials to carry, and how many units per trip
3. Define the **Return Manifest** (optional): what the ship brings back. Empty return trips waste fuel but are valid
4. Assign a Cargo Ship to the route
5. Set dispatch condition: **Manual** / **Auto — hold 80% full** / **Auto — schedule every N minutes**

**Example Route:**
```
Route:    A1 → Planet B
Outbound: 800 Steel Plates + 200 Alloy Rods
Return:   600 Crystal Lattices + 100 Energy Cells
Dispatch: Auto when hold 80% full
Ship:     Medium Freighter "ISV Carver"
```

**Trip times (real time):**
- A1 ↔ Planet B: 3–4 minutes
- A1 ↔ Planet C: 8–10 minutes
- Planet B ↔ Planet C: 6–7 minutes

During transit, the ship is unavailable for reassignment. If an emergency demand arises while a ship is in flight, there is no instant fix — this is the tension the system is designed to create.

### 15.5 Stockpile Buffers

Each planet's Storage Depot has a designated **Export Buffer** and **Import Buffer** for logistics.

**Export Buffer**: Materials reserved for loading onto outbound ships. Other production systems (refineries, crafting stations) draw from the main storage, not the export buffer — preventing a refinery from accidentally consuming the ore that was meant for a departing ship.

**Import Buffer**: Incoming cargo from arriving ships offloads here first. Local production chains pull from the import buffer as needed.

**Buffer Management Rules:**
- Player sets the buffer target per route in the Logistics Panel (e.g., "Reserve 800 Steel Plates per A1→Planet B trip")
- If the export buffer falls below the minimum trip load when a ship arrives to depart, the ship enters **LOADING** state and waits
- A partial ship will not depart unless the player manually overrides — this prevents "ghost shipments" that arrive with 40% of the expected material and cause downstream stalls
- Buffer thresholds can be adjusted at any time without canceling the route

### 15.6 Route Health and Stall Cascades

The Logistics Panel's route list and Galaxy Map LOGISTICS overlay both surface route status at a glance:

| Status | Meaning |
|---|---|
| **ACTIVE** | Ship en route or dispatching normally on schedule |
| **LOADING** | Ship is docked and waiting for export buffer to reach threshold |
| **DELAYED** | Dispatch interval exceeded by 50% — buffer filling slowly |
| **STALLED** | No dispatch in 2× expected cycle time — needs player attention |
| **BREAKDOWN** | Ship suffered mid-route malfunction — cargo held, repair needed |

**Common stall causes:**
- Export buffer not filling (upstream harvesters stalled for fuel or full hoppers)
- Dispatch threshold too high for current production rate (the buffer never reaches 80%)
- Destination depot at capacity (no room to offload — consume locally or expand storage)
- Ship accidentally reassigned or docked for maintenance

**Cascade effect**: When a route stalls, the destination planet's import buffer gradually empties. Any production chain requiring the imported material then halts. A stalled Steel Plate route to Planet B freezes every crafting schematic requiring Steel Plates there. The Logistics Panel's amber/red status indicators are the player's early warning — checking route health is a habit that prevents larger crises.

### 15.7 Ship Naming and Fleet Management

Ships receive default names (ISV Carver, ISV Morrow, ISV Drift, ISV Vance, ISV Rook…) and can be renamed by the player. Each ship entry in the Fleet Panel shows:

- Assigned route and current leg (outbound / return / docked)
- Current position and progress bar during transit
- Current cargo manifest
- Fuel remaining (while docked)
- Trip count and last successful delivery timestamp
- Degradation level (see § 15.8)

**Fleet size**: No hard cap, but each additional active ship increases Rocket Fuel consumption. Optimizing fleet size vs. fuel supply is a late-game balancing act.

### 15.8 Ship Maintenance

Ships degrade with use. After every 20 trips, a Cargo Ship has a 5% chance of a mid-route malfunction: it drops to BREAKDOWN status, halts at its last map position, and holds its cargo until repaired.

**Repair options:**
- Phase 3–4: Player dispatches a Repair Drone manually from the Fleet Panel. The drone travels to the ship's position, repairs it (requires 5 Alloy Rods carried by the drone), and the ship resumes its route with cargo intact
- Phase 5: The "Emergency Repair Protocol" tech node enables automatic Repair Drone dispatch when any ship enters BREAKDOWN status

**Preventive maintenance**: Interact with a docked ship + 5 Alloy Rods → reset degradation counter to 0. A MAINTAIN FLEET drone task (Phase 5, Fleet Strategy tier) automates this for all docked ships.

### 15.9 Route Automation Progression

| Phase | Dispatch Capability |
|---|---|
| Phase 3 | Manual dispatch only — player opens Logistics Panel and clicks "SEND" |
| Phase 4 | Auto-dispatch by fill threshold (80% hold full) |
| Phase 5 | Full schedule automation + emergency repair integration |

This mirrors the drone automation arc: the player earns automation by first managing logistics manually, learning what a healthy route looks like before the system handles it.

### 15.10 Galaxy Map Logistics Overlay

Press [L] while the Galaxy Map is open to switch to LOGISTICS mode:

- **Route lines** between planets, color-coded by status (green = active, amber = loading/delayed, red = stalled or breakdown)
- **Animated ship icons** mid-route with a cargo progress indicator (fill %)
- **Per-route tooltip**: hover shows cargo manifest, estimated arrival, last trip time, trip count
- **Planet buffer health**: small fill indicator per planet showing import/export buffer levels relative to route demands
- **Fleet summary bar**: total active ships, trips completed this session, Rocket Fuel consumed by fleet today

---

## 17. Scaffolding Assessment

### 15.1 What Stays Unchanged

| Element | Notes |
|---|---|
| `GameState.gd` | Expand: add `deposit_data[]`, `harvester_states[]`, `drone_task_queues[]`, `rocket_fuel_level`, `resource_quality_lots{}` |
| `ProducerData.gd` | Expand: add `schematics.json`, `deposits.json`, `harvesters.json` |
| `SaveManager.gd` | Extend save payload with new state |
| `AudioManager.gd` | Add hooks for harvester start/stop, rocket launch, survey ping |
| `Player.gd` | Add: equip/unequip Survey Tool; survey mode overlay on HUD |
| `Interactable.gd` | Base class works for harvesters and new buildings |
| `ScoutDrone.gd` | Extend with task queue system; keep core state machine |
| `GalaxyMapPanel.gd` | Extend with route animations, automation status |
| `PauseMenu.gd` | No changes |
| `MobileControls.gd` | No changes |
| `AudioManager.gd` | Add: survey ping SFX, harvester ambient loop, rocket launch |

### 15.2 What Evolves

**OreNode → Two-tier ore system**
Surface OreNodes are *kept* for early-game manual mining and remain as supplemental mining. But the primary extraction system is now Deposits + Harvesters. OreNodes are "outcroppings" — low-yield, infinite respawn, no quality attributes, always visible. Deposits are the real resource base.
*Code change:* OreNode.gd unchanged; new `deposit.gd` and `deposit_map.gd` added.

**StorageDepot → Quality-aware storage**
The depot now stores ore in quality lots. The fill indicator gains a type breakdown. The lot system requires `storage_lots[]` in GameState (array of `{ore_type, quantity, attributes{}}` structs).
*Code change:* `storage_depot.gd` extended; `GameState.dump_inventory_to_storage()` must preserve quality metadata.

**Spaceship node → Launchpad building**
The existing Spaceship node is retired. The Launchpad replaces it as a buildable structure. The existing `spaceship.gd` and `spaceship_panel.gd` are redesigned as `launchpad.gd` and `rocket_assembly_panel.gd`. The ghost-silhouette visual is new art.

**DroneBay → Fleet Command (major UI expansion)**
The same physical object but the panel now has 5 tabs (Fleet, Zones, Deploy, Assignments, Presets). The `drone_bay.gd` backend adds zone management (`zone_manager.gd` autoload) and task queue logic (`drone_task_queue.gd` mixin).

**ShopPanel → Trade Terminal (add SCHEMATICS tab)**
A new tab shows all known crafting schematics with ingredient requirements and quality previews. The UPGRADES tab becomes the Tech Tree panel. The BUILDINGS tab (from v0.1) is now also present.

**SellTerminal → Legacy pathway**
Kept for early-game direct selling. Trade Hub building supersedes it mid-game. Physical object remains.

### 15.3 What Is New (Key Files)

| New System | Priority | Key Files |
|---|---|---|
| Survey Tool + Deposits | Critical | `survey_tool.gd`, `deposit.gd`, `deposit_map.gd` |
| Harvester System | Critical | `harvester_base.gd`, `mineral_harvester.gd`, `crystal_harvester.gd`, `gas_collector.gd` |
| Gas resource type | Critical | New entry in GameState + ore_prices + resource icons |
| Drone Task Queue system | High | `drone_task_queue.gd`, `zone_manager.gd` |
| Quality Lot system | High | Embedded in GameState storage methods |
| Crafting Station | High | `crafting_station.gd`, `crafting_panel.gd`, `schematic.gd` |
| Rocket Assembly | High | `launchpad.gd`, `rocket_assembly_panel.gd`, `rocket_component.gd` |
| Fuel Synthesizer | High | `fuel_synthesizer.gd` |
| Building placement | Medium | `building_placement.gd`, `building_base.gd` |
| Tech Tree panel | Medium | `tech_tree_panel.gd` |
| Research Lab | Medium | `research_lab.gd`, `sample_analysis.gd` |
| Planet Stranding logic | Medium | Extend `main.gd` travel handler; `stranding_manager.gd` |
| Zone Management panel | Medium | `zone_manager_panel.gd` (Fleet Command tab 2) |
| Ore Refinery | Medium | `ore_refinery.gd` |
| Power Grid | Medium | `power_grid.gd` autoload |
| Cargo Ship Bay | Later | `cargo_ship_bay.gd`, `cargo_ship.gd` |
| Warp Gate | Later | `warp_gate.gd` |
| Prestige system | Later | `sector_manager.gd`, `prestige_panel.gd` |
| Galactic Hub | Later | `galactic_hub.gd` |

### 15.4 What Scrap Metal Does Now

Previously undefined beyond "accumulates." Assigned uses:
1. Building repair: 1 Scrap → restore harvester/building to 100% efficiency (replaces daily efficiency loss)
2. Emergency Steel: 2 Scrap → 1 Steel Plate at Refinery (poor ratio but useful)
3. Gas Canister crafting: 5 Scrap + 5 Steel Plates → 1 Gas Canister (alternative recipe if Alloy Rods are scarce)

---

## 18. Economy Model & Key Numbers

### 16.1 Harvester Income Projections

**Single Personal Mineral Harvester** at average deposit (Concentration 50%, ER 500):
`5 × 0.50 × 0.50 = 1.25 units/min = 75 units/hr`

Selling raw Vorax: 75 CR/hr. Refining to Steel Plates: 75/3 = 25 plates/hr = 125 CR/hr.

**Single Heavy Mineral Harvester** at good deposit (Concentration 75%, ER 700):
`20 × 0.75 × 0.70 = 10.5 units/min = 630 units/hr`

Raw Vorax: 630 CR/hr. Refined Steel Plates: 210/hr = 1,050 CR/hr.

**Same Heavy Harvester** at excellent deposit (Concentration 90%, ER 850):
`20 × 0.90 × 0.85 = 15.3 units/min = 918 units/hr`

Raw Vorax: 918 CR/hr. Refined Steel Plates: 306/hr = 1,530 CR/hr.

**The survey dividend:** The excellent deposit produces 45% more than the good one. Survey quality is the most effective "upgrade" in the game.

### 16.2 CR/min Benchmarks by Phase

| Phase | Typical Setup | CR/min |
|---|---|---|
| Phase 0 | Manual mining only | 10–20 CR/min |
| Phase 1 | 2× Personal Harvesters + manual carry | 30–60 CR/min |
| Phase 2 | 4× Medium Harvesters + drone circuit | 120–200 CR/min |
| Phase 3 | 2× Heavy Harvesters + Refinery + 10 drones | 350–600 CR/min |
| Phase 4 | A1 + A2 fully automated | 1,000–2,000 CR/min |
| Phase 5 | A1+A2+A3 + Galactic Hub | 4,000–8,000 CR/min |

### 16.3 Rocket Construction Cost Model

| Component | Materials (approx CR equiv.) | Craft Time |
|---|---|---|
| Launchpad (prerequisite building) | ~1,400 CR | Build: 2 min |
| Hull Assembly | 120 Steel Plates (~600 CR raw ore equiv.) | 3 min fabricate |
| Engine Assembly | 50 Steel + 20 Alloy + 10 Crystal Lattices (~1,600 CR) | 4 min |
| Fuel Tank | 40 Steel + 15 Alloy + 5 Energy Cells (~950 CR) | 2 min |
| Avionics Core | 15 Crystal Lattices + 10 Alloy + 5 Void Cores (~2,200 CR) | 5 min |
| Landing Gear | 20 Steel + 8 Alloy (~340 CR) | 90 sec |
| Rocket Fuel (100 units) | 300 Gas units → ~150 CR of gas | — |
| **Total** | **~7,000–8,000 CR equivalent materials** | ~17 min craft time |

Compared to v0.1's ~2,655 CR total — the rocket is substantially more expensive and requires materials from Planet B (Aethite for Crystal Lattices, Voidstone for Void Cores). This is intentional. The 30-60 minute construction window is the design target for a focused session.

**Note on Void Cores:** 5 Void Cores for Avionics is achievable pre-Planet B via: buying Crystal Lattices at markup AND... wait, Void Cores come from Voidstone which is Planet B exclusive. The Avionics Core's minimum quality requirement must be achievable with substitutes: if Void Cores are unavailable, the schematic falls back to requiring 20 Alloy Rods (worse quality outcome, but functional). This allows a minimum-viable first launch without requiring Planet B ores, while rewarding players who secure them before launch with better navigation precision.

### 16.4 Gas Economy

**Gas consumption rates (all harvesters combined):**

| Setup | Gas/hr consumed |
|---|---|
| 2× Personal Mineral Harvesters | 6 gas/hr |
| 5× Medium Mineral Harvesters | 40 gas/hr |
| 3× Heavy Crystal Harvesters | 66 gas/hr |
| Full Phase 3 setup (~10 harvesters mixed) | ~150 gas/hr |

**Gas production (Personal Gas Collector, 50% concentration, PE 500):**
`6 × 0.50 × 0.50 = 1.5 units/min = 90 gas/hr`

For Phase 3 consumption of ~150 gas/hr: need 2× Medium Gas Collectors (each ~200 gas/hr at average concentrations).

**Gas balance guideline:** Always maintain ~2× your hourly consumption in gas production capacity. Gas shortage kills harvester networks; over-investing in gas production wastes good deposit slots.

---

## 19. Feel & Feedback Design

### 17.1 Survey Feedback

**Survey Mode active:**
The HUD border changes color (subtle cyan pulse). The ore readout slots show live concentration values that animate as the player moves (numbers tick up and down). An audio tone rises in pitch as the player approaches a concentration peak (like a Geiger counter). At the exact peak, a "PEAK FOUND" ding plays and the concentration readout locks.

**Survey waypoint placed:**
A mineral icon appears at the location in the world (visible from ~200px away). The minimap shows it immediately. A brief text pop: "DEPOSIT MARKED — [Ore Type] [Concentration]%".

**Analysis complete (Research Lab):**
A notification appears: "ANALYSIS COMPLETE: [Deposit Name]". The deposit's quality card appears on screen for 3 seconds showing all 11 attributes with color coding (green = top quarter, yellow = middle, red = bottom quarter). The player now knows exactly which schematics will benefit.

### 17.2 Harvester Feedback

**Harvester running normally:**
A gentle mechanical loop ambient SFX plays from the harvester. A small particle effect at the drill head. The harvester icon on the minimap pulses slowly green.

**Harvester hopper filling:**
The hopper fill bar on the in-world UI (visible when nearby) changes color at 80% full: orange warning. At 95%: red, with a flashing icon.

**Harvester stopped — no fuel:**
A warning SFX (brief alarm). In-world: the harvester dims and shows a fuel can icon. On minimap: the icon pulses yellow. HUD: a notification "HARVESTER STOPPED: No Fuel" appears in the alert area.

**Harvester stopped — hopper full:**
Same pattern but shows a "full" icon. Distinct warning tone from the fuel warning.

**Refinery Drone fueling a harvester:**
The drone approaches, plays a brief "refuel" animation (connecting to the intake). The fuel gauge rises smoothly. SFX: fluid transfer sound. The harvester resumes with a startup animation (drill spins up, particles resume).

### 17.3 Drone Swarm Feedback

**Traffic overlay (T key toggle):**
Colored motion lines representing all active drone paths:
- Scout/Heavy (mining): blue
- Refinery (logistics): green
- Survey: cyan
- Builder: yellow
- Cargo: purple

At 50+ drones, the overlay looks like a complex network diagram of the player's operation. Turning it on for the first time at swarm scale is a revelation moment.

**Zone assignment:**
When drones accept a zone assignment, they visually converge on the zone boundary, then fan out. The zone polygon on the minimap fills with moving dots.

**Fleet Preset activated:**
A full-screen flash (very brief, translucent) in the preset's theme color. All drones simultaneously update their waypoints — the traffic overlay shows a mass redirecting.

### 17.4 Rocket Construction Feedback

**Each component crafted:**
A crafted item appears in inventory with its quality stats visible. The quality grade appears with color: F=gray, D=brown, C=white, B=blue, A=gold, S=purple/rainbow.

**Component carried to Launchpad:**
The player walks toward the rocket ghost with the component in hand. When in range, a prompt: "[E] Attach Hull Assembly". On attach: a satisfying mechanical clunk SFX, the ghost section fills in with the real asset, a brief light flash at the attachment point, and a progress text: "Hull Assembly attached (SR: 724). The rocket can take a beating."

**Fuel loaded:**
The fuel gauge on the Launchpad fills visibly. When it reaches 100%: fuel indicator turns green, launch readiness increases.

**All components assembled and fueled:**
The rocket fully illuminates — running lights activate, engine pre-glow appears, a low hum begins. The launch button turns bright green. A "PRE-LAUNCH SEQUENCE READY" message in the HUD.

**Launch:**
Camera pulls back to show the full launchpad. 3-second countdown audio. Rocket engine ignites (particle burst, screen shake). Rocket rises off the pad and disappears upward. Cut to Galaxy Map.

### 17.5 Planet Stranding Arrival

**Atmospheric entry:**
The galaxy map travel animation shows the rocket entering atmosphere — a brief heat-shield glow effect on the ship icon. On landing, the camera does a slow pan across the new planet terrain before settling on the player. First visual impression should be memorable: Planet B has a purple-cyan sky and glowing Aethite crystal outcroppings visible from the spawn point.

**Fuel warning on arrival:**
Immediately on landing, the HUD shows: "FUEL REMAINING: 20 units — INSUFFICIENT FOR LAUNCH". This is the "you're committed" signal. Not alarming — just present. It establishes the goal without being punishing.

**First survey ping on new planet:**
The first use of the Survey Tool on a new planet plays a unique, wider-radius ping with a distinctive sound. The first reading of "GAS DETECTED: 41%" is a relief moment — the player knows the path forward exists.

---


---

## 21. Consumption & Crew System

### 21.1 Design Intent

Every resource VoidYield produces has two potential destinations: export (sell or ship) and consumption (feed the crew). From Phase 1 onward, the player must manage both simultaneously. This creates a genuine demand side — production goals are not just "maximize output" but "balance output against crew needs while still generating surplus for growth."

Crew productivity directly gates automation capability. A well-fed colony of Technicians enables Fabricators. A well-supplied colony of Engineers enables Assembly Complexes. Starving a tier's basic needs causes a productivity cascade that reaches every system on the planet.

### 21.2 Population Tiers

Each planet's colony advances through tiers as the player meets upgrade conditions.

| Tier | Phase | Typical Count | Enables |
|---|---|---|---|
| Pioneers | Phase 0–1 | 5–15 | Basic mining, surface operations |
| Colonists | Phase 1–2 | 20–60 | Research Lab, Storage Silos, Trade Hub |
| Technicians | Phase 2–3 | 60–200 | Fabricators, full Drone Bay operations |
| Engineers | Phase 3–4 | 200–500 | Assembly Complexes, Cargo Ship Bay |
| Directors | Phase 4–5 | 500–1,200 | Inter-planet logistics management, Galactic Hub |

Tier advancement requires: (1) current tier's luxury needs met at 100% for 10 consecutive in-game minutes, and (2) sufficient Habitation Module capacity for the new tier's population count.

### 21.3 The Escalating Needs Ladder

The critical design principle: **one tier's luxury becomes the next tier's basic need.** This cascades the production chain upward naturally.

| Tier | Basic Needs (must be 100%) | Luxury Needs (enable advancement) |
|---|---|---|
| Pioneers | Compressed Gas (heating), Water | Processed Rations |
| Colonists | Processed Rations, Compressed Gas, Water | Power Cells |
| Technicians | Power Cells, Processed Rations, Compressed Gas | Bio-Circuit Boards |
| Engineers | Bio-Circuit Boards, Power Cells, Processed Rations | Warp Components |
| Directors | Warp Components, Bio-Circuit Boards, Power Cells | — |

**Example chain read:** A Colonist colony needs Processed Rations as a basic need. To advance to Technicians, it must also supply Power Cells as a luxury. Once Technicians are established, Power Cells become *their* basic need — meaning the player can no longer treat Power Cell supply as optional.

### 21.4 Consumption Rates

Per person per in-game day (1 day = 20 real minutes):

| Resource | Per Pioneer | Per Colonist | Per Technician | Per Engineer | Per Director |
|---|---|---|---|---|---|
| Compressed Gas | 2 units | 3 units | 4 units | 4 units | 5 units |
| Water | 1 unit | 1.5 units | 1.5 units | 2 units | 2 units |
| Processed Rations | — | 5 units | 5 units | 6 units | 6 units |
| Power Cells | — | — | 3 units | 4 units | 5 units |
| Bio-Circuit Boards | — | — | — | 2 units | 3 units |
| Warp Components | — | — | — | — | 1 unit |

**Example**: A colony of 150 Technicians needs: 600 Compressed Gas/day + 225 Water/day + 750 Processed Rations/day + 450 Power Cells/day. That's 450 Power Cells the Fabricators must produce *on top of* factory self-consumption (Section 10.6). Total Power Cell demand for a 150-Technician colony running a 4-Fabricator 1-Assembly Complex factory is roughly 450 + (12 + 8) = **470 Power Cells/day**.

### 21.5 Productivity Effects

Basic need supply is tracked as a percentage (current supply rate vs. required consumption rate).

| Supply % | Productivity Multiplier |
|---|---|
| 100% | 1.00× (full rate) |
| 75% | 0.85× |
| 50% | 0.65× |
| 25% | 0.40× |
| 0% | 0.15× (minimal — crew can't work but won't leave) |

Productivity multiplier applies to: harvester BER, Processing Plant output rate, Fabricator output rate, drone work speed, and Research Lab RP generation. A 50% supply crisis halves the effective throughput of everything on that planet.

### 21.6 Habitation Modules

Each Habitation Module (1 Industrial Site slot, 800 CR + 20 Steel Plates + 10 Alloy Rods) houses 30 crew of any tier. Population cap = (number of Habitation Modules) × 30. The player must expand housing to grow the colony.

Habitation Modules also project a comfort radius (Section 7.5). Crew housed near the factory core get a +5% productivity bonus.

### 21.7 Production Dashboard Integration

The Consumption & Crew panel is a tab within the Production Dashboard (Section 23). It shows per-tier population, per-resource supply %, projected days to shortage, and current productivity multiplier. A red bar on any tier's basic need is the player's immediate action signal.

---

## 22. Industrial Sites & Planet Constraints

### 22.1 What Industrial Sites Are

Industrial Sites are designated construction zones on each planet — cleared, leveled areas with infrastructure hookups (power conduits, storage connections, drone pathfinding anchors). They are the scarce resource that forces planet specialization.

**Not** every building uses Industrial Sites. Harvesters placed at ore deposits use **Deposit Slots** (each deposit supports 1–3 harvesters based on deposit size). Surface infrastructure like Survey Markers and Relay Stations are also slot-free. Industrial Sites are specifically for production buildings.

### 22.2 Slot Capacity by Planet

| Planet | Type | Industrial Site Slots |
|---|---|---|
| A1 — Iron Rock | Small Asteroid | 6 slots |
| Planet B — Vortex Drift | Planet | 14 slots |
| Planet C — Shattered Ring | Large Planet | 18 slots |
| (Future Sector) — varies | — | 6–18 slots |

A1's 6 slots are the defining constraint of the early game. Every slot decision is consequential.

### 22.3 Slot Costs Per Building

| Building | Slots | Notes |
|---|---|---|
| Processing Plant | 1 | Each recipe is a separate plant |
| Fabricator | 2 | Recipe retooling costs 500 CR + 30 min |
| Assembly Complex | 3 | Requires all input factories running |
| Research Lab | 2 | |
| Drone Bay | 1 | Has service radius; may need multiples |
| Habitation Module | 1 | 30 crew capacity each |
| Gas Collector (installed) | 1 | Must be near gas vent/deposit |
| Heavy Harvester | 1 | Deposit-adjacent; counts toward industrial footprint |
| Cargo Ship Bay | 2 | One per planet for inter-planet routes |
| Launchpad | 3 | Required for spacecraft + cargo ship assembly |

### 22.4 Planet A1 — The 6-Slot Puzzle

With only 6 slots, A1 can never run a full production chain. Optimal A1 configurations:

**Raw processing focus (recommended Phase 1–2):**
- 4× Processing Plant (Ore Smelter × 2, Alloy Refinery, Gas Compressor) → 4 slots
- 1× Drone Bay → 1 slot
- 1× Habitation Module → 1 slot
- **Total: 6 slots.** No Fabricators. Exports Steel Bars + Alloy Rods to Planet B for Fabrication.

**Partial Fabrication (Phase 3 upgrade):**
- 3× Processing Plant → 3 slots
- 1× Fabricator → 2 slots
- 1× Drone Bay → 1 slot
- **Total: 6 slots.** One Fabricator for Drill Heads (A1 specialization). Habitation Module offloaded.

A1 never gets a Launchpad (3 slots) unless the player sacrifices 3 other buildings. The Launchpad is a Planet B or Planet C asset.

### 22.5 Strategic Implications

Slot scarcity naturally produces planet specialization without arbitrary locking:

- **A1** runs Processing Plants and exports raw processed materials. Its 6 slots are too precious for Fabricators or Assembly Complexes.
- **Planet B** with 14 slots can support a Research Lab, Fabricators for advanced components, Launchpad, and Drone Bay while still running several Processing Plants for exotic materials (Crystal Lattice, Processed Resin).
- **Planet C** with 18 slots becomes the endgame manufacturing hub — Assembly Complexes for Warp Capacitors and Navigation Cores, plus the Dark Gas collection infrastructure (Gas Traps don't use Industrial Slots, but Gas Compressors do).

This is a design goal, not a hard rule. Players can make unusual configurations work — running 3 Assembly Complexes on Planet B at the cost of no Research Lab and no Launchpad is valid if they've solved the component supply chain externally.

### 22.6 Expanding Industrial Sites (Late Game)

The "Site Expansion" tech tree node (Phase 4, Expansion branch) adds +2 Industrial Sites to one planet (player's choice). Can be researched once per sector. This gives a late-game reward for investing in the tech tree without trivializing early slot scarcity.

---

## 23. Production Dashboard & UI Systems

### 23.1 Production Rate Dashboard

The Production Dashboard is a dedicated overlay screen (default hotkey [P] or HUD button) showing the full resource flow of the current planet in real time. It is the answer to the most common player frustration in automation games: "I can tell something is wrong but I can't find it."

**Screen layout: resource rows**

Each tracked resource gets a row:

| Resource | Production (units/min) | Consumption (units/min) | Net Delta | Days to Empty |
|---|---|---|---|---|
| Steel Bars | +124 | −98 (factories: 72, export: 26) | **+26** 🟢 | — |
| Processed Rations | +310 | −380 (crew: 380) | **−70** 🔴 | 0.8 days |
| Power Cells | +88 | −112 (factories: 21, crew: 91) | **−24** 🔴 | 1.4 days |
| Compressed Gas | +540 | −290 (crew: 130, harvesters: 160) | **+250** 🟢 | — |

- **Net Delta**: green = surplus, red = deficit
- **Days to Empty**: appears only for deficits; based on current stockpile ÷ deficit rate
- **Consumption breakdown**: click any row to expand — see exactly which buildings or crew tier is consuming that resource and at what rate
- **Drill-down**: click a production entry to highlight contributing buildings on the world map

### 23.2 Planet Switcher

The dashboard has a planet tab bar. Switch between A1, Planet B, and Planet C without leaving the screen. Cross-planet deficits surface immediately — if Planet B is importing Steel Bars from A1, the A1 dashboard shows that as export consumption and the Planet B dashboard shows it as import production.

### 23.3 Production Overlay Mode

Press [O] on the world map to toggle Production Overlay. Every building gets a color-coded status indicator:

| Color | Meaning |
|---|---|
| 🟢 Green | Running at full rate |
| 🟡 Yellow | Running at partial rate (supply constrained or crew shortage) |
| 🔴 Red | Stalled (no input, no power, full hopper) |
| ⚫ Grey | Idle (no recipe set, or manually paused) |

Building icons in overlay mode also show a small stacked notification dot for actionable issues: fuel canister (harvester low fuel), hopper (harvester full), wrench (degradation), exclamation (no input material). Players can identify bottlenecks spatially without opening every building's panel.

### 23.4 Offline Event Log

When the player returns after being away, a summary panel appears before the normal HUD loads:

```
╔════════════════════════════════════════════════════╗
║  EMPIRE DISPATCH — While you were away (4h 23m)   ║
╠════════════════════════════════════════════════════╣
║  [🚀] ISV Carver completed 3 routes (A1 → B)      ║
║       Delivered: 2,400 Steel Bars, 600 Alloy Rods  ║
║                                                    ║
║  [⛏] Harvesters extracted 4,820 ore units         ║
║       Harvester A7: ran out of gas after 2h —      ║
║       paused for 2h 23m. (~1,100 units lost)       ║
║                                                    ║
║  [🔬] Survey Drone found Grade B Aethite deposit   ║
║       in Sector 6. Added to Journal.               ║
║                                                    ║
║  [🏭] Factories produced:                          ║
║       Steel Bars ×1,240 | Power Cells ×88          ║
║       Assembly Complex stalled after 1h 12m        ║
║       (Bio-Circuit input depleted)                 ║
║                                                    ║
║  [💰] Net credits: +4,820 CR                       ║
║       (Auto-sell: 2,410 Steel Bars × 2 CR each)    ║
╠════════════════════════════════════════════════════╣
║  [DISMISS]                    [VIEW DASHBOARD]     ║
╚════════════════════════════════════════════════════╝
```

Key design principles for the Event Log:
- Every entry has a concrete number, not vague language ("Harvester A7 paused for 2h 23m" not "some harvester had issues")
- Issues are highlighted with their opportunity cost ("~1,100 units lost" from the stall)
- The player can tap "VIEW DASHBOARD" to jump directly to the Production Dashboard with current deficit rows highlighted
- Tone is dispatches from an empire, not error alerts — positive events listed first

---

## 24. Art Direction

### 24.1 Vision: Optimistic Retro-Futurism

VoidYield's visual direction moves away from harsh industrial amber-on-black toward something warmer, more inviting, and more alive. The game is about building civilization in space — the art should feel like *arriving somewhere*, not like operating a machine in the dark.

The reference aesthetic: the warm optimism of 1960s–70s space program art, the lived-in texture of early colony retrofuturism, with the crisp readability of modern automation game UIs. Think Oxygen Not Included's warmth meets Factorio's information density, on a deep navy canvas.

### 24.2 Color Palette Direction

**Backgrounds:**
- Deep space: rich navy (#0D1B3E) rather than near-black — feels like sky, not void
- Planet surfaces: each world has a distinct ambient tint (A1: cool grey-brown, Planet B: dim teal-purple, Planet C: deep violet)

**Buildings and structures:**
- Habitation structures: warm oranges and tans, lit windows with warm interior glow — these are *homes*
- Processing Plants: industrial greys and blues, steam/exhaust particle effects
- Fabricators: bright teal energy conduits, rotating mechanical elements
- Assembly Complexes: large, imposing, amber-orange arc welder glow

**Resources — color-coded by type:**
- Vorax ore / Steel Bars: rust orange
- Krysite / Alloy Rods: silver-blue
- Shards / Crystal Lattice: electric teal
- Aethite: soft purple
- Voidstone / Void Cores: deep violet with faint luminescence
- Bio-Resin / flora: living green
- Gas (standard): pale yellow
- Dark Gas: near-black with a green shimmer

**UI panels:**
- Soft off-white text on dark navy backgrounds (#0D1B3E)
- Rounded corners, warmer borders (move away from harsh amber-on-black CRT style)
- Resource icons use their type color as a fill, with a consistent icon style (chunky, readable at small sizes)

### 24.3 Animation Systems

**Animated crew figures**: small settler/colonist sprites visibly walking between buildings, entering Habitation Modules, carrying goods. At low zoom they read as motion dots; at full zoom they're recognizable. This is PP2's most-praised visual upgrade and VoidYield should have it from Phase 3 onward.

**Reactive buildings**: every factory building should show visible activity when running. Processing Plants: smoke vent particles, conveyor flicker. Fabricators: energy conduit pulse, rotating assembly arm. Assembly Complexes: arc welder flash, component-on-track animation. Buildings that are stalled should look visibly *still* — no motion, dimmed lights.

**Drone trails**: drones leave a brief light trail (0.3s fade) showing their movement path. With a large swarm, the trails form a visible traffic pattern — arcs between harvesters and silos, delivery paths between factories. The swarm reads as *motion*, not as static dots.

**Ship animations**: Cargo Ships dock with a landing sequence — approach vector, deceleration, landing strut deploy, loading crane animation. Departure has engine glow buildup and a particle exhaust trail. Ships docked at the Cargo Ship Bay are visually distinct from ships in transit on the Galaxy Map.

**Planet ambient lighting**: colonized planets emit warm ambient light from the direction of the colony. Unexplored planets are cold blue-lit under starlight. As the player builds up a world, the ambient warmth increases — a visual confirmation that civilization is taking hold.

### 24.4 Production Overlay Mode Visuals

When Production Overlay is active ([O] key), the world dims slightly and buildings glow in their status color (green/yellow/red/grey). The effect should feel like a satellite thermal view — the same world, but with information made visible. Small stacked status icons above each building (fuel, hopper, stall) use consistent iconography. The overlay should be readable at maximum zoom-out.

---

## 25. Planet Specialization Meta

### 25.1 Emergent, Not Forced

Planet specialization in VoidYield is not imposed by rules — it emerges from the intersection of two constraints: **slot scarcity** and **ore exclusivity**. No planet can build everything (slots), and no planet can produce everything (unique ores). The result is a natural division of labor that the player discovers and optimizes rather than is told to follow.

### 25.2 Natural Planet Roles

**A1 — Iron Rock: Raw Processing Hub**

A1's 6 Industrial Site slots are too limited for complex factory chains. Its strength is volume: high-density Vorax deposits, excellent ER values, fast exhaust cycles that incentivize rotating harvester locations. A1's natural role is running several Processing Plants (Ore Smelter × 2, Plate Press, Alloy Refinery, Gas Compressor) and exporting the outputs upstream. A single Drill Head Fabricator is achievable by trading one slot, making A1 a specialist in the one Fabricator recipe it runs best — typically Drill Heads (exploiting its high-UT Krysite).

**Planet B — Vortex Drift: Exotic Materials & Research**

Planet B's 14 slots and unique resource mix (Shards, Aethite, Bio-Resin, Voidstone) push it toward specialist production. Its natural build is: Research Lab + Crystal Processor (Aethite → Lattice) + Bio-Extractor + Cave Drill operations + several Fabricators for Sensor Arrays and Power Cells + Launchpad for cargo ship assembly. Planet B is where advanced components get made from the materials only it can provide.

**Planet C — Shattered Ring: Endgame Manufacturing**

Planet C's 18 slots and unique access to Resonance Crystals, Dark Gas, and Void-Touched high-OQ ore make it the natural home for Assembly Complexes. A fully developed Planet C runs 2–3 Assembly Complexes (Warp Capacitors, Navigation Cores, Jump Relay Modules), supported by Gas Traps and Resonance cracking operations. The instability of Planet C's terrain (resurveying required every 2–4 hours) means it always requires active attention — it never truly runs itself.

### 25.3 The Player's Real Decision

The slot constraint doesn't tell the player what to build on each planet — it tells them they *can't* build everything. The real decision is about depth vs. breadth on each world:

- Run Planet B deeper (more Fabricators, more Assembly Complexes, less room for crew) at the cost of a weaker Planet C?
- Or spread the Fabricator load across Planet B and Planet C, running a more balanced empire that's harder to stall from a single planet outage?

There's no single correct answer. The prestige system (Sector Bonuses, Section 14) rewards players who specialize aggressively — some bonuses specifically boost A1 ore quality or Planet C slot count, incentivizing different factory configurations across sector runs.

---

## 26. Implementation Priorities

Build in this order, play-testing each layer before adding the next.

### Priority 1 — Survey & Deposit Foundation (Required First)
The survey system is the new core loop. Nothing else works without deposits.

1. `deposit.gd` — Hidden resource concentration with attribute profile (OQ + type subset)
2. `deposit_map.gd` autoload — generates and persists deposit locations per planet
3. `survey_tool.gd` — equippable item, Survey Mode HUD overlay, concentration readout, peak detection, waypoint placement [E] + [M]
4. Add Gas as a resource type in GameState (ore_prices, inventory tracking, storage)
5. Survey waypoint markers: world-space icon + minimap dot

### Priority 2 — Harvester System (Core Economy Replacement)
6. `harvester_base.gd` — base class: hopper, fuel tank, BER formula, running/stopped states, degradation
7. `mineral_harvester.gd` (Personal + Medium tiers first, Heavy/Elite later)
8. `gas_collector.gd` — self-powered, wind-driven, hopper-only (no fuel drain)
9. Harvester placement: blueprint mode, deposit proximity check, placement efficiency indicator
10. Fuel system: Gas Canister item, manual refuel interaction, drone FUEL task hook
11. Hopper system: fill tracking, halt on full, EMPTY task hook
12. In-world harvester UI: fuel gauge, hopper bar, efficiency %, warning states

### Priority 3 — Drone Task Queue (Mid-game Unlocker)
13. `drone_task_queue.gd` — extend base drone with task queue (up to 5 tasks, LOOP option)
14. Right-click assignment: MINE, FUEL, EMPTY, CARRY task types first
15. Fleet Command panel Tab 1 (FLEET) — drone table with task queue display
16. `zone_manager.gd` autoload — zone polygon storage, drone assignment to zones
17. Zone behaviors: AUTO-MINE and AUTO-HARVEST-SUPPORT first
18. Fleet Command panel Tab 2 (ZONES) — zone list, drone count sliders, behavior dropdowns

### Priority 4 — Crafting Quality System
19. Quality lot metadata added to GameState storage (tag ore batches with attribute dict)
20. Refinery: preserve quality lots through processing
21. `crafting_station.gd` and `crafting_panel.gd` — schematic selection, lot selection, quality preview
22. `schematic.gd` data class — attribute weights, ingredient list, output stats formula
23. Implement first 3 schematics: Gas Canister, Scout Drone, Drill Bit Mk.III
24. Research Lab: sample analysis (2-minute timer, attribute reveal)

### Priority 5 — Spacecraft Construction (The Milestone)
25. `launchpad.gd` — buildable structure, component attachment slots, fuel gauge, launch sequence
26. `rocket_assembly_panel.gd` — checklist UI, quality display per component
27. `rocket_component.gd` — carriable item type with embedded stats
28. `fuel_synthesizer.gd` — gas → rocket fuel conversion building
29. Implement 5 rocket component schematics (Hull, Engine, Fuel Tank, Avionics, Landing Gear)
30. Launch sequence: camera pullback, countdown, particle FX, galaxy map transition
31. Update ship parts JSON to new material recipes (Steel Plates, Alloy Rods, Crystal Lattices)

### Priority 6 — Planet Stranding Logic
32. Track `rocket_fuel_level` in GameState; deplete on planet transit
33. Add arrival conditions: stranding check, HUD fuel warning
34. Planet B starting supply pack (inventory contents on first arrival)
35. Stranding resolved signal: `GameState.planet_stranding_resolved(planet_id)`

### Priority 7 — Tech Tree UI & Research Branch
36. `tech_tree_panel.gd` — node graph visual, RP/CR costs, unlock conditions
37. Migrate existing upgrade purchases (Fleet License, Storage Expansion, Auto-Sell, Drone upgrades) to tech tree nodes
38. Add new tech tree nodes from Section 12 (survey upgrades, harvester BER, crafting quality branches)

### Priority 8 — Multi-Planet Logistics
39. Cargo Ship Bay + inter-planet manifest UI
40. Galaxy Map enhancements: route animations, automation status, per-planet stats
41. A3 scene creation with Ferrovoid deposits and Galactic Hub placement zone

### Priority 9 — Prestige System
42. `sector_manager.gd` — what resets vs. persists, bonus storage
43. Galactic Hub build trigger → Sector Complete screen
44. Bonus selection UI, prestige transition animation, new sector generation

---

*This document is the authoritative design reference for VoidYield v0.2. The SWG-inspired resource quality system, harvester network, and drone swarm management are the three pillars that distinguish VoidYield from a generic incremental game. Build them in order and playtest each extensively before moving on. The feel of discovering a high-quality deposit and immediately knowing exactly what you'll build with it is the emotional core of the mid-game. Protect that feeling in every implementation decision.*

---

**Sources consulted:**
- [Resource — SWG Wiki (Fandom)](https://swg.fandom.com/wiki/Resource) — attribute definitions, spawning mechanics, crafting quality system
- [Harvester — SWG Wiki (Fandom)](https://swg.fandom.com/wiki/Harvester) — BER formula, hopper/fuel mechanics, harvester tiers and costs
- [Resources — SWGEmu Wiki (Fandom)](https://swgemulator.fandom.com/wiki/Resources) — attribute value ranges, resource class hierarchy, deposit lifespan
- [Crafting Resources — SWG Restoration](https://swgr.org/wiki/crafting_resources/) — schematic quality interaction, attribute ordering
- [Galaxy Harvester Help](https://galaxyharvester.net/help.py) — concentration %, extraction rate formula

---

## Visual Mockups

The following diagrams are saved in `design_mocks/` and use the game's amber/dark-purple CRT palette (`#0A0A12` background, `#D4A845` amber, `#7CB87C` green, `#C0C0C8` silver, `#4A4A50` dim). Open any `.svg` file in a browser to view it at full resolution.

1. **[Survey Flow](design_mocks/01_survey_flow.svg)** — Five-step horizontal sequence showing the player's path from traversal through signal rising, 6-second hold scan, marking a deposit with `[M]`, and opening the Survey Journal with `[J]`. Illustrates the core feedback loop of the Survey Tool's Full Scan tier.

2. **[Harvester + Gas Loop](design_mocks/02_harvester_gas_loop.svg)** — Top-down base layout showing a Gas Collector (self-powered, wind-driven) feeding gas to a Mineral Harvester, with Refinery Drones carrying materials to a Storage Depot. Includes the BER extraction formula and hopper/fuel bar callouts.

3. **[Drone Swarm Overview](design_mocks/03_drone_swarm_overview.svg)** — Bird's-eye base view with Fleet Command hub, refineries, and harvesters, surrounded by multiple drones labeled with their active tasks (MINING, REFUELING, HAULING, IDLE). Dashed path lines show zone assignments and movement routes.

4. **[Crafting Quality Screen](design_mocks/04_crafting_quality_screen.svg)** — Three-panel crafting UI: schematic info on the left, ingredient slots with per-attribute quality bars in the center (showing a high-UT Krysite Alloy Rod lot and a fair-SR Steel Plate lot), and a live output preview on the right predicting the resulting Scout Drone Mk.II stats with Grade B result.

5. **[Rocket Assembly Sequence](design_mocks/05_rocket_assembly_sequence.svg)** — Horizontal timeline with seven nodes: Hull Assembly → Engine Assembly → Fuel Tank + Fill → Avionics Core → Landing Gear → Carry to Launchpad → Launch. Each node shows craft time, required materials, and key quality attributes that affect the final spacecraft.

6. **[Vehicle Roster](design_mocks/06_vehicle_roster.svg)** — Three-column comparison card for Rover, Speeder, and Shuttle: silhouette illustration, stat bars for Speed/Cargo/Range, unlock phase, cost (credits or craft materials), and fuel type. Speeder is highlighted as the recommended Phase 2 upgrade with its Vehicle Survey Mount callout.

7. **[Planet Stranding Loop](design_mocks/07_planet_stranding_loop.svg)** — Circular flow diagram set against Planet B's atmosphere: Land → Fuel Warning (20/100 RF) → Survey for Gas → Place Gas Collector → Collect Gas (300 units, ~25 min) → Synthesize Fuel (3 Gas → 1 RF) → Launch, with a dashed re-land arrow completing the loop. Central status panel shows fuel bar, time estimate, and the reassuring "NO DANGER — just committed" note.

8. **[Survey Quality Report](design_mocks/08_survey_quality_report.svg)** — Full UI panel that appears after a successful Deep Scan of a deposit. Shows Deposit #A7 "Vorax Vein" with all 11 quality attributes as horizontal bar graphs (FL: 820 ★, MA: 890 ★, and OQ: 720 ★ highlighted in amber as standout values), deposit size rating, estimated lifetime, and Mark Deposit / Add to Journal action buttons. Right-side annotations panel explains what each highlighted attribute means for gameplay.

9. **[Logistics Route Panel](design_mocks/09_logistics_route.svg)** — Galaxy map in LOGISTICS overlay mode showing A1, Planet B, and Planet C connected by color-coded route lines (green = active, red = stalled). ISV Carver is shown mid-route with a transit progress bar. The right panel shows the full route detail for Route 1 (outbound Steel Plates + Alloy Rods, return Crystal Lattices + Energy Cells, hold at 83% fill), and a stalled-route alert for ISV Morrow with the diagnostic cause ("export buffer at 23% — check A1 harvesters for fuel") and override buttons.

10. **[Planet Resource Comparison](design_mocks/10_planet_comparison.svg)** — Three-column planet identity card for A1, Planet B, and Planet C. Each column shows the planet's visual icon, surface condition callouts, all resource types with rarity-colored indicators (green = common, amber = uncommon, purple = rare, teal = planet-exclusive), harvester type requirements, unique mechanics (Crystal Bore, Cave Drill, Resonance Charge cracking, HARVEST FLORA behavior, Gas Trap), and export summary. A cross-planet dependency bar at the bottom lists which multi-planet ingredient combinations are required for the game's most advanced crafted items.

11. **[Factory Floor](design_mocks/26_factory_floor.svg)** — Top-down view of an Industrial Site showing a Processing Plant → Fabricator → Assembly Complex production chain. Input/output arrows connect the buildings; slot count badges sit on each building's corner; a drone is shown mid-path carrying an intermediate good between the Fabricator and Assembly Complex. Stall state is illustrated on one Fabricator (red overlay, "NO INPUT" badge) to show the cascade visualization.

12. **[Production Dashboard](design_mocks/27_production_dashboard.svg)** — Full-screen Production Rate Dashboard. Resource rows show production rate, consumption breakdown (factories vs. crew vs. export), net delta (green surplus / red deficit), and days-to-empty for each deficit row. Two rows are in deficit (Processed Rations, Power Cells) with red highlighting. The drill-down panel on the right shows which buildings contribute to Steel Bar production. Planet tab bar at top shows A1 / Planet B / Planet C switching.

13. **[Offline Event Log](design_mocks/28_offline_event_log.svg)** — The "Empire Dispatch" welcome-back panel. Shows five event rows: cargo ship route completions, harvester totals with a stall callout (Harvester A7 — 2h 23m lost, ~1,100 units), a survey drone discovery, factory outputs with an Assembly Complex stall noted, and net credit change. Dismiss and View Dashboard buttons at the bottom. Tone is dispatches from an empire, not error alerts.

---

