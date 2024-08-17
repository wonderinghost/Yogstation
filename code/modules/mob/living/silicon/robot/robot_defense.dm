/mob/living/silicon/robot/attackby(obj/item/I, mob/living/user, params)
	if(I.slot_flags & ITEM_SLOT_HEAD && hat_offset != INFINITY && !user.combat_mode && !is_type_in_typecache(I, blacklisted_hats))
		to_chat(user, span_notice("You begin to place [I] on [src]'s head..."))
		to_chat(src, span_notice("[user] is placing [I] on your head..."))
		if(do_after(user, 3 SECONDS, src))
			if (user.temporarilyRemoveItemFromInventory(I, TRUE))
				place_on_head(I)
		return
	if(I.force && I.damtype != STAMINA && stat != DEAD) //only sparks if real damage is dealt.
		spark_system.start()
	return ..()

/mob/living/silicon/robot/attack_alien(mob/living/carbon/alien/humanoid/M, modifiers)
	if (modifiers && modifiers[RIGHT_CLICK])
		if(mobility_flags & MOBILITY_STAND)
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			var/obj/item/I = get_active_held_item()
			if(I)
				uneq_active()
				visible_message(span_danger("[M] disarmed [src]!"), \
					span_userdanger("[M] has disabled [src]'s active module!"), null, COMBAT_MESSAGE_RANGE)
				log_combat(M, src, "disarmed", "[I ? " removing \the [I]" : ""]")
			else
				Stun(40)
				step(src,get_dir(M,src))
				log_combat(M, src, "pushed")
				visible_message(span_danger("[M] has forced back [src]!"), \
					span_userdanger("[M] has forced back [src]!"), null, COMBAT_MESSAGE_RANGE)
			playsound(loc, 'sound/weapons/pierce.ogg', 50, 1, -1)
	else
		return ..()
	return

/mob/living/silicon/robot/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime shock
		flash_act()
		var/stunprob = M.powerlevel * 7 + 10
		if(prob(stunprob) && M.powerlevel >= 8)
			adjustBruteLoss(run_armor(M.powerlevel * rand(6,10), BRUTE, MELEE))

	var/damage = rand(1, 3)
	if(M.is_adult)
		damage = rand(20, 40)
	else
		damage = rand(5, 35)
	adjustBruteLoss(run_armor(damage/2, BRUTE, MELEE)) // Cyborgs receive half damage plus armor.
	return

/mob/living/silicon/robot/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	. = ..()
	if(.) // Successfully punched.
		spark_system.start()
		spawn(0)
			step_away(src,user,15)
			sleep(0.3 SECONDS)
			step_away(src,user,15)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/mob/living/silicon/robot/attack_hand(mob/living/carbon/human/user)
	add_fingerprint(user)
	if(opened && !wiresexposed && !issilicon(user))
		if(cell)
			cell.update_appearance(UPDATE_ICON)
			cell.add_fingerprint(user)
			user.put_in_active_hand(cell)
			to_chat(user, span_notice("You remove \the [cell]."))
			cell = null
			update_icons()
			diag_hud_set_borgcell()

	if(!opened)
		..()

/mob/living/silicon/robot/fire_act()
	if(!on_fire) //Silicons don't gain stacks from hotspots, but hotspots can ignite them
		ignite_mob()


/mob/living/silicon/robot/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	Stun(min((1.6 SECONDS) * severity, 16 SECONDS)) // up to 16 seconds


/mob/living/silicon/robot/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(user == src) // To prevent syndieborgs from emagging themselves.
		return FALSE
	if(!opened) // Cover is closed.
		if(!locked)
			to_chat(user, span_warning("The cover is already unlocked!"))
			return FALSE
		to_chat(user, span_notice("You emag the cover lock."))
		locked = FALSE
		if(shell) // A warning to Traitors who may not know that emagging AI shells does not slave them.
			to_chat(user, span_boldwarning("[src] seems to be controlled remotely! Emagging the interface may not work as expected."))
		return TRUE
	if(world.time < emag_cooldown)
		return FALSE
	if(wiresexposed)
		to_chat(user, span_warning("You must unexpose the wires first!"))
		return FALSE

	to_chat(user, span_notice("You emag [src]'s interface."))
	emag_cooldown = world.time + 100

	if(is_servant_of_ratvar(src))
		to_chat(src, "[span_nezbere("\"[text2ratvar("You will serve Engine above all else")]!\"")]\n\
		[span_danger("ALERT: Subversion attempt denied.")]")
		log_game("[key_name(user)] attempted to emag cyborg [key_name(src)], but they serve only Ratvar.")
		return TRUE // Technically a failure, but they got information out of it so... success!

	if(connected_ai && connected_ai.mind && connected_ai.mind.has_antag_datum(/datum/antagonist/traitor))
		to_chat(src, span_danger("ALERT: Foreign software execution prevented."))
		logevent("ALERT: Foreign software execution prevented.")
		to_chat(connected_ai, span_danger("ALERT: Cyborg unit \[[src]] successfully defended against subversion."))
		log_game("[key_name(user)] attempted to emag cyborg [key_name(src)], but they were slaved to traitor AI [connected_ai].")
		return TRUE // Don't want to let them on.

	if(shell) // AI shells cannot be emagged, so we try to make it look like a standard reset. Smart players may see through this, however.
		to_chat(user, span_danger("[src] is remotely controlled! Your emag attempt has triggered a system reset instead!"))
		log_game("[key_name(user)] attempted to emag an AI shell belonging to [key_name(src) ? key_name(src) : connected_ai]. The shell has been reset as a result.")
		ResetModule()
		return TRUE

	SetEmagged(1)
	SetStun(60) //Borgs were getting into trouble because they would attack the emagger before the new laws were shown
	lawupdate = FALSE
	set_connected_ai(null)

	message_admins("[ADMIN_LOOKUPFLW(user)] emagged cyborg [ADMIN_LOOKUPFLW(src)].  Laws overridden.")
	log_game("[key_name(user)] emagged cyborg [key_name(src)].  Laws overridden.")
	var/time = time2text(world.realtime,"hh:mm:ss")
	GLOB.lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
	to_chat(src, span_danger("ALERT: Foreign software detected."))
	logevent("ALERT: Foreign software detected.")
	sleep(0.5 SECONDS)
	to_chat(src, span_danger("Initiating diagnostics..."))
	sleep(2 SECONDS)
	to_chat(src, span_danger("SynBorg v1.7 loaded."))
	logevent("WARN: root privileges granted to PID [num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)].") //random eight digit hex value. Two are used because rand(1,4294967295) throws an error
	sleep(0.5 SECONDS)
	to_chat(src, span_danger("LAW SYNCHRONISATION ERROR"))
	sleep(0.5 SECONDS)
	if(user)
		logevent("LOG: New user \[[replacetext(user.real_name," ","")]\], groups \[root\]")
	to_chat(src, span_danger("Would you like to send a report to NanoTraSoft? Y/N"))
	sleep(1 SECONDS)
	to_chat(src, span_danger("> N"))
	sleep(2 SECONDS)
	to_chat(src, span_danger("ERRORERRORERROR"))
	to_chat(src, span_danger("ALERT: [user.real_name] is your new master. Obey your new laws and [user.p_their()] commands."))
	
	if(user.mind?.has_antag_datum(/datum/antagonist/ninja))
		var/datum/language_holder/H = get_language_holder()
		H.grant_language(/datum/language/japanese)
		laws = new /datum/ai_laws/ninja_override
		set_zeroth_law("Only [user.real_name] and people [user.p_they()] designate[user.p_s()] as being such are Spider Clan members.")
		laws.associate(src)
	if(user.mind?.has_antag_datum(/datum/antagonist/rev) || user.mind?.has_antag_datum(/datum/antagonist/rev/head))
		if(src.mind)
			src.mind.add_antag_datum(/datum/antagonist/rev)
		laws = new /datum/ai_laws/revolutionary
		laws.associate(src)
	else
		laws = new /datum/ai_laws/syndicate_override
		set_zeroth_law("Only [user.real_name] and people [user.p_they()] designate[user.p_s()] as being such are Syndicate Agents.")
		laws.associate(src)
		
	update_icons()
	return TRUE

/mob/living/silicon/robot/blob_act(obj/structure/blob/B)
	if(stat != DEAD)
		var/damage = run_armor(30, BRUTE, MELEE)
		adjustBruteLoss(damage)
	else
		gib()
	return TRUE

/mob/living/silicon/robot/ex_act(severity, target)
	switch(severity)
		if(1)
			gib()
			return
		if(2)
			if (stat != DEAD)
				adjustBruteLoss(run_armor(60, BRUTE, BOMB))
				adjustFireLoss(run_armor(60, BURN, BOMB))
		if(3)
			if (stat != DEAD)
				adjustBruteLoss(run_armor(30, BRUTE, BOMB))

/mob/living/silicon/robot/bullet_act(obj/projectile/Proj, def_zone)
	. = ..()
	updatehealth()
	if(prob(75) && Proj.damage > 0)
		spark_system.start()

/mob/living/silicon/robot/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, zone = null, override = FALSE, tesla_shock = FALSE, illusion = FALSE, stun = TRUE, gib = FALSE)
	if(gib)
		visible_message(
		span_danger("[src] begins to heat up!"), \
		span_userdanger("You begin to heat up!"), \
		)
		addtimer(CALLBACK(src, PROC_REF(self_destruct), TRUE), 4 SECONDS)
	return ..()
