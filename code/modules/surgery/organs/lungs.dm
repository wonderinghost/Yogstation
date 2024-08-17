/obj/item/organ/lungs
	var/failed = FALSE
	var/operated = FALSE	//whether we can still have our damages fixed through surgery
	name = "lungs"
	icon_state = "lungs"
	visual = FALSE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LUNGS
	gender = PLURAL
	w_class = WEIGHT_CLASS_SMALL

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY * 0.9 // fails around 16.5 minutes, lungs are one of the last organs to die (of the ones we have)

	high_threshold_passed = span_warning("You feel some sort of constriction around your chest as your breathing becomes shallow and rapid.")
	now_fixed = span_warning("Your lungs seem to once again be able to hold air.")
	high_threshold_cleared = span_info("The constriction around your chest loosens as your breathing calms down.")

	//Breath damage

	var/breathing_class = BREATH_OXY // can be a gas instead of a breathing class
	var/safe_breath_min = 16
	var/safe_breath_max = 50
	var/safe_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/safe_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/safe_damage_type = OXY
	var/list/gas_min = list()
	var/list/gas_max = list(
		GAS_CO2 = 30, // Yes it's an arbitrary value who cares?
		GAS_PLASMA = MOLES_GAS_VISIBLE,
	)
	var/list/gas_damage = list(
		"default" = list(
			min = MIN_TOXIC_GAS_DAMAGE,
			max = MAX_TOXIC_GAS_DAMAGE,
			damage_type = OXY,
		),
		GAS_PLASMA = list(
			min = MIN_TOXIC_GAS_DAMAGE,
			max = MAX_TOXIC_GAS_DAMAGE,
			damage_type = TOX,
		)
	)

	var/SA_para_min = 1 //nitrous values
	var/SA_sleep_min = 5
	var/BZ_trip_balls_min = 1 //BZ gas
	var/gas_stimulation_min = 0.002 // Nitrium, Freon and Hyper-noblium
	/// Whether helium speech effects are currently active
	var/helium_speech = FALSE

	var/cold_message = "your face freezing and an icicle forming"
	var/cold_level_1_threshold = 260
	var/cold_level_2_threshold = 200
	var/cold_level_3_threshold = 120
	var/cold_level_1_damage = COLD_GAS_DAMAGE_LEVEL_1 //Keep in mind with gas damage levels, you can set these to be negative, if you want someone to heal, instead.
	var/cold_level_2_damage = COLD_GAS_DAMAGE_LEVEL_2
	var/cold_level_3_damage = COLD_GAS_DAMAGE_LEVEL_3
	var/cold_damage_type = BURN

	var/hot_message = "your face burning and a searing heat"
	var/heat_level_1_threshold = 360
	var/heat_level_2_threshold = 400
	var/heat_level_3_threshold = 1000
	var/heat_level_1_damage = HEAT_GAS_DAMAGE_LEVEL_1
	var/heat_level_2_damage = HEAT_GAS_DAMAGE_LEVEL_2
	var/heat_level_3_damage = HEAT_GAS_DAMAGE_LEVEL_3
	var/heat_damage_type = BURN

	var/crit_stabilizing_reagent = /datum/reagent/medicine/epinephrine

/obj/item/organ/lungs/Initialize(mapload)
	. = ..()
	populate_gas_info()

/obj/item/organ/lungs/proc/populate_gas_info()
	gas_min[breathing_class] = safe_breath_min
	gas_max[breathing_class] = safe_breath_max
	gas_damage[breathing_class] = list(
		min = safe_breath_dam_min,
		max = safe_breath_dam_max,
		damage_type = safe_damage_type
	)
	if(ispath(breathing_class))
		var/datum/breathing_class/class = GLOB.gas_data.breathing_classes[breathing_class]
		for(var/g in class.gases)
			if(class.gases[g] > 0)
				gas_min -= g

/obj/item/organ/lungs/proc/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/H)
	var/breathModifier = (5-(5*(damage/maxHealth)/2)) //range 2.5 - 5
	if(H.status_flags & GODMODE)
		return
	if(HAS_TRAIT(H, TRAIT_NOBREATH))
		return

	if(!breath || (breath.total_moles() == 0))
		if(H.reagents.has_reagent(crit_stabilizing_reagent, needs_metabolizing = TRUE))
			return
		if(H.health >= H.crit_threshold)
			H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		else if(!HAS_TRAIT(H, TRAIT_NOCRITDAMAGE))
			H.adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)

		H.failed_last_breath = TRUE
		var/alert_category
		var/alert_type
		if(ispath(breathing_class))
			var/datum/breathing_class/class = GLOB.gas_data.breathing_classes[breathing_class]
			alert_category = class.low_alert_category
			alert_type = class.low_alert_datum
		else
			var/list/breath_alert_info = GLOB.gas_data.breath_alert_info
			if(breathing_class in breath_alert_info)
				var/list/alert = breath_alert_info[breathing_class]["not_enough_alert"]
				alert_category = alert["alert_category"]
				alert_type = alert["alert_type"]
		if(alert_category)
			H.throw_alert(alert_category, alert_type)
		var/list/too_much_gas_alerts = list()
		for(var/gas in gas_max)
			var/gas_alert_category
			if(ispath(gas))
				var/datum/breathing_class/breathclass = gas
				gas_alert_category = breathclass.high_alert_category
			else
				gas_alert_category = GLOB.gas_data.breath_alert_info[gas]["too_much_alert"]["alert_category"]
			too_much_gas_alerts += gas_alert_category
		for(var/alert as anything in too_much_gas_alerts)
			H.clear_alert(alert)
		return FALSE

	#define PP_MOLES(X) ((X / total_moles) * pressure)

	#define PP(air, gas) PP_MOLES(air.get_moles(gas))

	var/gas_breathed = 0
	var/eff = get_organ_efficiency()

	var/pressure = breath.return_pressure()
	var/total_moles = breath.total_moles()
	var/list/breath_alert_info = GLOB.gas_data.breath_alert_info
	var/list/breath_results = GLOB.gas_data.breath_results
	var/list/breathing_classes = GLOB.gas_data.breathing_classes
	var/list/mole_adjustments = list()
	for(var/entry in gas_min)
		var/required_pp = 0
		var/required_moles = 0
		var/safe_min = gas_min[entry]
		var/alert_category = null
		var/alert_type = null
		if(ispath(entry))
			var/datum/breathing_class/class = breathing_classes[entry]
			var/list/gases = class.gases
			var/list/products = class.products
			alert_category = class.low_alert_category
			alert_type = class.low_alert_datum
			for(var/gas in gases)
				var/moles = breath.get_moles(gas)
				var/multiplier = gases[gas]
				mole_adjustments[gas] = (gas in mole_adjustments) ? mole_adjustments[gas] - moles : -moles
				required_pp += PP_MOLES(moles) * multiplier
				required_moles += moles
				if(multiplier > 0)
					var/to_add = moles * multiplier
					for(var/product in products)
						mole_adjustments[product] = (product in mole_adjustments) ? mole_adjustments[product] + to_add : to_add
		else
			required_moles = breath.get_moles(entry)
			required_pp = PP_MOLES(required_moles)
			if(entry in breath_alert_info)
				var/list/alert = breath_alert_info[entry]["not_enough_alert"]
				alert_category = alert["alert_category"]
				alert_type = alert["alert_type"]
			mole_adjustments[entry] = -required_moles
			mole_adjustments[breath_results[entry]] = required_moles
		if(required_pp < safe_min)
			var/multiplier = handle_too_little_breath(H, required_pp, safe_min, required_moles)
			if(required_moles > 0)
				multiplier /= required_moles
			for(var/adjustment in mole_adjustments)
				mole_adjustments[adjustment] *= multiplier
			if(alert_category)
				H.throw_alert(alert_category, alert_type)
		else
			H.failed_last_breath = FALSE
			if(H.health >= H.crit_threshold)
				H.adjustOxyLoss(-breathModifier)
			if(alert_category)
				H.clear_alert(alert_category)
	var/list/danger_reagents = GLOB.gas_data.breath_reagents_dangerous
	for(var/entry in gas_max)
		var/found_pp = 0
		var/datum/breathing_class/breathing_class = entry
		var/datum/reagent/danger_reagent = null
		var/alert_category = null
		var/alert_type = null
		if(ispath(breathing_class))
			breathing_class = breathing_classes[breathing_class]
			alert_category = breathing_class.high_alert_category
			alert_type = breathing_class.high_alert_datum
			danger_reagent = breathing_class.danger_reagent
			found_pp = breathing_class.get_effective_pp(breath)
		else
			danger_reagent = danger_reagents[entry]
			if(entry in breath_alert_info)
				var/list/alert = breath_alert_info[entry]["too_much_alert"]
				alert_category = alert["alert_category"]
				alert_type = alert["alert_type"]
			found_pp = PP(breath, entry)
		if(found_pp > gas_max[entry])
			if(istype(danger_reagent))
				H.reagents.add_reagent(danger_reagent,1)
			var/list/damage_info = (entry in gas_damage) ? gas_damage[entry] : gas_damage["default"]
			var/dam = found_pp / gas_max[entry] * 10
			H.apply_damage_type(clamp(dam, damage_info["min"], damage_info["max"]), damage_info["damage_type"])
			if(alert_category && alert_type)
				H.throw_alert(alert_category, alert_type)
		else if(alert_category)
			H.clear_alert(alert_category)

	// Handle gases that give you reagents
	var/mole_ratio
	var/breath_reagent_type // define these here to speed it up a bit
	var/datum/reagent/breath_reagent
	for(var/gas in breath.get_gases())
		breath_reagent_type = GLOB.gas_data.breath_reagents[gas]
		mole_ratio = eff * breath.get_moles(gas) / gas_stimulation_min
		if(breath_reagent_type && mole_ratio > 1)
			breath_reagent = new breath_reagent_type()
			breath_reagent.reaction_mob(H, VAPOR|BREATH, 2*mole_ratio)
			breath.set_moles(gas, 0) // absorbed into the lungs

	//-- TRACES --//

	if(breath)	// If there's some other shit in the air lets deal with it here.

	//yogs start -- Adds Nitrogen Narcosis
	//NITROGEN
		var/N2_pp = PP(breath, GAS_N2)
		if(N2_pp > NITROGEN_NARCOSIS_PRESSURE_LOW) // Giggles
			if(prob(20))
				INVOKE_ASYNC(H, TYPE_PROC_REF(/mob/living/carbon/human, emote), pick("giggle","laugh"))
			if(N2_pp > NITROGEN_NARCOSIS_PRESSURE_HIGH) // Hallucinations
				if(prob(15))
					to_chat(H, span_userdanger("You can't think straight!"))
					H.adjust_confusion_up_to(N2_pp / 10, 12 SECONDS)
				H.adjust_hallucinations(5 SECONDS)
	//yogs end

	// N2O

		var/SA_pp = PP(breath, GAS_NITROUS)
		if(SA_pp > SA_para_min) // Enough to make us stunned for a bit
			H.Unconscious(60) // 60 gives them one second to wake up and run away a bit!
			if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
				H.Sleeping(max(H.AmountSleeping() + 40, 200))
				ADD_TRAIT(owner, TRAIT_SURGERY_PREPARED, GAS_NITROUS)
		else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
			if(prob(20))
				H.emote(pick("giggle", "laugh"))
				SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "chemical_euphoria", /datum/mood_event/chemical_euphoria)
		else
			SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "chemical_euphoria")
			REMOVE_TRAIT(owner, TRAIT_SURGERY_PREPARED, GAS_NITROUS)


	// BZ

		var/bz_pp = PP(breath, GAS_BZ)
		if(bz_pp > BZ_trip_balls_min)
			H.adjust_hallucinations(10 SECONDS)
			H.reagents.add_reagent(/datum/reagent/bz_metabolites,5)
			if(prob(33))
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150)

		else if(bz_pp > 0.01)
			H.adjust_hallucinations(5 SECONDS)
			H.reagents.add_reagent(/datum/reagent/bz_metabolites,1)

	// Pluonium
		// Inert

	// Zauker
		var/zauker_pp = PP(breath,GAS_ZAUKER)
		if(zauker_pp > safe_breath_max)
			H.adjustBruteLoss(25)
			H.adjustOxyLoss(5)
			H.adjustFireLoss(8)
			H.adjustToxLoss(8)
		gas_breathed = breath.get_moles(GAS_ZAUKER)
		breath.adjust_moles(GAS_ZAUKER, -gas_breathed)

	// Miasma
		if (breath.get_moles(GAS_MIASMA))
			var/miasma_pp = PP(breath,GAS_MIASMA)

			//Miasma sickness
			if(prob(0.5 * miasma_pp))
				var/datum/disease/advance/miasma_disease = new /datum/disease/advance/random(2, 3)
				miasma_disease.name = "Unknown"
				miasma_disease.try_infect(owner)

			// Miasma side effects
			switch(miasma_pp)
				if(0.25 to 5)
					// At lower pp, give out a little warning
					SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "smell")
					if(prob(5))
						to_chat(owner, span_notice("There is an unpleasant smell in the air."))
				if(5 to 15)
					//At somewhat higher pp, warning becomes more obvious
					if(prob(15))
						to_chat(owner, span_warning("You smell something horribly decayed inside this room."))
						SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/bad_smell)
				if(15 to 30)
					//Small chance to vomit. By now, people have internals on anyway
					if(prob(5))
						to_chat(owner, span_warning("The stench of rotting carcasses is unbearable!"))
						SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/nauseating_stench)
						owner.vomit()
				if(30 to INFINITY)
					//Higher chance to vomit. Let the horror start
					if(prob(15))
						to_chat(owner, span_warning("The stench of rotting carcasses is unbearable!"))
						SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/nauseating_stench)
						owner.vomit()
				else
					SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "smell")

			// In a full miasma atmosphere with 101.34 pKa, about 10 disgust per breath, is pretty low compared to threshholds
			// Then again, this is a purely hypothetical scenario and hardly reachable
			owner.adjust_disgust(0.1 * miasma_pp)

			breath.adjust_moles(GAS_MIASMA, -gas_breathed)

		// Clear out moods when no miasma at all
		else
			SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "smell")

		handle_breath_temperature(breath, H)
	return TRUE


/obj/item/organ/lungs/proc/handle_too_little_breath(mob/living/carbon/human/H = null, breath_pp = 0, safe_breath_min = 0, true_pp = 0)
	. = 0
	if(!H || !safe_breath_min) //the other args are either: Ok being 0 or Specifically handled.
		return FALSE

	if(prob(20))
		H.emote("gasp")
	if(breath_pp > 0)
		var/ratio = safe_breath_min/breath_pp
		H.adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS)) // Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!
		H.failed_last_breath = TRUE
		. = true_pp*ratio/6
	else
		H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		H.failed_last_breath = TRUE


/obj/item/organ/lungs/proc/handle_breath_temperature(datum/gas_mixture/breath, mob/living/carbon/human/H) // called by human/life, handles temperatures
	var/breath_temperature = breath.return_temperature()

	if(!HAS_TRAIT(H, TRAIT_RESISTCOLD)) // COLD DAMAGE
		var/cold_modifier = H.dna.species.coldmod
		if(breath_temperature < cold_level_3_threshold)
			H.apply_damage_type(cold_level_3_damage*cold_modifier, cold_damage_type)
		if(breath_temperature > cold_level_3_threshold && breath_temperature < cold_level_2_threshold)
			H.apply_damage_type(cold_level_2_damage*cold_modifier, cold_damage_type)
		if(breath_temperature > cold_level_2_threshold && breath_temperature < cold_level_1_threshold)
			H.apply_damage_type(cold_level_1_damage*cold_modifier, cold_damage_type)
		if(breath_temperature < cold_level_1_threshold)
			if(prob(20))
				to_chat(H, span_warning("You feel [cold_message] in your [name]!"))

	if(!HAS_TRAIT(H, TRAIT_RESISTHEAT)) // HEAT DAMAGE
		var/heat_modifier = H.dna.species.heatmod
		if(breath_temperature > heat_level_1_threshold && breath_temperature < heat_level_2_threshold)
			H.apply_damage_type(heat_level_1_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_2_threshold && breath_temperature < heat_level_3_threshold)
			H.apply_damage_type(heat_level_2_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_3_threshold)
			H.apply_damage_type(heat_level_3_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_1_threshold)
			if(prob(20))
				to_chat(H, span_warning("You feel [hot_message] in your [name]!"))

/obj/item/organ/lungs/on_life()
	..()
	if((!failed) && ((organ_flags & ORGAN_FAILING)))
		if(owner.stat == CONSCIOUS)
			owner.visible_message(span_userdanger("[owner] grabs [owner.p_their()] throat, struggling for breath!"))
		failed = TRUE
	else if(!(organ_flags & ORGAN_FAILING))
		failed = FALSE
	return

/obj/item/organ/lungs/attackby(obj/item/W, mob/user, params)
	if(!(organ_flags & ORGAN_SYNTHETIC) && organ_efficiency == 1 && W.tool_behaviour == TOOL_CROWBAR)
		user.visible_message(span_notice("[user] extends [src] with [W]!"), span_notice("You use [W] to extend [src]!"), "You hear something stretching.")
		name = "extended [name]"
		icon_state += "-crobar" //shh! don't tell anyone i handed you this card
		safe_breath_min *= 2 //SCREAM LOUDER i dont know maybe eventually
		safe_breath_max *= 2 //BREATHE HARDER
		for(var/gas in gas_min)
			gas_min[gas] *= 2
		for(var/gas in gas_max)
			gas_max[gas] *= 2
		organ_efficiency *= 2 //HOLD YOUR BREATH FOR REALLY LONG
		maxHealth *= 0.5 //This procedure is not legal but i will do it for you

/obj/item/organ/lungs/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent(/datum/reagent/medicine/salbutamol, 5)
	return S

/obj/item/organ/lungs/get_availability(datum/species/species)
	return !(TRAIT_NOBREATH in species.inherent_traits)

/obj/item/organ/lungs/ipc
	name = "cooling radiator"
	desc = "A radiator in the shape of a lung used to exchange heat to cool down"
	icon_state = "lungs-c"
	organ_flags = ORGAN_SYNTHETIC
	compatible_biotypes = MOB_ROBOTIC // no more humans with IPC lungs, that's just silly
	status = ORGAN_ROBOTIC
	COOLDOWN_DECLARE(last_message)

/obj/item/organ/lungs/ipc/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/H)
	if(H.status_flags & GODMODE)
		return
	if(HAS_TRAIT(H, TRAIT_NOBREATH))
		return

	var/total_heat_capacity = 0
	if(!breath || (breath.total_moles() == 0)) // Space
		H.throw_alert("not_enough_oxy", /atom/movable/screen/alert/not_enough_oxy/ipc)
		if(COOLDOWN_FINISHED(src, last_message))
			to_chat(H, span_boldwarning("Warning: Cooling subsystem offline!"))
			COOLDOWN_START(src, last_message, 30 SECONDS)
		H.adjust_bodytemperature(40, max_temp = 500)
		H.failed_last_breath = TRUE
		return FALSE
	var/temperature = breath.return_temperature()
	for(var/id in breath.get_gases())
		var/moles = breath.get_moles(id)
		total_heat_capacity += GLOB.gas_data.specific_heats[id] * moles
	// Normal atmos is 0.416
	// 20C -> 293K
	// At about 50C overheating will begin
	// At 70C burn damage will start happening
	breath.remove(breath.total_moles()) // Remove as exhaust or whatever
	if(total_heat_capacity > 0)
		var/ipc_heat_capacity = 20 * ONE_ATMOSPHERE * BREATH_VOLUME / (R_IDEAL_GAS_EQUATION * T20C) // balanced to have an equilibrium of around 40C with one atmosphere of air at room temperature, not accounting for passive cooling/heating from the environment
		var/heat_generation = 10 + ((temperature - (H.bodytemperature + 10)) * organ_efficiency * total_heat_capacity / (total_heat_capacity + ipc_heat_capacity)) // heat up by 20 kelvin while being cooled by the gas
		H.adjust_bodytemperature(heat_generation, 73, 500)
		if(heat_generation > 0 && H.bodytemperature > T0C+50) // not dispelling enough heat
			H.throw_alert("not_enough_oxy", /atom/movable/screen/alert/not_enough_oxy/ipc)
			if(COOLDOWN_FINISHED(src, last_message))
				to_chat(H, span_boldwarning("Warning: System overheating!"))
				COOLDOWN_START(src, last_message, 30 SECONDS)
			H.failed_last_breath = TRUE
		else
			H.failed_last_breath = FALSE
			H.clear_alert("not_enough_oxy")
	else // backup but should be impossible to ever run
		if(COOLDOWN_FINISHED(src, last_message))
			to_chat(H, span_boldwarning("Warning: System overheating!"))
			COOLDOWN_START(src, last_message, 30 SECONDS)
		H.adjust_bodytemperature(40, max_temp = 500)
		H.failed_last_breath = TRUE

/obj/item/organ/lungs/plasmaman
	name = "plasma filter"
	desc = "A spongy rib-shaped mass for filtering plasma from the air."
	icon_state = "lungs-plasma"

	breathing_class = BREATH_PLASMA

/obj/item/organ/lungs/plasmaman/populate_gas_info()
	..()
	gas_max -= GAS_PLASMA

/obj/item/organ/lungs/xeno
	name = "devolved plasma vessel"
	desc = "A lung-shaped organ vaguely similar to a plasma vessel, restructured from a storage system to a respiratory one."
	icon_state = "lungs-x"
	breathing_class = /datum/breathing_class/oxygen_plas

	heat_level_1_threshold = 313
	heat_level_2_threshold = 353
	heat_level_3_threshold = 600

/obj/item/organ/lungs/xeno/populate_gas_info()
	..()
	gas_max -= GAS_PLASMA
	gas_damage -= GAS_PLASMA

/obj/item/organ/lungs/slime
	name = "vacuole"
	desc = "A large organelle designed to store oxygen and other important gasses."

/obj/item/organ/lungs/slime/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/H)
	. = ..()
	if (breath)
		var/total_moles = breath.total_moles()
		var/pressure = breath.return_pressure()
		var/plasma_pp = PP(breath, GAS_PLASMA)
		owner.blood_volume += (0.2 * plasma_pp) // 10/s when breathing literally nothing but plasma, which will suffocate you.

/obj/item/organ/lungs/ghetto
	name = "oxygen tanks welded to a modular receiver"
	desc = "A pair of oxygen tanks which have been attached to a modular (oxygen) receiver. They are incapable of supplying air, but can work as a replacement for lungs."
	icon_state = "lungs-g"
	organ_efficiency = 0.5
	organ_flags = ORGAN_SYNTHETIC //the moment i understood the weakness of flesh, it disgusted me, and i yearned for the certainty, of steel

/obj/item/organ/lungs/cybernetic
	name = "cybernetic lungs"
	desc = "A cybernetic version of the lungs found in traditional humanoid entities. Slightly more effecient than organic lungs."
	icon_state = "lungs-c"
	organ_flags = ORGAN_SYNTHETIC
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	organ_efficiency = 1.5
	safe_breath_min = 13
	safe_breath_max = 100

/obj/item/organ/lungs/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	owner.losebreath = 2 * severity

/obj/item/organ/lungs/cybernetic/upgraded
	name = "upgraded cybernetic lungs"
	desc = "A more advanced version of the stock cybernetic lungs, more efficient at, well, breathing. Features higher temperature tolerances and the ability to filter out most potentially harmful gases."
	icon_state = "lungs-c-u"
	safe_breath_min = 4
	safe_breath_max = 250
	gas_max = list(
		GAS_PLASMA = 30,
		GAS_CO2 = 30
	)
	maxHealth = 3 * STANDARD_ORGAN_THRESHOLD
	organ_efficiency = 2
	SA_para_min = 3
	SA_sleep_min = 6
	BZ_trip_balls_min = 2

	cold_level_1_threshold = 200
	cold_level_2_threshold = 140
	cold_level_3_threshold = 80

	heat_level_1_threshold = 500
	heat_level_2_threshold = 800
	heat_level_3_threshold = 1400

// ELECTROLYZER LUNGS!!!!!
/obj/item/organ/lungs/ethereal
	name = "aeration reticulum"
	desc = "These exotic lungs seem crunchier than most."
	icon_state = "lungs-ethereal"
	breathing_class = /datum/breathing_class/oxygen_vapor

/obj/item/organ/lungs/ethereal/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/H)
	. = ..()
	var/electrolysis = breath.get_moles(GAS_H2O)
	if(electrolysis)
		breath.adjust_moles(GAS_H2O, -electrolysis)
		breath.adjust_moles(GAS_H2, electrolysis)
		breath.adjust_moles(GAS_O2, electrolysis/2)
