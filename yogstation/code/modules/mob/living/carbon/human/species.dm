////////////////////
/////BODYPARTS/////
////////////////////
/datum/species
	var/yogs_draw_robot_hair = FALSE //DAMN ROBOTS STEALING OUR HAIR AND AIR
	var/yogs_virus_infect_chance = 100
	///Should we use the same static husk sprite or create a husk sprite on-the-fly by recoloring bodyparts
	var/generate_husk_icon = FALSE
	var/limb_icon_file
	///Icon containing eye sprites, this is copied to the head upon updating the head
	var/eyes_icon = 'icons/mob/human_face.dmi'
	///Which body zones contain "static" sprite parts, which are independent of the rest of the sprite
	var/list/static_part_body_zones
	///Species specific suicide messages, these are added to the global list of human suicide messages
	var/list/suicide_messages
	///Items to add to and remove from the survival box in backpacks
	var/list/survival_box_replacements /*= list(items_to_delete= list(), new_items= list())*/

/datum/species/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	if(yogs_draw_robot_hair)
		for(var/obj/item/bodypart/BP in C.bodyparts)
			BP.yogs_draw_robot_hair = TRUE
		
/datum/species/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	for(var/obj/item/bodypart/BP in C.bodyparts)
		BP.yogs_draw_robot_hair = initial(BP.yogs_draw_robot_hair)

/datum/species/proc/spec_AltClickOn(atom/A,mob/living/carbon/human/H)
	return FALSE

/datum/species/proc/return_accessory_layer(layer, datum/sprite_accessory/added_accessory, mob/living/carbon/human/host, passed_color)
	var/list/return_list = list()
	var/layertext = mutant_bodyparts_layertext(layer)
	var/g = (host.gender == FEMALE) ? "f" : "m"
	for(var/list_item in added_accessory.external_slots)
		var/can_hidden_render = return_external_render_state(list_item, host)
		if(!can_hidden_render)
			continue // we failed the render check just dont bother
		if(!host.getorganslot(list_item))
			continue
		var/mutable_appearance/new_overlay = mutable_appearance(added_accessory.icon, layer = -layer)
		if(added_accessory.gender_specific)
			new_overlay.icon_state = "[g]_[list_item]_[added_accessory.icon_state]_[layertext]"
		else
			new_overlay.icon_state = "m_[list_item]_[added_accessory.icon_state]_[layertext]"
		new_overlay.color = passed_color
		return_list += new_overlay

	for(var/list_item in added_accessory.body_slots)
		if(!host.get_bodypart(list_item))
			continue
		var/mutable_appearance/new_overlay = mutable_appearance(added_accessory.icon, layer = -layer)
		if(added_accessory.gender_specific)
			new_overlay.icon_state = "[g]_[list_item]_[added_accessory.icon_state]_[layertext]"
		else
			new_overlay.icon_state = "m_[list_item]_[added_accessory.icon_state]_[layertext]"
		new_overlay.color = passed_color
		return_list += new_overlay

	return return_list

/proc/return_external_render_state(external_slot, mob/living/carbon/human/human)
	switch(external_slot)
		if(ORGAN_SLOT_TAIL)
			if(human.wear_suit && (human.wear_suit.flags_inv & HIDEJUMPSUIT))
				return FALSE
			return TRUE

/datum/species/proc/get_icon_variant(mob/living/carbon/person_to_check)
	return

///Species with eyes bigger than 1px may have an independent part of the eye sprite
/datum/species/proc/get_eyes_static(mob/living/carbon/person_to_check)
	return

///Species with static sprite parts in their bodyparts, may have variant static parts. Example is the Mossy Vox skin tone, which looks much scruffier than the others
/datum/species/proc/get_special_statics(mob/living/carbon/person_to_check)
	return list()

///Proc to swap out contents of survival boxes for species with different contents, examples are Plasmamen and Vox
/datum/species/proc/survival_box_replacement(mob/living/carbon/human/box_holder, obj/item/storage/box/survival_box, list/soon_deleted_items, list/soon_added_items)
	for(var/item as anything in soon_deleted_items)
		var/obj/item/item_to_delete = (locate(item) in survival_box)
		if(item_to_delete)
			qdel(item_to_delete)
	for(var/item as anything in soon_added_items)
		new item(survival_box)
