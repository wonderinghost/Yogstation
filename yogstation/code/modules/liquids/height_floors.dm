/obj/item/stack/tile/elevated
	name = "elevated floor tile"
	singular_name = "elevated floor tile"
	turf_type = /turf/open/floor/elevated
	merge_type = /obj/item/stack/tile/elevated
	icon = 'yogstation/icons/obj/items/tiles.dmi'
	icon_state = "elevated"

/obj/item/stack/tile/lowered
	name = "lowered floor tile"
	singular_name = "lowered floor tile"
	turf_type = /turf/open/floor/lowered
	merge_type = /obj/item/stack/tile/lowered
	icon = 'yogstation/icons/obj/items/tiles.dmi'
	icon_state = "lowered"

/obj/item/stack/tile/lowered/iron
	name = "lowered floor tile"
	singular_name = "lowered floor tile"
	turf_type = /turf/open/floor/lowered
	merge_type = /obj/item/stack/tile/lowered
	icon = 'yogstation/icons/obj/items/tiles.dmi'
	icon_state = "lowered"

/turf/open/floor/iron/pool/rust_heretic_act()
	return

/turf/open/floor/elevated
	name = "elevated floor"
	floor_tile = /obj/item/stack/tile/elevated
	icon = 'yogstation/icons/turf/floors/elevated_iron.dmi'
	icon_state = "elevated_plasteel-0"
	base_icon_state = "elevated_plasteel-0"
	smoothing_flags = SMOOTH_CORNERS
	smoothing_groups = SMOOTH_GROUP_ELEVATED_PLASTEEL
	canSmoothWith = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_ELEVATED_PLASTEEL
	liquid_height = 30
	turf_height = 30

/turf/open/floor/elevated/rust_heretic_act()
	return

/turf/open/floor/lowered
	name = "lowered floor"
	floor_tile = /obj/item/stack/tile/lowered
	icon = 'yogstation/icons/turf/floors/lowered_iron.dmi'
	icon_state = "lowered_plasteel-0"
	base_icon_state = "lowered_plasteel-0"
	smoothing_flags = SMOOTH_CORNERS
	smoothing_groups = SMOOTH_GROUP_LOWERED_PLASTEEL
	canSmoothWith = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_LOWERED_PLASTEEL
	liquid_height = -30
	turf_height = -30


/turf/open/floor/lowered/rust_heretic_act()
	return
