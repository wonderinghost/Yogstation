/client/proc/spawn_liquid()
	set category = "Misc.Unused"
	set name = "Spawn Liquid"
	set desc = "Spawns an amount of chosen liquid at your current location."

	var/choice
	var/valid_id
	while(!valid_id)
		choice = stripped_input(usr, "Enter the ID of the reagent you want to add.", "Search reagents")
		if(isnull(choice)) //Get me out of here!
			break
		if (!ispath(text2path(choice)))
			choice = pick_closest_path(choice, make_types_fancy(subtypesof(/datum/reagent)))
			if (ispath(choice))
				valid_id = TRUE
		else
			valid_id = TRUE
		if(!valid_id)
			to_chat(usr, span_warning("A reagent with that ID doesn't exist!"))
	if(!choice)
		return
	var/volume = input(usr, "Volume:", "Choose volume") as num
	if(!volume)
		return
	if(volume >= 100000)
		to_chat(usr, span_warning("Please limit the volume to below 100000 units!"))
		return
	var/turf/epicenter = get_turf(mob)
	epicenter.add_liquid(choice, volume, FALSE, 300)
	message_admins("[ADMIN_LOOKUPFLW(usr)] spawned liquid at [epicenter.loc] ([choice] - [volume]).")
	log_admin("[key_name(usr)] spawned liquid at [epicenter.loc] ([choice] - [volume]).")

/client/proc/remove_liquid()
	set name = "Remove Liquids"
	set category = "Misc.Unused"
	set desc = "Removes liquids in a specified radius."
	var/turf/epicenter = get_turf(mob)

	var/range = input(usr, "Enter range:", "Range selection", 2) as num

	for(var/obj/effect/abstract/liquid_turf/liquid in range(range, epicenter))
		if(QDELETED(liquid))
			continue
		if(!liquid)
			continue
		if(!liquid.liquid_group)
			continue
		liquid.liquid_group.remove_any(liquid, liquid.liquid_group.reagents_per_turf)
		qdel(liquid)

	message_admins("[key_name_admin(usr)] removed liquids with range [range] in [epicenter.loc.name]")
	log_game("[key_name_admin(usr)] removed liquids with range [range] in [epicenter.loc.name]")



/client/proc/change_ocean()
	set category = "Admin.Fun"
	set name = "Change Ocean Liquid"
	set desc = "Changes the reagent of the ocean."


	var/choice = tgui_input_list(usr, "Choose a reagent", "Ocean Reagent", subtypesof(/datum/reagent))
	if(!choice)
		return
	var/datum/reagent/chosen_reagent = choice
	var/rebuilt = FALSE
	for(var/turf/open/floor/plating/ocean/listed_ocean as anything in SSliquids.ocean_turfs)
		if(!rebuilt)
			listed_ocean.ocean_reagents = list()
			listed_ocean.ocean_reagents[chosen_reagent] = 10
			listed_ocean.static_overlay.mix_colors(listed_ocean.ocean_reagents)
			for(var/area/ocean/ocean_types in GLOB.initalized_ocean_areas)
				ocean_types.base_lighting_color = listed_ocean.static_overlay.color
				ocean_types.update_base_lighting()
			rebuilt = TRUE
