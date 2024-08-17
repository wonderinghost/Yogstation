#define REM REAGENTS_EFFECT_MULTIPLIER

GLOBAL_VAR_INIT(global_evaporation_rate, 1)

GLOBAL_LIST_INIT(name2reagent, build_name2reagent())

/proc/build_name2reagent()
	. = list()
	for (var/t in subtypesof(/datum/reagent))
		var/datum/reagent/R = t
		if (length(initial(R.name)))
			.[ckey(initial(R.name))] = t


//Various reagents
//Toxin & acid reagents
//Hydroponics stuff

/// A single reagent
/datum/reagent
	/// datums don't have names by default
	var/name = "Reagent"
	/// nor do they have descriptions
	var/description = ""
	///J/(K*mol)
	var/specific_heat = SPECIFIC_HEAT_DEFAULT
	/// used by taste messages
	var/taste_description = "metaphorical salt"
	///how this taste compares to others. Higher values means it is more noticable
	var/taste_mult = 1
	/// use for specialty drinks.
	var/glass_name = "glass of ...what?"
	/// desc applied to glasses with this reagent
	var/glass_desc = "You can't really tell what this is."
	/// Otherwise just sets the icon to a normal glass with the mixture of the reagents in the glass.
	var/glass_icon_state = null
	/// used for shot glasses, mostly for alcohol
	var/shot_glass_icon_state = null
	/// reagent holder this belongs to
	var/datum/reagents/holder = null
	/// LIQUID, SOLID, GAS
	var/reagent_state = LIQUID
	/// special data associated with this like viruses etc
	var/list/data
	/// increments everytime on_mob_life is called
	var/current_cycle = 0
	///pretend this is moles
	var/volume = 0
	/// color it looks in containers etc
	var/color = "#000000" // rgb: 0, 0, 0
	/// can this reagent be synthesized? (for example: odysseus syringe gun)
	var/can_synth = TRUE
	///how fast the reagent is metabolized by the mob
	var/metabolization_rate = REAGENTS_METABOLISM
	/// appears unused
	var/overrides_metab = 0
	/// above this overdoses happen
	var/overdose_threshold = 0
	/// above this amount addictions start
	var/addiction_threshold = 0
	/// increases as addiction gets worse
	var/addiction_stage = 0
	/// Alternative names used for the drug
	var/addiction_name = null
	/// What biotypes can process this? We'll assume by default that it affects organics (and undead, for plasmemes)
	var/compatible_biotypes = ALL_NON_ROBOTIC
	
	/// You fucked up and this is now triggering its overdose effects, purge that shit quick.
	var/overdosed = 0
	///if false stops metab in liverless mobs
	var/self_consuming = FALSE
	///affects how far it travels when sprayed
	var/reagent_weight = 1
	///is it currently metabolizing
	var/metabolizing = FALSE
	/// is it bad for you? Currently only used for borghypo. C2s and Toxins have it TRUE by default.
	var/harmful = FALSE
	/// The default reagent container for the reagent. Currently only used for crafting icon/displays.
	var/obj/item/reagent_containers/default_container = /obj/item/reagent_containers/glass/bottle
	
	///Whether it will evaporate if left untouched on a liquids simulated puddle
	var/evaporates = TRUE
	/// How flammable is this material? For liquid spills and molotov cocktails
	var/accelerant_quality = 0
	///Whether a fire from this requires oxygen in the atmosphere
	var/fire_needs_oxygen = TRUE
	///The opacity of the chems used to determine the alpha of liquid turfs
	var/opacity = 175
	///The rate of evaporation in units per call
	var/evaporation_rate = 1
	///The rate of evaporation for the entire GROUP per call, for special things like drying agent
	var/group_evaporation_rate = 0
	/// do we have a turf exposure (used to prevent liquids doing un-needed processes)
	var/turf_exposure = FALSE
	/// are we slippery?
	var/slippery = TRUE

/datum/reagent/Destroy() // This should only be called by the holder, so it's already handled clearing its references
	. = ..()
	holder = null

/// Applies this reagent to a [/mob/living]
/datum/reagent/proc/reaction_mob(mob/living/M, methods = TOUCH, reac_volume, show_message = 1, permeability = 1)
	if(!istype(M))
		return 0
	if(methods & VAPOR) //smoke, foam, spray
		if(M.reagents)
			var/modifier = clamp(permeability, 0, 1)
			var/amount = round(max(reac_volume - M.reagents.get_reagent_amount(type), 0) * modifier, 0.1) // no reagent duplication on mobs
			if(amount >= 0.5)
				M.reagents.add_reagent(type, amount)
	return 1

/// Applies this reagent to an [/obj]
/datum/reagent/proc/reaction_obj(obj/O, volume)
	return

/// Applies this reagent to a [/turf]
/datum/reagent/proc/reaction_turf(turf/T, volume)
	return

/// Called from [/datum/reagents/proc/metabolize]
/datum/reagent/proc/on_mob_life(mob/living/carbon/M)
	current_cycle++
	if(holder)
		holder.remove_reagent(type, metabolization_rate * M.metabolism_efficiency) //By default it slowly disappears.
	return

///Called after a reagent is transfered
/datum/reagent/proc/on_transfer(atom/A, methods=TOUCH, trans_volume)

/// Called when this reagent is first added to a mob
/datum/reagent/proc/on_mob_add(mob/living/L)
	return

/// Called when this reagent is removed while inside a mob
/datum/reagent/proc/on_mob_delete(mob/living/L)
	return

/// Called when this reagent first starts being metabolized by a liver
/datum/reagent/proc/on_mob_metabolize(mob/living/L)
	return

/// Called when this reagent stops being metabolized by a liver
/datum/reagent/proc/on_mob_end_metabolize(mob/living/L)
	return

/// Called by [/datum/reagents/proc/conditional_update_move]
/datum/reagent/proc/on_move(mob/M)
	return

/// Called after add_reagents creates a new reagent.
/datum/reagent/proc/on_new(data)
	return

/// Called when two reagents of the same are mixing.
/datum/reagent/proc/on_merge(data)
	return

/// Called by [/datum/reagents/proc/conditional_update]
/datum/reagent/proc/on_update(atom/A)
	return

/// Called when the reagent container is hit by an explosion
/datum/reagent/proc/on_ex_act(severity)
	return

/datum/reagent/proc/evaporate(turf/exposed_turf, reac_volume)
	return

/// Called if the reagent has passed the overdose threshold and is set to be triggering overdose effects
/datum/reagent/proc/overdose_process(mob/living/M)
	return

/// Called when an overdose starts
/datum/reagent/proc/overdose_start(mob/living/M)
	to_chat(M, span_userdanger("You feel like you took too much of [name]!"))
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/overdose, name)
	return

/// Called when addiction hits stage1, see [/datum/reagents/proc/metabolize]
/datum/reagent/proc/addiction_act_stage1(mob/living/M)
	if(!addiction_name)
		addiction_name = name
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/withdrawal_light, addiction_name)
	if(prob(30))

		to_chat(M, span_notice("You feel like having some [addiction_name] right about now."))
	return

/// Called when addiction hits stage2, see [/datum/reagents/proc/metabolize]
/datum/reagent/proc/addiction_act_stage2(mob/living/M)
	if(!addiction_name)
		addiction_name = name
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/withdrawal_medium, addiction_name)
	if(prob(30))
		to_chat(M, span_notice("You feel like you need [addiction_name]. You just can't get enough."))
	return

/// Called when addiction hits stage3, see [/datum/reagents/proc/metabolize]
/datum/reagent/proc/addiction_act_stage3(mob/living/M)
	if(!addiction_name)
		addiction_name = name
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/withdrawal_severe, addiction_name)
	if(prob(30))
		to_chat(M, span_danger("You have an intense craving for [addiction_name]."))
	return

/// Called when addiction hits stage4, see [/datum/reagents/proc/metabolize]
/datum/reagent/proc/addiction_act_stage4(mob/living/M)
	if(!addiction_name)
		addiction_name = name
	SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "[type]_overdose", /datum/mood_event/withdrawal_critical, addiction_name)
	if(prob(30))
		to_chat(M, span_boldannounce("You're not feeling good at all! You really need some [addiction_name]."))
	return

/proc/pretty_string_from_reagent_list(list/reagent_list)
	//Convert reagent list to a printable string for logging etc
	var/list/rs = list()
	for (var/datum/reagent/R in reagent_list)
		rs += "[R.name], [R.volume]"

	return rs.Join(" | ")
