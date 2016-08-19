/mob/living/simple_animal/hostile/megafauna
	name = "boss of this gym"
	desc = "Attack the weak point for massive damage."
	health = 1000
	maxHealth = 1000
	a_intent = "harm"
	sentience_type = SENTIENCE_BOSS
	environment_smash = 3
	luminosity = 3
	weather_immunities = list("lava","ash")
	robust_searching = 1
	stat_attack = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	layer = LARGE_MOB_LAYER //Looks weird with them slipping under mineral walls and cameras and shit otherwise
	var/alert_admins

/mob/living/simple_animal/hostile/megafauna/death(gibbed)
	if(health > 0)
		return
	else
		feedback_set_details("megafauna_kills","[initial(name)]")
		..()

/mob/living/simple_animal/hostile/megafauna/gib()
	if(health > 0)
		return
	else
		..()

/mob/living/simple_animal/hostile/megafauna/dust()
	if(health > 0)
		return
	else
		..()

/mob/living/simple_animal/hostile/megafauna/AttackingTarget()
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			if(ranged && ranged_cooldown <= world.time)
				OpenFire()


/mob/living/simple_animal/hostile/megafauna/onShuttleMove()
	var/turf/oldloc = loc
	. = ..()
	if(!.)
		return
	var/turf/newloc = loc
	message_admins("Megafauna [src] \
		(<A HREF='?_src_=holder;adminplayerobservefollow=\ref[src]'>FLW</A>) \
		moved via shuttle from ([oldloc.x],[oldloc.y],[oldloc.z]) to \
		([newloc.x],[newloc.y],[newloc.z])")

/mob/living/simple_animal/hostile/megafauna/Life()
	..()
	if((loc.z != ZLEVEL_LAVALAND) && !alert_admins)
		message_admins("A live [src.name] ([src.desc]) has left the lavaland and is currently on another z level. <A HREF='?_src_=holder;adminplayerobservefollow=\ref[src]'>FLW</A> ([loc.x], [loc.y], [loc.z])")
		log_admin("[src] is off of the lavaland.")
		alert_admins = !alert_admins
		spawn(3000) // a cooldown, so it'll alert the admins again if it's still off the z level.
			alert_admins = !alert_admins