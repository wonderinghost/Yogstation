/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammarically correct text-parsing
	var/chained = 0

	body_parts_covered = FEET
	slot_flags = ITEM_SLOT_FEET

	slowdown = SHOES_SLOWDOWN
	var/footprint_sprite = FOOTPRINT_SPRITE_SHOES
	var/offset = 0
	var/equipped_before_drop = FALSE
	var/xenoshoe = NO_DIGIT  // Check for if shoes can be worn by straight legs (NO_DIGIT) which is default, both / hybrid (EITHER_STYLE), or digitigrade only (YES_DIGIT)
	var/mutantrace_variation = NO_MUTANTRACE_VARIATION // Assigns shoes to have variations for if worn clothing doesn't enforce straight legs (such as cursed jumpskirts)
	var/adjusted = NORMAL_STYLE // Default needed to make the above work
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 15, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/shoes/suicide_act(mob/living/carbon/user)
	if(rand(2)>1)
		user.visible_message(span_suicide("[user] begins tying \the [src] up waaay too tightly! It looks like [user.p_theyre()] trying to commit suicide!"))
		var/obj/item/bodypart/l_leg = user.get_bodypart(BODY_ZONE_L_LEG)
		var/obj/item/bodypart/r_leg = user.get_bodypart(BODY_ZONE_R_LEG)
		if(l_leg)
			l_leg.dismember()
			playsound(user,pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg') ,50, 1, -1)
		if(r_leg)
			r_leg.dismember()
			playsound(user,pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg') ,50, 1, -1)
		return BRUTELOSS
	else//didnt realize this suicide act existed (was in miscellaneous.dm) and didnt want to remove it, so made it a 50/50 chance. Why not!
		user.visible_message(span_suicide("[user] is bashing [user.p_their()] own head in with [src]! Ain't that a kick in the head?"))
		for(var/i = 0, i < 3, i++)
			sleep(0.3 SECONDS)
			playsound(user, 'sound/weapons/genhit2.ogg', 50, 1)
		return(BRUTELOSS)

/obj/item/clothing/shoes/worn_overlays(isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(damaged_clothes)
			. += mutable_appearance('icons/effects/item_damage.dmi', "damagedshoe")
		if(HAS_BLOOD_DNA(src))
			var/mutable_appearance/bloody_shoes
			bloody_shoes = mutable_appearance('icons/effects/blood.dmi', "shoeblood")
			bloody_shoes.color = get_blood_dna_color(return_blood_DNA())
			. += bloody_shoes

/obj/item/clothing/shoes/equipped(mob/user, slot)
	if(adjusted)
		adjusted = NORMAL_STYLE
	if(mutantrace_variation && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(DIGITIGRADE in H.dna.species.species_traits)
			for(var/X in H.bodyparts)
				var/obj/item/bodypart/O = X
				if(!O.use_digitigrade)
					continue
				if(O.use_digitigrade == FULL_DIGITIGRADE)
					adjusted = DIGITIGRADE_STYLE
		user.update_inv_shoes()
	. = ..()
	if(offset && slot_flags & slot)
		user.pixel_y += offset
		worn_y_dimension -= (offset * 2)
		equipped_before_drop = TRUE

	user.update_inv_shoes()

/obj/item/clothing/shoes/proc/restore_offsets(mob/user)
	equipped_before_drop = FALSE
	user.pixel_y -= offset
	worn_y_dimension = world.icon_size

/obj/item/clothing/shoes/dropped(mob/user)
	if(offset && equipped_before_drop)
		restore_offsets(user)
	. = ..()

/obj/item/clothing/shoes/update_clothes_damaged_state()
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_shoes()

/obj/item/proc/negates_gravity()
	return FALSE
