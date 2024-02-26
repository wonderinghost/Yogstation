/datum/job/clerk
	title = "Clerk"
	description = "Set up shop on the station and unique sell trinkets to the crew for a profit."
	orbit_icon = "basket-shopping"
	department_head = list("Head of Personnel")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	added_access = list()
	base_access = list(ACCESS_MANUFACTURING)
	alt_titles = list("Salesman", "Gift Shop Attendent", "Retail Worker")
	outfit = /datum/outfit/job/clerk
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	display_order = JOB_DISPLAY_ORDER_CLERK
	minimal_character_age = 18 //Capitalism doesn't care about age

	departments_list = list(
		/datum/job_department/service,
	)

	mail_goodies = list(
		/obj/effect/spawner/lootdrop/maintenance/three = 35, //bunch of stuff that could interest assistants
		/obj/item/stack/sheet/plastic/five = 30,
		/obj/effect/spawner/lootdrop/plushies = 20,
		/obj/item/toy/minimeteor = 15,
		/obj/item/circuitboard/computer/slot_machine = 15,
		/obj/item/melee/dualsaber/toy = 10,
		/obj/item/toy/windupToolbox = 10,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 5,
		/obj/item/storage/fancy/heart_box = 5,
		/obj/item/lipstick/random = 5,
		/obj/item/skub = 2, //pro skub have taken over the mail
		/obj/item/stack/ore/bluespace_crystal/refined/nt = 1
	)

	smells_like = "cheap plastic"

/datum/outfit/job/clerk
	name = "Clerk"
	jobtype = /datum/job/clerk

	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/yogs/rank/clerk
	uniform_skirt = /obj/item/clothing/under/yogs/rank/clerk/skirt
	shoes = /obj/item/clothing/shoes/sneakers/black
	head = /obj/item/clothing/head/yogs/clerkcap
	backpack_contents = list(/obj/item/circuitboard/machine/paystand = 1)
