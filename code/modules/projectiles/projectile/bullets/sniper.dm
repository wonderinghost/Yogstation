// .50 (Sniper Rifle)

/obj/projectile/bullet/p50
	name = ".50 bullet"
	speed = 0.3
	damage = 70
	paralyze = 100
	dismemberment = 50
	armour_penetration = 50
	demolition_mod = 2.2 // very effective against armored structures and vehicles
	var/shieldbuster = TRUE // doesn't just penetrate shields, it DESTROYS them

/obj/projectile/bullet/p50/Initialize(mapload)
	. = ..()
	if(shieldbuster)
		ADD_TRAIT(src, TRAIT_SHIELDBUSTER, INNATE_TRAIT)

/obj/projectile/bullet/p50/soporific
	name = ".50 soporific bullet"
	armour_penetration = 0
	damage = 0
	dismemberment = 0
	paralyze = 0
	shieldbuster = FALSE

/obj/projectile/bullet/p50/soporific/on_hit(atom/target, blocked = FALSE)
	if((blocked != 100) && isliving(target))
		var/mob/living/L = target
		L.Sleeping(400)
	return ..()

/obj/projectile/bullet/p50/penetrator
	name = ".50 penetrator bullet"
	icon_state = "gauss"
	damage = 60
	penetrations = INFINITY //Passes through everything and anything until it reaches the end of its range
	penetration_flags = PENETRATE_OBJECTS | PENETRATE_MOBS
	dismemberment = 0 //It goes through you cleanly.
	paralyze = 0
	shieldbuster = FALSE

/obj/projectile/bullet/p50/penetrator/shuttle //Nukeop Shuttle Variety
	icon_state = "gaussstrong"
	damage = 25
	speed = 0.3
	range = 16
