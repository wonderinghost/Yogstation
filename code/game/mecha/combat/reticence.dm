/obj/mecha/combat/reticence
	desc = "A silent, fast, and nigh-invisible miming exosuit. Popular among mimes and mime assassins."
	name = "\improper reticence"
	icon_state = "reticence"
	step_in = 2
	dir_in = 1 //Facing North.
	max_integrity = 200
	integrity_failure = 100
	deflect_chance = 3
	armor = list(MELEE = 25, BULLET = 20, LASER = 30, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	max_temperature = 15000
	operation_req_access = list(ACCESS_THEATRE)
	internals_req_access = list(ACCESS_MECH_SCIENCE, ACCESS_THEATRE)
	add_req_access = 0
	internal_damage_threshold = 25
	max_equip = 2
	color = "#87878715"
	stepsound = null
	turnsound = null
	meleesound = FALSE
	opacity = FALSE

/obj/mecha/combat/reticence/Initialize(mapload)
	. = ..()
	if(internal_tank)
		internal_tank.set_light_on(FALSE) //remove the light that is granted by the internal canister
		internal_tank.set_light_range_power_color(0, 0, COLOR_BLACK) //just turning it off isn't enough apparently

/obj/mecha/combat/reticence/loaded/Initialize(mapload)
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/silenced
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/rcd/mime //HAHA IT MAKES WALLS GET IT
	ME.attach(src)
