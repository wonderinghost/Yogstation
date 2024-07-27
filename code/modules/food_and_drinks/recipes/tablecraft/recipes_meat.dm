// see code/module/crafting/table.dm

////////////////////////////////////////////////KEBAB//////////////////////////////////////////////////

/datum/crafting_recipe/food/doubleratkebab
	name = "Double Rat Kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/reagent_containers/food/snacks/deadmouse = 2
	)
	result = /obj/item/reagent_containers/food/snacks/kebab/rat/double
	category = CAT_MEAT

/datum/crafting_recipe/food/humankebab
	name = "Human Kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/reagent_containers/food/snacks/meat/steak/plain/human = 2
	)
	result = /obj/item/reagent_containers/food/snacks/kebab/human
	category = CAT_MEAT

/datum/crafting_recipe/food/kebab
	name = "Kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/reagent_containers/food/snacks/meat/steak = 2
	)
	result = /obj/item/reagent_containers/food/snacks/kebab/monkey
	category = CAT_MEAT

/datum/crafting_recipe/food/tailkebab
	name = "Lizard Tail Kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/organ/tail/lizard = 1
	)
	result = /obj/item/reagent_containers/food/snacks/kebab/tail
	category = CAT_MEAT

/datum/crafting_recipe/food/ratkebab
	name = "Rat Kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/reagent_containers/food/snacks/deadmouse = 1
	)
	result = /obj/item/reagent_containers/food/snacks/kebab/rat
	category = CAT_MEAT

/datum/crafting_recipe/food/tofukebab
	name = "Tofu Kebab"
	reqs = list(
		/obj/item/stack/rods = 1,
		/obj/item/reagent_containers/food/snacks/tofu = 2
	)
	result = /obj/item/reagent_containers/food/snacks/kebab/tofu
	category = CAT_MEAT

////////////////////////////////////////////////OTHER////////////////////////////////////////////////
/datum/crafting_recipe/food/ribs
	name = "BBQ Ribs"
	reqs = list(
		/obj/item/stack/rods = 2,
		/datum/reagent/consumable/bbqsauce = 5,
		/obj/item/reagent_containers/food/snacks/meat/steak = 2
	)
	result = /obj/item/reagent_containers/food/snacks/bbqribs
	category = CAT_MEAT

/datum/crafting_recipe/food/nugget
	name = "Chicken Nugget"
	reqs = list(
		/datum/reagent/consumable/batter = 2,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 1
	)
	result = /obj/item/reagent_containers/food/snacks/nugget
	category = CAT_MEAT

/datum/crafting_recipe/food/cornedbeef
	name = "Corned Beef and Cabbage"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 5,
		/obj/item/reagent_containers/food/snacks/meat/steak = 1,
		/obj/item/reagent_containers/food/snacks/grown/cabbage = 2
	)
	result = /obj/item/reagent_containers/food/snacks/cornedbeef
	category = CAT_MEAT

/datum/crafting_recipe/food/enchiladas
	name = "Enchiladas"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 2,
		/obj/item/reagent_containers/food/snacks/grown/chili = 2,
		/obj/item/reagent_containers/food/snacks/tortilla = 2,
		/obj/item/reagent_containers/food/snacks/cheesewedge = 1
	)
	result = /obj/item/reagent_containers/food/snacks/enchiladas
	category = CAT_MEAT

/datum/crafting_recipe/food/bearsteak
	name = "Filet Migrawr"
	reqs = list(
		/datum/reagent/consumable/ethanol/manly_dorf = 5,
		/obj/item/reagent_containers/food/snacks/meat/steak/bear = 1
	)
	tool_paths = list(/obj/item/lighter)
	result = /obj/item/reagent_containers/food/snacks/bearsteak
	category = CAT_MEAT

/datum/crafting_recipe/food/pigblanket
	name = "Pig in a Blanket"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/bun = 1,
		/obj/item/reagent_containers/food/snacks/butterslice = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 1
	)
	result = /obj/item/reagent_containers/food/snacks/pigblanket
	category = CAT_MEAT

/datum/crafting_recipe/food/rawkhinkali
	name = "Raw Khinkali"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/doughslice = 1,
		/obj/item/reagent_containers/food/snacks/meatball = 1,
		/obj/item/reagent_containers/food/snacks/onion_slice = 1,
		/obj/item/reagent_containers/food/snacks/grown/garlic = 1
	)
	result =  /obj/item/reagent_containers/food/snacks/rawkhinkali
	category = CAT_MEAT

/datum/crafting_recipe/food/ricepork
	name = "Rice and Pork"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 2
	)
	result = /obj/item/reagent_containers/food/snacks/salad/ricepork
	category = CAT_MEAT

/datum/crafting_recipe/food/sausage
	name = "Raw Sausage"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/raw_meatball = 1,
		/obj/item/reagent_containers/food/snacks/meat/raw_cutlet = 2
	)
	result = /obj/item/reagent_containers/food/snacks/raw_sausage
	category = CAT_MEAT

/datum/crafting_recipe/food/stewedsoymeat
	name = "Stewed Soymeat"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/soydope = 2,
		/obj/item/reagent_containers/food/snacks/grown/carrot = 1,
		/obj/item/reagent_containers/food/snacks/grown/tomato = 1
	)
	result = /obj/item/reagent_containers/food/snacks/stewedsoymeat
	category = CAT_MEAT

/datum/crafting_recipe/food/meatclown
	name = "Meat Clown"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/meat/steak/plain = 1,
		/obj/item/reagent_containers/food/snacks/grown/banana = 1
	)
	result = /obj/item/reagent_containers/food/snacks/meatclown
	category = CAT_MEAT

/datum/crafting_recipe/food/gumbo
	name = "Black eyed gumbo"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/salad/boiledrice = 1,
		/obj/item/reagent_containers/food/snacks/grown/peas = 1,
		/obj/item/reagent_containers/food/snacks/grown/chili = 1,
		/obj/item/reagent_containers/food/snacks/meat/cutlet = 1
	)
	result = /obj/item/reagent_containers/food/snacks/salad/gumbo
	category = CAT_MEAT

/datum/crafting_recipe/food/fishfry
	name = "Fish fry"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/grown/corn = 1,
		/obj/item/reagent_containers/food/snacks/grown/peas =1,
		/obj/item/reagent_containers/food/snacks/carpmeat/fish/cooked = 1
	)
	result = /obj/item/reagent_containers/food/snacks/fishfry
	category = CAT_MEAT

/datum/crafting_recipe/food/spam_musubi
	name = "Spam Musubi"
	reqs = list(
		/datum/reagent/consumable/nutriment/protein = 1,
		/datum/reagent/consumable/rice = 1,
		/obj/item/reagent_containers/food/snacks/seaweedsheet = 1
	)
	result = /obj/item/reagent_containers/food/snacks/spam_musubi
	category = CAT_MEAT

/datum/crafting_recipe/food/full_roast
	name = "Roast Chicken Dinner"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/meat/steak/chicken = 3,
		/obj/item/reagent_containers/food/snacks/roastparsnip = 3,
		/obj/item/reagent_containers/food/snacks/grown/onion = 1,
		/obj/item/reagent_containers/food/snacks/grown/peas = 3,
		/obj/item/reagent_containers/food/snacks/grown/potato = 6,
		/obj/item/reagent_containers/food/snacks/grown/cabbage = 1,
		/datum/reagent/consumable/flour = 5,
		/datum/reagent/consumable/gravy = 15,
		/datum/reagent/consumable/sodiumchloride = 2,
		/datum/reagent/consumable/blackpepper = 2
	)
	result = /obj/item/reagent_containers/food/snacks/roast_dinner
	category = CAT_MEAT

/datum/crafting_recipe/food/full_roast_tofu
	name = "Meat-Free Roast Dinner"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/tofu = 6,
		/obj/item/reagent_containers/food/snacks/roastparsnip = 3,
		/obj/item/reagent_containers/food/snacks/grown/onion = 1,
		/obj/item/reagent_containers/food/snacks/grown/peas = 3,
		/obj/item/reagent_containers/food/snacks/grown/potato = 6,
		/obj/item/reagent_containers/food/snacks/grown/cabbage = 1,
		/datum/reagent/consumable/flour = 5,
		/datum/reagent/consumable/soymilk = 15,
		/datum/reagent/consumable/sodiumchloride = 2,
		/datum/reagent/consumable/blackpepper = 2
	)
	result = /obj/item/reagent_containers/food/snacks/roast_dinner_tofu
	category = CAT_MEAT


/datum/crafting_recipe/food/fried_chicken
	name = "Fried Chicken"
	reqs = list(
		/obj/item/reagent_containers/food/snacks/meat/steak/chicken = 1,
		/datum/reagent/consumable/corn_starch = 5,
		/datum/reagent/consumable/flour = 5
	)
	result = /obj/item/reagent_containers/food/snacks/fried_chicken
	category = CAT_MEAT