/obj/item/reagent_containers/syringe
	name = "syringe"
	desc = "A syringe that can hold up to 15 units."
	icon = 'icons/obj/syringe.dmi'
	item_state = "syringe_0"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	icon_state = "0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5, 10, 15)
	volume = 15
	var/busy = FALSE		// needed for delayed drawing of blood
	var/proj_piercing = 0 //does it pierce through thick clothes when shot with syringe gun
	materials = list(/datum/material/iron=10, /datum/material/glass=20)
	reagent_flags = TRANSPARENT
	sharpness = SHARP_POINTY
	embedding = list("embedded_pain_chance" = 0, "embedded_pain_multiplier" = 0, "embedded_unsafe_removal_time" = 1 SECONDS, "embedded_unsafe_removal_pain_multiplier" = 0, "embed_chance" = 15, "embedded_fall_chance" = 5, "embedded_bleed_rate" = 0)

/obj/item/reagent_containers/syringe/Initialize(mapload)
	. = ..()
	if(list_reagents) //syringe starts in inject mode if its already got something inside
		update_appearance(UPDATE_ICON)
	RegisterSignal(src, COMSIG_ITEM_EMBED_TICK, PROC_REF(embed_inject))

/obj/item/reagent_containers/syringe/on_reagent_change(changetype)
	update_appearance(UPDATE_ICON)

/obj/item/reagent_containers/syringe/attackby(obj/item/I, mob/user, params)
	return

/obj/item/reagent_containers/syringe/proc/try_syringe(atom/target, mob/user, proximity)
	if(busy)
		return FALSE
	if(!proximity)
		return FALSE
	if(!target.reagents)
		return FALSE
	
	if(isliving(target))
		var/mob/living/living_target = target
		if(!living_target.can_inject(user, TRUE, user.zone_selected, proj_piercing))
			return FALSE

	// chance of monkey retaliation
	if(ismonkey(target) && prob(MONKEY_SYRINGE_RETALIATION_PROB))
		var/mob/living/carbon/monkey/M = target
		M.retaliate(user)

	SEND_SIGNAL(target, COMSIG_LIVING_TRY_SYRINGE, user)
	return TRUE

/obj/item/reagent_containers/syringe/afterattack(atom/target, mob/user, proximity)
	. = ..()

	if(!try_syringe(target, user, proximity))
		return
	
	var/contained = reagents.log_list()
	log_combat(user, target, "attempted to inject", src, addition="which had [contained]")

	if(!reagents.total_volume)
		to_chat(user, span_warning("[src] is empty! Right-click to draw."))
		return

	if(!isliving(target) && !target.is_injectable(user))
		to_chat(user, span_warning("You cannot directly fill [target]!"))
		return

	if(target.reagents.total_volume >= target.reagents.maximum_volume)
		to_chat(user, span_notice("[target] is full."))
		return
	
	if(isliving(target))
		var/mob/living/living_target = target
		if(!living_target.can_inject(user, TRUE, user.zone_selected, proj_piercing))
			return
		if(living_target != user)
			living_target.visible_message(span_danger("[user] is trying to inject [living_target]!"), \
									span_userdanger("[user] is trying to inject you!"))
			if(!do_after(user, 3 SECONDS, living_target, extra_checks = CALLBACK(living_target, TYPE_PROC_REF(/mob/living, can_inject), user, TRUE, user.zone_selected, proj_piercing)))
				return

			if(!reagents.total_volume)
				return

			if(living_target.reagents.total_volume >= living_target.reagents.maximum_volume)
				return
			
			living_target.visible_message(span_danger("[user] injects [living_target] with the syringe!"), \
							span_userdanger("[user] injects you with the syringe!"))

		if (living_target == user)
			living_target.log_message("injected themselves ([contained]) with [name]", LOG_ATTACK, color="orange")
		else
			var/viruslist = "" // yogs start - Adds viruslist stuff
			for(var/datum/reagent/R in reagents.reagent_list)
				if(istype(R, /datum/reagent/blood))
					var/datum/reagent/blood/RR = R
					for(var/datum/disease/D in RR.data["viruses"])
						viruslist += " [D.name]"
						if(istype(D, /datum/disease/advance))
							var/datum/disease/advance/DD = D
							viruslist += " \[ symptoms: "
							for(var/datum/symptom/S in DD.symptoms)
								viruslist += "[S.name] "
							viruslist += "\]"
			if(viruslist)
				investigate_log("[user.real_name] ([user.ckey]) attempted to inject [living_target.real_name] ([living_target.ckey]) with [viruslist]", INVESTIGATE_VIROLOGY)
				log_game("[user.real_name] ([user.ckey]) injected [living_target.real_name] ([living_target.ckey]) with [viruslist]") // yogs end
			log_combat(user, living_target, "injected", src, addition="which had [contained]")
	reagents.reaction(target, INJECT, min(amount_per_transfer_from_this / reagents.total_volume, 1))
	reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
	to_chat(user, "<span class='notice'>You inject [amount_per_transfer_from_this] units of the solution. The syringe now contains [reagents.total_volume] units.</span>")

/obj/item/reagent_containers/syringe/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	if (!try_syringe(target, user, proximity_flag))
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	if(reagents.total_volume >= reagents.maximum_volume)
		to_chat(user, span_notice("[src] is full."))
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	if(isliving(target))
		var/mob/living/living_target = target
		if(ishuman(target))
			var/mob/living/carbon/human/species_check = living_target
			if(species_check?.dna?.species?.species_traits && (NOBLOOD in species_check.dna.species.species_traits))
				to_chat(user, span_warning("[target] has no blood to draw!."))
				return SECONDARY_ATTACK_CONTINUE_CHAIN

		var/drawn_amount = reagents.maximum_volume - reagents.total_volume
		if(target != user)
			target.visible_message(span_danger("[user] is trying to take a blood sample from [target]!"), \
							span_userdanger("[user] is trying to take a blood sample from you!"))
			busy = TRUE
			if(!do_after(user, 3 SECONDS, living_target, extra_checks = CALLBACK(living_target, TYPE_PROC_REF(/mob/living, can_inject), user, TRUE, user.zone_selected, proj_piercing)))
				busy = FALSE
				return SECONDARY_ATTACK_CONTINUE_CHAIN
			if(reagents.total_volume >= reagents.maximum_volume)
				return SECONDARY_ATTACK_CONTINUE_CHAIN
		busy = FALSE
		if(living_target.transfer_blood_to(src, drawn_amount))
			user.visible_message(span_notice("[user] takes a blood sample from [living_target]."))
		else
			to_chat(user, span_warning("You are unable to draw any blood from [living_target]!"))
	else
		if(!target.reagents.total_volume)
			to_chat(user, span_warning("[target] is empty!"))
			return SECONDARY_ATTACK_CONTINUE_CHAIN

		if(!target.is_drawable(user))
			to_chat(user, span_warning("You cannot directly remove reagents from [target]!"))
			return SECONDARY_ATTACK_CONTINUE_CHAIN

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user) // transfer from, transfer to - who cares?

		to_chat(user, span_notice("You fill [src] with [trans] units of the solution. It now contains [reagents.total_volume] units."))
	
	return SECONDARY_ATTACK_CONTINUE_CHAIN

/obj/item/reagent_containers/syringe/update_overlays()
	. = ..()
	var/rounded_vol
	if(reagents && reagents.total_volume)
		rounded_vol = clamp(round((reagents.total_volume / volume * 15),5), 1, 15)
		var/image/filling_overlay = mutable_appearance('icons/obj/reagentfillings.dmi', "syringe[rounded_vol]")
		filling_overlay.color = mix_color_from_reagents(reagents.reagent_list)
		. += filling_overlay
	else
		rounded_vol = 0
	icon_state = "[rounded_vol]"
	item_state = "syringe_[rounded_vol]"

/obj/item/reagent_containers/syringe/proc/embed_inject(target, mob/living/carbon/human/embedde, obj/item/bodypart/part)
	if(!reagents.total_volume)
		return
	// Half of transfer amount, or 2.5 units per tick for default syringes
	var/fraction = min((0.5 * amount_per_transfer_from_this) / reagents.total_volume, 1)
	reagents.reaction(embedde, INJECT, fraction)
	reagents.trans_to(embedde, amount_per_transfer_from_this)

/obj/item/reagent_containers/syringe/epinephrine
	name = "syringe (epinephrine)"
	desc = "Contains epinephrine - used to stabilize patients."
	list_reagents = list(/datum/reagent/medicine/epinephrine = 15)

/obj/item/reagent_containers/syringe/charcoal
	name = "syringe (charcoal)"
	desc = "Contains charcoal."
	list_reagents = list(/datum/reagent/medicine/charcoal = 15)

/obj/item/reagent_containers/syringe/perfluorodecalin
	name = "syringe (perfluorodecalin)"
	desc = "Contains perfluorodecalin."
	list_reagents = list(/datum/reagent/medicine/perfluorodecalin = 15)

/obj/item/reagent_containers/syringe/antiviral
	name = "syringe (spaceacillin)"
	desc = "Contains antiviral agents."
	list_reagents = list(/datum/reagent/medicine/spaceacillin = 15)

/obj/item/reagent_containers/syringe/bioterror
	name = "bioterror syringe"
	desc = "Contains several paralyzing reagents."
	list_reagents = list(/datum/reagent/consumable/ethanol/neurotoxin = 5, /datum/reagent/toxin/mutetoxin = 5, /datum/reagent/toxin/sodium_thiopental = 5)

/obj/item/reagent_containers/syringe/stimulants
	name = "Stimpack"
	desc = "Contains stimulants."
	amount_per_transfer_from_this = 50
	volume = 50
	list_reagents = list(/datum/reagent/medicine/stimulants = 50)

/obj/item/reagent_containers/syringe/calomel
	name = "syringe (calomel)"
	desc = "Contains calomel."
	list_reagents = list(/datum/reagent/medicine/calomel = 15)

/obj/item/reagent_containers/syringe/plasma
	name = "syringe (plasma)"
	desc = "Contains plasma."
	list_reagents = list(/datum/reagent/toxin/plasma = 15)

/obj/item/reagent_containers/syringe/lethal
	name = "lethal injection syringe"
	desc = "A syringe used for lethal injections. It can hold up to 50 units."
	amount_per_transfer_from_this = 50
	volume = 50

/obj/item/reagent_containers/syringe/lethal/choral
	list_reagents = list(/datum/reagent/toxin/chloralhydrate = 50)

/obj/item/reagent_containers/syringe/lethal/execution
	list_reagents = list(/datum/reagent/toxin/plasma = 15, /datum/reagent/toxin/formaldehyde = 15, /datum/reagent/toxin/cyanide = 10, /datum/reagent/toxin/acid/fluacid = 10)

/obj/item/reagent_containers/syringe/mulligan
	name = "Mulligan"
	desc = "A syringe used to completely change the users identity."
	amount_per_transfer_from_this = 1
	volume = 1
	list_reagents = list(/datum/reagent/mulligan = 1)

/obj/item/reagent_containers/syringe/gluttony
	name = "Gluttony's Blessing"
	desc = "A syringe recovered from a dread place. It probably isn't wise to use."
	amount_per_transfer_from_this = 1
	volume = 1
	list_reagents = list(/datum/reagent/gluttonytoxin = 1)

/obj/item/reagent_containers/syringe/ghost
	name = "Spectral Curse"
	desc = "A syringe recovered from a dreaded place. It probably isn't wise to use."
	amount_per_transfer_from_this = 1
	volume = 1
	list_reagents = list(/datum/reagent/ghosttoxin = 1)

/obj/item/reagent_containers/syringe/big
	name = "large syringe"
	desc = "A large syringe that can hold 30 units of chemicals"
	amount_per_transfer_from_this = 10
	volume = 30

/obj/item/reagent_containers/syringe/big/polonium
	name = "syringe (polonium)"
	desc = "Contains 30 units of polonium. Will irradiate victims, metabolized very slowly."
	list_reagents = list(/datum/reagent/toxin/polonium = 30)

/obj/item/reagent_containers/syringe/big/venom
	name = "syringe (venom)"
	desc = "Contains 30 units of venom. Deadliness increase with the dosage, can decay into histamine."
	list_reagents = list(/datum/reagent/toxin/venom = 30)

/obj/item/reagent_containers/syringe/big/spewium
	name = "syringe (spewium)"
	desc = "Contains 30 units of spewium. Cause victims to vomit, more than 29 units cause to victims puking out their own organs."
	list_reagents = list(/datum/reagent/toxin/spewium = 30)

/obj/item/reagent_containers/syringe/big/histamine
	name = "syringe (histamine)"
	desc = "Contains 30 units of histamine. Provoke itching, sneezing, coughing and blurry vision, more than 30 units cause victims to take large amounts of brute, toxin and oxygen damage."
	list_reagents = list(/datum/reagent/toxin/histamine = 30)

/obj/item/reagent_containers/syringe/big/initropidril
	name = "syringe (initropidril)"
	desc = "Contains 30 units of initropidril. A paralytic agent that will cause failures of respiratory systems and cardiac arrest."
	list_reagents = list(/datum/reagent/toxin/initropidril = 30)

/obj/item/reagent_containers/syringe/big/pancuronium
	name = "syringe (pancuronium)"
	desc = "Contains 30 units of pancuronium. Stun and suffocate victims."
	list_reagents = list(/datum/reagent/toxin/pancuronium = 30)

/obj/item/reagent_containers/syringe/big/sodium_thiopental
	name = "syringe (sodium thiopental)"
	desc = "Contains 30 units of sodium thiopental. Will tire victims and knock them out non lethally."
	list_reagents = list(/datum/reagent/toxin/sodium_thiopental = 30)

/obj/item/reagent_containers/syringe/big/curare
	name = "syringe (curare)"
	desc = "Contains 30 units of curare. Will paralyze victims and inflict toxin and suffocation, metabolized very slowly."
	list_reagents = list(/datum/reagent/toxin/curare = 30)

/obj/item/reagent_containers/syringe/big/amanitin
	name = "syringe (amanitin)"
	desc = "Contains 30 units of amanitin. Once fully metabolized inflict toxin damage proportional to the time it was in system of the victims."
	list_reagents = list(/datum/reagent/toxin/amanitin = 30)

/obj/item/reagent_containers/syringe/big/coniine
	name = "syringe (coniine)"
	desc = "Contains 30 units of coniine. Will cause toxin and loss of breath, metabolized incredibly slowly."
	list_reagents = list(/datum/reagent/toxin/coniine = 30)

/obj/item/reagent_containers/syringe/big/relaxant
	name = "syringe (muscle relaxant)"
	desc = "Contains 30 units of muscle relaxant. Slow the movements and actions of the victims noticeably."
	list_reagents = list(/datum/reagent/toxin/relaxant = 30)

/obj/item/reagent_containers/syringe/bluespace
	name = "bluespace syringe"
	desc = "An advanced syringe that can hold 60 units of chemicals."
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = list(10, 20, 30, 40, 50, 60)
	volume = 60

/obj/item/reagent_containers/syringe/piercing
	name = "piercing syringe"
	desc = "A diamond-tipped syringe that can safely inject its contents into those wearing bulky clothing. It can hold up to 15 units."
	proj_piercing = 1

/obj/item/reagent_containers/syringe/crude
	name = "crude syringe"
	desc = "A crudely made syringe. The flimsy wooden construction makes it hold up minimal amounts of reagents."
	volume = 5

/obj/item/reagent_containers/syringe/spider_extract
	name = "spider extract syringe"
	desc = "Contains crikey juice - makes any gold core create the most deadly companions in the world."
	list_reagents = list(/datum/reagent/spider_extract = 1)

/obj/item/reagent_containers/syringe/dart
	name = "reagent dart"
	amount_per_transfer_from_this = 10
	embedding = list("embedded_pain_chance" = 0, "embedded_pain_multiplier" = 0, "embedded_unsafe_removal_time" = 0.25 SECONDS, "embedded_unsafe_removal_pain_multiplier" = 0, "embed_chance" = 15, "embedded_fall_chance" = 0, "embedded_bleed_rate" = 0)

/obj/item/reagent_containers/syringe/dart/temp
	item_flags = DROPDEL

/obj/item/reagent_containers/syringe/dart/temp/Initialize(mapload)
	..()
	RegisterSignal(src, COMSIG_ITEM_EMBED_REMOVAL, PROC_REF(on_embed_removal))

/obj/item/reagent_containers/syringe/dart/temp/proc/on_embed_removal(mob/living/carbon/human/embedde)
	return COMSIG_ITEM_QDEL_EMBED_REMOVAL
