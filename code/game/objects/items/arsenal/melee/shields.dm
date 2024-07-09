/obj/item/shield
	name = "shield"
	icon = 'icons/obj/weapons/shield.dmi'
	slowdown = 0.2
	item_flags = SLOWS_WHILE_IN_HAND
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 0, BOMB = 30, BIO = 0, RAD = 0, FIRE = 80, ACID = 70)
	var/block_force = 20
	var/block_flags = SHIELD_BLOCK_FLAGS

/obj/item/shield/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/blocking, block_force = src.block_force, block_flags = src.block_flags)
	RegisterSignal(src, COMSIG_ITEM_PRE_BLOCK, PROC_REF(block_check))

/obj/item/shield/proc/block_check(obj/item/source, mob/living/defender, atom/movable/incoming, damage, attack_type)
	return NONE

/obj/item/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon_state = "riot"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	force = 10
	throwforce = 5
	throw_speed = 2
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY
	materials = list(/datum/material/glass=7500, /datum/material/iron=1000)
	attack_verb = list("shoved", "bashed")
	var/cooldown = 0 //shield bash cooldown. based on world.time
	block_flags = SHIELD_BLOCK_FLAGS|TRANSPARENT_BLOCK // oh no, they saw right through our evil plans!
	max_integrity = 75
	var/obj/item/stack/sheet/mineral/repair_material = /obj/item/stack/sheet/mineral/titanium

/obj/item/shield/riot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/melee/baton))
		if(cooldown < world.time - 25)
			user.visible_message(span_warning("[user] bashes [src] with [W]!"))
			playsound(user.loc, 'sound/effects/shieldbash.ogg', 50, 1)
			cooldown = world.time
	else if(istype(W, repair_material))
		if (atom_integrity >= max_integrity)
			to_chat(user, span_notice("[src] is already in perfect condition."))
		else
			var/obj/item/stack/sheet/mineral/T = W
			T.use(1)
			update_integrity(max_integrity)
			to_chat(user, span_notice("You repair [src] with [T]."))
	else
		return ..()

/obj/item/shield/riot/proc/shatter(turf/drop_to)
	playsound(drop_to, 'sound/effects/glassbr3.ogg', 100)
	new /obj/item/shard(drop_to)

/obj/item/shield/riot/atom_destruction(damage_flag)
	shatter(get_turf(src))
	return ..()
	

/obj/item/shield/riot/roman
	name = "\improper Roman shield"
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>."
	icon_state = "roman_shield"
	item_state = "roman_shield"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	block_flags = SHIELD_BLOCK_FLAGS
	materials = list(/datum/material/iron=8500)
	max_integrity = 65
	repair_material = /obj/item/stack/sheet/mineral/wood

/obj/item/shield/riot/roman/fake
	desc = "Bears an inscription on the inside: <i>\"Romanes venio domus\"</i>. It appears to be a bit flimsy."
	block_force = 5 // can block punches at most
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	max_integrity = 30

/obj/item/shield/riot/roman/shatter(turf/drop_to)
	playsound(drop_to, 'sound/effects/grillehit.ogg', 100)
	new /obj/item/stack/sheet/metal(drop_to)

/obj/item/shield/riot/buckler
	name = "wooden buckler"
	desc = "A medieval wooden buckler."
	icon_state = "buckler"
	item_state = "buckler"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	materials = list()
	resistance_flags = FLAMMABLE
	block_force = 10
	block_flags = SHIELD_BLOCK_FLAGS|PARRYING_BLOCK // small enough to parry with
	max_integrity = 55
	w_class = WEIGHT_CLASS_NORMAL
	repair_material = /obj/item/stack/sheet/mineral/wood

/obj/item/shield/riot/buckler/shatter(turf/drop_to)
	playsound(drop_to, 'sound/effects/bang.ogg', 50)
	new /obj/item/stack/sheet/mineral/wood(drop_to)

/obj/item/shield/riot/goliath
	name = "Goliath shield"
	desc = "A shield made from interwoven plates of goliath hide."
	icon_state = "goliath_shield"
	item_state = "goliath_shield"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	materials = list ()
	block_flags = SHIELD_BLOCK_FLAGS
	block_force = 15
	max_integrity = 70
	w_class = WEIGHT_CLASS_BULKY
	armor = list(MELEE = 50, BULLET = 50, LASER = 30, ENERGY = 20, BOMB = 30, BIO = 0, RAD = 0, FIRE = 80, ACID = 70)

/obj/item/shield/riot/goliath/shatter(turf/drop_to)
	playsound(drop_to, 'sound/effects/bang.ogg', 50)
	new /obj/item/stack/sheet/animalhide/goliath_hide(drop_to)

/obj/item/shield/riot/flash
	name = "strobe shield"
	desc = "A shield with a built in, high intensity light capable of blinding and disorienting suspects. Takes regular handheld flashes as bulbs."
	icon_state = "flashshield"
	item_state = "flashshield"
	var/obj/item/assembly/flash/handheld/embedded_flash

/obj/item/shield/riot/flash/Initialize(mapload)
	. = ..()
	embedded_flash = new(src)
	RegisterSignal(src, COMSIG_ITEM_POST_BLOCK, PROC_REF(post_block))

/obj/item/shield/riot/flash/attack(mob/living/M, mob/user)
	. =  embedded_flash.attack(M, user)
	update_appearance(UPDATE_ICON)

/obj/item/shield/riot/flash/attack_self(mob/living/carbon/user)
	. = embedded_flash.attack_self(user)
	update_appearance(UPDATE_ICON)

/obj/item/shield/riot/flash/proc/post_block(obj/item/source, mob/living/defender, atom/movable/incoming, damage, attack_type)
	if(!embedded_flash.burnt_out)
		embedded_flash.activate()
		update_appearance(UPDATE_ICON)

/obj/item/shield/riot/flash/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/assembly/flash/handheld))
		var/obj/item/assembly/flash/handheld/flash = W
		if(flash.burnt_out)
			to_chat(user, "No sense replacing it with a broken bulb.")
			return
		else
			to_chat(user, "You begin to replace the bulb.")
			if(do_after(user, 2 SECONDS, user))
				if(flash.burnt_out || !flash || QDELETED(flash))
					return
				playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
				qdel(embedded_flash)
				embedded_flash = flash
				flash.forceMove(src)
				update_appearance(UPDATE_ICON)
				return
	..()

/obj/item/shield/riot/flash/emp_act(severity)
	. = ..()
	embedded_flash.emp_act(severity)
	update_appearance(UPDATE_ICON)

/obj/item/shield/riot/flash/update_icon_state()
	. = ..()
	if(!embedded_flash || embedded_flash.burnt_out)
		icon_state = "riot"
		item_state = "riot"
	else
		icon_state = "flashshield"
		item_state = "flashshield"

/obj/item/shield/riot/flash/examine(mob/user)
	. = ..()
	if (embedded_flash?.burnt_out)
		. += span_info("The mounted bulb has burnt out. You can try replacing it with a new one.")

/obj/item/shield/energy
	name = "energy combat shield"
	desc = "A shield that reflects almost all energy projectiles, but is useless against physical attacks. It can be retracted, expanded, and stored anywhere."
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	icon_state = "eshield1" // So it can display without initializing
	base_icon_state = "eshield" // [base_icon_state]1 for expanded, [base_icon_state]0 for contracted
	w_class = WEIGHT_CLASS_TINY
	attack_verb = list("shoved", "bashed")
	throw_range = 5
	force = 3
	throwforce = 3
	throw_speed = 3
	block_force = 30
	block_flags = PROJECTILE_ATTACK|REFLECTIVE_BLOCK
	var/on_force = 10
	var/on_throwforce = 8
	var/on_throw_speed = 2
	var/active = 0
	var/clumsy_check = TRUE

/obj/item/shield/energy/Initialize(mapload)
	. = ..()
	icon_state = "[base_icon_state]0"

// can only block reflectable projectiles
/obj/item/shield/energy/block_check(obj/item/source, mob/living/defender, atom/movable/incoming, damage, attack_type)
	if(!active)
		return COMPONENT_CANCEL_BLOCK
	if(!isprojectile(incoming))
		return COMPONENT_CANCEL_BLOCK
	var/obj/projectile/incoming_projectile = incoming
	if(!(incoming_projectile.reflectable & REFLECT_NORMAL))
		return COMPONENT_CANCEL_BLOCK
	return NONE

/obj/item/shield/energy/attack_self(mob/living/carbon/human/user)
	if(clumsy_check && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, span_warning("You beat yourself in the head with [src]."))
		user.take_bodypart_damage(5)
	active = !active
	icon_state = "[base_icon_state][active]"

	if(active)
		force = on_force
		throwforce = on_throwforce
		throw_speed = on_throw_speed
		w_class = WEIGHT_CLASS_BULKY
		playsound(user, 'sound/weapons/saberon.ogg', 35, 1)
		to_chat(user, span_notice("[src] is now active."))
	else
		force = initial(force)
		throwforce = initial(throwforce)
		throw_speed = initial(throw_speed)
		w_class = WEIGHT_CLASS_TINY
		playsound(user, 'sound/weapons/saberoff.ogg', 35, 1)
		to_chat(user, span_notice("[src] can now be concealed."))
	add_fingerprint(user)

/obj/item/shield/energy/honk_act()
	new /obj/item/shield/energy/bananium(src.loc)
	qdel(src)

/obj/item/shield/riot/tele
	name = "telescopic shield"
	desc = "An advanced riot shield made of lightweight materials that collapses for easy storage."
	icon_state = "teleriot0"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	slot_flags = null
	force = 3
	throwforce = 3
	throw_speed = 3
	throw_range = 4
	w_class = WEIGHT_CLASS_NORMAL
	var/active = 0

/obj/item/shield/riot/tele/block_check(obj/item/source, mob/living/defender, atom/movable/incoming, damage, attack_type)
	if(active)
		return NONE
	return COMPONENT_CANCEL_BLOCK

/obj/item/shield/riot/tele/attack_self(mob/living/user)
	active = !active
	icon_state = "teleriot[active]"
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)

	if(active)
		force = 8
		throwforce = 5
		throw_speed = 2
		w_class = WEIGHT_CLASS_BULKY
		slot_flags = ITEM_SLOT_BACK
		to_chat(user, span_notice("You extend \the [src]."))
	else
		force = 3
		throwforce = 3
		throw_speed = 3
		w_class = WEIGHT_CLASS_NORMAL
		slot_flags = null
		to_chat(user, span_notice("[src] can now be concealed."))
	add_fingerprint(user)
