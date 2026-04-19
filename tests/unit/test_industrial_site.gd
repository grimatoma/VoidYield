extends "res://tests/framework/test_case.gd"
## TDD unit tests for IndustrialSite.
## Covers: slot allocation, building placement, removal, signal emission.

var IndustrialSiteClass = preload("res://scenes/world/industrial_site.gd")

func test_new_site_has_no_buildings() -> void:
	var site = IndustrialSiteClass.new()
	site.site_id = "test_site"
	site.max_slots = 3
	assert_eq(site._buildings.size(), 0, "new site has no buildings")
	assert_eq(site.used_slots, 0, "new site has no used slots")


func test_can_place_when_slots_available() -> void:
	var site = IndustrialSiteClass.new()
	site.max_slots = 3
	assert_true(site.can_place(1), "can place 1-slot building in empty 3-slot site")
	assert_true(site.can_place(2), "can place 2-slot building in empty 3-slot site")
	assert_true(site.can_place(3), "can place 3-slot building in empty 3-slot site")


func test_cannot_place_when_slots_full() -> void:
	var site = IndustrialSiteClass.new()
	site.max_slots = 3
	site.used_slots = 3
	assert_false(site.can_place(1), "cannot place when slots full")


func test_place_building_tracks_used_slots() -> void:
	var site = IndustrialSiteClass.new()
	site.max_slots = 5
	var building = Node.new()

	var success = site.place_building(building, 2)
	assert_true(success, "placement should succeed")
	assert_eq(site.used_slots, 2, "used_slots increased by slot_cost")
	assert_eq(site._buildings.size(), 1, "building added to list")


func test_remove_building_frees_slots() -> void:
	var site = IndustrialSiteClass.new()
	site.max_slots = 5
	var building = Node.new()

	site.place_building(building, 2)
	assert_eq(site.used_slots, 2)

	site.remove_building(building)
	assert_eq(site.used_slots, 0, "slots freed after removal")
	assert_eq(site._buildings.size(), 0, "building removed from list")


func test_free_slots_calculation() -> void:
	var site = IndustrialSiteClass.new()
	site.max_slots = 10
	var b1 = Node.new()
	var b2 = Node.new()

	site.place_building(b1, 3)
	assert_eq(site.free_slots(), 7, "free_slots = max_slots - used_slots")

	site.place_building(b2, 2)
	assert_eq(site.free_slots(), 5, "free_slots updated after second placement")


func test_place_emits_signal() -> void:
	var site = IndustrialSiteClass.new()
	site.max_slots = 3
	var building = Node.new()

	var signal_received = []
	site.building_placed.connect(func(b):
		signal_received.append(b)
	)

	site.place_building(building, 1)
	assert_eq(signal_received.size(), 1, "building_placed signal emitted")
	assert_eq(signal_received[0], building, "signal passes the building")


func test_remove_emits_signal() -> void:
	var site = IndustrialSiteClass.new()
	site.max_slots = 3
	var building = Node.new()
	site.place_building(building, 1)

	var signal_received = []
	site.building_removed.connect(func(b):
		signal_received.append(b)
	)

	site.remove_building(building)
	assert_eq(signal_received.size(), 1, "building_removed signal emitted")
	assert_eq(signal_received[0], building, "signal passes the building")


func test_cannot_overfill_site() -> void:
	var site = IndustrialSiteClass.new()
	site.max_slots = 2
	var big_building = Node.new()

	var success = site.place_building(big_building, 3)
	assert_false(success, "cannot place 3-slot building in 2-slot site")
	assert_eq(site.used_slots, 0, "slots unchanged on failed placement")
	assert_eq(site._buildings.size(), 0, "building not added on failed placement")


func test_place_returns_false_when_insufficient_slots() -> void:
	var site = IndustrialSiteClass.new()
	site.max_slots = 5
	var b1 = Node.new()
	var b2 = Node.new()

	site.place_building(b1, 3)
	var success = site.place_building(b2, 3)  # needs 3, only 2 free
	assert_false(success, "place_building returns false when insufficient slots")
	assert_eq(site.used_slots, 3, "used_slots unchanged on failed placement")
