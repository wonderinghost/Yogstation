/obj/item/mantis/blade
	name = "mantis blade"
	desc = "A blade designed to be hidden just beneath the skin. The brain is directly linked to this bad boy, allowing it to spring into action."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "mantis"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	flags_1 = CONDUCT_1
	force = 20
	armour_penetration = 30
	wound_bonus = 20
	bare_wound_bonus = 20
	w_class = WEIGHT_CLASS_NORMAL
	sharpness = SHARP_EDGED
	tool_behaviour = TOOL_CROWBAR // just a very "sharp" crowbar
	toolspeed = 0.35 //for door prying speed, ends up at about 3 seconds
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "lacerated", "ripped", "diced", "cut")

/obj/item/mantis/blade/equipped(mob/user, slot, initial)
	. = ..()
	if(slot != ITEM_SLOT_HANDS)
		return
	var/side = user.get_held_index_of_item(src)

	if(side == LEFT_HANDS)
		transform = null
	else
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/mantis/blade/attack(mob/living/M, mob/living/user, params, secondattack = FALSE)
	. = ..()
	var/obj/item/mantis/blade/secondblade = user.get_inactive_held_item()
	if(istype(secondblade, /obj/item/mantis/blade) && !secondattack)
		addtimer(CALLBACK(src, PROC_REF(secondattack), M, user, params, secondblade), 2, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/item/mantis/blade/proc/secondattack(mob/living/M, mob/living/user, params, obj/item/mantis/blade/secondblade)
	if(QDELETED(secondblade) || QDELETED(src))
		return
	secondblade.attack(M, user, params, TRUE)
	user.changeNext_move(CLICK_CD_MELEE)

/obj/item/mantis/blade/syndicate
	name = "G.O.R.L.E.X. mantis blade"
	icon_state = "syndie_mantis"

/obj/item/mantis/blade/syndicate/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/blocking, block_force = 10, block_flags = WEAPON_BLOCK_FLAGS|PROJECTILE_ATTACK)

/obj/item/mantis/blade/NT
	name = "H.E.P.H.A.E.S.T.U.S. mantis blade"
	icon_state = "mantis"
	force = 18
