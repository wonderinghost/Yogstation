/obj/item/gun/ballistic/bow
	name = "wooden bow"
	desc = "A well-made weapon capable of firing arrows. Mostly outdated, but still dependable."
	icon_state = "bow"
	item_state = "bow"
	icon = 'icons/obj/guns/bows.dmi'
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY //need both hands to fire
	force = 5
	spread = 1
	mag_type = /obj/item/ammo_box/magazine/internal/bow
	fire_sound = 'sound/weapons/sound_weapons_bowfire.ogg'
	slot_flags = ITEM_SLOT_BACK
	item_flags = NEEDS_PERMIT | SLOWS_WHILE_IN_HAND
	casing_ejector = FALSE
	internal_magazine = TRUE
	pin = null
	no_pin_required = TRUE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL //so ashwalkers can use it

	// No vertical grip on a bow
	available_attachments = list(
		/obj/item/attachment/scope/simple,
		/obj/item/attachment/scope/holo,
		/obj/item/attachment/scope/infrared,
		/obj/item/attachment/laser_sight,
	)

	// Drawing vars //
	var/drawing = FALSE
	var/drop_release_draw = TRUE
	var/move_drawing = TRUE
	var/draw_time = 0.5 SECONDS
	var/draw_slowdown = 0.75
	var/draw_sound = 'sound/weapons/sound_weapons_bowdraw.ogg'
	/// If the last loaded arrow was a toy arrow or not, used to see if foam darts / arrows should do stamina damage
	var/nerfed = FALSE

/obj/item/gun/ballistic/bow/shoot_with_empty_chamber()
	return

/obj/item/gun/ballistic/bow/chamber_round()
	chambered = magazine.get_round(1)
	update_slowdown()
	update_appearance(UPDATE_ICON)

/obj/item/gun/ballistic/bow/dropped()
	. = ..()
	if(!QDELING(src))
		addtimer(CALLBACK(src, PROC_REF(release_draw_if_not_held)))

/obj/item/gun/ballistic/bow/proc/release_draw_if_not_held()
	if(!ismob(loc))
		if(drop_release_draw)
			release_draw()
		nerfed = initial(nerfed) // So you can't meta if the last arrow loaded by a dropped bow was a toy arrow or not

/obj/item/gun/ballistic/bow/proc/release_draw()
	var/old_chambered = chambered
	chambered = null
	magazine.give_round(old_chambered)
	update_slowdown()
	update_appearance(UPDATE_ICON)

/obj/item/gun/ballistic/bow/equipped(mob/user, slot)
	..()
	nerfed = initial(nerfed)

/obj/item/gun/ballistic/bow/process_chamber()
	chambered = null
	magazine.get_round(FALSE)
	update_slowdown()
	update_appearance(UPDATE_ICON)

/obj/item/gun/ballistic/bow/attack_self(mob/living/user)
	if(drawing)
		to_chat(user, span_notice("You are already drawing the bowstring!"))
		return TRUE
	if(chambered)
		release_draw()
		to_chat(user, span_notice("You gently release the bowstring."))
		return TRUE
	else if(get_ammo())
		drawing = TRUE
		update_slowdown()
		if(!do_after(user, draw_time, src, timed_action_flags = (move_drawing ? IGNORE_USER_LOC_CHANGE|IGNORE_HELD_ITEM : IGNORE_HELD_ITEM)))
			drawing = FALSE
			update_slowdown()
			return TRUE
		drawing = FALSE
		to_chat(user, span_notice("You draw back the bowstring."))
		playsound(src, draw_sound, 75, 0, falloff_exponent = 3) //gets way too high pitched if the freq varies
		chamber_round()
		return TRUE

/obj/item/gun/ballistic/bow/AltClick(mob/user)
	if(chambered || get_ammo())
		var/obj/item/ammo_casing/AC = chambered ? chambered : magazine.get_round(TRUE)
		AC.attack_self(user)
		return
	..()

/obj/item/gun/ballistic/bow/attack_hand(mob/user)
	if(internal_magazine && loc == user && user.is_holding(src) && (chambered || get_ammo()))
		remove_arrow(user)
		return
	return ..()

/obj/item/gun/ballistic/bow/proc/remove_arrow(mob/user)
	if(!chambered && !get_ammo())
		return
	var/obj/item/ammo_casing/AC = magazine.get_round(FALSE)
	chambered = null
	if(CHECK_BITFIELD(AC.item_flags, DROPDEL))
		// Shouldn't be put into someone's hand
		qdel(AC)
		if(user)
			to_chat(user, span_notice("You disperse [AC]."))
	else if(user)
		user.put_in_hands(AC)
		to_chat(user, span_notice("You remove [AC]."))
	update_slowdown()
	update_appearance(UPDATE_ICON)

/obj/item/gun/ballistic/bow/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_casing))
		if(!user.is_holding(src))
			to_chat(user, span_notice("You need to hold [src] to load \the [I]."))
		else if (magazine.attackby(I, user, params, 1))
			to_chat(user, span_notice("You notch [I]."))
			nerfed = istype(I, /obj/item/ammo_casing/reusable/arrow/toy)
	update_slowdown()
	update_appearance(UPDATE_ICON)

/obj/item/gun/ballistic/bow/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][chambered ? "_firing" : ""]"

/obj/item/gun/ballistic/bow/update_overlays()
	. = ..()
	if(get_ammo())
		var/obj/item/ammo_casing/reusable/arrow/E = magazine.get_round(TRUE)
		var/mutable_appearance/arrow_overlay = mutable_appearance(icon, "[initial(E.item_state)][chambered ? "_firing" : ""]")
		. += arrow_overlay

/obj/item/gun/ballistic/bow/proc/update_slowdown()
	if(chambered || drawing)
		slowdown = draw_slowdown
	else
		slowdown = initial(slowdown)

/obj/item/gun/ballistic/bow/can_shoot()
	return chambered

/obj/item/gun/ballistic/bow/ashen
	name = "bone bow"
	desc = "A primitive bow with a sinew bowstring. Typically used by tribal hunters and warriors."
	icon_state = "ashenbow"
	item_state = "ashenbow"
	force = 10
	spread = 3

/obj/item/gun/ballistic/bow/pipe
	name = "pipe bow"
	desc = "A variety of pipes and plastic bent together with a silk bowstring. Cumbersome and inaccurate."
	icon_state = "pipebow"
	item_state = "pipebow"
	force = 12
	spread = 5
	draw_time = 1 SECONDS

/obj/item/gun/ballistic/bow/maint
	name = "makeshift bow"
	desc = "A crude contraption of rods, tape, and cable; this bow is servicable, but of poor quality."
	icon_state = "makeshift_bow"
	item_state = "makeshift_bow"
	force = 8
	spread = 7
	draw_time = 1 SECONDS
	
/obj/item/gun/ballistic/bow/crossbow
	name = "wooden crossbow"
	desc = "A handcrafted version of a typical medieval crossbow. The stock is heavy and loading it takes time, but it can be quickly fired once ready."
	icon_state = "crossbow"
	item_state = "crossbow"
	force = 15 //Beating someone with a goddamned stock are we
	spread = 0
	weapon_weight = WEAPON_MEDIUM // You only need one hand to pull the trigger, though good luck reloading it with one hand
	draw_time = 2 SECONDS
	draw_slowdown = FALSE
	drop_release_draw = FALSE
	move_drawing = FALSE
	
/obj/item/gun/ballistic/bow/crossbow/ashen
	name = "bone crossbow"
	desc = "An advanced, primitive bow that is designed to function similar to a crossbow. The stock is heavy and loading it takes time, but it can be quickly fired once ready."
	icon_state = "ashencrossbow"
	item_state = "ashencrossbow"
	spread = 1
	
/obj/item/gun/ballistic/bow/crossbow/magfed
	name = "wooden magfed crossbow"
	desc = "A bow with a locking mechanism that more closely resembles a modern gun. This one seems to be outfitted with an automatic loading mechanism."
	mag_type = /obj/item/ammo_box/magazine/arrow
	internal_magazine = FALSE

/obj/item/gun/ballistic/bow/crossbow/magfed/attackby(obj/item/I, mob/user, params)
	if (!internal_magazine && istype(I, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = I
		if (!magazine)
			insert_magazine(user, AM)
		else
			if (tac_reloads)
				eject_magazine(user, FALSE, AM)
			else
				to_chat(user, span_notice("There's already a [magazine_wording] in \the [src]."))
		return
	..()


// Toy //

/obj/item/gun/ballistic/bow/toy
	name = "toy bow"
	desc = "A plastic bow that can fire arrows. Features real voice action!"
	force = 0
	spread = 10
	draw_time = 2 SECONDS
	nerfed = TRUE

	var/obj/item/assembly/assembly = /obj/item/assembly/voice_box/bow

/obj/item/gun/ballistic/bow/toy/Initialize(mapload)
	. = ..()
	if(ispath(assembly))
		assembly = new assembly(src)

/obj/item/gun/ballistic/bow/toy/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(!assembly)
		to_chat(user, span_warning("[src] doesn't have a device inside!"))
		return TRUE
	I.play_tool_sound(src)
	to_chat(user, span_notice("You remove [assembly] from [src]."))
	user.put_in_hands(assembly)
	assembly = null
	return TRUE

/obj/item/gun/ballistic/bow/toy/process_chamber()
	..()
	if(assembly)
		assembly.pulsed()

/obj/item/gun/ballistic/bow/toy/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/assembly))
		if(assembly)
			to_chat(user, span_warning("[src] already has a device inside!"))
			return
		if(!user.transferItemToLoc(I, src))
			return
		assembly = I
		return
	return ..()

/obj/item/gun/ballistic/bow/toy/white
	name = "white toy bow"
	icon_state = "bow_toy_white"
	item_state = "bow_hardlight_arrow_disable"

/obj/item/gun/ballistic/bow/toy/blue
	name = "blue toy bow"
	desc = "A toy bow equipped with a screeching voice box, themed after Nanotrasen."
	icon_state = "bow_toy_blue"
	item_state = "bow_ert_arrow_pulse"
	assembly = /obj/item/assembly/voice_box/bow/nanotrasen

/obj/item/gun/ballistic/bow/toy/red
	name = "red toy bow"
	desc = "A red toy boy meant to replicate the hardlight bow used by Syndicate operatives. Comes equipped with a loud voice box."
	icon_state = "bow_toy_red"
	item_state = "bow_syndicate_arrow_energy"
	assembly = /obj/item/assembly/voice_box/bow/syndie

/obj/item/gun/ballistic/bow/toy/clockwork
	name = "clockwork toy bow"
	desc = "A plastic, Ratvarian-based toy bow. Sounds a gnarly, obnoxious voice box when fired."
	icon_state = "bow_toy_clockwork"
	item_state = "bow_clockwork_arrow_energy"
	assembly = /obj/item/assembly/voice_box/bow/clockwork


// Wizard //

/obj/item/gun/ballistic/bow/break_bow
	name = "break bow"
	desc = "A finely-crafted bow consisting of two blades combined at the hilt and a magical, semi-transparent bowstring. Can be taken apart to use the blades individually."
	icon_state = "breakbow"
	item_state = "breakbow"
	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 40	// You can still hit them with both of the blades (better)
	throwforce = 40 //Last ditch screaming
	armour_penetration = 50 //Bro this shit's MAGIC
	sharpness = SHARP_EDGED
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "cut")
	wound_bonus = 10
	draw_time = 0.25 SECONDS
	draw_slowdown = 0 //They're a wizard they need to zoom around
	var/bladetype = /obj/item/break_blade

/obj/item/gun/ballistic/bow/break_bow/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 80 - force, 100, force - 10)

/obj/item/gun/ballistic/bow/break_bow/attack_self(mob/living/user)
	if(get_ammo())
		return ..()
	form_blades(user)

/obj/item/gun/ballistic/bow/break_bow/proc/form_blades(mob/living/user)
	moveToNullspace()
	user.put_in_hands(new bladetype())
	user.put_in_hands(new bladetype())
	playsound(user, 'sound/weapons/batonextend.ogg', 50, 1)
	to_chat(user, span_notice("You detach the two blades of [src]."))
	qdel(src)

/obj/item/break_blade
	name = "break bow blade"
	desc = "One of two blades used to form a break bow. Can attack with both blades at the same time or combine them into a bow."
	icon_state = "brakebow_blade"
	item_state = "brakebow_blade"
	icon = 'icons/obj/weapons/shortsword.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 10, "embedded_fall_chance" = 10, "embedded_ignore_throwspeed_threshold" = TRUE)
	force = 27 //Total of 54 damage = death in two clicks (probably) PLUS it doesn't care about anti-magic
	throwforce = 45 //Can't return if it hits anti-magic
	armour_penetration = 50 //Enchanted blade of fuck you
	sharpness = SHARP_EDGED
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "cut")
	wound_bonus = 10
	var/bowtype = /obj/item/gun/ballistic/bow/break_bow
	var/returning = FALSE

/obj/item/break_blade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 80 - force, 100, force - 10)

/obj/item/break_blade/attack_self(mob/living/user)
	var/obj/item/break_blade/secondblade = user.get_inactive_held_item()
	if(istype(secondblade))
		form_bow(user, secondblade)
	else
		to_chat(user, span_warning("You need two of [src] to combine them!"))

/obj/item/break_blade/proc/form_bow(mob/living/user, obj/item/break_blade/other_blade)
	if(!istype(other_blade))
		return
	moveToNullspace()
	other_blade.moveToNullspace()
	user.put_in_hands(new bowtype())
	playsound(user, 'sound/weapons/batonextend.ogg', 50, 1)
	to_chat(user, span_notice("You combine the two [src]."))
	qdel(other_blade)
	qdel(src)

/obj/item/break_blade/pre_attack(atom/A, mob/living/user, params)
	if(istype(A, /obj/item/break_blade))
		form_bow(user, A)
		return TRUE
	. = ..()

/obj/item/break_blade/attack(mob/living/M, mob/living/user, secondattack = FALSE)
	. = ..()
	var/obj/item/break_blade/secondblade = user.get_inactive_held_item()
	if(istype(secondblade) && !secondattack)
		sleep(0.2 SECONDS)
		secondblade.attack(M, user, TRUE)

/obj/item/break_blade/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, quickstart)
	. = ..()
	if(!thrower)
		return
	if(!returning)
		addtimer(CALLBACK(src, PROC_REF(return_to), thrower), 3 SECONDS)
		returning = TRUE
	var/obj/item/break_blade/secondblade = thrower.get_inactive_held_item()
	if(istype(secondblade))
		addtimer(CALLBACK(src, PROC_REF(finish_throw), secondblade, target, range, speed, thrower, spin, diagonals_first, callback, force, quickstart), 0.2 SECONDS)

/obj/item/break_blade/proc/finish_throw(obj/item/break_blade/secondblade, atom/target, range, speed, mob/thrower, \
										spin, diagonals_first, datum/callback/callback, force, quickstart)
	thrower.dropItemToGround(secondblade, silent = TRUE)
	secondblade.throw_at(target, range, speed, thrower, spin, diagonals_first, callback, force, quickstart)

/obj/item/break_blade/proc/return_to(mob/living/user)
	if(!istype(user))
		return

	var/mob/holder = loc
	if(istype(holder) && holder.can_cast_magic())
		to_chat(holder, span_notice("You feel [src] tugging on you."))
		return

	var/mob/living/carbon/carbon = loc
	if(istype(carbon))
		var/obj/item/bodypart/part = carbon.get_embedded_part(src)
		if(part)
			if(!carbon.remove_embedded_object(src, unsafe = TRUE))
				to_chat(carbon, span_notice("You feel [src] tugging on you."))
				return
			to_chat(carbon, span_userdanger("[src] suddenly rips out of you!"))

	if(!user.put_in_hands(src))
		return
	playsound(user, 'sound/magic/blink.ogg', 50, 1)
	returning = FALSE
	to_chat(user, span_notice("[src] suddenly returns to you!"))


// Hardlight //

/obj/item/gun/ballistic/bow/energy
	name = "hardlight bow"
	desc = "A modern bow that can fabricate hardlight arrows using an internal energy."
	icon_state = "bow_hardlight"
	item_state = "bow_hardlight"
	mag_type = /obj/item/ammo_box/magazine/internal/bow/energy
	no_pin_required = FALSE
	draw_slowdown = 0
	var/recharge_time = 1 SECONDS

	var/can_fold = FALSE
	var/folded_w_class = WEIGHT_CLASS_NORMAL
	var/folded = FALSE
	//var/stored_ammo ///what was stored in the magazine before being folded?
	var/fold_sound = 'sound/weapons/batonextend.ogg'

/obj/item/gun/ballistic/bow/energy/Initialize(mapload)
	if(folded)
		toggle_folded(TRUE)
	. = ..()

/obj/item/gun/ballistic/bow/energy/examine(mob/user)
	. = ..()
	var/obj/item/ammo_box/magazine/internal/bow/energy/M = magazine
	if(magazine.ammo_type)
		var/obj/item/arrow_type = magazine.ammo_type
		. += "It is current firing mode is \"[initial(arrow_type.name)]\"[M.selectable_types.len > 1 ? ", you can select firing modes by using ALT + CLICK" : ""]."
	if(can_fold)
		. += "[folded ? "It is currently folded, you can unfold it" : "It can be folded into a compact form"] by using CTRL + CLICK."
	if(TIMER_COOLDOWN_CHECK(src, "arrow_recharge"))
		. += span_warning("It is currently recharging!")

/obj/item/gun/ballistic/bow/energy/update_icon_state()
	. = ..()
	if(folded)
		icon_state = "[initial(icon_state)]_folded"
		item_state = "[initial(item_state)]_folded"
	else if(get_ammo())
		icon_state = initial(icon_state)
	else
		item_state = initial(item_state)
		icon_state = initial(icon_state)

	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()

/obj/item/gun/ballistic/bow/energy/shoot_live_shot(mob/living/user, pointblank, atom/pbtarget, message)
	if(folded)
		to_chat(user, span_notice("You must unfold [src] before firing it!"))
		return FALSE
	. = ..()
	if(recharge_time)
		TIMER_COOLDOWN_START(src, "arrow_recharge", recharge_time)
		addtimer(CALLBACK(src, PROC_REF(end_cooldown)), recharge_time)

/obj/item/gun/ballistic/bow/energy/proc/end_cooldown()
	playsound(src, 'sound/effects/sparks4.ogg', 25, 0)

/obj/item/gun/ballistic/bow/energy/attack_self(mob/living/user)
	if(folded)
		toggle_folded(FALSE, user)
	if(..())
		return TRUE
	if(!chambered && !get_ammo() && (!recharge_time || !TIMER_COOLDOWN_CHECK(src, "arrow_recharge")))
		to_chat(user, span_notice("You fabricate an arrow."))
		recharge_arrow()
	update_slowdown()
	update_appearance(UPDATE_ICON)

/obj/item/gun/ballistic/bow/energy/proc/recharge_arrow()
	if(folded || magazine.get_round(TRUE))
		return
	var/ammo_type = magazine.ammo_type
	magazine.give_round(new ammo_type())
	update_slowdown()
	update_appearance(UPDATE_ICON)

/obj/item/gun/ballistic/bow/energy/attackby(obj/item/I, mob/user, params)
	return

/obj/item/gun/ballistic/bow/energy/AltClick(mob/living/user)
	select_projectile(user)
	var/current_round = magazine.get_round(TRUE)
	if(current_round)
		QDEL_NULL(current_round)
	if(!TIMER_COOLDOWN_CHECK(src, "arrow_recharge"))
		recharge_arrow()
	update_appearance(UPDATE_ICON)

/obj/item/gun/ballistic/bow/energy/proc/select_projectile(mob/living/user)
	var/obj/item/ammo_box/magazine/internal/bow/energy/M = magazine
	if(!istype(M) || !M.selectable_types)
		return
	var/list/selectable_types = M.selectable_types
	
	switch(selectable_types.len)
		if(1)
			M.ammo_type = selectable_types[1]
			to_chat(user, span_notice("\The [src] doesn't have any other firing modes."))
		if(2)
			selectable_types = selectable_types - M.ammo_type
			var/obj/item/ammo_casing/reusable/arrow/energy/new_ammo_type = selectable_types[1]
			M.ammo_type = new_ammo_type
			to_chat(user, span_notice("You switch \the [src]'s firing mode to \"[initial(new_ammo_type.name)]\"."))
		else
			var/list/choice_list = list()
			var/list/radial_list = list()
			for(var/type in M.selectable_types)
				var/obj/item/arrow_type = type
				var/datum/radial_menu_choice/choice = new
				choice.image = image(initial(arrow_type.icon), icon_state = initial(arrow_type.icon_state))
				choice.info = initial(arrow_type.desc)
				choice.active = M.ammo_type == type
				choice_list[initial(arrow_type.name)] = arrow_type
				radial_list[initial(arrow_type.name)] = choice
			var/raw_choice = show_radial_menu(user, user, radial_list, tooltips = TRUE)
			if(!raw_choice || !(raw_choice in radial_list))
				return
			var/obj/item/ammo_casing/reusable/arrow/energy/choice = choice_list[raw_choice]
			if(!choice || !(choice in M.selectable_types))
				return
			M.ammo_type = choice
			to_chat(user, span_notice("You switch \the [src]'s firing mode to \"[initial(choice.name)]\"."))
			QDEL_NULL(choice_list)
			QDEL_NULL(radial_list)
	update_appearance(UPDATE_ICON)

/obj/item/gun/ballistic/bow/energy/CtrlClick(mob/living/user)
	if(!can_fold || !user.is_holding(src))
		return ..()
	if(drawing)
		to_chat(user, span_notice("You can't fold \the [src] while drawing the bowstring."))
	toggle_folded(!folded, user)

/obj/item/gun/ballistic/bow/energy/proc/toggle_folded(new_folded, mob/living/user)
	if(!can_fold)
		return

	if(folded != new_folded)
		playsound(src.loc, fold_sound, 50, 1)

	folded = new_folded

	if(folded)
		w_class = folded_w_class
		chambered = null
		//stored_ammo = magazine.ammo_list()
		//magazine.stored_ammo = null
		if(user)
			to_chat(user, span_notice("You fold [src]."))
	else
		w_class = initial(w_class)
		//magazine.stored_ammo = stored_ammo
		if(user)
			to_chat(user, span_notice("You extend [src], allowing it to be fired."))
	update_appearance(UPDATE_ICON)

/obj/item/gun/ballistic/bow/energy/advanced
	name = "advanced hardlight bow"
	mag_type = /obj/item/ammo_box/magazine/internal/bow/energy/advanced
	recharge_time = 0
	pin = /obj/item/firing_pin
	can_fold = TRUE

/obj/item/gun/ballistic/bow/energy/ert
	name = "\improper HL-P1 Multipurpose Combat Bow"
	desc = "An expensive hardlight bow designed by Nanotrasen and often sold to the SIC's espionage branch. Capable of firing disabler, energy, pulse, and taser bolts."
	icon_state = "bow_ert"
	item_state = "bow_ert"
	mag_type = /obj/item/ammo_box/magazine/internal/bow/energy/ert
	pin = /obj/item/firing_pin
	can_fold = TRUE

/obj/item/gun/ballistic/bow/energy/syndicate
	name = "syndicate hardlight bow"
	desc = "A modern bow that can fabricate hardlight arrows using an internal energy. This one is designed by the Syndicate for silent takedowns of targets."
	icon_state = "bow_syndicate"
	item_state = "bow_syndicate"
	mag_type = /obj/item/ammo_box/magazine/internal/bow/energy/syndicate
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 5
	pin = /obj/item/firing_pin
	fire_sound = null
	draw_sound = null
	can_fold = TRUE

/obj/item/gun/ballistic/bow/energy/syndicate/folded
	folded = TRUE

/obj/item/gun/ballistic/bow/energy/clockwork
	name = "brass bow"
	desc = "A bow made from brass and other components that you can't quite understand. It glows with a deep energy and fabricates arrows by itself."
	icon_state = "bow_clockwork"
	item_state = "bow_clockwork"
	mag_type = /obj/item/ammo_box/magazine/internal/bow/energy/clockcult
	pin = /obj/item/firing_pin/clockie
