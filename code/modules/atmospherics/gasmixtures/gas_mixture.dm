 /*
What are the archived variables for?
	Calculations are done using the archived variables with the results merged into the regular variables.
	This prevents race conditions that arise based on the order of tile processing.
*/

/**
 *I feel the need to document what happens here. Basically this is used
 *catch rounding errors, and make gas go away in small portions.
 *People have raised it to higher levels in the past, do not do this. Consider this number a soft limit
 *If you're making gasmixtures that have unexpected behavior related to this value, you're doing something wrong.
 *
 *On an unrelated note this may cause a bug that creates negative gas, related to round(). When it has a second arg it will round up.
 *So for instance round(0.5, 1) == 1. I've hardcoded a fix for this into share, by forcing the garbage collect.
 *Any other attempts to fix it just killed atmos. I leave this to a greater man then I
 */
/// The minimum heat capacity of a gas
#define MINIMUM_HEAT_CAPACITY 0.0003
/// Minimum mole count of a gas
#define MINIMUM_MOLE_COUNT 0.01

#define QUANTIZE(variable)		(round(variable,0.0000001))/*I feel the need to document what happens here. Basically this is used to catch most rounding errors, however it's previous value made it so that
															once gases got hot enough, most procedures wouldnt occur due to the fact that the mole counts would get rounded away. Thus, we lowered it a few orders of magnititude */

/datum/gas_mixture
	/// Never ever set this variable, hooked into vv_get_var for view variables viewing.
	var/gas_list_view_only
	var/initial_volume = CELL_VOLUME //liters
	var/list/reaction_results
	var/list/analyzer_results //used for analyzer feedback - not initialized until its used
	var/_extools_pointer_gasmixture // Contains the index in the gas vector for this gas mixture in rust land. Don't. Touch. This. Var.

GLOBAL_VAR_INIT(auxtools_atmos_initialized, FALSE)

/datum/gas_mixture/New(volume)
	if (!isnull(volume))
		initial_volume = volume
	if(!GLOB.auxtools_atmos_initialized && auxtools_atmos_init(GLOB.gas_data))
		GLOB.auxtools_atmos_initialized = TRUE
	__gasmixture_register()
	reaction_results = new

/datum/gas_mixture/Del()
	__gasmixture_unregister()
	. = ..()

/datum/gas_mixture/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, _extools_pointer_gasmixture))
		return FALSE // please no. segfaults bad.
	if(var_name == "gas_list_view_only")
		return FALSE
	return ..()

/datum/gas_mixture/vv_get_var(var_name)
	. = ..()
	if(var_name == "gas_list_view_only")
		var/list/dummy = get_gases()
		for(var/gas in dummy)
			dummy[gas] = get_moles(gas)
			dummy["CAP [gas]"] = partial_heat_capacity(gas)
		dummy["TEMP"] = return_temperature()
		dummy["PRESSURE"] = return_pressure()
		dummy["HEAT CAPACITY"] = heat_capacity()
		dummy["TOTAL MOLES"] = total_moles()
		dummy["VOLUME"] = return_volume()
		dummy["THERMAL ENERGY"] = thermal_energy()
		return debug_variable("gases (READ ONLY)", dummy, 0, src)

/datum/gas_mixture/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---")
	VV_DROPDOWN_OPTION(VV_HK_PARSE_GASSTRING, "Parse Gas String")
	VV_DROPDOWN_OPTION(VV_HK_EMPTY, "Empty")
	VV_DROPDOWN_OPTION(VV_HK_SET_MOLES, "Set Moles")
	VV_DROPDOWN_OPTION(VV_HK_SET_TEMPERATURE, "Set Temperature")
	VV_DROPDOWN_OPTION(VV_HK_SET_VOLUME, "Set Volume")

/datum/gas_mixture/vv_do_topic(list/href_list)
	. = ..()
	if(!.)
		return
	if(href_list[VV_HK_PARSE_GASSTRING])
		var/gasstring = input(usr, "Input Gas String (WARNING: Advanced. Don't use this unless you know how these work.", "Gas String Parse") as text|null
		if(!istext(gasstring))
			return
		log_admin("[key_name(usr)] modified gas mixture [REF(src)]: Set to gas string [gasstring].")
		message_admins("[key_name(usr)] modified gas mixture [REF(src)]: Set to gas string [gasstring].")
		parse_gas_string(gasstring)
	if(href_list[VV_HK_EMPTY])
		log_admin("[key_name(usr)] emptied gas mixture [REF(src)].")
		message_admins("[key_name(usr)] emptied gas mixture [REF(src)].")
		clear()
	if(href_list[VV_HK_SET_MOLES])
		var/list/gases = get_gases()
		for(var/gas in gases)
			gases[gas] = get_moles(gas)
		var/gasid = input(usr, "What kind of gas?", "Set Gas") as null|anything in GLOB.gas_data.ids
		if(!gasid)
			return
		var/amount = input(usr, "Input amount", "Set Gas", gases[gasid] || 0) as num|null
		if(!isnum(amount))
			return
		amount = max(0, amount)
		log_admin("[key_name(usr)] modified gas mixture [REF(src)]: Set gas [gasid] to [amount] moles.")
		message_admins("[key_name(usr)] modified gas mixture [REF(src)]: Set gas [gasid] to [amount] moles.")
		set_moles(gasid, amount)
	if(href_list[VV_HK_SET_TEMPERATURE])
		var/temp = input(usr, "Set the temperature of this mixture to?", "Set Temperature", return_temperature()) as num|null
		if(!isnum(temp))
			return
		temp = max(2.7, temp)
		log_admin("[key_name(usr)] modified gas mixture [REF(src)]: Changed temperature to [temp].")
		message_admins("[key_name(usr)] modified gas mixture [REF(src)]: Changed temperature to [temp].")
		set_temperature(temp)
	if(href_list[VV_HK_SET_VOLUME])
		var/volume = input(usr, "Set the volume of this mixture to?", "Set Volume", return_volume()) as num|null
		if(!isnum(volume))
			return
		volume = max(0, volume)
		log_admin("[key_name(usr)] modified gas mixture [REF(src)]: Changed volume to [volume].")
		message_admins("[key_name(usr)] modified gas mixture [REF(src)]: Changed volume to [volume].")
		set_volume(volume)

/proc/gas_types()
	var/list/L = subtypesof(/datum/gas)
	for(var/gt in L)
		var/datum/gas/G = gt
		L[gt] = initial(G.specific_heat)
	return L

/datum/gas_mixture/proc/get_last_share()

/datum/gas_mixture/proc/archive()
	//Update archived versions of variables
	//Returns: 1 in all cases


/datum/gas_mixture/proc/remove(amount)
	//Proportionally removes amount of gas from the gas_mixture
	//Returns: gas_mixture with the gases removed

/datum/gas_mixture/proc/remove_by_flag(flag, amount)
	//Removes amount of gas from the gas mixture by flag
	//Returns: gas_mixture with gases that match the flag removed

/datum/gas_mixture/proc/remove_ratio(ratio)
	//Proportionally removes amount of gas from the gas_mixture
	//Returns: gas_mixture with the gases removed

/datum/gas_mixture/proc/copy()
	//Creates new, identical gas mixture
	//Returns: duplicate gas mixture

/datum/gas_mixture/proc/copy_from_turf(turf/model)
	//Copies all gas info from the turf into the gas list along with temperature
	//Returns: 1 if we are mutable, 0 otherwise

/datum/gas_mixture/proc/parse_gas_string(gas_string)
	//Copies variables from a particularly formatted string.
	//Returns: 1 if we are mutable, 0 otherwise

/datum/gas_mixture/proc/share(datum/gas_mixture/sharer)
	//Performs air sharing calculations between two gas_mixtures assuming only 1 boundary length
	//Returns: amount of gas exchanged (+ if sharer received)

/datum/gas_mixture/remove_by_flag(flag, amount)
	var/datum/gas_mixture/removed = new type
	__remove_by_flag(removed, flag, amount)

	return removed

/datum/gas_mixture/remove(amount)
	var/datum/gas_mixture/removed = new type
	__remove(removed, amount)

	return removed

/datum/gas_mixture/remove_ratio(ratio)
	var/datum/gas_mixture/removed = new type
	__remove_ratio(removed, ratio)

	return removed

/datum/gas_mixture/copy()
	var/datum/gas_mixture/copy = new type
	copy.copy_from(src)

	return copy

/datum/gas_mixture/copy_from_turf(turf/model)
	set_temperature(initial(model.initial_temperature))
	parse_gas_string(model.initial_gas_mix)
	return 1

/datum/gas_mixture/parse_gas_string(gas_string)
	__auxtools_parse_gas_string(gas_string)
	/*
	var/list/gas = params2list(gas_string)
	if(gas["TEMP"])
		var/temp = text2num(gas["TEMP"])
		gas -= "TEMP"
		if(!isnum(temp) || temp < 2.7)
			temp = 2.7
		set_temperature(temp)
	clear()
	for(var/id in gas)
		set_moles(id, text2num(gas[id]))
	return 1
	*/

/datum/gas_mixture/proc/set_analyzer_results(instability)
	if(!analyzer_results)
		analyzer_results = new
	analyzer_results["fusion"] = instability

//Mathematical proofs:
/*
get_breath_partial_pressure(gas_pp) --> gas_pp/total_moles()*breath_pp = pp
get_true_breath_pressure(pp) --> gas_pp = pp/breath_pp*total_moles()

10/20*5 = 2.5
10 = 2.5/5*20
*/

/datum/gas_mixture/turf

/// Releases gas from src to output air. This means that it can not transfer air to gas mixture with higher pressure.
/datum/gas_mixture/proc/release_gas_to(datum/gas_mixture/output_air, target_pressure)
	var/output_starting_pressure = output_air.return_pressure()
	var/input_starting_pressure = return_pressure()

	if(output_starting_pressure >= min(target_pressure,input_starting_pressure-10))
		//No need to pump gas if target is already reached or input pressure is too low
		//Need at least 10 kPa difference to overcome friction in the mechanism
		return FALSE

	//Calculate necessary moles to transfer using PV = nRT
	if((total_moles() > 0) && (return_temperature()>0))
		var/pressure_delta = min(target_pressure - output_starting_pressure, (input_starting_pressure - output_starting_pressure)/2)
		//Can not have a pressure delta that would cause output_pressure > input_pressure

		var/transfer_moles = pressure_delta*output_air.return_volume()/(return_temperature() * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = remove(transfer_moles)
		output_air.merge(removed)
		return TRUE
	return FALSE

/datum/gas_mixture/proc/vv_react(datum/holder)
	return react(holder)

/datum/gas_mixture/proc/remove_specific_ratio(gas_id, ratio)
	if(ratio <= 0)
		return null
	ratio = min(ratio, 1)

	var/datum/gas_mixture/removed = new

	removed.set_temperature(return_temperature())

	var/current_moles = get_moles(gas_id)
	var/moles_to_remove = QUANTIZE(current_moles * ratio)
	var/moles_left = current_moles - moles_to_remove

	// sanitize moles to ensure we aren't writing any invalid or tiny values
	moles_left = clamp(moles_left, 0, current_moles)
	if (moles_left < MINIMUM_MOLE_COUNT)
		moles_left = 0
		moles_to_remove = current_moles

	removed.set_moles(gas_id, moles_to_remove)
	set_moles(gas_id, moles_left)

	return removed

///Distributes the contents of two mixes equally between themselves
//Returns: bool indicating whether gases moved between the two mixes
/datum/gas_mixture/proc/equalize(datum/gas_mixture/other)
	. = FALSE

	if(!return_volume() || !other.return_volume())
		return

	var/self_temp = return_temperature()
	var/other_temp = other.return_temperature()
	if(abs(self_temp - other_temp) > MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND)
		. = TRUE
		var/self_heat_cap = heat_capacity()
		var/other_heat_cap = other.heat_capacity()
		var/new_temp = max((self_temp * self_heat_cap + other_temp * other_heat_cap) / (self_heat_cap + other_heat_cap), TCMB)
		set_temperature(new_temp)
		other.set_temperature(new_temp)

	var/min_p_delta = 0.1
	var/total_volume = return_volume() + other.return_volume()
	var/list/gas_list = get_gases() | other.get_gases()
	for(var/gas_id in gas_list)
		//math is under the assumption temperatures are equal
		var/self_moles = get_moles(gas_id)
		var/other_moles = other.get_moles(gas_id)
		
		if(abs(self_moles / return_volume() - other_moles / other.return_volume()) > min_p_delta / (R_IDEAL_GAS_EQUATION * return_temperature()))
			. = TRUE
			var/total_moles = self_moles + other_moles
			set_moles(gas_id, total_moles * (return_volume() / total_volume))
			other.set_moles(gas_id, total_moles * (other.return_volume() / total_volume))
