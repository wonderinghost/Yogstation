GLOBAL_LIST_INIT(synthetic_base_access, list(
		ACCESS_SERVICE, ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_LIBRARY, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_HYDROPONICS, ACCESS_JANITOR, ACCESS_LAWYER, ACCESS_CLERK, ACCESS_HOP,
		ACCESS_SECURITY, ACCESS_SEC_BASIC, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_DETECTIVE, ACCESS_BRIG_PHYS, ACCESS_WEAPONS_PERMIT, ACCESS_LAWYER, ACCESS_MECH_SECURITY, ACCESS_HOS,
		ACCESS_MEDICAL, ACCESS_SURGERY, ACCESS_PARAMEDIC, ACCESS_MORGUE, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_PSYCHOLOGY, ACCESS_GENETICS, ACCESS_BRIG_PHYS, ACCESS_MECH_MEDICAL, ACCESS_CMO,
		ACCESS_SCIENCE, ACCESS_RESEARCH, ACCESS_TOXINS, ACCESS_TOXINS_STORAGE, ACCESS_EXPERIMENTATION, ACCESS_GENETICS, ACCESS_ROBOTICS, ACCESS_ROBO_CONTROL, ACCESS_XENOBIOLOGY, ACCESS_RND_SERVERS, ACCESS_AI_MASTER, ACCESS_AI_SAT, ACCESS_MECH_SCIENCE, ACCESS_RD,
		ACCESS_ENGINEERING, ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ENGINE_EQUIP, ACCESS_CONSTRUCTION, ACCESS_TECH_STORAGE, ACCESS_SECURE_TECH, ACCESS_TCOMMS, ACCESS_TCOMMS_ADMIN, ACCESS_AUX_BASE, ACCESS_MECH_ENGINE, ACCESS_CE,
		ACCESS_CARGO, ACCESS_CARGO_BAY, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_VAULT, ACCESS_MECH_MINING, ACCESS_QM,
		ACCESS_COMMAND, ACCESS_AI_MASTER, ACCESS_AI_SAT, ACCESS_TELEPORTER, ACCESS_EVA, ACCESS_VAULT, ACCESS_SECURE_TECH, ACCESS_RND_SERVERS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMMS_ADMIN, ACCESS_PERSONAL_LOCKERS, ACCESS_CHANGE_IDS, ACCESS_HOP, ACCESS_CAPTAIN))

GLOBAL_LIST_EMPTY(synthetic_added_access)

/datum/job/synthetic
	title = "Synthetic"
	description = "Watch over the crew, carry out mundane tasks that nobody else want to. Do no harm."
	orbit_icon = "microchip"
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON|DEADMIN_POSITION_CRITICAL
	department_head = list("AI")
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	supervisors = "the AI"
	minimal_player_age = 30
	exp_requirements = 900
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_COMMAND

	outfit = /datum/outfit/job/synthetic

	alt_titles = list("Android")

	added_access = list()
	base_access = list()
	paycheck = 0
	paycheck_department = ACCOUNT_SCI
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_SYNTHETIC

	departments_list = list(
		/datum/job_department/silicon,
	)


	mail_goodies = list()

	smells_like = "calculated machinery"
	alt_titles = list()

	forced_species = /datum/species/wy_synth

/datum/job/synthetic/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	. = ..()
	H.apply_pref_name(/datum/preference/name/synthetic, M.client)
	H.remove_all_quirks()

/datum/job/synthetic/get_access()
	return GLOB.synthetic_base_access


/datum/outfit/job/synthetic
	name = "Synthetic"
	jobtype = /datum/job/synthetic

	id_type = /obj/item/card/id/silver/synthetic
	ears = /obj/item/radio/headset/headset_synthetic
	suit = /obj/item/clothing/suit/space/hardsuit/synth
	pda_type = null

/datum/outfit/job/synthetic/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(H.w_uniform)
		var/obj/item/clothing/under/wearing = H.w_uniform
		wearing.has_sensor = FALSE
	
	var/obj/machinery/ai/data_core/core 
	core = H.available_ai_cores(forced = TRUE)
	if(core)
		core.network.add_synth(H)


/datum/outfit/job/synthetic/naked
	name = "Synthetic (Naked)"

	uniform = null
	ears = null
	back = null
	shoes = null
	box = null

	preload = FALSE // These are used by the prefs ui, and also just kinda could use the extra help at roundstart

	backpack = null
	satchel  = null
	duffelbag = null

/datum/outfit/job/synthetic/naked/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	return
