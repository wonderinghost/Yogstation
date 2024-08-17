/mob/living/simple_animal/cheese
	name = "sentient cheese"
	icon = 'icons/mob/animal.dmi'
	icon_state = "parmesan"
	icon_living = "parmesan"
	icon_dead = "parmesan_dead"
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC
	butcher_results = list(/obj/item/reagent_containers/food/snacks/cheesewedge/parmesan = 2)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	health = 50
	maxHealth = 50
	wander = 0
	response_harm = "takes a bite out of"
	attacked_sound = 'sound/items/eatfood.ogg'
	deathmessage = "dies from the pain of existence!"
	deathsound = "bodyfall"
	speed = 5
	can_be_held = TRUE
	density = FALSE
	var/mob/living/stored_mob
	var/temporary = FALSE //permanent until made temporary

/mob/living/simple_animal/cheese/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	..()
	if(stored_mob)
		stored_mob.life_tickrate = 0
	if(temporary)
		addtimer(CALLBACK(src, PROC_REF(uncheeseify), src), 1 MINUTES, TIMER_UNIQUE)
	if(stat)
		return
	if(health < maxHealth)
		adjustBruteLoss(-1)

/mob/living/simple_animal/cheese/attack_hand(mob/living/L)
	..()
	if(L.combat_mode && L.reagents && !stat)
		L.reagents.add_reagent(/datum/reagent/consumable/nutriment, 0.4)
		L.reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 0.4)
		L.adjustBruteLoss(-0.1, 0)
		L.adjustFireLoss(-0.1, 0)
		L.adjustToxLoss(-0.1, 0)
		L.adjustOxyLoss(-0.1, 0)

/mob/living/simple_animal/cheese/grabbedby(mob/living/carbon/user, supress_message)
	if(ishuman(user))
		if(stat == DEAD || status_flags & GODMODE || !can_be_held)
			return ..()
		if(user.get_active_held_item())
			to_chat(user, span_warning("Your hands are full!"))
			return ..()
		visible_message(span_warning("[user] starts picking up [src]."), \
						span_userdanger("[user] starts picking you up!"))
		if(!do_after(user, 2 SECONDS, src))
			return ..()
		visible_message(span_warning("[user] picks up [src]!"), \
						span_userdanger("[user] picks you up!"))
		if(buckled)
			to_chat(user, span_warning("[src] is buckled to [buckled] and cannot be picked up!"))
			return ..()
		to_chat(user, span_notice("You pick [src] up."))
		drop_all_held_items()
		var/obj/item/clothing/mob_holder/cheese/P = new(get_turf(src), src, null, null, null, ITEM_SLOT_HEAD, mob_size, null)
		user.put_in_hands(P)
	return ..()

/mob/living/simple_animal/cheese/death(gibbed)
	for(var/i = 0; i < 4; i++)
		new /obj/item/reagent_containers/food/snacks/cheesewedge/parmesan(loc)
	if(stored_mob)
		uncheeseify(src)
	. = ..()
	
/mob/living/simple_animal/cheese/proc/uncheeseify(mob/living/simple_animal/cheese/cheese)
	if(cheese.stored_mob)
		var/mob/living/L = cheese.stored_mob
		var/mob/living/simple_animal/cheese/C = cheese
		L.life_tickrate = initial(L.life_tickrate)
		L.forceMove(get_turf(C))
		C.stored_mob = null
		if(L.mind)
			C.mind.transfer_to(L)
		else
			L.key = C.key
		C.transfer_observers_to(L)
		to_chat(L, "<span class='big bold'>You have fallen out of the cheese wheel!</b>")
		qdel(C)

/mob/living/simple_animal/cheese/canSuicide()
	return FALSE
