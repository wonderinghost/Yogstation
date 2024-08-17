/*
 * Vxtvul Hammer
 */
/obj/item/melee/vxtvulhammer
	icon = 'icons/obj/weapons/hammer.dmi'
	icon_state = "vxtvul_hammer0-0"
	base_icon_state = "vxtvul_hammer"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	name = "Vxtvul Hammer"
	desc = "A relic sledgehammer with charge packs wired to two blast pads on its head. \
			While wielded in two hands, the user can charge a massive blow that will shatter construction and hurl bodies."
	force = 4 //It's heavy as hell
	demolition_mod = 3 // it's a big hammer, what do you expect
	armour_penetration = 50 //Designed for shattering walls in a single blow, I don't think it cares much about armor
	throwforce = 18
	attack_verb = list("attacked", "hit", "struck", "bludgeoned", "bashed", "smashed")
	sharpness = SHARP_NONE //Blunt, breaks bones
	wound_bonus = -10
	bare_wound_bonus = 15
	max_integrity = 200
	resistance_flags = ACID_PROOF | FIRE_PROOF
	w_class = WEIGHT_CLASS_HUGE
	hitsound = 'sound/effects/hammerhitbasic.ogg'
	slot_flags = ITEM_SLOT_BACK
	actions_types = list(/datum/action/item_action/charge_hammer)
	light_system = MOVABLE_LIGHT
	light_color = LIGHT_COLOR_HALOGEN
	light_range = 2
	light_power = 2

	var/force_wielded = 24
	var/datum/effect_system/spark_spread/spark_system //It's a surprise tool that'll help us later
	var/charging = FALSE
	var/supercharged = FALSE
	var/toy = FALSE

/obj/item/melee/vxtvulhammer/Initialize(mapload) //For the sparks when you begin to charge it
	. = ..()
	spark_system = new
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	set_light_on(FALSE)
	AddComponent(/datum/component/two_handed, \
		force_wielded = force_wielded, \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
	)
	AddComponent(/datum/component/cleave_attack, \
		arc_size=180, \
		requires_wielded=TRUE, \
		cleave_end_callback=CALLBACK(src, PROC_REF(end_swing)), \
	)
	if(!toy)
		AddComponent(/datum/component/blocking, block_force = 20, block_flags = WEAPON_BLOCK_FLAGS|WIELD_TO_BLOCK)

/obj/item/melee/vxtvulhammer/Destroy() //Even though the hammer won't probably be destroyed, Ever™
	QDEL_NULL(spark_system)
	return ..()

/obj/item/melee/vxtvulhammer/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][HAS_TRAIT(src, TRAIT_WIELDED)]-[supercharged]"

/obj/item/melee/vxtvulhammer/examine(mob/living/carbon/user)
	. = ..()
	if(supercharged)
		. += "<b>Electric sparks</b> are bursting from the blast pads!"

/obj/item/melee/vxtvulhammer/proc/on_unwield(atom/source, mob/living/carbon/user)
	if(supercharged) //So you can't one-hand the charged hit
		to_chat(user, span_notice("Your hammer loses its power as you adjust your grip."))
		user.visible_message(span_warning("The sparks from [user]'s hammer suddenly stop!"))
		supercharge()
	if(charging) //So you can't one-hand while charging
		to_chat(user, span_notice("You flip the switch off as you adjust your grip."))
		user.visible_message(span_warning("[user] flicks the hammer off!"))
		charging = FALSE

/obj/item/melee/vxtvulhammer/proc/end_swing(obj/item/weapon, mob/user)
	if(supercharged)
		supercharge()

/obj/item/melee/vxtvulhammer/attack(mob/living/carbon/human/target, mob/living/carbon/user) //This doesn't consider objects, only people
	if (charging) //So you can't attack while charging
		to_chat(user, span_notice("You flip the switch off before your attack."))
		user.visible_message(span_warning("[user] flicks the hammer off and raises it!"))
		charging = FALSE
	return ..()

/obj/item/melee/vxtvulhammer/AltClick(mob/living/carbon/user)
	charge_hammer(user)

/obj/item/melee/vxtvulhammer/proc/supercharge() //Proc to handle when it's charged for light + sprite + damage
	supercharged = !supercharged
	if(supercharged)
		set_light_on(TRUE) //Glows when charged
		if(!toy)
			force = initial(force) + (HAS_TRAIT(src, TRAIT_WIELDED) ? force_wielded : 0) + 12 //12 additional damage for a total of 40 has to be a massively irritating check because of how force_wielded works
			armour_penetration = 100
			ADD_TRAIT(src, TRAIT_SHIELDBUSTER, "supercharge")
	else
		set_light_on(FALSE)
		force = initial(force) + (HAS_TRAIT(src, TRAIT_WIELDED) ? force_wielded : 0)
		armour_penetration = initial(armour_penetration)
		REMOVE_TRAIT(src, TRAIT_SHIELDBUSTER, "supercharge")
	update_appearance(UPDATE_ICON)

/obj/item/melee/vxtvulhammer/proc/charge_hammer(mob/living/carbon/user)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		to_chat(user, span_warning("The hammer must be wielded in two hands in order to charge it!"))
		return
	if(supercharged)
		to_chat(user, span_warning("The hammer is already supercharged!"))
	else
		charging = TRUE
		to_chat(user, span_notice("You begin charging the weapon, concentration flowing into it..."))
		user.visible_message(span_warning("[user] flicks the hammer on, tilting [user.p_their()] head down as if in thought."))
		spark_system.start() //Generates sparks when you charge
		if(!do_after(user, ispreternis(user)? 5 SECONDS : 6 SECONDS))
			if(!charging) //So no duplicate messages
				return
			to_chat(user, span_notice("You flip the switch off as you lose your focus."))
			user.visible_message(span_warning("[user]'s concentration breaks!"))
			charging = FALSE
		if(!charging) //No charging for you if you cheat
			return //Has to double-check return because attacking or one-handing won't actually proc !do_mob, so the channel will seem to continue despite the message that pops out, but this actually ensures that it won't charge despite attacking or one-handing
		to_chat(user, span_notice("You complete charging the weapon."))
		user.visible_message(span_warning("[user] looks up as [user.p_their()] hammer begins to crackle and hum!"))
		playsound(loc, 'sound/magic/lightningshock.ogg', 60, TRUE) //Mainly electric crack
		playsound(loc, 'sound/effects/magic.ogg', 40, TRUE) //Reverb undertone
		supercharge()
		charging = FALSE

/obj/item/melee/vxtvulhammer/afterattack(atom/target, mob/living/carbon/user, proximity) //Afterattack to properly be able to smack walls
	. = ..()
	if(!proximity)
		return
	if(isfloorturf(target)) //So you don't just lose your supercharge if you miss and wack the floor. No I will NOT let people space with this thing
		return

	if(charging) //Needs a special snowflake check if you hit something that isn't a mob
		if(ismachinery(target) || isstructure(target) || ismecha(target))
			to_chat(user, span_notice("You flip the switch off after your blow."))
			user.visible_message(span_warning("[user] flicks the hammer off after striking [target]!"))
			charging = FALSE

	if(supercharged)
		var/turf/target_turf = get_turf(target) //Does the nice effects first so whatever happens to what's about to get clapped doesn't affect it
		var/obj/effect/temp_visual/kinetic_blast/K = new /obj/effect/temp_visual/kinetic_blast(target_turf)
		K.color = color
		playsound(loc, 'sound/effects/powerhammerhit.ogg', 80, FALSE) //Mainly this sound
		playsound(loc, 'sound/effects/explosion3.ogg', 20, TRUE) //Bit of a reverb
		if(!HAS_TRAIT(src, TRAIT_CLEAVING)) // wait for the swing to end
			supercharge() //At start so it doesn't give an unintentional message if you hit yourself

		if(ismecha(target) && !toy)
			user.visible_message(span_danger("The hammer thunders against [target], caving in part of its outer plating!"))
			target.take_damage(target.max_integrity/3, damtype, MELEE, FALSE, null, armour_penetration)

		else if(target.uses_integrity && !toy)
			user.visible_message(span_danger("The hammer thunders against [target], demolishing it!"), blind_message=span_hear("You hear thunder."))
			target.atom_destruction(damtype)
			if(ismachinery(target))
				for(var/obj/structure/door_assembly/door in target_turf) //Will destroy airlock assembly left behind, but drop the parts
					door.take_damage(door.max_integrity * 2)
				for(var/obj/structure/frame/base in target_turf) //Will destroy machine or computer frame left behind, but drop the parts
					base.take_damage(base.max_integrity * 2)
				for(var/obj/structure/light_construct/light in target_turf) //Also light frames because why not
					light.take_damage(light.max_integrity * 2)
			if(istype(target, /obj/structure/table))
				for(var/obj/structure/table_frame/platform in target_turf)
					platform.take_damage(platform.max_integrity * 2) //Destroys table frames left behind

		else if(isliving(target))
			var/atom/throw_target = get_edge_target_turf(target, user.dir)
			var/mob/living/victim = target
			if(toy)
				if(user == target)
					victim.Paralyze(2 SECONDS)
					victim.emote("scream")
					to_chat(victim, span_userdanger("That was stupid."))
				else
					ADD_TRAIT(victim, TRAIT_IMPACTIMMUNE, "Toy Hammer")
					victim.safe_throw_at(throw_target, rand(1,2), 3, callback = CALLBACK(src, PROC_REF(afterimpact), victim))
			else
				victim.throw_at(throw_target, 15, 5) //Same distance as maxed out power fist with three extra force
				victim.Paralyze(2 SECONDS)
				user.visible_message(span_danger("The hammer thunders as it viscerally strikes [target.name]!"))
				to_chat(victim, span_userdanger("Agony sears through you as [user]'s blow cracks your body off its feet!"))
				victim.emote("scream")

/obj/item/melee/vxtvulhammer/proc/afterimpact(mob/living/victim)
	REMOVE_TRAIT(victim, TRAIT_IMPACTIMMUNE, "Toy Hammer")

/obj/item/melee/vxtvulhammer/pirate //Exact same but different text and sprites
	icon_state = "vxtvul_hammer_pirate0-0"
	base_icon_state = "vxtvul_hammer_pirate"
	name = "pirate Vxtvul Hammer"
	desc = "A relic sledgehammer with charge packs wired to two blast pads on its head. This one has been defaced by Syndicate pirates. \
			While wielded in two hands, the user can charge a massive blow that will shatter construction and hurl bodies."

/datum/action/item_action/charge_hammer
	name = "Charge the Blast Pads"

/datum/action/item_action/charge_hammer/Trigger()
	var/obj/item/melee/vxtvulhammer/vxtvulhammer = target
	if(istype(vxtvulhammer))
		vxtvulhammer.charge_hammer(owner)
