//Colored pipes, use these for mapping

#define HELPER_PARTIAL(Fulltype, Type, Iconbase, Color) \
	##Fulltype {						\
		pipe_color = Color;				\
		color = Color;					\
	}									\
	##Fulltype/visible { \
		hide = FALSE; \
		layer = GAS_PIPE_VISIBLE_LAYER; \
		FASTDMM_PROP(pipe_group = "atmos-[piping_layer]-"+Type+"-visible");\
	}									\
	##Fulltype/visible/layer2 {			\
		piping_layer = 2;				\
		icon_state = Iconbase + "-2";	\
	}									\
	##Fulltype/visible/layer4 {			\
		piping_layer = 4;				\
		icon_state = Iconbase + "-4";	\
	}									\
	##Fulltype/hidden {					\
		hide = TRUE;		\
		FASTDMM_PROP(pipe_group = "atmos-[piping_layer]-"+Type+"-hidden");\
	}									\
	##Fulltype/hidden/layer2 {			\
		piping_layer = 2;				\
		icon_state = Iconbase + "-2";	\
	}									\
	##Fulltype/hidden/layer4 {			\
		piping_layer = 4;				\
		icon_state = Iconbase + "-4";	\
	}

#define HELPER_PARTIAL_NAMED(Fulltype, Type, Iconbase, Color, Name) \
	HELPER_PARTIAL(Fulltype, Type, Iconbase, Color)	\
	##Fulltype {								\
		name = Name;							\
	}

#define HELPER(Type, Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/smart/simple/##Type, "pipe11", Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/smart/manifold/##Type, "manifold", Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/smart/manifold4w/##Type, "manifold4w", Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/bridge_pipe/##Type, "bridge_map", Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/layer_manifold/##Type, "manifoldlayer", Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/components/binary/pump/off/##Type, "pump_map", Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/components/binary/pump/on/##Type, "pump_on_map", Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/multiz/##Type, "adapter", Color) \

#define HELPER_NAMED(Type, Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/smart/simple/##Type, "pipe11", Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/smart/manifold/##Type, "manifold", Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/smart/manifold4w/##Type, "manifold4w", Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/bridge_pipe/##Type, "bridge_map", Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/layer_manifold/##Type, "manifoldlayer", Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/components/binary/pump/off/##Type, "pump_map", Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/components/binary/pump/on/##Type, "pump_on_map", Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/multiz/##Type, "adapter", Name, Color) \

HELPER(yellow, COLOR_YELLOW)
HELPER(general, COLOR_VERY_LIGHT_GRAY)
HELPER(cyan, COLOR_CYAN)
HELPER(green, COLOR_VIBRANT_LIME)
HELPER(orange, COLOR_TAN_ORANGE)
HELPER(purple, COLOR_PURPLE)
HELPER(dark, COLOR_DARK)
HELPER(brown, COLOR_BROWN)
HELPER(violet, COLOR_STRONG_VIOLET)
HELPER(pink, COLOR_LIGHT_PINK)

HELPER_NAMED(scrubbers, "scrubbers pipe", COLOR_RED)
HELPER_NAMED(supply, "air supply pipe", COLOR_BLUE)

#undef HELPER_NAMED
#undef HELPER
#undef HELPER_PARTIAL_NAMED
#undef HELPER_PARTIAL
