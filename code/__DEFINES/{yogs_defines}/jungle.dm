#define ORE_TURF "ore_turf"
#define ORE_PLASMA "plasma"
#define ORE_IRON "iron"
#define ORE_URANIUM "uranium"
#define ORE_TITANIUM "titanium"
#define ORE_BLUESPACE "bluespace"
#define ORE_GOLD "gold"
#define ORE_SILVER "silver"
#define ORE_DIAMOND "diamond"
#define ORE_DILITHIUM "dilithium"
#define ORE_EMPTY "empty"


#define MINETYPE_JUNGLE "jungle"
#define MINETYPE_LAVALAND "lavaland"
#define MINETYPE_ICEMOON "icemoon"
GLOBAL_VAR(minetype)

GLOBAL_LIST_INIT(jungle_ores, list( \
		ORE_IRON = new /datum/ore_patch/iron(), 
		ORE_GOLD = new /datum/ore_patch/gold(), 
		ORE_SILVER = new /datum/ore_patch/silver(), 
		ORE_PLASMA = new /datum/ore_patch/plasma(), 
		ORE_DIAMOND = new /datum/ore_patch/diamond(), 
		ORE_TITANIUM = new /datum/ore_patch/titanium(), 
		ORE_URANIUM = new /datum/ore_patch/uranium(),
		ORE_BLUESPACE = new /datum/ore_patch/bluespace(),
		ORE_DILITHIUM = new /datum/ore_patch/dilithium()
))

GLOBAL_LIST_INIT(quarry_ores, list( \
		ORE_IRON = new /datum/ore_patch/iron(), 
		ORE_GOLD = new /datum/ore_patch/gold(), 
		ORE_SILVER = new /datum/ore_patch/silver(), 
		ORE_PLASMA = new /datum/ore_patch/plasma(), 
))


GLOBAL_LIST_EMPTY(tar_pits)
