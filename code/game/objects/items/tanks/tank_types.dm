/* Types of tanks!
 * Contains:
 *		Oxygen
 *		Anesthetic
 *		Air
 *		Plasma
 *		Emergency Oxygen
 */

/// Allows carbon to toggle internals via AltClick of the equipped tank.
/obj/item/tank/internals/AltClick(mob/user)
	..()
	if((loc == user) && user.canUseTopic(src, be_close = TRUE, no_dexterity = TRUE, no_tk = TRUE))
		toggle_internals(user)

/obj/item/tank/internals/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click the tank to toggle the valve.")

/*
 * Oxygen
 */
/obj/item/tank/internals/oxygen
	name = "oxygen tank"
	desc = "A tank of oxygen, this one is blue."
	icon_state = "oxygen"
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
	force = 10
	dog_fashion = /datum/dog_fashion/back


/obj/item/tank/internals/oxygen/populate_gas()
	air_contents.set_moles(GAS_O2, (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))


/obj/item/tank/internals/oxygen/yellow
	desc = "A tank of oxygen, this one is yellow."
	icon_state = "oxygen_f"
	dog_fashion = null

/obj/item/tank/internals/oxygen/red
	desc = "A tank of oxygen, this one is red."
	icon_state = "oxygen_fr"
	dog_fashion = null

/obj/item/tank/internals/oxygen/tactical
	name = "tactical oxygen tank"
	desc = "A tactically colored tank of oxygen."
	color = "#aeb08c"

/obj/item/tank/internals/oxygen/empty/populate_gas()
	return

/*
 * Anesthetic
 */
/obj/item/tank/internals/anesthetic
	name = "anesthetic tank"
	desc = "A tank with an N2O/O2 gas mix."
	icon_state = "anesthetic"
	item_state = "an_tank"
	force = 10

/obj/item/tank/internals/anesthetic/populate_gas()
	air_contents.set_moles(GAS_O2, (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD)
	air_contents.set_moles(GAS_NITROUS, (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD)

/*
 * Air
 */
/obj/item/tank/internals/air
	name = "air tank"
	desc = "Mixed anyone?"
	icon_state = "air"
	item_state = "air"
	force = 10
	dog_fashion = /datum/dog_fashion/back

/obj/item/tank/internals/air/populate_gas()
	air_contents.set_moles(GAS_O2, (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * O2STANDARD)
	air_contents.set_moles(GAS_N2, (6*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C) * N2STANDARD)

/*
 * Plasma
 */
/obj/item/tank/internals/plasma
	name = "plasma tank"
	desc = "Contains dangerous plasma. Do not inhale. Warning: extremely flammable."
	icon_state = "plasma"
	flags_1 = CONDUCT_1
	slot_flags = null	//they have no straps!
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
	force = 8


/obj/item/tank/internals/plasma/populate_gas()
	air_contents.set_moles(GAS_PLASMA, (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))

/obj/item/tank/internals/plasma/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/gun/flamethrower))
		var/obj/item/gun/flamethrower/F = W
		if (F.fuel_tank)
			return
		if(!user.transferItemToLoc(src, F))
			return
		src.master = F
		F.fuel_tank = src
		F.update_appearance(UPDATE_ICON)
	else
		return ..()

/obj/item/tank/internals/plasma/full/populate_gas()
	air_contents.set_moles(GAS_PLASMA, (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))

/obj/item/tank/internals/plasma/empty/populate_gas()
	return

/*
 * Plasmaman Plasma Tank
 */

/obj/item/tank/internals/plasmaman
	name = "plasma internals tank"
	desc = "A tank of plasma gas designed specifically for use as internals, particularly for plasma-based lifeforms. If you're not a Plasmaman, you probably shouldn't use this."
	icon_state = "plasmaman_tank"
	item_state = "plasmaman_tank"
	force = 10
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE

/obj/item/tank/internals/plasmaman/populate_gas()
	air_contents.set_moles(GAS_PLASMA, (3*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))

/obj/item/tank/internals/plasmaman/full/populate_gas()
	air_contents.set_moles(GAS_PLASMA, (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))


/obj/item/tank/internals/plasmaman/belt
	icon_state = "plasmaman_tank_belt"
	item_state = "plasmaman_tank_belt"
	slot_flags = ITEM_SLOT_BELT
	force = 5
	volume = 6
	w_class = WEIGHT_CLASS_SMALL //thanks i forgot this

/obj/item/tank/internals/plasmaman/belt/full/populate_gas()
	air_contents.set_moles(GAS_PLASMA, (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))

/obj/item/tank/internals/plasmaman/belt/empty/populate_gas()
	return



/*
 * Emergency Oxygen
 */
/obj/item/tank/internals/emergency_oxygen
	name = "emergency oxygen tank"
	desc = "Used for emergencies. Contains very little oxygen, so try to conserve it until you actually need it."
	icon_state = "emergency"
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	force = 4
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
	volume = 1 //Tiny. Real life equivalents only have 21 breaths of oxygen in them. They're EMERGENCY tanks anyway -errorage (dangercon 2011)


/obj/item/tank/internals/emergency_oxygen/populate_gas()
	air_contents.set_moles(GAS_O2, (10*ONE_ATMOSPHERE)*volume/(R_IDEAL_GAS_EQUATION*T20C))


/obj/item/tank/internals/emergency_oxygen/empty/populate_gas()
	return

/obj/item/tank/internals/emergency_oxygen/engi
	name = "extended-capacity emergency oxygen tank"
	icon_state = "emergency_engi"
	volume = 2 // should last a bit over 30 minutes if full

/obj/item/tank/internals/emergency_oxygen/engi/empty/populate_gas()
	return

/obj/item/tank/internals/emergency_oxygen/double
	name = "double emergency oxygen tank"
	icon_state = "emergency_double"
	item_state = "emergency_engi"
	volume = 8

/obj/item/tank/internals/emergency_oxygen/double/empty/populate_gas()
	return

/obj/item/tank/internals/ipc_coolant
	name = "IPC coolant tank"
	desc = "A tank of cold nitrogen for use as a coolant by IPCs. Not breathable."
	icon_state = "ipc_coolant"
	item_state = "ipc_coolant"
	slot_flags = ITEM_SLOT_BELT
	force = 5
	volume = 6
	w_class = WEIGHT_CLASS_SMALL
	distribute_pressure = 8

/obj/item/tank/internals/ipc_coolant/populate_gas()
	air_contents.set_moles(GAS_N2, (10 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * (T0C - 50)))
	air_contents.set_temperature(T0C - 50)

/obj/item/tank/internals/ipc_coolant/empty/populate_gas()
	return
