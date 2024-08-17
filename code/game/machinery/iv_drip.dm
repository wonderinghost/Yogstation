#define IV_TAKING 0
#define IV_INJECTING 1

/obj/machinery/iv_drip
	name = "\improper IV drip"
	desc = "An IV drip with an advanced infusion pump that can both drain blood into and inject liquids from attached containers. Blood packs are processed at an accelerated rate."
	icon = 'icons/obj/iv_drip.dmi'
	icon_state = "iv_drip"
	anchored = FALSE
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER
	var/mob/living/carbon/attached
	var/mode = IV_INJECTING
	var/obj/item/reagent_containers/beaker
	var/static/list/drip_containers = typecacheof(list(/obj/item/reagent_containers/blood,
									/obj/item/reagent_containers/food,
									/obj/item/reagent_containers/glass))
	var/can_convert = TRUE // If it can be made into an anesthetic machine or not

/obj/machinery/iv_drip/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/machinery/iv_drip/Destroy()
	attached = null
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/iv_drip/update_icon_state()
	. = ..()
	if(attached)
		if(mode)
			icon_state = "injecting"
		else
			icon_state = "donating"
	else
		if(mode)
			icon_state = "injectidle"
		else
			icon_state = "donateidle"

/obj/machinery/iv_drip/update_overlays()
	. = ..()
	if(!beaker)
		return
	if(attached)
		. += "beakeractive"
	else
		. += "beakeridle"
	if(!beaker.reagents.total_volume)
		return
	var/mutable_appearance/filling_overlay = mutable_appearance('icons/obj/iv_drip.dmi', "reagent")
	var/percent = round((beaker.reagents.total_volume / beaker.volume) * 100)
	switch(percent)
		if(0 to 9)
			filling_overlay.icon_state = "reagent0"
		if(10 to 24)
			filling_overlay.icon_state = "reagent10"
		if(25 to 49)
			filling_overlay.icon_state = "reagent25"
		if(50 to 74)
			filling_overlay.icon_state = "reagent50"
		if(75 to 79)
			filling_overlay.icon_state = "reagent75"
		if(80 to 90)
			filling_overlay.icon_state = "reagent80"
		if(91 to INFINITY)
			filling_overlay.icon_state = "reagent100"

	filling_overlay.color = list("#0000", "#0000", "#0000", "#000f", mix_color_from_reagents(beaker.reagents.reagent_list))
	. += filling_overlay

/obj/machinery/iv_drip/MouseDrop(mob/living/target)
	. = ..()
	if( !usr.canUseTopic(src, BE_CLOSE) || !isliving(target))
		return

	if(attached)
		visible_message(span_warning("[attached] is detached from [src]."))
		attached = null
		update_appearance(UPDATE_ICON)
		return

	if(!target.has_dna())
		to_chat(usr, span_danger("The drip beeps: Warning, incompatible creature!"))
		return

	if(Adjacent(target) && usr.Adjacent(target))
		if(beaker)
			usr.visible_message(span_warning("[usr] attaches [src] to [target]."), span_notice("You attach [src] to [target]."))
			log_combat(usr, target, "attached", src, "containing: [beaker.name] - ([beaker.reagents.log_list()])")
			add_fingerprint(usr)
			attached = target
			START_PROCESSING(SSmachines, src)
			update_appearance(UPDATE_ICON)
		else
			to_chat(usr, span_warning("There's nothing attached to the IV drip!"))

/obj/machinery/iv_drip/MouseDrop_T(atom/dropping, mob/user)
	if(is_type_in_typecache(dropping, drip_containers))
		attackby(dropping, user)
	else
		..()

/obj/machinery/iv_drip/attackby(obj/item/W, mob/user, params)
	if(is_type_in_typecache(W, drip_containers))
		if(beaker)
			to_chat(user, span_warning("There is already a reagent container loaded!"))
			return
		if(!user.transferItemToLoc(W, src))
			return
		beaker = W
		to_chat(user, span_notice("You attach [W] to [src]."))
		user.log_message("attached a [W] to [src] at [AREACOORD(src)] containing ([beaker.reagents.log_list()])", LOG_ATTACK)
		add_fingerprint(user)
		update_appearance(UPDATE_ICON)
		return
	else if(istype(W,/obj/item/screwdriver))
		return
	else
		return ..()

/obj/machinery/iv_drip/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/metal(loc)
	qdel(src)

/obj/machinery/iv_drip/process(delta_time)
	if(!attached)
		return PROCESS_KILL

	if(!(get_dist(src, attached) <= 1 && isturf(attached.loc)))
		to_chat(attached, span_userdanger("The IV drip needle is ripped out of you!"))
		attached.apply_damage(3, BRUTE, pick(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM))
		attached = null
		update_appearance(UPDATE_ICON)
		return PROCESS_KILL

	if(beaker)
		// Give blood
		if(mode)
			if(beaker.reagents.total_volume)
				var/transfer_amount = 5
				if(istype(beaker, /obj/item/reagent_containers/blood))
					// speed up transfer on blood packs
					transfer_amount = 10
				var/fraction = min(transfer_amount/beaker.reagents.total_volume, 1) //the fraction that is transfered of the total volume
				beaker.reagents.reaction(attached, INJECT, fraction, FALSE) //make reagents reacts, but don't spam messages
				beaker.reagents.trans_to(attached, transfer_amount * delta_time * 0.5)
				update_appearance(UPDATE_ICON)

		// Take blood
		else
			var/amount = beaker.reagents.maximum_volume - beaker.reagents.total_volume
			amount = min(amount, 4) * delta_time * 0.5
			// If the beaker is full, ping
			if(!amount)
				if(prob(5))
					visible_message("[src] pings.")
				return

			// If the human is losing too much blood, beep.
			if(attached.blood_volume < BLOOD_VOLUME_SAFE(attached) && prob(5))
				visible_message("[src] beeps loudly.")
				playsound(loc, 'sound/machines/twobeep_high.ogg', 50, 1)
			attached.transfer_blood_to(beaker, amount)
			update_appearance(UPDATE_ICON)

/obj/machinery/iv_drip/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!ishuman(user) && !iscyborg(user))
		return
	if(attached)
		visible_message("[attached] is detached from [src].")
		attached = null
		update_appearance(UPDATE_ICON)
		return
	else if(beaker)
		eject_beaker(user)
	else
		toggle_mode()

/obj/machinery/iv_drip/attack_robot(mob/user)
	if(Adjacent(user))
		attack_hand(user)

/obj/machinery/iv_drip/verb/eject_beaker()
	set category = "Object"
	set name = "Remove IV Container"
	set src in view(1)

	if(!isliving(usr))
		to_chat(usr, span_warning("You can't do that!"))
		return

	if(usr.incapacitated() || !beaker)
		return
	beaker.forceMove(drop_location())
	beaker = null

	if(attached)
		visible_message("[attached] is detached from [src].")
		attached = null

	update_appearance(UPDATE_ICON)

/obj/machinery/iv_drip/verb/toggle_mode()
	set category = "Object"
	set name = "Toggle Mode"
	set src in view(1)

	if(!isliving(usr))
		to_chat(usr, span_warning("You can't do that!"))
		return

	if(usr.incapacitated())
		return
	mode = !mode
	to_chat(usr, "The IV drip is now [mode ? "injecting" : "taking blood"].")
	update_appearance(UPDATE_ICON)

/obj/machinery/iv_drip/examine(mob/user)
	. = ..()
	if(get_dist(user, src) > 2)
		return

	. += "[src] is [mode ? "injecting" : "taking blood"]."

	if(beaker)
		if(beaker.reagents && beaker.reagents.reagent_list.len)
			. += span_notice("Attached is \a [beaker] with [beaker.reagents.total_volume] units of liquid.")
		else
			. += span_notice("Attached is an empty [beaker.name].")
	else
		. += span_notice("No chemicals are attached.")

	. += span_notice("[attached ? attached : "No one"] is attached.")

/obj/machinery/iv_drip/attackby(obj/item/attacking_item, mob/living/user)
	if(istype(attacking_item, /obj/item/clothing/mask/breath) && can_convert)
		visible_message("<span class='warning'>[user] attempts to attach the breath mask to [src].</span>", "<span class='notice'>You attempt to attach the breath mask to [src].</span>")
		if(!do_after(user, 5 SECONDS, src, timed_action_flags = IGNORE_HELD_ITEM))
			to_chat(user, "<span class='warning'>You fail to attach the breath mask to [src]!</span>")
			return
		visible_message("<span class='warning'>[user] attaches the breath mask to [src].</span>", "<span class='notice'>You attach the breath mask to [src].</span>")
		qdel(attacking_item)
		new /obj/machinery/anesthetic_machine(loc)
		qdel(src)
		return
	return ..()

/obj/machinery/iv_drip/saline
	name = "saline drip"
	desc = "An all-you-can-drip saline canister designed to supply a hospital without running out, with a scary looking pump rigged to inject saline into containers, but filling people directly might be a bad idea."
	icon_state = "saline"
	density = TRUE
	can_convert = FALSE

/obj/machinery/iv_drip/saline/Initialize(mapload)
	AddElement(/datum/element/update_icon_blocker)
	. = ..()
	beaker = new /obj/item/reagent_containers/glass/saline(src)

/obj/machinery/iv_drip/saline/eject_beaker()
	return

/obj/machinery/iv_drip/saline/toggle_mode()
	return

#undef IV_TAKING
#undef IV_INJECTING
