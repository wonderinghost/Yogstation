/*
Slimecrossing Armor
	Armor added by the slimecrossing system.
	Collected here for clarity.
*/

//Rebreather mask - Chilling Blue
/obj/item/clothing/mask/nobreath
	name = "rebreather mask"
	desc = "A transparent mask, resembling a conventional breath mask, but made of bluish slime. Seems to lack any air supply tube, though, as if it doesn't need one."
	icon_state = "slime"
	item_state = "slime"
	body_parts_covered = NONE
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 15, RAD = 0, FIRE = 0, ACID = 0)
	flags_cover = MASKCOVERSMOUTH
	resistance_flags = NONE

/obj/item/clothing/mask/nobreath/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_MASK)
		ADD_TRAIT(user, TRAIT_NOBREATH, "breathmask_[REF(src)]")
		user.failed_last_breath = FALSE
		user.clear_alert("not_enough_oxy")
		user.apply_status_effect(/datum/status_effect/rebreathing)

/obj/item/clothing/mask/nobreath/dropped(mob/living/carbon/human/user)
	..()
	REMOVE_TRAIT(user, TRAIT_NOBREATH, "breathmask_[REF(src)]")
	user.remove_status_effect(/datum/status_effect/rebreathing)

/obj/item/clothing/glasses/prism_glasses
	name = "prism glasses"
	desc = "The lenses seem to glow slightly, and reflect light into dazzling colors."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "prismglasses"
	actions_types = list(/datum/action/item_action/change_prism_colour, /datum/action/item_action/place_light_prism)
	var/glasses_color = "#FFFFFF"

/obj/item/clothing/glasses/prism_glasses/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_EYES)
		return TRUE

/obj/structure/light_prism
	name = "light prism"
	desc = "A shining crystal of semi-solid light. Looks fragile."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "lightprism"
	density = FALSE
	anchored = TRUE
	max_integrity = 10

/obj/structure/light_prism/Initialize(mapload, newcolor)
	. = ..()
	color = newcolor
	light_color = newcolor
	set_light(2)

/obj/structure/light_prism/attack_hand(mob/user)
	to_chat(user, span_notice("You dispel [src]"))
	qdel(src)

/datum/action/item_action/change_prism_colour
	name = "Adjust Prismatic Lens"
	button_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "prismcolor"

/datum/action/item_action/change_prism_colour/Trigger()
	if(!IsAvailable(feedback = FALSE))
		return
	var/obj/item/clothing/glasses/prism_glasses/glasses = target
	var/new_color = input(owner, "Choose the lens color:", "Color change",glasses.glasses_color) as color|null
	if(!new_color)
		return
	glasses.glasses_color = new_color

/datum/action/item_action/place_light_prism
	name = "Fabricate Light Prism"
	button_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "lightprism"

/datum/action/item_action/place_light_prism/Trigger()
	if(!IsAvailable(feedback = FALSE))
		return
	var/obj/item/clothing/glasses/prism_glasses/glasses = target
	if(locate(/obj/structure/light_prism) in get_turf(owner))
		to_chat(owner, span_warning("There isn't enough ambient energy to fabricate another light prism here."))
		return
	if(istype(glasses))
		if(!glasses.glasses_color)
			to_chat(owner, span_warning("The lens is oddly opaque..."))
			return
		to_chat(owner, span_notice("You channel nearby light into a glowing, ethereal prism."))
		new /obj/structure/light_prism(get_turf(owner), glasses.glasses_color)

/obj/item/clothing/head/peaceflower
	name = "heroine bud"
	desc = "An extremely addictive flower, full of peace magic."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "peaceflower"
	item_state = "peaceflower"
	slot_flags = ITEM_SLOT_HEAD
	body_parts_covered = NONE
	dynamic_hair_suffix = ""
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3

/obj/item/clothing/head/peaceflower/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_HEAD)
		ADD_TRAIT(user, TRAIT_PACIFISM, "peaceflower_[REF(src)]")

/obj/item/clothing/head/peaceflower/dropped(mob/living/carbon/human/user)
	..()
	REMOVE_TRAIT(user, TRAIT_PACIFISM, "peaceflower_[REF(src)]")

/obj/item/clothing/head/peaceflower/attack_hand(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.head)
			to_chat(user, span_warning("You feel at peace. <b style='color:pink'>Why would you want anything else?</b>"))
			return
	return ..()

/obj/item/clothing/suit/armor/heavy/adamantine
	name = "adamantine armor"
	desc = "A full suit of adamantine plate armor. Impressively resistant to damage, but weighs about as much as you do."
	icon_state = "adamsuit"
	item_state = "adamsuit"
	flags_inv = NONE
	obj_flags = IMMUTABLE_SLOW
	armor = list(MELEE = 60, BULLET = 50, LASER = 30, ENERGY = 50, BOMB = 80, BIO = 100, RAD = 0, FIRE = 90, ACID = 90)
	slowdown = 4
	var/hit_reflect_chance = 40

/obj/item/clothing/suit/armor/heavy/adamantine/equipped(mob/user, slot)
	. = ..()
	if(slot_flags & slot)
		RegisterSignal(user, COMSIG_ATOM_BULLET_ACT, PROC_REF(do_reflect))

/obj/item/clothing/suit/armor/heavy/adamantine/dropped(mob/user)
	if(user.get_item_by_slot(ITEM_SLOT_OCLOTHING) == src)
		UnregisterSignal(user, COMSIG_ATOM_BULLET_ACT)
	return ..()

/obj/item/clothing/suit/armor/heavy/adamantine/proc/do_reflect(mob/living/defender, obj/projectile/incoming, def_zone)
	if(!(incoming.reflectable & REFLECT_NORMAL))
		return NONE
	if(!(def_zone in list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))) //If not shot where ablative is covering you, you don't get the reflection bonus!
		return NONE
	incoming.damage *= 0.5 // split the damage between you and whoever it gets reflected at
	incoming.on_hit(defender, defender.run_armor_check(def_zone, incoming.armor_flag, "", "", incoming.armour_penetration))
	incoming.setAngle()
	if(incoming.hitscan) // hitscan check
		incoming.store_hitscan_collision(incoming.trajectory.copy_to())
	incoming.firer = defender
	var/new_angle_s = incoming.Angle + rand(120,240)
	while(new_angle_s > 180)	// Translate to regular projectile degrees
		new_angle_s -= 360
	incoming.setAngle(new_angle_s)
	playsound(defender, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, 1)
	return BULLET_ACT_FORCE_PIERCE
