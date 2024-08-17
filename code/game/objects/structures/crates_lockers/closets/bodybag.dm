
/obj/structure/closet/body_bag
	name = "body bag"
	desc = "A plastic bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bodybag"
	density = FALSE
	mob_storage_capacity = 2
	open_sound = 'sound/items/zip.ogg'
	close_sound = 'sound/items/zip.ogg'
	integrity_failure = 0
	material_drop = /obj/item/stack/sheet/cloth
	delivery_icon = null //unwrappable
	anchorable = FALSE
	open_flags = HORIZONTAL_HOLD //intended for bodies, so people lying down
	notreallyacloset = TRUE
	door_anim_time = 0 // no animation

	var/foldedbag_path = /obj/item/bodybag
	var/obj/item/bodybag/foldedbag_instance = null

	///The tagged name of the bodybag, also used to check if the bodybag IS tagged.
	var/tag_name

/obj/structure/closet/body_bag/Destroy()
	// If we have a stored bag, and it's in nullspace (not in someone's hand), delete it.
	if (foldedbag_instance && !foldedbag_instance.loc)
		QDEL_NULL(foldedbag_instance)
	return ..()

/obj/structure/closet/body_bag/attackby(obj/item/interact_tool, mob/user, params)
	if (istype(interact_tool, /obj/item/pen) || istype(interact_tool, /obj/item/toy/crayon))
		if(!user.is_literate(interact_tool))
			to_chat(user, span_notice("You scribble illegibly on [src]!"))
			return
		var/t = tgui_input_text(user, "What would you like the label to be?", name, max_length = 53)
		if(user.get_active_held_item() != interact_tool)
			return
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		handle_tag("[t ? t : initial(name)]")
		return
	if(!tag_name)
		return
	if(interact_tool.tool_behaviour == TOOL_WIRECUTTER || interact_tool.get_sharpness())
		to_chat(user, span_notice("You cut the tag off [src]."))
		handle_tag()

///Handles renaming of the bodybag's examine tag.
/obj/structure/closet/body_bag/proc/handle_tag(new_name)
	tag_name = new_name
	name = tag_name ? "[initial(name)] - [tag_name]" : initial(name)
	update_appearance()

/obj/structure/closet/body_bag/update_overlays()
	. = ..()
	if (tag_name)
		. += "bodybag_label"

/obj/structure/closet/body_bag/close()
	if(..())
		density = FALSE
		return 1
	return 0

/obj/structure/closet/body_bag/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr) && (in_range(src, usr) || usr.contents.Find(src)))
		if(!attempt_fold(usr))
			return FALSE
		perform_fold(usr)
		qdel(src)

		/**
		  * Checks to see if we can fold. Return TRUE to actually perform the fold and delete.
			*
		  * Arguments:
		  * * the_folder - over_object of MouseDrop aka usr
		  */
/obj/structure/closet/body_bag/proc/attempt_fold(mob/living/carbon/human/the_folder)
	. = FALSE
	if(!istype(the_folder))
		return
	if(opened)
		to_chat(the_folder, span_warning("You wrestle with [src], but it won't fold while unzipped."))
		return
	if(contents.len)
		to_chat(the_folder, span_warning("There are too many things inside of [src] to fold it up!"))
		return
	// toto we made it!
	return TRUE

	/**
		* Performs the actual folding. Deleting is automatic, please do not include.
		*
		* Arguments:
		* * the_folder - over_object of MouseDrop aka usr
		*/
/obj/structure/closet/body_bag/proc/perform_fold(mob/living/carbon/human/the_folder)
	visible_message(span_notice("[usr] folds up [src]."))
	var/obj/item/bodybag/B = foldedbag_instance || new foldedbag_path
	the_folder.put_in_hands(B)


/obj/structure/closet/body_bag/bluespace
	name = "bluespace body bag"
	desc = "A bluespace body bag designed for the storage and transportation of cadavers."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "bluebodybag"
	foldedbag_path = /obj/item/bodybag/bluespace
	mob_storage_capacity = 15
	max_mob_size = MOB_SIZE_LARGE

/obj/structure/closet/body_bag/bluespace/attempt_fold(mob/living/carbon/human/the_folder)
	. = FALSE
	//copypaste zone, we do not want the content check so we don't want inheritance
	if(!istype(the_folder))
		return
	if(opened)
		to_chat(the_folder, span_warning("You wrestle with [src], but it won't fold while unzipped.</span>"))
		return
	//end copypaste zone
	if(contents.len >= mob_storage_capacity / 2)
		to_chat(usr, span_warning("There are too many things inside of [src] to fold it up!"))
		return
	for(var/obj/item/bodybag/bluespace/B in src)
		to_chat(usr, span_warning("You can't recursively fold bluespace body bags!"))
		return
	if(the_folder in src)
		to_chat(usr, span_warning("You can't fold a bluespace body bag from the inside!"))
		return
	return TRUE

/obj/structure/closet/body_bag/bluespace/perform_fold(mob/living/carbon/human/the_folder)
	visible_message("<span class='notice'>[usr] folds up [src].</span>")
	var/obj/item/bodybag/B = foldedbag_instance || new foldedbag_path
	var/max_weight_of_contents = initial(B.w_class)
	usr.put_in_hands(B)
	for(var/am in contents)
		var/atom/movable/content = am
		content.forceMove(B)
		if(isliving(content))
			to_chat(content, span_userdanger("You're suddenly forced into a tiny, compressed space!"))
		if(!isitem(content))
			max_weight_of_contents = max(WEIGHT_CLASS_BULKY, max_weight_of_contents)
			continue
		var/obj/item/A_is_item = content
		if(A_is_item.w_class < max_weight_of_contents)
			continue
		max_weight_of_contents = A_is_item.w_class
	B.w_class = max_weight_of_contents

/// Environmental bags

/obj/structure/closet/body_bag/environmental
	name = "environmental protection bag"
	desc = "An insulated, reinforced bag designed to protect against exoplanetary storms and other environmental factors."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "envirobag"
	mob_storage_capacity = 1
	contents_pressure_protection = 0.8
	contents_thermal_insulation = 0.5
	foldedbag_path = /obj/item/bodybag/environmental
	weather_protection = WEATHER_STORM

/obj/structure/closet/body_bag/environmental/nanotrasen
	name = "elite environmental protection bag"
	desc = "A heavily reinforced and insulated bag, capable of fully isolating its contents from external factors."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "ntenvirobag"
	contents_pressure_protection = 1
	contents_thermal_insulation = 1
	foldedbag_path = /obj/item/bodybag/environmental/nanotrasen/
	weather_protection = WEATHER_STORM

/// Securable enviro. bags

/obj/structure/closet/body_bag/environmental/prisoner
	name = "prisoner transport bag"
	desc = "Intended for transport of prisoners through hazardous environments, this environmental protection bag comes with straps to keep an occupant secure."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "prisonerenvirobag"
	foldedbag_path = /obj/item/bodybag/environmental/prisoner/
	breakout_time = 4 MINUTES // because it's probably about as hard to get out of this as it is to get out of a straightjacket.
	/// How long it takes to sinch the bag.
	var/sinch_time = 10 SECONDS
	/// Whether or not the bag is sinched. Starts unsinched.
	var/sinched = FALSE
	/// The sound that plays when the bag is done sinching.
	var/sinch_sound = 'sound/items/handling/toolbelt_equip.ogg'

/obj/structure/closet/body_bag/environmental/prisoner/attempt_fold(mob/living/carbon/human/the_folder)
	if(sinched)
		to_chat(the_folder, span_warning("You wrestle with [src], but it won't fold while its straps are fastened."))
	return ..()

/obj/structure/closet/body_bag/environmental/prisoner/update_icon_state()
	. = ..()
	if(sinched)
		icon_state = initial(icon_state) + "_sinched"
	else
		icon_state = initial(icon_state)

/obj/structure/closet/body_bag/environmental/prisoner/can_open(mob/living/user, force = FALSE)
	if(force)
		return TRUE
	if(sinched)
		to_chat(user, span_danger("The buckles on [src] are sinched down, preventing it from opening."))
		return FALSE
	. = ..()

/obj/structure/closet/body_bag/environmental/prisoner/open(mob/living/user, force = FALSE)
	if(!can_open(user, force))
		return
	if(opened)
		return
	sinched = FALSE
	playsound(loc, open_sound, 15, TRUE, -3)
	opened = TRUE
	if(!dense_when_open)
		density = FALSE
	dump_contents()
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/structure/closet/body_bag/environmental/prisoner/container_resist(mob/living/user)
	/// copy-pasted with changes because flavor text as well as some other misc stuff
	if(opened)
		return
	if(ismovable(loc))
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		return
	if(!sinched)
		open()
		return

	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(span_warning("Someone in [src] begins to wriggle!"), \
		span_notice("You start wriggling, attempting to loosen [src]'s buckles... (this will take about [DisplayTimeText(breakout_time)].)"), \
		span_hear("You hear straining cloth from [src]."))
	if(do_after(user,(breakout_time), src))
		if(!user || user.stat != CONSCIOUS || user.loc != src || opened || !sinched )
			return
		//we check after a while whether there is a point of resisting anymore and whether the user is capable of resisting
		user.visible_message(span_danger("[user] successfully broke out of [src]!"),
							span_notice("You successfully break out of [src]!"))
		bust_open()
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, span_warning("You fail to break out of [src]!"))

/obj/structure/closet/body_bag/environmental/prisoner/bust_open()
	sinched = FALSE
	// We don't break the bag, because the buckles were backed out as opposed to fully broken.
	open()

/obj/structure/closet/body_bag/environmental/prisoner/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE) || !isturf(loc))
		return
	if(!opened)
		togglelock(user)
	return TRUE

/obj/structure/closet/body_bag/environmental/prisoner/togglelock(mob/living/user, silent)
	if(user in contents)
		to_chat(user, span_warning("You can't reach the buckles from here!"))
		return
	if(iscarbon(user))
		add_fingerprint(user)
	if(!sinched)
		for(var/mob/living/target in contents)
			to_chat(target, span_userdanger("You feel the lining of [src] tighten around you! Soon, you won't be able to escape!"))
		user.visible_message(span_notice("You begin cinching down the buckles on [src]."))
		if(!(do_after(user, (sinch_time), src)))
			return
	sinched = !sinched
	if(sinched)
		playsound(loc, sinch_sound, 15, TRUE, -2)
	user.visible_message(span_notice("[user] [sinched ? null : "un"]sinches [src]."),
							span_notice("You [sinched ? null : "un"]sinch [src]."),
							span_hear("You hear stretching followed by metal clicking from [src]."))
	log_game("[key_name(user)] [sinched ? "sinched":"unsinched"] secure environmental bag [src] at [AREACOORD(src)]")
	update_appearance(UPDATE_ICON)

/obj/structure/closet/body_bag/environmental/prisoner/syndicate
	name = "syndicate prisoner transport bag"
	desc = "An alteration of Nanotrasen's environmental protection bag which has been used in several high-profile kidnappings. Designed to keep a victim unconscious, alive, and secured during transport."
	icon = 'icons/obj/bodybag.dmi'
	icon_state = "syndieenvirobag"
	contents_pressure_protection = 1
	contents_thermal_insulation = 1
	foldedbag_path = /obj/item/bodybag/environmental/prisoner/syndicate
	weather_protection = WEATHER_STORM
	breakout_time = 8 MINUTES
	sinch_time = 4 SECONDS

/obj/structure/closet/body_bag/environmental/prisoner/syndicate/update_overlays()
	. = ..()
	var/obj/item/bodybag/environmental/prisoner/syndicate/inner_bag = foldedbag_instance
	if(sinched && inner_bag && inner_bag.killing)
		. += "kill_flash"

/obj/structure/closet/body_bag/environmental/prisoner/syndicate/Initialize(mapload)
	. = ..()
	update_airtightness()
	START_PROCESSING(SSobj, src)

/obj/structure/closet/body_bag/environmental/prisoner/syndicate/togglelock(mob/living/user, silent)
	var/obj/item/bodybag/environmental/prisoner/syndicate/inner_bag = foldedbag_instance
	if(sinched && inner_bag && inner_bag.killing) // let him cook
		user.visible_message(span_notice("You begin prying back the buckles on [src]."))
		if(!(do_after(user, (sinch_time), src)))
			return
	. = ..()

/obj/structure/closet/body_bag/environmental/prisoner/syndicate/process(delta_time)
	var/obj/item/bodybag/environmental/prisoner/syndicate/inner_bag = foldedbag_instance
	if(!inner_bag || !inner_bag.killing || !sinched)
		return
	for(var/mob/living/target in contents)
		if(!target.reagents)
			continue
		if(target.stat == DEAD)
			target.adjustFireLoss(10 * delta_time) // Husks after a few seconds
			continue
		target.reagents.add_reagent(/datum/reagent/clf3, 3 * delta_time)
		target.reagents.add_reagent(/datum/reagent/phlogiston, 3 * delta_time)
		target.reagents.add_reagent(/datum/reagent/teslium, 3 * delta_time)
		target.reagents.add_reagent(/datum/reagent/toxin/acid/fluacid, 3 * delta_time)

/obj/structure/closet/body_bag/environmental/prisoner/syndicate/update_airtightness()
	if(sinched)
		refresh_air()
	else if(!sinched && air_contents)
		air_contents = null

/obj/structure/closet/body_bag/environmental/prisoner/syndicate/proc/refresh_air()
	air_contents = null
	air_contents = new(50) // liters
	air_contents.set_temperature(T20C)
	air_contents.set_moles(GAS_O2, (ONE_ATMOSPHERE*50)/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD)
	air_contents.set_moles(GAS_NITROUS, (ONE_ATMOSPHERE*50)/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD)

/obj/structure/closet/body_bag/environmental/prisoner/syndicate/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(air_contents)
		QDEL_NULL(air_contents)
	return ..()

/obj/structure/closet/body_bag/environmental/prisoner/syndicate/return_air()
	if(sinched)
		update_airtightness()
		return air_contents
	return ..()

/obj/structure/closet/body_bag/environmental/prisoner/syndicate/remove_air(amount)
	if(sinched)
		update_airtightness()
		return air_contents // The internals for this bag are bottomless. Syndicate bluespace trickery.
	return ..(amount)

/obj/structure/closet/body_bag/environmental/prisoner/syndicate/return_analyzable_air()
	update_airtightness()
	return air_contents

/obj/structure/closet/body_bag/environmental/prisoner/syndicate/togglelock(mob/living/user, silent)
	. = ..()
	if(sinched)
		for(var/mob/living/target in contents)
			to_chat(target, span_warning("You hear a faint hiss, and a white mist fills your vision..."))
