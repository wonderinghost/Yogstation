/// Base sight
/obj/item/attachment/scope
	name = "sight"
	desc = "It's a sight."
	attachment_type = TYPE_SIGHT
	var/accuracy = 0
	var/mouse_icon // https://www.byond.com/docs/ref/#/client/var/mouse_pointer_icon

/obj/item/attachment/scope/on_attach(obj/item/gun/G, mob/user = null)
	. = ..()
	G.spread -= accuracy

/obj/item/attachment/scope/on_detach(obj/item/gun/G, mob/living/user = null)
	. = ..()
	G.spread += accuracy

/obj/item/attachment/scope/pickup_user(mob/user)
	. = ..()
	if(user && user.client && mouse_icon)
		user.client.mouse_override_icon = mouse_icon
		user.update_mouse_pointer()

/obj/item/attachment/scope/equip_user(mob/user)
	. = ..()
	if(user && user.client && mouse_icon)
		user.client.mouse_override_icon = null
		user.update_mouse_pointer()

/obj/item/attachment/scope/drop_user(mob/user)
	. = ..()
	if(user && user.client && mouse_icon)
		user.client.mouse_override_icon = null
		user.update_mouse_pointer()

/obj/item/attachment/scope/simple
	name = "simple sight"
	desc = "A rugged scope with LED dots for nighttime planetside operations. Better than ironsights."
	icon_state = "simple_sight"
	accuracy = 3
	mouse_icon = 'icons/effects/mouse_pointers/simple_sight.dmi'

/obj/item/attachment/scope/holo
	name = "holographic sight"
	desc = "A highly advanced sight that projects a holographic design onto its lens, providing unobscured and precise view of your target."
	icon_state = "holo_sight"
	accuracy = 6
	mouse_icon = 'icons/effects/mouse_pointers/holo_sight.dmi'

/obj/item/attachment/scope/infrared
	name = "infrared sight"
	desc = "A polarizing camera that picks up infrared radiation. The quality is rather poor, so it ends up making it harder to aim."
	icon_state = "ifr_sight"
	accuracy = -2
	mouse_icon = 'icons/effects/mouse_pointers/infr_sight.dmi'
	actions_list = list(/datum/action/item_action/toggle_infrared_sight)

/obj/item/attachment/scope/infrared/attack_self(mob/user)
	. = ..()
	toggle_on()

/obj/item/attachment/scope/infrared/proc/toggle_on()
	is_on = !is_on
	playsound(get_turf(loc), is_on ? 'sound/weapons/magin.ogg' : 'sound/weapons/magout.ogg', 40, 1)
	if(attached_gun)
		if(is_on)
			attached_gun.spread -= accuracy
			if(current_user?.is_holding(attached_gun))
				pickup_user(current_user)
		else
			attached_gun.spread += accuracy
			drop_user(current_user)
	update_appearance(UPDATE_ICON)

/obj/item/attachment/scope/infrared/pickup_user(mob/user)
	. = ..()
	if(user && is_on)
		ADD_TRAIT(user, TRAIT_INFRARED_VISION, ATTACHMENT_TRAIT)
		user.update_sight()

/obj/item/attachment/scope/infrared/equip_user(mob/user)
	. = ..()
	if(user)
		REMOVE_TRAIT(user, TRAIT_INFRARED_VISION, ATTACHMENT_TRAIT)
		user.update_sight()

/obj/item/attachment/scope/infrared/drop_user(mob/user)
	. = ..()
	if(user)
		REMOVE_TRAIT(user, TRAIT_INFRARED_VISION, ATTACHMENT_TRAIT)
		user.update_sight()

/datum/action/item_action/toggle_infrared_sight
	name = "Toggle Infrared"
	button_icon = 'icons/obj/guns/attachment.dmi'
	button_icon_state = "ifr_sight"
	var/obj/item/attachment/scope/infrared/att

/datum/action/item_action/toggle_infrared_sight/Trigger()
	if(!att)
		if(istype(target, /obj/item/gun))
			var/obj/item/gun/parent_gun = target
			for(var/obj/item/attachment/A in parent_gun.current_attachments)
				if(istype(A, /obj/item/attachment/scope/infrared))
					att = A
					break
	att?.toggle_on()
	build_all_button_icons(UPDATE_BUTTON_ICON)

/datum/action/item_action/toggle_infrared_sight/apply_button_icon(atom/movable/screen/movable/action_button/current_button, status_only = FALSE, force)
	var/obj/item/attachment/scope/infrared/ifrsight = target
	if(istype(ifrsight))
		button_icon_state = "ifr_sight[att?.is_on ? "_on" : ""]"

	return ..()
