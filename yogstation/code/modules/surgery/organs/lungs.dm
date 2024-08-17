/obj/item/organ/lungs/ashwalker
	name = "grey lungs"
	desc = "The grey-ish lungs of an ashwalker."
	icon = 'yogstation/icons/obj/surgery.dmi'
	icon_state = "lungs-ash"

	safe_breath_min = 6
	safe_breath_max = 18
	
	gas_min = list(
		GAS_O2 = 0,
		GAS_N2 = 16,
	)
	gas_max = list(
		GAS_CO2 = 20,
		GAS_PLASMA = 0.05
	)

	SA_para_min = 1
	SA_sleep_min = 5
	BZ_trip_balls_min = 1
	gas_stimulation_min = 0.002

/obj/item/organ/lungs/plant
	name = "mesophyll"
	desc = "A lung-shaped organ playing a key role in phytosian's photosynthesis." //phytosians don't need that for their light healing so that's just flavor, I might try to tie their light powers to it later(tm)
	icon = 'yogstation/icons/obj/surgery.dmi'
	icon_state = "lungs-plant"

	gas_max = list(
		GAS_CO2 = 0, //make them not choke on CO2 so they can actually breathe it
		GAS_PLASMA = 0.05
	)

	breathing_class = /datum/breathing_class/oxygen_co2

/obj/item/organ/lungs/plant/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/H) //Directly taken from the xenos lungs
	. = ..()
	if(breath)
		var/breath_amt = breath.get_moles(GAS_CO2)
		breath.adjust_moles(GAS_CO2, -breath_amt)
		breath.adjust_moles(GAS_O2, breath_amt)

/obj/item/organ/lungs/plant/prepare_eat()
	var/obj/item/reagent_containers/food/snacks/organ/plant_lung/S = new
	S.name = name
	S.desc = desc
	S.icon = icon
	S.icon_state = icon_state
	S.w_class = w_class

	return S

/obj/item/reagent_containers/food/snacks/organ/plant_lung
	list_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/medicine/salbutamol = 5)
	foodtype = VEGETABLES | FRUIT

/obj/item/organ/lungs/plant/ivymen
	desc = "These lungs appear to be covered in a symbiotic fungus that allows ivymen to handle higher temperatures."
	heat_level_1_threshold = 550
	heat_level_2_threshold = 600
	heat_level_3_threshold = 1100

/obj/item/organ/lungs/vox
	name = "vox lungs"
	icon_state = "lungs-vox"
	desc = "They're filled with dust...wow."
	decay_factor = 0
	breathing_class = BREATH_VOX

/obj/item/organ/lungs/vox/populate_gas_info()
	..()
	gas_max[GAS_O2] = 0.05
	gas_max -= BREATH_VOX
	gas_damage[GAS_O2] = list(min = MIN_TOXIC_GAS_DAMAGE, max = MAX_TOXIC_GAS_DAMAGE, damage_type = TOX)

/obj/item/organ/lungs/vox/emp_act()
	owner.emote("gasp")
