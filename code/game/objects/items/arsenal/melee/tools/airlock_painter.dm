/// below these levels trigger the special sprites
#define PAINTER_MOST 0.76
#define PAINTER_MID 0.5
#define PAINTER_LOW 0.2

/obj/item/airlock_painter
	name = "airlock painter"
	desc = "An advanced autopainter preprogrammed with several paintjobs for airlocks. Use it on an airlock during or after construction to change the paintjob."
	icon = 'icons/obj/objects.dmi'
	icon_state = "paint_sprayer"
	item_state = "paint_sprayer"
	
	w_class = WEIGHT_CLASS_SMALL

	materials = list(/datum/material/iron=50, /datum/material/glass=50)

	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	usesound = 'sound/effects/spray2.ogg'

	/// The ink cartridge to pull charges from.
	var/obj/item/toner/ink = null
	/// The type path to instantiate for the ink cartridge the device initially comes with, eg. /obj/item/toner
	var/initial_ink_type = /obj/item/toner
	var/painter_mode = 1
	/// Associate list of all paint jobs the airlock painter can apply. The key is the name of the airlock the user will see. The value is the type path of the airlock
	var/list/available_paint_jobs = list(
		"Public" = /obj/machinery/door/airlock/public,
		"Engineering" = /obj/machinery/door/airlock/engineering,
		"Atmospherics" = /obj/machinery/door/airlock/atmos,
		"Security" = /obj/machinery/door/airlock/security,
		"Command" = /obj/machinery/door/airlock/command,
		"Medical" = /obj/machinery/door/airlock/medical,
		"Research" = /obj/machinery/door/airlock/research,
		"Freezer" = /obj/machinery/door/airlock/freezer,
		"Science" = /obj/machinery/door/airlock/science,
		"Mining" = /obj/machinery/door/airlock/mining,
		"Maintenance" = /obj/machinery/door/airlock/maintenance,
		"External" = /obj/machinery/door/airlock/external,
		"External Maintenance"= /obj/machinery/door/airlock/maintenance/external,
		"Virology" = /obj/machinery/door/airlock/virology,
		"Standard" = /obj/machinery/door/airlock,
	    "Centcom"  = /obj/machinery/door/airlock/centcom,
		"Shuttle" = /obj/machinery/door/airlock/shuttle,
		"Alien" = /obj/machinery/door/airlock/abductor
	)

/obj/item/airlock_painter/Initialize(mapload)
	. = ..()
	ink = new initial_ink_type(src)

/obj/item/airlock_painter/update_icon_state()
	. = ..()
	var/base = initial(icon_state)
	if(!ink || !istype(ink))
		icon_state = "[base]_none"
		return
	switch(ink.charges / ink.max_charges)
		if(0.001 to PAINTER_LOW)
			icon_state = "[base]_low"
		if(PAINTER_LOW to PAINTER_MID)
			icon_state = "[base]_mid"
		if(PAINTER_MID to PAINTER_MOST)
			icon_state = "[base]_most"
		if(PAINTER_MOST to INFINITY)
			icon_state = base
		else
			icon_state = "[base]_empty"

/obj/item/airlock_painter/proc/get_mode()
	return painter_mode

//This proc doesn't just check if the painter can be used, but also uses it.
//Only call this if you are certain that the painter will be used right after this check!
/obj/item/airlock_painter/proc/use_paint(mob/user)
	if(can_use(user))
		ink.charges--
		update_appearance(UPDATE_ICON)
		playsound(src.loc, 'sound/effects/spray2.ogg', 50, TRUE)
		return TRUE
	else
		return FALSE

//This proc only checks if the painter can be used.
//Call this if you don't want the painter to be used right after this check, for example
//because you're expecting user input.
/obj/item/airlock_painter/proc/can_use(mob/user)
	if(!ink)
		balloon_alert(user, "no cartridge!")
		return FALSE
	else if(ink.charges < 1)
		balloon_alert(user, "out of ink!")
		return FALSE
	else
		return TRUE

/obj/item/airlock_painter/suicide_act(mob/living/user)
	var/obj/item/organ/lungs/L = user.getorganslot(ORGAN_SLOT_LUNGS)

	if(can_use(user) && L)
		user.visible_message(span_suicide("[user] is inhaling toner from [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		use(user)

		// Once you've inhaled the toner, you throw up your lungs
		// and then die.

		// Find out if there is an open turf in front of us,
		// and if not, pick the turf we are standing on.
		var/turf/T = get_step(get_turf(src), user.dir)
		if(!isopenturf(T))
			T = get_turf(src)

		// they managed to lose their lungs between then and
		// now. Good job.
		if(!L)
			return OXYLOSS

		L.Remove(user)

		// make some colorful reagent, and apply it to the lungs
		L.create_reagents(10)
		L.reagents.add_reagent(/datum/reagent/colorful_reagent, 10)
		L.reagents.reaction(L, TOUCH, 1)

		// TODO maybe add some colorful vomit?

		user.visible_message(span_suicide("[user] vomits out [user.p_their()] [L]!"))
		playsound(user.loc, 'sound/effects/splat.ogg', 50, TRUE)

		L.forceMove(T)

		return (TOXLOSS|OXYLOSS)
	else if(can_use(user) && !L)
		user.visible_message(span_suicide("[user] is spraying toner on [user.p_them()]self from [src]! It looks like [user.p_theyre()] trying to commit suicide."))
		user.reagents.add_reagent(/datum/reagent/colorful_reagent, 1)
		user.reagents.reaction(user, TOUCH, 1)
		return TOXLOSS

	else
		user.visible_message(span_suicide("[user] is trying to inhale toner from [src]! It might be a suicide attempt if [src] had any toner."))
		return SHAME


/obj/item/airlock_painter/examine(mob/user)
	. = ..()
	if(!ink)
		. += span_notice("The ink compartment hangs open.")
		return
	var/ink_level = "high"
	switch(ink.charges/ink.max_charges)
		if(0.001 to PAINTER_LOW)
			ink_level = "extremely low"
		if(PAINTER_LOW to PAINTER_MID)
			ink_level = "low"
		if(PAINTER_MID to 1)
			ink_level = "high"
		if(1 to INFINITY) //Over 100% (admin var edit)
			ink_level = "dangerously high"
	if(ink.charges <= 0)
		ink_level = "empty"
	. += span_notice("Its ink levels look [ink_level].")


/obj/item/airlock_painter/attackby(obj/item/W, mob/user, params)
	if(!istype(W, /obj/item/toner))
		return ..()
	if(ink)
		to_chat(user, span_warning("[src] already contains \a [ink]!"))
		return
	if(!user.transferItemToLoc(W, src))
		return
	to_chat(user, span_notice("You install [W] into [src]."))
	ink = W
	playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
	update_appearance(UPDATE_ICON)

/obj/item/airlock_painter/AltClick(mob/user, obj/item/W)
	. = ..()
	if(ink)
		playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
		ink.forceMove(user.drop_location())
		user.put_in_hands(ink)
		to_chat(user, span_notice("You remove [ink] from [src]."))
		ink = null
		update_appearance(UPDATE_ICON)

/obj/item/airlock_painter/decal
	name = "decal painter"
	desc = "An airlock painter, reprogrammed to use a different style of paint in order to apply decals for floor tiles as well, in addition to repainting doors. Decals break when the floor tiles are removed. Alt-Click to take out toner."
	icon = 'icons/obj/objects.dmi'
	icon_state = "decal_sprayer"
	item_state = "decal_sprayer"
	painter_mode = 2
	custom_materials = list(/datum/material/iron=50, /datum/material/glass=50)
	initial_ink_type = /obj/item/toner/large
	/// The current direction of the decal being printed
	var/stored_dir = 2
	/// The current color of the decal being printed.
	var/stored_color = "yellow"
	/// The current base icon state of the decal being printed.
	var/stored_decal = "warningline"
	/// The full icon state of the decal being printed.
	var/stored_decal_total = "warningline"
	/// The type path of the spritesheet being used for the frontend.
	var/spritesheet_type = /datum/asset/spritesheet/decals // spritesheet containing previews
	/// Does this printer implementation support custom colors?
	var/supports_custom_color = FALSE
	/// Current custom color
	var/stored_custom_color
	/// Is this painter a tile painter?
	var/tile_painter = FALSE
	/// Default alpha for /obj/effect/turf_decal
	var/default_alpha = 255
	/// List of color options as list(user-friendly label, color value to return)
	var/color_list = list(
		list("Yellow", "yellow"),
		list("Red", "red"),
		list("White", "white"),
	)
	/// List of direction options as list(user-friendly label, dir value to return)
	var/dir_list = list(
		list("North", NORTH),
		list("South", SOUTH),
		list("East", EAST),
		list("West", WEST),
		list("NorthEast", NORTHEAST),
		list("NorthWest", NORTHWEST),
		list("SouthEast", SOUTHEAST),
		list("SouthWest", SOUTHWEST)
	)
	/// List of decal options as list(user-friendly label, icon state base value to return)
	var/decal_list = list(list("Warning Line","warningline"),
			list("Warning Line Corner","warninglinecorner"),
			list("Warning Line U Corner","warn_end"),
			list("Warning Line Box","warn_box"),
			list("Caution Label","caution"),
			list("Directional Arrows","arrows"),
			list("Stand Clear Label","stand_clear"),
			list("Box Corner","box_corners"),
			list("Loading Arrow","loadingarea"),
			list("Delivery Marker","delivery"),
			list("Warning Box","warn_full"),
			list("Box","box"),
			list("Bot","bot"),
			list("Bot Right","bot_right"),
			list("Bot Left","bot_left"),
			list("NO","no"),
			list("Radiation Hazard","radiation"),
			list("Circle Radiation Hazard","radiation_huge"),
			list("Bio Warning","bio"),
			list("Shock Warning","shock"),
			list("Danger Warning","danger"),
			list("Explosive Warning","explosives"),
			list("High Explosive Warning","explosives2"),
			list("Fire Warning","fire"),
			list("No Smoking","nosmoking2"),
			list("No Smoking Circle","nosmoking"),
			list("Safety First","safety"),
			list("Nanotrasen","nanotrasen"),
			list("RAVEN1","RAVEN1"),
			list("RAVEN2","RAVEN2"),
			list("RAVEN3","RAVEN3"),
			list("RAVEN4","RAVEN4"),
			list("RAVEN5","RAVEN5"),
			list("RAVEN6","RAVEN6"),
			list("RAVEN7","RAVEN7"),
			list("RAVEN8","RAVEN8"),
			list("RAVEN9","RAVEN9"),
			list("Rainbow", "rainbow"),
			list("Animated Red Circuit","rcircuitanim"),
			list("Animated Green Circuit","gcircuitanim"),
			list("Blue Circuit","bcircuit"),
			list("Green Circuit","gcircuit"),
			list("Red Circuit","rcircuit"),
			list("Disco Floor","disco"),
			list("Grimy Floor","grimy"),
			list("Chapel Floor","chapel"),
			list("Sepia Floor","sepia"),
			list("Pink Floor","pinkblack"),
			list("Blank & White Floor","blackwhite"),
			list("Yellow Floor","noslip"),
			list("Pod Floor","podfloor_light"),
			list("Freezer Floor","freezerfloor"),
			list("Dark Floor","elevatorshaft"),
			list("Recharge Station","recharge_floor"),
			list("Solar Panel","solarpanel"),
			list("Gaming Floor","eighties"),
			list("Planet Floor","planet"),
			list("Bamboo Floor","bamboo"),
			list("Grass Floor","grass2"),
			list("Sand","sand"),
			list("Asteroid Sand","asteroid"),
			list("Iron Sand","ironsand1"),
			list("Snow Floor","snow"),
			list("Ice Floor","ice"),
			list("Sandstone Vault","sandstonevault"),
			list("Rock Vault","rockvault"),
			list("Alien Vault","alienvault"),
			list("Alien Floor","alienpod5"),
			list("Wood Floor","wood"),
			list("Diamond Floor","diamond"),
			list("Gold Floor","gold"),
			list("Plasma Floor","plasma"),
			list("Silver Floor","silver"),
			list("Uranium Floor","uranium"),
			list("Titanium Floor","titanium_white"),
			list("Plastitanium Floor","plastitanium"),
			list("Bluespace Floor","bluespace"),
			list("Reinforced Floor","engine"),
			list("Bananium Floor","bananium"),
			list("Brick Floor","terracotta"),
			list("Copper Floor","copper"),
			list("Clockwork Floor","clockwork_floor"),
			list("Cult Floor","cult"),
			list("Paper Floor","paperfloor"),
			list("Lavaland Floor","basalt1"),
			list("Hierophant Floor","hiero"),
			list("Wobby Hierophant Floor","hierophant1"),
			list("Necro Floor","necro1"),
			list("Lava","lava"),
			list("River Water","riverwater_motion"),
			list("Liquid Plasma","liquidplasma"),
			list("Error","error"),
			list("01010101","binary"),
			list("Space","space")

			
	)
	// These decals only have a south sprite.
	var/nondirectional_decals = list(
		"bot",
		"box",
		"rainbow",
		"delivery",
		"warn_full",
		"warn_box",
		"bot_right",
		"bot_left",
		"no",
		"radiation",
		"radiation_huge",
		"bio",
		"shock",
		"danger",
		"explosives",
		"explosives2",
		"fire",
		"nosmoking2",
		"nosmoking",
		"safety",
		"nanotrasen",
		"RAVEN1",
		"RAVEN2",
		"RAVEN3",
		"RAVEN4",
		"RAVEN5",
		"RAVEN6",
		"RAVEN7",
		"RAVEN8",
		"RAVEN9",
		"rcircuitanim",
		"gcircuitanim",
		"bcircuit",
		"gcircuit",
		"rcircuit",
		"disco",
		"grimy",
		"chapel",
		"sepia",
		"pinkblack",
		"blackwhite",
		"noslip",
		"podfloor_light",
		"freezerfloor",
		"elevatorshaft",
		"recharge_floor",
		"solarpanel",
		"eighties",
		"planet",
		"bamboo",
		"grass2",
		"sand",
		"asteroid",
		"ironsand1",
		"snow",
		"ice",
		"sandstonevault",
		"rockvault",
		"alienvault",
		"alienpod5",
		"wood",
		"diamond",
		"gold",
		"plasma",
		"silver",
		"uranium",
		"titanium_white",
		"plastitanium",
		"bluespace",
		"engine",
		"bananium",
		"terracotta",
		"copper",
		"clockwork_floor",
		"cult",
		"paperfloor",
		"basalt1",
		"hiero",
		"hierophant1",
		"necro1",
		"lava",
		"riverwater_motion",
		"liquidplasma",
		"error",
		"binary",
		"space",
	)

/obj/item/airlock_painter/decal/Initialize(mapload)
	. = ..()
	stored_custom_color = stored_color

/obj/item/airlock_painter/decal/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		to_chat(user, span_notice("You need to get closer!"))
		return

	if(isfloorturf(target) && use_paint(user))
		paint_floor(target)

/**
 * Actually add current decal to the floor.
 *
 * Responsible for actually adding the element to the turf for maximum flexibility.area
 * Can be overriden for different decal behaviors.
 * Arguments:
 * * target - The turf being painted to
*/
/obj/item/airlock_painter/decal/proc/paint_floor(turf/open/floor/target)
	target.AddElement(/datum/element/decal, 'icons/turf/decals.dmi', stored_decal_total, stored_dir, null, null, default_alpha, color, null, FALSE, null)

/**
 * Return the final icon_state for the given decal options
 *
 * Arguments:
 * * decal - the selected decal base icon state
 * * color - the selected color
 * * dir - the selected dir
 */
/obj/item/airlock_painter/decal/proc/get_decal_path(decal, color, dir)
	// Special case due to icon_state names
	if(color == "yellow")
		color = ""

	return "[decal][color ? "_" : ""][color]"

/obj/item/airlock_painter/decal/proc/update_decal_path()
	stored_decal_total = get_decal_path(stored_decal, stored_color, stored_dir)

/obj/item/airlock_painter/decal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DecalPainter", name)
		ui.open()

/obj/item/airlock_painter/decal/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(spritesheet_type)

/obj/item/airlock_painter/decal/ui_static_data(mob/user)
	. = ..()
	var/datum/asset/spritesheet/icon_assets = get_asset_datum(spritesheet_type)

	.["icon_prefix"] = "[icon_assets.name]32x32"
	.["supports_custom_color"] = supports_custom_color
	.["decal_list"] = list()
	.["color_list"] = list()
	.["dir_list"] = list()
	.["nondirectional_decals"] = nondirectional_decals

	for(var/decal in decal_list)
		.["decal_list"] += list(list(
			"name" = decal[1],
			"decal" = decal[2],
		))
	for(var/color in color_list)
		.["color_list"] += list(list(
			"name" = color[1],
			"color" = color[2],
		))
	for(var/dir in dir_list)
		.["dir_list"] += list(list(
			"name" = dir[1],
			"dir" = dir[2],
		))

/obj/item/airlock_painter/decal/ui_data(mob/user)
	. = ..()
	.["current_decal"] = stored_decal
	.["current_color"] = stored_color
	.["current_dir"] = stored_dir
	.["current_custom_color"] = stored_custom_color
	.["tile_painter"] = tile_painter

/obj/item/airlock_painter/decal/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		//Lists of decals and designs
		if("select decal")
			var/selected_decal = params["decal"]
			var/selected_dir = text2num(params["dir"])
			stored_decal = selected_decal
			stored_dir = selected_dir
		if("select color")
			var/selected_color = params["color"]
			stored_color = selected_color
		if("pick custom color")
			if(supports_custom_color)
				var/chosen_color = input(usr, "Pick new color", "[src]", "yellow") as color|null
				if(!chosen_color || QDELETED(src) || usr.incapacitated() || !usr.is_holding(src))
					return
				stored_custom_color = chosen_color
				stored_color = chosen_color
	update_decal_path()
	. = TRUE



/obj/item/airlock_painter/decal/tile
	name = "tile sprayer"
	desc = "An airlock painter, reprogramed to use a different style of paint in order to spray colors on floor tiles as well, in addition to repainting doors. Decals break when the floor tiles are removed."
//	desc_controls = "Alt-Click to remove the ink cartridge."
	icon_state = "tile_sprayer"
	stored_dir = 2
	stored_color = "#D4D4D4"
	stored_decal = "tile_corner"
	spritesheet_type = /datum/asset/spritesheet/decals/tiles
	supports_custom_color = TRUE
	tile_painter = TRUE
	dir_list = list(
		list("North", NORTH),
		list("South", SOUTH),
		list("East", EAST),
		list("West", WEST),
		list("NorthEast", NORTHEAST),
		list("NorthWest", NORTHWEST),
		list("SouthEast", SOUTHEAST),
		list("SouthWest", SOUTHWEST)
	)
	// Colors can have a an alpha component as RGBA, or just be RGB and use default alpha
	color_list = list(
		list("Neutral", "#D4D4D4"),
		list("Dark", "#0e0f0f"),
		list("Bar Burgundy", "#791500"),
		list("Sec Red", "#DE3A3A"),
		list("Cargo Brown", "#A46106"),
		list("Engi Yellow", "#CCB223"),
		list("Service Green", "#9FED58"),
		list("Med Blue", "#52B4E9"),
		list("R&D Purple", "#D381C9"),
	)
	decal_list = list(
		list("Siding Corner", "siding_corner"),
		list("Siding End", "siding_end"),
		list("Siding Thinplating Corner", "siding_thinplating_corner"),
		list("Siding Thinplating End", "siding_thinplating_end"),
		list("Siding Thinplating Line", "siding_thinplating_line"),
		list("Siding Wideplating Corner", "siding_wideplating_corner"),
		list("Siding Wideplating End", "siding_wideplating_end"),
		list("Siding Wideplating Line", "siding_wideplating_line"),
		list("Siding Wood Corner", "siding_wood_corner"),
		list("Siding Wood End", "siding_wood_end"),
		list("Siding Wood Line", "siding_wood_line"),
		list("Siding Line", "siding_line"),
		list("Trimline", "trimline"),
		list("Trimline Arrow CCw", "trimline_arrow_ccw"),
		list("Trimline Arrow Ccw Fill", "trimline_arrow_ccw_fill"),
		list("Trimline Arrow Cw", "trimline_arrow_cw"),
		list("Trimline Arrow Cw Fill", "trimline_arrow_cw_fill"),
		list("Trimline Box", "trimline_box"),
		list("Trimline Box Fill", "trimline_box_fill"),
		list("Trimline Box Fill Lower", "trimline_box_fill_lower"),
		list("Trimline Corner", "trimline_corner"),
		list("Trimline Corner Fill", "trimline_corner_fill"),
		list("Trimline Corner Lower", "trimline_corner_lower"),
		list("Trimline Corner Lower Warn", "trimline_corner_lower_warn"),
		list("Trimline Corner Lower Warn Flip", "trimline_corner_lower_warn_flip"),
		list("Trimline End Fill", "trimline_end_fill"),
		list("Trimline End Fill Lower", "trimline_end_fill_lower"),
		list("Trimline Fill", "trimline_fill"),
		list("Trimline Fill Lower", "trimline_fill_lower"),
		list("Trimline Shrink Ccw", "trimline_shrink_ccw"),
		list("Trimline Shrink Ccw Lower", "trimline_shrink_ccw_lower"),
		list("Trimline Shrink Cw", "trimline_shrink_cw"),
		list("Trimline Shrink Cw Lower", "trimline_shrink_cw_lower"),
		list("Trimline Warn", "trimline_warn"),
		list("Trimline Warn End Fill Lower", "trimline_warn_end_fill_lower"),
		list("Trimline Warn Fill", "trimline_warn_fill"),
		list("Trimline Warn Fill Flip", "trimline_warn_fill_flip"),
		list("Trimline Warn Lower", "trimline_warn_lower"),
		list("Trimline Warn Lower Flip", "trimline_warn_lower_flip"),
		list("Trimline Warn Lower Nobottom", "trimline_warn_lower_nobottom"),
		list("Trimline Warn Lower Nobottom Flip", "trimline_warn_lower_notbottom_flip"),
		list("4 Corners", "tile_fourcorners"),
		list("Diagonal", "diagonal_centre"),
		list("Corner", "tile_corner"),
		list("Half", "tile_half_contrasted"),
		list("Opposing Corners", "tile_opposing_corners"),
		list("3 Corners", "tile_anticorner_contrasted"),

	)
	nondirectional_decals = list(
		"tile_fourcorners",
		"trimline_box_fill_lower",
		"diagonal_centre",
		"trimline_box_fill",
		"trimline_box",
		
	)

	/// Regex to split alpha out.
	var/static/regex/rgba_regex = new(@"(#[0-9a-fA-F]{6})([0-9a-fA-F]{2})")

/obj/item/airlock_painter/decal/tile/paint_floor(turf/open/floor/target)
	// Account for 8-sided decals.
	var/source_decal = stored_decal
	var/source_dir = stored_dir
	if(copytext(stored_decal, -3) == "__8")
		source_decal = splicetext(stored_decal, -3, 0, "")
		source_dir = turn(stored_dir, 45)

	var/decal_color = stored_color
	var/decal_alpha = default_alpha
	// Handle the RGBA case.
	if(rgba_regex.Find(decal_color))
		decal_color = rgba_regex.group[1]
		decal_alpha = text2num(rgba_regex.group[2], 16)

	target.AddElement(/datum/element/decal, 'icons/turf/decals.dmi', source_decal, source_dir, null, null, decal_alpha, decal_color, null, FALSE, null)
