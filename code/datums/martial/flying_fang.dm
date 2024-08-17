#define CHOMP_COMBO "GH"
#define TAIL_COMBO_START "DD"
#define TAIL_COMBO "TD"


/datum/martial_art/flyingfang
	name = "Flying Fang"
	id = MARTIALART_FLYINGFANG
	no_guns = TRUE
	help_verb = /mob/living/carbon/human/proc/flyingfang_help
	martial_traits = list(TRAIT_NOSOFTCRIT, TRAIT_REDUCED_DAMAGE_SLOWDOWN, TRAIT_NO_STUN_WEAPONS)
	///used to keep track of the pounce ability
	var/leaping = FALSE
	COOLDOWN_DECLARE(next_leap)

/datum/martial_art/flyingfang/can_use(mob/living/carbon/human/H)
	return islizard(H)

/datum/martial_art/flyingfang/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(findtext(streak,TAIL_COMBO_START))
		streak = "T"
		Slam(A,D)
		return TRUE
	if(findtext(streak, TAIL_COMBO))
		streak = ""
		Slap(A,D)
		return TRUE
	if(findtext(streak, CHOMP_COMBO))
		streak = ""
		Chomp(A,D)
		return TRUE

///second attack of the tail slap combo, deals high stamina damage, low brute damage, and causes a short slowdown
/datum/martial_art/flyingfang/proc/Slam(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	var/selected_zone = A.zone_selected
	var/obj/item/bodypart/affecting = D.get_bodypart(check_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, MELEE, armour_penetration = 50)
	var/slam_staminadamage = A.get_punchdamagehigh() * 1.5 + 10	//25 damage
	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
	playsound(D, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
	D.apply_damage(slam_staminadamage, STAMINA, selected_zone, armor_block)
	D.apply_damage(A.get_punchdamagehigh() + 5, A.dna.species.attack_type, selected_zone, armor_block)	//15 damage
	D.visible_message(span_danger("[A] slams into [D], knocking them off balance!"), \
					  span_userdanger("[A] slams into you, knocking you off balance!"))
	D.add_movespeed_modifier("tail slap", update=TRUE, priority=101, multiplicative_slowdown=0.9)
	addtimer(CALLBACK(D, TYPE_PROC_REF(/mob, remove_movespeed_modifier), "tail slap"), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
	log_combat(A, D, "slammed (Flying Fang)")

///last hit of the tail slap combo, causes a short stun or throws whatever blocks the attack
/datum/martial_art/flyingfang/proc/Slap(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	A.emote("spin")
	if(A.wear_suit?.flags_inv & HIDEJUMPSUIT)
		to_chat(A, span_warning("Your tail is covered by your [A.wear_suit]!"))
		return
	var/obj/item/organ/tail = A.getorganslot(ORGAN_SLOT_TAIL)
	if(!istype(tail, /obj/item/organ/tail/lizard))
		A.visible_message(span_danger("[A] spins around."), \
						  span_userdanger("You spin around like a doofus."))
		return
	playsound(get_turf(A), 'sound/weapons/slap.ogg', 50, TRUE, -1)
	for(var/obj/item/I in D.held_items)
		if(I.GetComponent(/datum/component/blocking))
			D.visible_message(span_danger("[A] tail slaps [I] out of [D]'s hands!"), \
							 span_userdanger("[A] tail slaps your [I] out of your hands!"))
			D.dropItemToGround(I)
			var/atom/throw_target = get_edge_target_turf(D, get_dir(A, get_step_away(D, A)))
			I.safe_throw_at(throw_target, 5, 2)
			return
	var/selected_zone = A.zone_selected
	var/obj/item/bodypart/affecting = D.get_bodypart(check_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, MELEE, armour_penetration = 50)
	var/slap_staminadamage = A.get_punchdamagehigh() * 1.5 + 10	//25 damage
	A.do_attack_animation(D, ATTACK_EFFECT_SMASH)
	D.apply_damage(slap_staminadamage, STAMINA, selected_zone, armor_block)
	D.apply_damage(A.get_punchdamagehigh(), A.dna.species.attack_type, selected_zone, armor_block)	//10 damage
	D.Knockdown(5 SECONDS)
	D.Paralyze(2 SECONDS)
	D.visible_message(span_danger("[A] tail slaps [D]!"), \
					  span_userdanger("[A] tail slaps you!"))
	log_combat(A, D, "tail slapped (Flying Fang)")

/datum/martial_art/flyingfang/proc/remove_bonk(mob/living/carbon/human/D)
	D.dna.species.aiminginaccuracy -= 25

/datum/martial_art/flyingfang/proc/Chomp(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return
	if(A.is_mouth_covered())
		to_chat(A, span_warning("Your mouth is obstructed!"))
		return
	if((D.mobility_flags & MOBILITY_STAND))
		return harm_act(A,D)
	var/obj/item/bodypart/affecting = D.get_bodypart(check_zone(BODY_ZONE_HEAD))
	var/armor_block = D.run_armor_check(affecting, MELEE, armour_penetration = 30)
	var/chomp_damage = A.get_punchdamagehigh() * 2 + 10	//30 damage
	A.do_attack_animation(D, ATTACK_EFFECT_BITE)
	playsound(D, 'sound/weapons/bite.ogg', 50, TRUE, -1)
	D.apply_damage(chomp_damage, A.dna.species.attack_type, BODY_ZONE_HEAD, armor_block, sharpness = SHARP_EDGED)
	// D.bleed_rate += 10
	D.visible_message(span_danger("[A] takes a large bite out of [D]'s neck!"), \
					  span_userdanger("[A] takes a large bite out of your neck!"))
	if(D.health > 0)
		to_chat(A, span_boldwarning("You feel reinvigorated!"))
		A.heal_overall_damage(25, 25)
		A.adjustToxLoss(-8)
		A.adjustStaminaLoss(-50)
		A.blood_volume += 30
	A.Stun(1.5 SECONDS) //actually about 1 second due to the stun resist
	D.Stun(2 SECONDS)
	log_combat(A, D, "neck chomped (Flying Fang)")

//headbutt, deals moderate brute and stamina damage with an eye blur, causes poor aim for a few seconds to the target if they have no helmet on
/datum/martial_art/flyingfang/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!(A.mobility_flags & MOBILITY_STAND))	//No fancy tail slaps whe you're prone
		return harm_act(A, D)
	add_to_streak("D",D)
	if(!can_use(A))
		return
	if(HAS_TRAIT(A, TRAIT_PACIFISM)) // All disarm attacks/combos deal non-stamina damage, yet pacifism is not accounted for in base disarm.
		to_chat(A, span_warning("You don't want to harm [D]!"))
		return
	if(check_streak(A,D))
		return TRUE
	var/obj/item/bodypart/affecting = D.get_bodypart(check_zone(BODY_ZONE_HEAD))
	var/armor_block = D.run_armor_check(affecting, MELEE)
	var/disarm_damage = A.get_punchdamagehigh() / 2 	//5 damage
	A.do_attack_animation(D, ATTACK_EFFECT_SMASH)
	playsound(D, 'sound/weapons/genhit1.ogg', 50, TRUE, -1)
	D.apply_damage(disarm_damage, STAMINA, BODY_ZONE_HEAD, armor_block)
	D.apply_damage(disarm_damage, A.dna.species.attack_type, BODY_ZONE_HEAD, armor_block)
	D.adjust_eye_blur(4)
	if(!istype(D.head, /obj/item/clothing/head/helmet))
		D.dna.species.aiminginaccuracy += 25
		addtimer(CALLBACK(src, PROC_REF(remove_bonk), D), 10 SECONDS)
	D.visible_message(span_danger("[A] headbutts [D]!"), \
					  span_userdanger("[A] headbutts you!"))
	log_combat(A, D, "headbutted (Flying Fang)")

/datum/martial_art/flyingfang/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE //nothing special here

/datum/martial_art/flyingfang/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	var/selected_zone = A.zone_selected
	var/obj/item/bodypart/affecting = D.get_bodypart(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, MELEE, armour_penetration = 10)
	A.do_attack_animation(D, ATTACK_EFFECT_CLAW)
	playsound(D, 'sound/weapons/slash.ogg', 50, TRUE, -1)
	D.apply_damage(A.get_punchdamagehigh() + 2, A.dna.species.attack_type, selected_zone, armor_block, sharpness = SHARP_EDGED) //+2 unarmed damage and sharp
	var/atk_verb = pick("rends", "claws", "slices", "tears at")
	D.visible_message(span_danger("[A] [atk_verb] [D]!"), \
					  span_userdanger("[A] [atk_verb] you!"))
	return TRUE

/datum/martial_art/flyingfang/proc/on_click(mob/living/carbon/human/lizard, atom/target, params)
	if(!lizard.combat_mode || !can_use(lizard))
		return NONE

	var/list/modifiers = params2list(params)
	if(modifiers[SHIFT_CLICK] || modifiers[CTRL_CLICK] || modifiers[ALT_CLICK])
		return NONE

	if(!modifiers[RIGHT_CLICK] || get_dist(lizard, target) <= 1)
		return NONE

	if(lizard.wear_suit?.clothing_flags & THICKMATERIAL)
		to_chat(lizard, span_warning("Your [lizard.wear_suit] is too bulky to pounce with!"))
		return NONE

	if(!COOLDOWN_FINISHED(src, next_leap))
		return NONE

	if(lizard.buckled)
		lizard.buckled.unbuckle_mob(lizard, force = TRUE)

	leaping = TRUE
	lizard.Knockdown(5 SECONDS)
	lizard.Immobilize(3 SECONDS, TRUE, TRUE) //prevents you from breaking out of your pounce
	lizard.throw_at(target, get_dist(lizard, target) + 1, 1, lizard, FALSE, TRUE, callback = CALLBACK(src, PROC_REF(leap_end), lizard))
	COOLDOWN_START(src, next_leap, 5 SECONDS)
	return COMSIG_MOB_CANCEL_CLICKON

/datum/martial_art/flyingfang/proc/leap_end(mob/living/carbon/human/lizard)
	lizard.SetImmobilized(0, TRUE, TRUE)
	leaping = FALSE

/datum/martial_art/flyingfang/handle_throw(atom/hit_atom, mob/living/carbon/human/lizard, datum/thrownthing/throwingdatum)
	if(!leaping)
		return FALSE
	if(hit_atom)
		if(isliving(hit_atom))
			var/mob/living/victim = hit_atom
			var/blocked = FALSE
			if(ishuman(hit_atom))
				var/mob/living/carbon/human/H = hit_atom
				if(H.check_shields(H, 0, "[lizard]", attack_type = LEAP_ATTACK))
					blocked = TRUE
			victim.visible_message("<span class ='danger'>[lizard] pounces on [victim]!</span>", "<span class ='userdanger'>[lizard] pounces on you!</span>")

			//Knockdown regardless of blocking,
			victim.Knockdown(10 SECONDS)

			//Blocking knocks the lizard down too
			if(blocked)
				lizard.SetKnockdown(10 SECONDS)

			//Otherwise the not-blocker gets stunned and the lizard is okay
			else
				victim.Paralyze(6 SECONDS)
				lizard.SetKnockdown(0)

			if(!blocked)
				COOLDOWN_RESET(src, next_leap) // landing the leap resets the cooldown
				COOLDOWN_START(src, next_leap, 0.2 SECONDS) // but wait another 2 ticks so you don't accidentally do it again if you clicked twice
			sleep(0.2 SECONDS)//Runtime prevention (infinite bump() calls on hulks)
			step_towards(src,victim)
		else if(hit_atom.density && !hit_atom.CanPass(lizard))
			lizard.visible_message("<span class ='danger'>[lizard] smashes into [hit_atom]!</span>", "<span class ='danger'>You smash into [hit_atom]!</span>")
			lizard.Knockdown(6 SECONDS)
			playsound(lizard, 'sound/weapons/punch2.ogg', 50, 1) // ow oof ouch my head
		leaping = FALSE
		return TRUE

/mob/living/carbon/human/proc/flyingfang_help()
	set name = "Recall Your Teachings"
	set desc = "You try to remember your training of Flying Fang."
	set category = "Flying Fang"
	to_chat(usr, "<b><i>You try to remember some of the basics of Flying Fang.</i></b>")

	to_chat(usr, span_notice("Your training has rendered you more resistant to pain, allowing you to keep fighting effectively for longer and reducing the effectiveness of stun and stamina weapons by about a third."))
	to_chat(usr, span_warning("However, the primitive instincts gained through this training prevent you from using guns or stun weapons."))
	to_chat(usr, span_notice("<b>All of your unarmed attacks deal increased brute damage with a small amount of armor piercing</b>"))

	to_chat(usr, "[span_notice("Disarm")]: Headbutt your enemy, Deals minor stamina and brute damage, as well as causing eye blurriness. Prevents the target from using ranged weapons effectively for a few seconds if they are not wearing a helmet.")

	to_chat(usr, "[span_notice("Tail Slap")]: Shove three times. High armor piercing attack that causes a short slow followed by a knockdown. Deals heavy stamina damage. Requires you to have a tail, which must be exposed")
	to_chat(usr, "[span_notice("Neck Bite")]: Grab, then punch. Target must be prone. Stuns you and your target for a short period, dealing heavy brute damage and bleeding. If the target is not in crit, this attack will heal you. Requires your mouth to be exposed.")
	to_chat(usr, "[span_notice("Leap")]: Right click to jump at a target, with a successful hit stunning them and preventing you from moving for a few seconds. Cannot be done while wearing thick clothing.")

/datum/martial_art/flyingfang/teach(mob/living/carbon/human/H,make_temporary=0)
	..()
	H.physiology.stamina_mod *= 0.66
	H.physiology.stun_mod *= 0.66
	H.physiology.crawl_speed -= 2 // "funny lizard skitter around on the floor" - mqiib
	RegisterSignal(H, COMSIG_MOB_CLICKON, PROC_REF(on_click))

/datum/martial_art/flyingfang/on_remove(mob/living/carbon/human/H)
	..()
	H.physiology.stamina_mod /= 0.66
	H.physiology.stun_mod /= 0.66
	H.physiology.crawl_speed += 2
	UnregisterSignal(H, COMSIG_MOB_CLICKON)
