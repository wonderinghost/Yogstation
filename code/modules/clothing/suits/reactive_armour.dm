/obj/item/reactive_armor_shell
	name = "reactive armor shell"
	desc = "An experimental suit of armor, awaiting installation of an anomaly core."
	icon_state = "reactiveoff"
	icon = 'icons/obj/clothing/suits/suits.dmi'
	w_class = WEIGHT_CLASS_BULKY

/obj/item/reactive_armor_shell/attackby(obj/item/I, mob/user, params)
	..()
	var/static/list/anomaly_armor_types = list(
		/obj/effect/anomaly/grav	                = /obj/item/clothing/suit/armor/reactive/repulse,
		/obj/effect/anomaly/flux 	           		= /obj/item/clothing/suit/armor/reactive/tesla,
		/obj/effect/anomaly/pyro	  			    = /obj/item/clothing/suit/armor/reactive/fire,
		/obj/effect/anomaly/bluespace = /obj/item/clothing/suit/armor/reactive/teleport,
		/obj/effect/anomaly/radiation = /obj/item/clothing/suit/armor/reactive/radiation,
		/obj/effect/anomaly/hallucination = /obj/item/clothing/suit/armor/reactive/hallucinating,
		)

	if(istype(I, /obj/item/assembly/signaler/anomaly))
		var/obj/item/assembly/signaler/anomaly/A = I
		var/armor_path = anomaly_armor_types[A.anomaly_type]
		if(!armor_path)
			armor_path = /obj/item/clothing/suit/armor/reactive/stealth //Lets not cheat the player if an anomaly type doesnt have its own armor coded
		to_chat(user, "You insert [A] into the chest plate, and the armor gently hums to life.")
		new armor_path(get_turf(src))
		qdel(src)
		qdel(A)

//Reactive armor
/obj/item/clothing/suit/armor/reactive
	name = "reactive armor"
	desc = "Doesn't seem to do much for some reason."
	icon_state = "reactiveoff"
	item_state = "reactiveoff"
	blood_overlay_type = "armor"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	actions_types = list(/datum/action/item_action/toggle)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	///Whether the armor will try to react to hits (is it on)
	var/active = 0
	///This will be true for 30 seconds after an EMP, it makes the reaction effect dangerous to the user.
	var/bad_effect = FALSE
	///Message sent when the armor is emp'd. It is not the message for when the emp effect goes off.
	var/emp_message = span_warning("The reactive armor has been emp'd! Damn, now it's REALLY gonna not do much!")
	///Message sent when the armor is still on cooldown, but activates.
	var/cooldown_message = span_danger("The reactive armor fails to do much, as it is recharging! From what? Only the reactive armor knows.")
	///Duration of the cooldown specific to reactive armor for when it can activate again.
	var/reactivearmor_cooldown_duration = 5 SECONDS
	///The cooldown itself of the reactive armor for when it can activate again.
	COOLDOWN_DECLARE(reactivearmor_cooldown)

/obj/item/clothing/suit/armor/reactive/equipped(mob/user, slot)
	. = ..()
	if(slot_flags & slot)
		RegisterSignal(user, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(hit_reaction))
	else
		UnregisterSignal(user, COMSIG_HUMAN_CHECK_SHIELDS)

/obj/item/clothing/suit/armor/reactive/dropped(mob/user)
	if(user.get_item_by_slot(ITEM_SLOT_OCLOTHING) == src)
		UnregisterSignal(user, COMSIG_HUMAN_CHECK_SHIELDS)
	return ..()

/obj/item/clothing/suit/armor/reactive/attack_self(mob/user)
	active = !(active)
	if(active)
		to_chat(user, span_notice("[src] is now active."))
		icon_state = "reactive"
		item_state = "reactive"
	else
		to_chat(user, span_notice("[src] is now inactive."))
		icon_state = "reactiveoff"
		item_state = "reactiveoff"
	add_fingerprint(user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_wear_suit()
	for(var/datum/action/A in actions)
		A.build_all_button_icons()
	return

/obj/item/clothing/suit/armor/reactive/proc/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, damage, attack_text, attack_type)
	if(!active)
		return NONE
	if(reactivearmor_cooldown_duration && !COOLDOWN_FINISHED(src, reactivearmor_cooldown))
		cooldown_activation(owner)
		return NONE
	if(reactivearmor_cooldown_duration)
		COOLDOWN_START(src, reactivearmor_cooldown, reactivearmor_cooldown_duration)

	if(bad_effect)
		return emp_activation(owner, hitby, attack_text, damage, attack_type)
	else
		return reactive_activation(owner, hitby, attack_text, damage, attack_type)

/**
 * A proc for doing cooldown effects (like the sparks on the tesla armor, or the semi-stealth on stealth armor)
 * Called from the suit activating whilst on cooldown.
 * You should be calling ..()
 */
/obj/item/clothing/suit/armor/reactive/proc/cooldown_activation(mob/living/carbon/human/owner)
	owner.visible_message(cooldown_message)

/**
 * A proc for doing reactive armor effects.
 * Called from the suit activating while off cooldown, with no emp.
 * Returning TRUE will block the attack that triggered this
 */
/obj/item/clothing/suit/armor/reactive/proc/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("The reactive armor doesn't do much! No surprises here."))
	return SHIELD_BLOCK

/**
 * A proc for doing owner unfriendly reactive armor effects.
 * Called from the suit activating while off cooldown, while the armor is still suffering from the effect of an EMP.
 * Returning TRUE will block the attack that triggered this
 */
/obj/item/clothing/suit/armor/reactive/proc/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("The reactive armor doesn't do much, despite being emp'd! Besides giving off a special message, of course."))
	return SHIELD_BLOCK

/obj/item/clothing/suit/armor/reactive/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF || bad_effect || !active) //didn't get hit or already emp'd, or off
		return
	if(ismob(loc))
		to_chat(loc, emp_message)
	bad_effect = TRUE
	addtimer(VARSET_CALLBACK(src, bad_effect, FALSE), (3 SECONDS) * severity)

//When the wearer gets hit, this armor will teleport the user a short distance away (to safety or to more danger, no one knows. That's the fun of it!)
/obj/item/clothing/suit/armor/reactive/teleport
	name = "reactive teleport armor"
	desc = "Someone separated our Research Director from his own head!"
	emp_message = span_warning("The reactive armor's teleportation calculations begin spewing errors!")
	cooldown_message = span_danger("The reactive teleport system is still recharging! It fails to activate!")
	reactivearmor_cooldown_duration = 10 SECONDS
	var/tele_range = 6
	var/rad_amount= 15

/obj/item/clothing/suit/armor/reactive/teleport/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("The reactive teleport system flings [owner] clear of [attack_text], shutting itself off in the process!"))
	playsound(get_turf(owner),'sound/magic/blink.ogg', 100, 1)
	do_teleport(teleatom = owner, destination = get_turf(owner), no_effects = TRUE, precision = tele_range, channel = TELEPORT_CHANNEL_BLUESPACE)
	owner.rad_act(rad_amount)
	return SHIELD_BLOCK

/obj/item/clothing/suit/armor/reactive/teleport/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("The reactive teleport system flings itself clear of [attack_text], leaving someone behind in the process!"))
	owner.dropItemToGround(src, TRUE, TRUE)
	playsound(get_turf(owner), 'sound/machines/buzz-sigh.ogg', 50, 1)
	playsound(get_turf(owner), 'sound/magic/blink.ogg', 100, 1)
	do_teleport(teleatom = src, destination = get_turf(owner), no_effects = TRUE, precision = tele_range, channel = TELEPORT_CHANNEL_BLUESPACE)
	owner.rad_act(rad_amount)
	return NONE //you didn't actually evade the attack now did you

//Fire

/obj/item/clothing/suit/armor/reactive/fire
	name = "reactive incendiary armor"
	desc = "An experimental suit of armor with a reactive sensor array rigged to a flame emitter. For the stylish pyromaniac."
	cooldown_message = span_danger("The reactive incendiary armor activates, but fails to send out flames as it is still recharging its flame jets!")
	emp_message = span_warning("The reactive incendiary armor's targeting system begins rebooting...")

/obj/item/clothing/suit/armor/reactive/fire/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src] blocks [attack_text], sending out jets of flame!"))
	playsound(get_turf(owner),'sound/magic/fireball.ogg', 100, 1)
	for(var/mob/living/carbon/C in ohearers(6, owner))
		C.fire_stacks += 8
		C.ignite_mob()
	owner.fire_stacks = -20
	return SHIELD_REFLECT

/obj/item/clothing/suit/armor/reactive/fire/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src] just makes [attack_text] worse by spewing fire on [owner]!"))
	playsound(get_turf(owner),'sound/magic/fireball.ogg', 100, 1)
	owner.fire_stacks += 12
	owner.ignite_mob()
	return NONE

//Stealth

/obj/item/clothing/suit/armor/reactive/stealth
	name = "reactive stealth armor"
	desc = "An experimental suit of armor that renders the wearer invisible on detection of imminent harm, and creates a decoy that runs away from the owner. You can't fight what you can't see."
	cooldown_message = span_danger("The reactive stealth system activates, but is not charged enough to fully cloak!")
	emp_message = span_warning("The reactive stealth armor's threat assessment system crashes...")
	reactivearmor_cooldown_duration = 15 SECONDS
	///when triggering while on cooldown will only flicker the alpha slightly. this is how much it removes.
	var/cooldown_alpha_removal = 50
	///cooldown alpha flicker- how long it takes to return to the original alpha
	var/cooldown_animation_time = 3 SECONDS
	///how long they will be fully stealthed
	var/stealth_time = 4 SECONDS
	///how long it will animate back the alpha to the original
	var/animation_time = 2 SECONDS
	var/in_stealth = FALSE

/obj/item/clothing/suit/armor/reactive/stealth/cooldown_activation(mob/living/carbon/human/owner)
	if(in_stealth)
		return //we don't want the cooldown message either)
	owner.alpha = max(0, owner.alpha - cooldown_alpha_removal)
	animate(owner, alpha = initial(owner.alpha), time = cooldown_animation_time)
	..()

/obj/item/clothing/suit/armor/reactive/stealth/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	var/mob/living/simple_animal/hostile/illusion/escape/decoy = new(owner.loc)
	decoy.Copy_Parent(owner, 50)
	decoy.GiveTarget(owner) //so it starts running right away
	decoy.Goto(owner, decoy.move_to_delay, decoy.minimum_distance)
	in_stealth = TRUE
	owner.visible_message(span_danger("[owner] is hit by [attack_text] in the chest!")) //We pretend to be hit, since blocking it would stop the message otherwise
	owner.alpha = 0
	addtimer(CALLBACK(src, PROC_REF(end_stealth), owner), stealth_time)
	return SHIELD_BLOCK

/obj/item/clothing/suit/armor/reactive/stealth/proc/end_stealth(mob/living/carbon/human/owner)
	in_stealth = FALSE
	animate(owner, alpha = initial(owner.alpha), time = animation_time)

/obj/item/clothing/suit/armor/reactive/stealth/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if(!isliving(hitby))
		return FALSE //it just doesn't activate
	var/mob/living/attacker = hitby
	owner.visible_message(span_danger("[src] activates, cloaking the wrong person!"))
	attacker.alpha = 0
	addtimer(VARSET_CALLBACK(attacker, alpha, initial(attacker.alpha)), 4 SECONDS)
	return NONE

//Tesla

/obj/item/clothing/suit/armor/reactive/tesla
	name = "reactive tesla armor"
	desc = "An experimental suit of armor with sensitive detectors hooked up to a huge capacitor grid, with emitters strutting out of it. Zap."
	reactivearmor_cooldown_duration = 3 SECONDS
	var/tesla_power = 25000
	var/tesla_range = 20
	var/tesla_flags = TESLA_MOB_DAMAGE | TESLA_OBJ_DAMAGE
	cooldown_message = span_danger("The tesla capacitors on the reactive tesla armor are still recharging! The armor merely emits some sparks.")
	emp_message = span_warning("The tesla capacitors beep ominously for a moment.")
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100, ELECTRIC = 100)

/obj/item/clothing/suit/armor/reactive/tesla/dropped(mob/user)
	..()
	if(istype(user))
		user.flags_1 &= ~TESLA_IGNORE_1
		UnregisterSignal(user, COMSIG_LIVING_ELECTROCUTE_ACT)

/obj/item/clothing/suit/armor/reactive/tesla/equipped(mob/user, slot)
	..()
	if(slot_flags & slot) //Was equipped to a valid slot for this item?
		user.flags_1 |= TESLA_IGNORE_1
		RegisterSignal(user, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(handle_shock))

/obj/item/clothing/suit/armor/reactive/tesla/proc/handle_shock(mob/living/victim, shock_damage, obj/source, siemens_coeff = 1, zone = null, tesla_shock = 0, illusion = 0)
	if(tesla_shock)
		return COMPONENT_NO_ELECTROCUTE_ACT

/obj/item/clothing/suit/armor/reactive/tesla/cooldown_activation(mob/living/carbon/human/owner)
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(1, 1, src)
	sparks.start()
	..()

/obj/item/clothing/suit/armor/reactive/tesla/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src] blocks [attack_text], sending out arcs of lightning!"))
	tesla_zap(owner, tesla_range, tesla_power, tesla_flags)
	return SHIELD_BLOCK

/obj/item/clothing/suit/armor/reactive/tesla/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src] blocks [attack_text], but pulls a massive charge of energy into [owner] from the surrounding environment!"))
	if(istype(owner))
		owner.flags_1 &= ~TESLA_IGNORE_1
	electrocute_mob(owner, get_area(src), src, 1)
	owner.flags_1 |= TESLA_IGNORE_1
	return NONE

//Repulse

/obj/item/clothing/suit/armor/reactive/repulse
	name = "reactive repulse armor"
	desc = "An experimental suit of armor that violently throws back attackers."
	reactivearmor_cooldown_duration = 5 SECONDS
	var/repulse_force = MOVE_FORCE_EXTREMELY_STRONG
	cooldown_message = span_danger("The repulse generator is still recharging! It fails to generate a strong enough wave!")
	emp_message = span_warning("The repulse generator is reset to default settings...")

/obj/item/clothing/suit/armor/reactive/repulse/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	playsound(get_turf(owner),'sound/magic/repulse.ogg', 100, 1)
	owner.visible_message(span_danger("[src] blocks [attack_text], converting the attack into a wave of force!"))
	var/turf/T = get_turf(owner)
	var/list/thrown_items = list()
	for(var/atom/movable/A in orange(7, T))
		if(A.anchored || thrown_items[A])
			continue
		var/throwtarget = get_edge_target_turf(T, get_dir(T, get_step_away(A, T)))
		A.safe_throw_at(throwtarget, 10, 1, force = repulse_force)
		thrown_items[A] = A

	return SHIELD_REFLECT

/obj/item/clothing/suit/armor/reactive/repulse/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	playsound(get_turf(owner),'sound/magic/repulse.ogg', 100, 1)
	owner.visible_message(span_danger("[src] does not block [attack_text], and instead generates an attracting force!"))
	var/turf/T = get_turf(owner)
	var/list/thrown_items = list()
	for(var/atom/movable/A as mob|obj in orange(7, T))
		if(A.anchored || thrown_items[A])
			continue
		A.safe_throw_at(owner, 10, 1, force = repulse_force)
		thrown_items[A] = A

	return NONE

//Table

/obj/item/clothing/suit/armor/reactive/table
	name = "reactive table armor"
	desc = "If you can't beat the memes, embrace them."
	var/tele_range = 10
	cooldown_message = span_danger("The reactive table armor's fabricators are still on cooldown!")
	emp_message = span_danger("The reactive table armor's fabricators click and whirr ominously for a moment...")

/obj/item/clothing/suit/armor/reactive/table/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("The reactive teleport system flings [owner] clear of [attack_text] and slams [owner.p_them()] into a fabricated table!"))
	owner.visible_message("<font color='red' size='3'>[owner] GOES ON THE TABLE!!!</font>")
	owner.Paralyze(40)
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "table", /datum/mood_event/table)
	do_teleport(teleatom = owner, destination = get_turf(owner), no_effects = TRUE, precision = tele_range, channel = TELEPORT_CHANNEL_BLUESPACE)
	new /obj/structure/table(get_turf(owner))
	return SHIELD_BLOCK

/obj/item/clothing/suit/armor/reactive/table/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("The reactive teleport system flings [owner] clear of [attack_text] and slams [owner.p_them()] into a fabricated glass table!"))
	owner.visible_message("<font color='red' size='3'>[owner] GOES ON THE TABLE!!!</font>")
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "table", /datum/mood_event/table)
	do_teleport(teleatom = owner, destination = get_turf(owner), no_effects = TRUE, precision = tele_range, channel = TELEPORT_CHANNEL_BLUESPACE)
	var/obj/structure/table/glass/table = new(get_turf(owner))
	table.table_shatter(owner)
	return SHIELD_BLOCK

//Hallucinating

/obj/item/clothing/suit/armor/reactive/hallucinating
	name = "reactive hallucination armor"
	desc = "An experimental suit of armor which produces an illusory defender upon registering an attack."
	cooldown_message = span_warning("The reactive hallucination armor's memetic array is currently recalibrating!")
	emp_message = span_warning("The reactive hallucination armor's array of lights and mirrors turns on you...")
	clothing_traits = list(TRAIT_MESONS)

/obj/item/clothing/suit/armor/reactive/hallucinating/cooldown_activation(mob/living/carbon/human/owner)
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(1, 1, src)
	sparks.start()
	..()

/obj/item/clothing/suit/armor/reactive/hallucinating/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src] blocks [attack_text], the body of an assistant forming to absorb it!")) //get down mr president
	var/mob/living/simple_animal/hostile/shadowclone = new /mob/living/simple_animal/hostile/hallucination(get_turf(src))
	shadowclone.friends += owner
	return SHIELD_BLOCK

/obj/item/clothing/suit/armor/reactive/hallucinating/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src] blocks [attack_text], the body of an assistant forming to absorb it, before turning on [owner]!"))
	var/mob/living/simple_animal/hostile/shadowclone = new /mob/living/simple_animal/hostile/hallucination(get_turf(src))
	shadowclone.GiveTarget(owner)
	owner.adjust_hallucinations(150)
	return SHIELD_BLOCK

//Radiation

/obj/item/clothing/suit/armor/reactive/radiation
	name = "reactive radiation armor"
	desc = "An experimental suit of armor thats give the owner radiation proof and on activation releases a wave of radiation around the owner."
	cooldown_message = span_warning("The connection is currently out of sync... Recalibrating.")
	emp_message = span_warning("You feel the radiation wave within you.")
	var/effect_range = 3
	clothing_traits = list(TRAIT_RADIMMUNE)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 100, FIRE = 100, ACID = 100)
	flags_1 = RAD_PROTECT_CONTENTS_1

/obj/item/clothing/suit/armor/reactive/radiation/cooldown_activation(mob/living/carbon/human/owner)
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(1, 1, src)
	sparks.start()
	..()

/obj/item/clothing/suit/armor/reactive/radiation/reactive_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src] blocks [attack_text], sending out radiation pulses and nuclear particles!"))
	radiation_pulse(src, 500, effect_range)
	for(var/i = 1 to 5)
		fire_nuclear_particle()
	return SHIELD_BLOCK

/obj/item/clothing/suit/armor/reactive/radiation/emp_activation(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	owner.visible_message(span_danger("[src] blocks [attack_text], but pulls a massive charge of radiation wave into [owner] from the surrounding environment!"))
	owner.adjustToxLoss(10)
	return SHIELD_BLOCK
