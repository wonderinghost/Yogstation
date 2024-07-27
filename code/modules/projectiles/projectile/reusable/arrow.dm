/obj/projectile/bullet/reusable/arrow //Base arrow. Good against fauna, not perfect, but well-rounded.
	name = "arrow"
	desc = "Woosh!"
	damage = 35
	armour_penetration = -25 //Melee armor tends to be much higher, so this hurts
	speed = 0.6
	armor_flag = MELEE
	icon_state = "arrow"
	var/embed_chance = 0.4
	var/break_chance = 0
	var/fauna_damage_bonus = 10

/obj/projectile/bullet/reusable/arrow/on_hit(atom/target, blocked = FALSE)
	..()
	var/turf/open/target_turf = get_turf(target)
	if(istype(target_turf))
		if(istype(ammo_type, /obj/item/ammo_casing/reusable/arrow))	
			var/obj/item/ammo_casing/reusable/arrow/arrow = ammo_type
			if(arrow.flaming)
				target_turf.ignite_turf(rand(8, 16))
		else
			target_turf.ignite_turf(rand(8, 16))

	if(!isliving(target) || (blocked == 100))
		return
		
	var/mob/living/L = target	
	if(ismegafauna(L) || istype(L, /mob/living/simple_animal/hostile/asteroid) || istype(L, /mob/living/simple_animal/hostile/asteroid/yog_jungle) || istype(L, /mob/living/simple_animal/hostile/tar))
		L.apply_damage(fauna_damage_bonus)

	if(!istype(ammo_type, /obj/item/ammo_casing/reusable/arrow))	
		return
	
	var/obj/item/ammo_casing/reusable/arrow/arrow = ammo_type
	if(istype(arrow.bola))
		if(iscarbon(target))
			arrow.bola.impactCarbon(target)
		if(isanimal(target))
			arrow.bola.impactAnimal(target)
		if(!istype(arrow.bola) || arrow.bola.loc != src)
			LAZYREMOVE(arrow.attached_parts, arrow.bola)
			arrow.bola = null
		
	if(arrow.flaming)
		L.adjust_fire_stacks(1)
		L.ignite_mob()
		arrow.flaming = FALSE

	arrow.update_appearance(UPDATE_ICON)

/obj/projectile/bullet/reusable/arrow/handle_drop(atom/target)
	if(dropped || !ammo_type)
		return ..()

	if(prob(break_chance))
		if(istype(ammo_type))
			visible_message(span_danger("\The [ammo_type] breaks on impact!"))
			qdel(ammo_type)
		dropped = TRUE
		return ..()

	if(iscarbon(target))
		ammo_type = ispath(ammo_type) ? new ammo_type(ammo_type) : ammo_type
		var/mob/living/carbon/embede = target
		var/obj/item/bodypart/part = embede.get_bodypart(def_zone)
		var/obj/item/ammo_casing/reusable/arrow/arrow = ammo_type
		if(!(istype(arrow) && arrow.explosive) && prob(embed_chance * clamp((100 - (embede.getarmor(part, armor_flag) - armour_penetration)), 0, 100)) && embede.embed_object(ammo_type, part, TRUE))
			arrow.on_land(src)
			dropped = TRUE
	return ..()


// Arrow Subtypes //

/obj/projectile/bullet/reusable/arrow/wood
	name = "wooden arrow"
	desc = "A wooden arrow, quickly made."

/obj/projectile/bullet/reusable/arrow/ash //Fire-tempered head makes it tougher; more damage, but less likely to embed
	name = "ashen arrow"
	desc = "A wooden arrow tempered by fire. It's tougher, but less likely to embed."
	damage = 40
	embed_chance = 0.3

/obj/projectile/bullet/reusable/arrow/bone_tipped //A fully upgraded normal arrow; it's got the stats to show. Still less damage than a slug, resolving against melee, fired less often, slower, and with negative AP
	name = "bone-tipped arrow"
	desc = "An arrow made from bone, wood, and sinew. Sturdy and sharp."
	damage = 45
	armour_penetration = -10

/obj/projectile/bullet/reusable/arrow/bone //Cheap, easy to make in bulk but mostly used for hunting fauna
	name = "bone arrow"
	desc = "An arrow made from bone and sinew. Better at hunting fauna."
	damage = 25
	armour_penetration = -10 //So it's not as terrible against miners; still bad
	fauna_damage_bonus = 35 //Significantly better for hunting fauna, but you don't get to instantly recharge your shots
	embed_chance = 0.33

/obj/projectile/bullet/reusable/arrow/chitin //Most expensive arrow time and resource-wise, simply because of ash resin. Should be good
	name = "chitin-tipped arrow"
	desc = "An arrow made from chitin, bone, and sinew. Incredibly potent at puncturing armor and hunting fauna."
	damage = 35
	armour_penetration = 30 //Basically an AP arrow
	fauna_damage_bonus = 40 //Even better, since they're that much harder to make

/obj/projectile/bullet/reusable/arrow/bamboo //Very brittle, very fragile, but very potent at splintering into targets assuming it isn't broken on impact
	name = "bamboo arrow"
	desc = "An arrow made from bamboo. Incredibly fragile and weak, but prone to shattering in unarmored targets."
	damage = 20
	armour_penetration = -40
	embed_chance = 0.6 //Reminder that this resolves against melee armor
	break_chance = 33 //Doesn't embed if it breaks

/obj/projectile/bullet/reusable/arrow/bronze //Bronze > iron, that's why they called it the bronze age
	name = "bronze arrow"
	desc = "An arrow tipped with bronze. Better against armor than iron."
	armour_penetration = -10

/obj/projectile/bullet/reusable/arrow/glass //Basically just a downgrade for people who can't get their hands on wood/cloth
	name = "glass arrow"
	desc = "A shoddy arrow with a broken glass shard as its tip. Can break upon impact."
	damage = 25
	embed_chance = 0.3
	break_chance = 10

/obj/projectile/bullet/reusable/arrow/glass/plasma //It's HARD to get plasmaglass shards without an axe, so this should be GOOD
	name = "plasmaglass arrow"
	desc = "An arrow with a plasmaglass shard affixed to its head. Incredibly capable of puncturing armor."
	damage = 25
	armour_penetration = 45 //18.75 damage against elite hardsuit assuming chest shot (and that's a long reload, draw, projectile speed, etc.)

/obj/projectile/bullet/reusable/arrow/magic
	name = "magic arrow"
	desc = "A magic arrow thats probably tracking you, how nice!"
	icon_state = "arrow_magic"
	damage = 40
	embed_chance = 0.6
	armour_penetration = 0

// Toy //

/obj/projectile/bullet/reusable/arrow/toy //Toy arrow with velcro tip that safely embeds into target
	name = "toy arrow"
	damage = 0
	embed_chance = 0.9
	break_chance = 0

/obj/projectile/bullet/reusable/arrow/toy/on_hit(atom/target, blocked)
	. = ..()

	if(!iscarbon(target))
		return
	
	var/nerfed = FALSE
	var/mob/living/carbon/C = target
	for(var/obj/item/gun/ballistic/T in C.held_items) // Is usually just ~2 items
		if(ispath(T.mag_type, /obj/item/ammo_box/magazine/toy) || ispath(T.mag_type, /obj/item/ammo_box/magazine/internal/shot/toy)) // All automatic foam force guns || Foam force shotguns & crossbows
			nerfed = TRUE
			break
		if(istype(T, /obj/item/gun/ballistic/bow)) // Bows have their own handling
			var/obj/item/gun/ballistic/bow/bow = T
			if(bow.nerfed)
				nerfed = TRUE
				break
	
	if(!nerfed)
		return
	
	C.adjustStaminaLoss(25) // ARMOR IS CHEATING!!!

/obj/projectile/bullet/reusable/arrow/toy/energy
	name = "toy energy bolt"
	icon_state = "arrow_energy"

/obj/projectile/bullet/reusable/arrow/toy/disabler
	name = "toy disabler bolt"
	icon_state = "arrow_disable"

/obj/projectile/bullet/reusable/arrow/toy/pulse
	name = "toy pulse bolt"
	icon_state = "arrow_pulse"

/obj/projectile/bullet/reusable/arrow/toy/xray
	name = "toy X-ray bolt"
	icon_state = "arrow_xray"

/obj/projectile/bullet/reusable/arrow/toy/shock
	name = "toy shock bolt"
	icon_state = "arrow_shock"

/obj/projectile/bullet/reusable/arrow/toy/magic
	name = "toy magic arrow"
	icon_state = "arrow_magic"


// Joke //

/obj/projectile/bullet/reusable/arrow/supermatter
	name = "supermatter arrow"

/obj/projectile/bullet/reusable/arrow/supermatter/on_hit(atom/target, blocked = FALSE)
	. = ..()
	var/obj/item/ammo_casing/reusable/arrow/supermatter/arrow = ammo_type
	if(istype(arrow))
		arrow.disintigrate(target)

/obj/projectile/bullet/reusable/arrow/supermatter/on_range()
	. = ..()
	var/obj/item/ammo_casing/reusable/arrow/supermatter/arrow = ammo_type
	if(istype(arrow))
		arrow.disintigrate(get_turf(src))

/obj/projectile/bullet/reusable/arrow/singulo
	name = "singularity shard arrow"

/obj/projectile/bullet/reusable/arrow/on_hit(atom/target, blocked = FALSE)
	. = ..()
	var/obj/item/ammo_casing/reusable/arrow/singulo/arrow = ammo_type
	if(istype(arrow))
		arrow.shard_effect()


// Hardlight //

/obj/projectile/energy/arrow //Hardlight projectile. Significantly more robust than a standard laser. Capable of hardening in target's flesh
	name = "energy bolt"
	icon_state = "arrow_energy"
	damage = 40
	wound_bonus = -60
	speed = 0.6
	var/embed_chance = 0.4
	var/obj/item/embed_type = /obj/item/ammo_casing/reusable/arrow/energy
	
/obj/projectile/energy/arrow/on_hit(atom/target, blocked = FALSE)
	if(istype(target, /obj/structure/blob))
		damage = damage / 2
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/embede = target
		var/obj/item/bodypart/part = embede.get_bodypart(def_zone)
		if(prob(embed_chance * clamp((100 - (embede.getarmor(part, armor_flag) - armour_penetration)), 0, 100)))
			embede.embed_object(new embed_type(), part, FALSE)
	return ..()

/obj/projectile/energy/arrow/disabler //Hardlight projectile. Much more draining than a standard disabler. Needs to be competitive in DPS
	name = "disabler bolt"
	icon_state = "arrow_disable"
	light_color = LIGHT_COLOR_BLUE
	damage = 50
	damage_type = STAMINA
	embed_type = /obj/item/ammo_casing/reusable/arrow/energy/disabler

/obj/projectile/energy/arrow/pulse //Hardlight projectile. Woe to your enemies.
	name = "pulse bolt"
	icon_state = "arrow_pulse"
	light_color = LIGHT_COLOR_BLUE
	damage = 75
	embed_type = /obj/item/ammo_casing/reusable/arrow/energy/pulse

/obj/projectile/energy/arrow/pulse/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if (!QDELETED(target) && (isturf(target) || istype(target, /obj/structure/)))
		if(isobj(target))
			SSexplosions.med_mov_atom += target
		else
			SSexplosions.medturf += target

/obj/projectile/energy/arrow/xray //Hardlight projectile. Weakened arrow capable of passing through material. Massive irradiation on hit.
	name = "X-ray bolt"
	icon_state = "arrow_xray"
	light_color = LIGHT_COLOR_GREEN
	damage = 30
	wound_bonus = -30
	irradiate = 500
	range = 20
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINES | PASSSTRUCTURE | PASSDOOR
	embed_type = /obj/item/ammo_casing/reusable/arrow/energy/xray

/obj/projectile/energy/arrow/shock //Hardlight projectile. Replicable tasers are fair and balanced.
	name = "shock bolt"
	icon_state = "arrow_shock"
	light_color = LIGHT_COLOR_YELLOW 
	nodamage = TRUE
	paralyze = 10 SECONDS
	stutter = 5
	jitter = 20
	damage_type = STAMINA
	embed_type = /obj/item/ammo_casing/reusable/arrow/energy/shock

/obj/projectile/energy/arrow/shock/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - burst into sparks!
		do_sparks(1, TRUE, src)
	else if(iscarbon(target))
		var/mob/living/carbon/C = target
		SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "tased", /datum/mood_event/tased)
		SEND_SIGNAL(C, COMSIG_LIVING_MINOR_SHOCK)
		if(C.dna && (C.dna.check_mutation(HULK)))
			C.say(pick("RAAAAAAAARGH!", "HNNNNNNNNNGGGGGGH!", "GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", "AAAAAAARRRGH!" ), forced = "hulk")
		else if((C.status_flags & CANKNOCKDOWN) && !HAS_TRAIT(C, TRAIT_STUNIMMUNE))
			addtimer(CALLBACK(C, TYPE_PROC_REF(/mob/living/carbon, do_jitter_animation), jitter), 5)
		if(istype(C.getorganslot(ORGAN_SLOT_STOMACH), /obj/item/organ/stomach/cell/ethereal))
			C.adjust_nutrition(40)
			to_chat(C,span_notice("You get charged by [src]."))

/obj/projectile/energy/arrow/clockbolt
	name = "redlight bolt"
	damage = 20
	wound_bonus = 5
	embed_type = /obj/item/ammo_casing/reusable/arrow/energy/clockbolt
