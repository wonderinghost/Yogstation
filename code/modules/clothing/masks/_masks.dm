/obj/item/clothing/mask
	name = "mask"
	icon = 'icons/obj/clothing/masks.dmi'
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_MASK
	strip_delay = 40
	equip_delay_other = 40
	var/modifies_speech = FALSE
	var/mask_adjusted = 0
	var/adjusted_flags = null
	var/mutantrace_variation = NONE //Are there special sprites for specific situations? Don't use this unless you need to.
	var/mutantrace_adjusted = NONE //Are there special sprites for specific situations? Don't use this unless you need to.

/obj/item/clothing/mask/attack_self(mob/user)
	if(CHECK_BITFIELD(clothing_flags, VOICEBOX_TOGGLABLE))
		TOGGLE_BITFIELD(clothing_flags, VOICEBOX_DISABLED)
		var/status = !CHECK_BITFIELD(clothing_flags, VOICEBOX_DISABLED)
		to_chat(user, span_notice("You turn the voice box in [src] [status ? "on" : "off"]."))

/obj/item/clothing/mask/equipped(mob/M, slot)
	. = ..()
	if (slot == ITEM_SLOT_MASK && modifies_speech)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/mask/dropped(mob/M)
	. = ..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/mask/proc/handle_speech()

/obj/item/clothing/mask/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	. = ..()
	if(!isinhands)
		if(body_parts_covered & HEAD)
			if(damaged_clothes)
				. += mutable_appearance('icons/effects/item_damage.dmi', "damagedmask")
			if(HAS_BLOOD_DNA(src))
				var/mutable_appearance/bloody_mask = mutable_appearance('icons/effects/blood.dmi', "maskblood")
				if(species_fitted && icon_exists(bloody_mask.icon, "maskblood_[species_fitted]")) 
					bloody_mask.icon_state = "maskblood_[species_fitted]"
				bloody_mask.color = get_blood_dna_color(return_blood_DNA())
				. += bloody_mask

/obj/item/clothing/mask/update_clothes_damaged_state()
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_wear_mask()

/obj/item/clothing/mask/update_icon_state()
	. = ..()
	if(mask_adjusted)
		icon_state = initial(icon_state) + "_up"
	else
		icon_state = initial(icon_state)

//Proc that moves gas/breath masks out of the way, disabling them and allowing pill/food consumption
/obj/item/clothing/mask/proc/adjustmask(mob/living/carbon/user)
	if(user && user.incapacitated())
		return
	mask_adjusted = !mask_adjusted
	if(!mask_adjusted)
		gas_transfer_coefficient = initial(gas_transfer_coefficient)
		clothing_flags |= visor_flags
		flags_inv |= visor_flags_inv
		flags_cover |= visor_flags_cover
		to_chat(user, span_notice("You push \the [src] back into place."))
		slot_flags = initial(slot_flags)
	else
		to_chat(user, span_notice("You push \the [src] out of the way."))
		gas_transfer_coefficient = null
		clothing_flags &= ~visor_flags
		flags_inv &= ~visor_flags_inv
		flags_cover &= ~visor_flags_cover
		if(adjusted_flags)
			slot_flags = adjusted_flags
	update_appearance(UPDATE_ICON)
	if(!istype(user))
		return
	// Update the mob if it's wearing the mask.
	if(user.wear_mask == src)
		user.wear_mask_update(src, toggle_off = mask_adjusted)
	if(loc == user)
		// Update action button icon for adjusted mask, if someone is holding it.
		user.update_mob_action_buttons()
