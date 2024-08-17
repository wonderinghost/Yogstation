/obj/item/clothing/mask/breath
	desc = "A close-fitting mask that can be connected to an air supply."
	name = "breath mask"
	icon_state = "breath"
	item_state = "m_mask"
	body_parts_covered = 0
	clothing_flags = MASKINTERNALS
	visor_flags = MASKINTERNALS
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.1
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 15, RAD = 0, FIRE = 0, ACID = 0)
	actions_types = list(/datum/action/item_action/adjust)
	flags_cover = MASKCOVERSMOUTH
	visor_flags_cover = MASKCOVERSMOUTH
	resistance_flags = NONE
	mutantrace_variation = DIGITIGRADE_VARIATION

/obj/item/clothing/mask/breath/tactical
	name = "tactical breath mask"
	desc = "A close-fitting 'tactical' mask that can be connected to an air supply."
	icon_state = "tacmask"
	item_state = "sechailer"
	visor_flags_inv = HIDEFACE

/obj/item/clothing/mask/breath/tactical/Initialize(mapload)
	. = ..()
	adjustmask() // this mask starts lowered

/obj/item/clothing/mask/breath/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is wrapping \the [src]'s tube around [user.p_their()] neck! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/clothing/mask/breath/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/breath/AltClick(mob/user)
	..()
	if(user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	else
		adjustmask(user)

/obj/item/clothing/mask/breath/examine(mob/user)
	. = ..()
	if(length(actions_types))
		. += span_notice("Alt-click [src] to adjust it.")

/obj/item/clothing/mask/breath/medical
	desc = "A close-fitting sterile mask that can be connected to an air supply."
	name = "medical mask"
	icon_state = "medical"
	item_state = "m_mask"
	equip_delay_other = 10
	mutantrace_variation = DIGITIGRADE_VARIATION
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 0, FIRE = 0, ACID = 0)
