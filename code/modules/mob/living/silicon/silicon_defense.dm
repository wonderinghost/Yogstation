
/mob/living/silicon/grippedby(mob/living/user, instant = FALSE)
	return //can't upgrade a simple pull into a more aggressive grab.

/mob/living/silicon/get_ear_protection()//no ears
	return 2

/mob/living/silicon/attack_alien(mob/living/carbon/alien/humanoid/M, modifiers)
	if(..()) //if harm or disarm intent
		var/damage = 20
		if (prob(90))
			log_combat(M, src, "attacked")
			playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
			visible_message(span_danger("[M] has slashed at [src]!"), \
							span_userdanger("[M] has slashed at [src]!"))
			if(prob(8))
				flash_act(affect_silicon = 1)
			log_combat(M, src, "attacked")
			adjustBruteLoss(run_armor(damage, BRUTE, MELEE))
			updatehealth()
		else
			playsound(loc, 'sound/weapons/slashmiss.ogg', 25, 1, -1)
			visible_message(span_danger("[M] took a swipe at [src]!"), \
							span_userdanger("[M] took a swipe at [src]!"))

/mob/living/silicon/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = run_armor(rand(M.melee_damage_lower, M.melee_damage_upper), M.melee_damage_type, MELEE, M.armour_penetration)
		if(prob(damage))
			for(var/mob/living/N in buckled_mobs)
				N.Paralyze(20)
				unbuckle_mob(N)
				N.visible_message(span_boldwarning("[N] is knocked off of [src] by [M]!"))
		switch(M.melee_damage_type)
			if(BRUTE)
				adjustBruteLoss(damage)
			if(BURN)
				adjustFireLoss(damage)

/mob/living/silicon/attack_paw(mob/living/user, modifiers)
	return attack_hand(user)

/mob/living/silicon/attack_larva(mob/living/carbon/alien/larva/L, modifiers)
	if(!L.combat_mode)
		visible_message("[L.name] rubs its head against [src].")

/mob/living/silicon/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.combat_mode)
		..(user, 1)
		adjustBruteLoss(run_armor(rand(10, 15), BRUTE, MELEE))
		playsound(loc, "punch", 25, 1, -1)
		visible_message(span_danger("[user] has punched [src]!"), \
				span_userdanger("[user] has punched [src]!"))
		return 1
	return 0

//ATTACK HAND IGNORING PARENT RETURN VALUE
/mob/living/silicon/attack_hand(mob/living/carbon/human/M, modifiers)
	. = FALSE
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, M, modifiers) & COMPONENT_NO_ATTACK_HAND)
		. = TRUE
	if(modifiers && modifiers[RIGHT_CLICK])
		M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
		playsound(src, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
		var/shove_dir = get_dir(M, src)
		if(!Move(get_step(src, shove_dir), shove_dir))
			log_combat(M, src, "shoved", "failing to move it")
			M.visible_message(span_danger("[M.name] shoves [src]!"),
				span_danger("You shove [src]!"), span_hear("You hear aggressive shuffling!"), COMBAT_MESSAGE_RANGE, list(src))
			to_chat(src, span_userdanger("You're shoved by [M.name]!"))
			return TRUE
		log_combat(M, src, "shoved", "pushing it")
		M.visible_message(span_danger("[M.name] shoves [src], pushing [p_them()]!"),
			span_danger("You shove [src], pushing [p_them()]!"), span_hear("You hear aggressive shuffling!"), COMBAT_MESSAGE_RANGE, list(src))
		to_chat(src, span_userdanger("You're pushed by [name]!"))
	else if(M.combat_mode)
		M.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		playsound(src.loc, 'sound/effects/bang.ogg', 10, 1)
		visible_message(span_danger("[M] punches [src], but doesn't leave a dent."), \
			span_warning("[M] punches [src], but doesn't leave a dent."), null, COMBAT_MESSAGE_RANGE)
	else
		if(buckled_mobs && length(buckled_mobs))
			for(var/mob/living/buckled_mob in buckled_mobs)
				unbuckle_mob(buckled_mob)
		else
			M.visible_message("[M] pets [src].", \
							span_notice("You pet [src]."))
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "pet_borg", /datum/mood_event/pet_borg)

/mob/living/silicon/attack_drone(mob/living/simple_animal/drone/M, modifiers)
	if(M.combat_mode)
		return
	return ..()

/mob/living/silicon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, zone = null, override = FALSE, tesla_shock = FALSE, illusion = FALSE, stun = TRUE, gib = FALSE)
	if(buckled_mobs)
		for(var/mob/living/M in buckled_mobs)
			unbuckle_mob(M)
			M.electrocute_act(shock_damage/100, source, siemens_coeff, zone, override, tesla_shock, illusion, stun, gib)	//Hard metal shell conducts!
	return 0 //So borgs they don't die trying to fix wiring

/mob/living/silicon/emp_act(severity)
	. = ..()
	to_chat(src, span_danger("Warning: Electromagnetic pulse detected."))
	if(. & EMP_PROTECT_SELF)
		return
	take_bodypart_damage(2 * severity)
	to_chat(src, span_userdanger("*BZZZT*"))
	for(var/mob/living/M in buckled_mobs)
		if(prob(5 * severity))
			unbuckle_mob(M)
			M.Paralyze(40)
			M.visible_message(span_boldwarning("[M] is thrown off of [src]!"))
	flash_act(affect_silicon = 1)

/mob/living/silicon/bullet_act(obj/projectile/Proj, def_zone)
	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, Proj, def_zone)
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		var/damage = run_armor(Proj.damage * (1 + Proj.demolition_mod)/2, Proj.damage_type, Proj.armor_flag, Proj.armour_penetration)
		adjustBruteLoss(damage)
		if(prob(damage*1.5))
			for(var/mob/living/M in buckled_mobs)
				M.visible_message(span_boldwarning("[M] is knocked off of [src]!"))
				unbuckle_mob(M)
				M.Paralyze(40)
	if(Proj.stun || Proj.knockdown || Proj.paralyze)
		for(var/mob/living/M in buckled_mobs)
			unbuckle_mob(M)
			M.visible_message(span_boldwarning("[M] is knocked off of [src] by the [Proj]!"))
	Proj.on_hit(src)
	return BULLET_ACT_HIT

/mob/living/silicon/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash/static)
	if(affect_silicon)
		return ..()

/mob/living/silicon/rust_heretic_act()
	adjustBruteLoss(run_armor(500, BRUTE, MELEE)) // Not gonna survive this, but it was worth the try.
