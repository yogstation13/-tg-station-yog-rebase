var/global/list/potentialRandomZlevels = generateMapList(filename = "config/awaymissionconfig.txt")

/proc/createRandomZlevel()
	if(awaydestinations.len)	//crude, but it saves another var!
		return

	if(potentialRandomZlevels && potentialRandomZlevels.len)
		world << "<span class='boldannounce'>Loading away mission...</span>"

		var/map = pick(potentialRandomZlevels)
		var/file = file(map)
		if(isfile(file))
			maploader.load_map(file)
			smooth_zlevel(world.maxz)
			world.log << "away mission loaded: [map]"

		map_transition_config.Add(AWAY_MISSION_LIST)

		for(var/obj/effect/landmark/L in landmarks_list)
			if (L.name != "awaystart")
				continue
			awaydestinations.Add(L)

		world << "<span class='boldannounce'>Away mission loaded.</span>"

		SortAreas() //To add recently loaded areas
	else
		world << "<span class='boldannounce'>No away missions found.</span>"
		return


/proc/generateMapList(filename)
	var/list/potentialMaps = list()
	var/list/Lines = file2list(filename)

	if(!Lines.len)
		return
	for (var/t in Lines)
		if (!t)
			continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))

		else
			name = lowertext(t)

		if (!name)
			continue

		potentialMaps.Add(t)

	return potentialMaps


/proc/seedRuins(z_level = 1, budget = 0, whitelist = /area/space, list/potentialRuins = space_ruins_templates)
	var/overall_sanity = 100
	var/ruins = potentialRuins.Copy()

	world << "<span class='boldannounce'>Loading ruins...</span>"

	while(budget > 0 && overall_sanity > 0)
		// Pick a ruin
		var/datum/map_template/ruin/ruin = ruins[pick(ruins)]
		// Can we afford it
		if(ruin.cost > budget)
			overall_sanity--
			continue
		// If so, try to place it
		var/sanity = 100
		// And if we can't fit it anywhere, give up, try again

		while(sanity > 0)
			sanity--
			var/turf/T = locate(rand(75, world.maxx - 75), rand(55, world.maxy - 55), z_level)
			var/valid = TRUE

			for(var/turf/check in ruin.get_affected_turfs(T,1))
				var/area/new_area = get_area(check)
				if(!(istype(new_area, whitelist)) || new_area.mapgen_protected)
					valid = FALSE
					break

			if(!valid)
				continue

			world.log << "Ruin \"[ruin.name]\" placed at ([T.x], [T.y], [T.z])"
			add_list_to_list(ruinAreas, list(ruin.name, T.x, T.y, T.z))

			var/obj/effect/ruin_loader/R = new /obj/effect/ruin_loader(T)
			R.Load(ruins,ruin)
			budget -= ruin.cost
			if(!ruin.allow_duplicates)
				ruins -= ruin.name
			break

	if(!overall_sanity)
		world.log << "Ruin loader gave up with [budget] left to spend."


/obj/effect/ruin_loader
	name = "random ruin"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "syndballoon"
	invisibility = 0

/obj/effect/ruin_loader/proc/Load(list/potentialRuins = space_ruins_templates, datum/map_template/template = null)
	var/list/possible_ruins = list()
	for(var/A in potentialRuins)
		var/datum/map_template/T = potentialRuins[A]
		if(!T.loaded)
			possible_ruins += T
	if(!template && possible_ruins.len)
		template = safepick(possible_ruins)
	if(!template)
		return FALSE
	for(var/i in template.get_affected_turfs(get_turf(src), 1))
		var/turf/T = i
		for(var/mob/living/simple_animal/monster in T)
			qdel(monster)
	template.load(get_turf(src),centered = TRUE)
	template.loaded++
	qdel(src)
	return TRUE
