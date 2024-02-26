/datum/job/artist
	title = "Artist"
	description = "Create unique pieces of art for display by the crew around the station."
	orbit_icon = "paintbrush"
	department_head = list("Head of Personnel")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"

	outfit = /datum/outfit/job/artist
	alt_titles = list("Painter", "Composer", "Artisan")
	added_access = list()
	base_access = list()
	paycheck = PAYCHECK_ASSISTANT
	paycheck_department = ACCOUNT_CIV

	display_order = JOB_DISPLAY_ORDER_ARTIST
	minimal_character_age = 18 //Young folks can be crazy crazy artists, something talented that can be self-taught feasibly

	mail_goodies = list(
	  	/obj/item/grenade/chem_grenade/colorful = 10,
		/obj/item/toy/crayon/spraycan = 10,
		/obj/item/choice_beacon/music = 5,
		/obj/item/storage/toolbox/artistic = 5,
		/obj/item/paint/anycolor = 5,
		/obj/item/cardboard_cutout = 3,
		/obj/item/toy/crayon/rainbow = 2
	)

	departments_list = list(
		/datum/job_department/service,
	)

	smells_like = "pain-t"

/datum/outfit/job/artist
	name = "Artist"
	jobtype = /datum/job/artist

	pda_type = /obj/item/modular_computer/tablet/pda/preset/basic
	
	head = /obj/item/clothing/head/frenchberet
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/artist
	uniform_skirt = /obj/item/clothing/under/rank/artist/skirt
	gloves = /obj/item/clothing/gloves/fingerless
	neck = /obj/item/clothing/neck/artist
	l_pocket = /obj/item/laser_pointer
	backpack_contents = list(
		/obj/item/stack/cable_coil/random/thirty = 1,
		/obj/item/toy/crayon/spraycan = 1,
		/obj/item/storage/crayons = 1,
		/obj/item/camera = 1
	)
