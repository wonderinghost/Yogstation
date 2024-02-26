/datum/job/qm
	title = "Quartermaster"
	description = "Coordinate cargo technicians and shaft miners, assist with \
		economical purchasing."
	orbit_icon = "sack-dollar"
	department_head = list("Head of Personnel")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	outfit = /datum/outfit/job/quartermaster
	alt_titles = list("Stock Controller", "Cargo Coordinator", "Shipping Overseer", "Postmaster General")
	added_access = list()
	base_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_MINING, ACCESS_MECH_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM, ACCESS_VAULT)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR
	display_order = JOB_DISPLAY_ORDER_QUARTERMASTER
	minimal_character_age = 20 //Probably just needs some baseline experience with bureaucracy, enough trust to land the position

	departments_list = list(
		/datum/job_department/cargo,
	)

	mail_goodies = list(
		/obj/item/stack/sheet/mineral/gold = 10,
		/obj/item/clothing/mask/facehugger/toy = 5,
		/obj/item/circuitboard/machine/emitter = 3,
		/obj/item/survivalcapsule/luxuryelite = 2,
		/obj/item/construction/rcd = 2,
		/obj/item/circuitboard/machine/vending/donksofttoyvendor = 1
	)

	minimal_lightup_areas = list(
		/area/quartermaster/qm
	)

	smells_like = "capitalism"

	exp_requirements = 120
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_SUPPLY

/datum/outfit/job/quartermaster
	name = "Quartermaster"
	jobtype = /datum/job/qm

	pda_type = /obj/item/modular_computer/tablet/pda/preset/cargo

	ears = /obj/item/radio/headset/headset_cargo
	uniform = /obj/item/clothing/under/rank/cargo
	uniform_skirt = /obj/item/clothing/under/rank/cargo/skirt
	shoes = /obj/item/clothing/shoes/sneakers/brown
	glasses = /obj/item/clothing/glasses/sunglasses
	l_hand = /obj/item/clipboard
	l_pocket = /obj/item/export_scanner

	chameleon_extras = /obj/item/stamp/qm

