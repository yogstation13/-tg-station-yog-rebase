/proc/getGolemType(obj/item/stack/sheet/S)
	if(!istype(S))
		return null
	var/static/list/golemTypes = list(
	/obj/item/stack/sheet/metal				= /datum/species/golem/iron,
	/obj/item/stack/sheet/mineral/plasma	= /datum/species/golem/plasma,
	/obj/item/stack/sheet/mineral/diamond	= /datum/species/golem/diamond,
	/obj/item/stack/sheet/mineral/gold		= /datum/species/golem/gold,
	/obj/item/stack/sheet/mineral/silver	= /datum/species/golem/silver,
	/obj/item/stack/sheet/mineral/uranium	= /datum/species/golem/uranium,
	/obj/item/stack/sheet/glass				= /datum/species/golem/glass,
	/obj/item/stack/sheet/rglass			= /datum/species/golem/glass/r_glass,
	/obj/item/stack/sheet/mineral/abductor	= /datum/species/golem/alloy,
	/obj/item/stack/sheet/mineral/sandstone	= /datum/species/golem/sand,
	/obj/item/stack/sheet/mineral/wood		= /datum/species/golem/wood,
	/obj/item/stack/sheet/mineral/mythril	= /datum/species/golem/mythril,
	/obj/item/stack/sheet/mineral/bananium	= /datum/species/golem/bananium,
	/obj/item/stack/sheet/plasteel			= /datum/species/golem/plasteel
	)
	return golemTypes[S.merge_type]
