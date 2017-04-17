/mob/living/simple_animal/hostile/megafauna/colossus
	name = "colossus"
	desc = "A monstrous creature protected by heavy shielding."
	health = 2500
	maxHealth = 2500
	attacktext = "judges"
	attack_sound = 'sound/magic/clockwork/ratvar_attack.ogg'
	icon_state = "eva"
	icon_living = "eva"
	icon_dead = "dragon_dead"
	friendly = "stares down"
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	faction = list("mining")
	weather_immunities = list("lava","ash")
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 1
	move_to_delay = 10
	ranged = 1
	flying = 1
	mob_size = MOB_SIZE_LARGE
	pixel_x = -32
	aggro_vision_range = 18
	idle_vision_range = 5
	del_on_death = 1
	loot = list(/obj/machinery/smartfridge/black_box)
	butcher_results = list(/obj/item/weapon/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/animalhide/ashdrake = 10, /obj/item/stack/sheet/bone = 30)

	deathmessage = "disintegrates, leaving a glowing core in its wake."
	death_sound = 'sound/magic/demon_dies.ogg'
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	var/anger_modifier = 0
	var/obj/item/device/gps/internal

/mob/living/simple_animal/hostile/megafauna/colossus/OpenFire()
	anger_modifier = Clamp(((maxHealth - health)/50),0,20)
	ranged_cooldown = (world.time + 120) / scaling

	if(prob(20+anger_modifier)) //Major attack
		telegraph()

		if(health < maxHealth/3)
			double_spiral()
		else
			visible_message("<span class='cult'><font size=5>\"<b>Judgement.</b>\"</font></span>")
			spiral_shoot(rand(0, 1))

	else if(prob(20))
		ranged_cooldown = (world.time + 30) / scaling
		random_shots()
	else
		if(prob(70))
			ranged_cooldown = (world.time + 20) / scaling
			blast()
		else
			ranged_cooldown = (world.time + 40) / scaling
			dir_shots(diagonals)
			sleep(10 / scaling)
			dir_shots(cardinal)
			sleep(10 / scaling)
			dir_shots(diagonals)
			sleep(10 / scaling)
			dir_shots(cardinal)


/mob/living/simple_animal/hostile/megafauna/colossus/New()
	..()
	internal = new/obj/item/device/gps/internal/lavaland/colossus(src)

// VAR SCALING //
	rawScaling = rand(70,150)
	scaling = rawScaling / 100
	maxHealth = round(maxHealth * scaling, 1)
	health = round(health * scaling, 1)
	move_to_delay = move_to_delay / scaling

	if(rawScaling < 80)
		var/prefix = "miserable"
		name = "[prefix] [name]"
		return
	if(rawScaling < 99 && rawScaling > 80)
		var/prefix = "crippled"
		name = "[prefix] [name]"
		return
	if(rawScaling >= 100 && rawScaling <= 120)
		var/prefix = "dangerous"
		name = "[prefix] [name]"
		loot += /obj/item/weapon/ore/diamond
		return
	if(rawScaling > 120 && rawScaling < 145)
		var/prefix = "powerful"
		name = "[prefix] [name]"
		loot += list(/obj/item/weapon/ore/diamond, /obj/item/weapon/ore/diamond)
		return
	if(rawScaling > 145)
		var/prefix = "perfect"
		name = "[prefix] [name]"
		loot += list(/obj/item/weapon/ore/diamond, /obj/item/weapon/ore/diamond)
		loot += pick(/obj/item/clothing/suit/space/hardsuit/shielded, /obj/item/weapon/shield/energy, /obj/item/organ/cyberimp/eyes/shield) //Third one being a fuck you, seeing as mining loves to have these.
		return

// VAR SCALING END //

/mob/living/simple_animal/hostile/megafauna/colossus/Destroy()
	qdel(internal)
	. = ..()

/obj/effect/overlay/temp/at_shield
	name = "anti-toolbox field"
	desc = "A shimmering forcefield protecting the colossus."
	icon = 'icons/effects/effects.dmi'
	icon_state = "at_shield2"
	layer = FLY_LAYER
	luminosity = 2
	duration = 80
	var/target

/obj/effect/overlay/temp/at_shield/New()
	..()
	spawn()
		orbit(target, 0, FALSE, 0, 0, FALSE, TRUE)

/mob/living/simple_animal/hostile/megafauna/colossus/bullet_act(obj/item/projectile/P)
	if(!stat)
		var/obj/effect/overlay/temp/at_shield/AT = new(src.loc)
		AT.target = src
		var/random_x = rand(-32, 32)
		AT.pixel_x += random_x

		var/random_y = rand(0, 72)
		AT.pixel_y += random_y
	..()


/mob/living/simple_animal/hostile/megafauna/colossus/proc/double_spiral()
	visible_message("<span class='cult'><font size=5>\"<b>Die.</b>\"</font></span>")

	sleep(10/scaling)
	spawn()
		spiral_shoot()
	spawn()
		spiral_shoot(1)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/spiral_shoot(negative = 0, counter_start = 1)
	spawn()
		var/counter = counter_start
		var/turf/marker
		for(var/i in 1 to round(80*scaling, 16))
			switch(counter)
				if(1)
					marker = locate(x, y - 2, z)
				if(2)
					marker = locate(x - 1,y - 2, z)
				if(3)
					marker = locate(x - 2, y - 2, z)
				if(4)
					marker = locate(x - 2, y - 1, z)
				if(5)
					marker = locate (x - 2 , y, z)
				if(6)
					marker = locate(x - 2, y + 1, z)
				if(7)
					marker = locate(x - 2, y + 2, z)
				if(8)
					marker = locate(x - 1, y + 2, z)
				if(9)
					marker = locate(x, y + 2, z)
				if(10)
					marker = locate(x + 1, y + 2, z)
				if(11)
					marker = locate(x + 2, y + 2, z)
				if(12)
					marker = locate(x + 2, y + 1, z)
				if(13)
					marker = locate(x + 2, y, z)
				if(14)
					marker = locate(x + 2, y - 1, z)
				if(15)
					marker = locate(x + 2, y - 2, z)
				if(16)
					marker = locate(x + 1, y - 2, z)

			if(negative)
				counter--
			else
				counter++
			if(counter > 16)
				counter = 0
			if(counter < 0)
				counter = 16
			shoot_projectile(marker)
			sleep(1)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/shoot_projectile(turf/marker)
	if(!marker)
		return
	var/turf/startloc = get_turf(src)
	var/obj/item/projectile/P = new /obj/item/projectile/colossus(startloc)
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 100, 1)
	P.current = startloc
	P.starting = startloc
	P.firer = src
	P.yo = marker.y - startloc.y
	P.xo = marker.x - startloc.x
	P.damage = round(P.damage * src.scaling, 1)
	P.speed = P.speed / src.scaling
	if(target)
		P.original = target
	else
		P.original = marker
	P.fire()

/mob/living/simple_animal/hostile/megafauna/colossus/proc/random_shots()
	for(var/turf/turf in range(12,get_turf(src)))
		if(prob(5))
			shoot_projectile(turf)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/blast()
	spawn()
		var/turf/T = get_turf(target)
		for(var/turf/turf in range(1, T))
			shoot_projectile(turf)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/dir_shots(list/dirs)
	if(!islist(dirs))
		dirs = alldirs.Copy()
	for(var/d in dirs)
		var/turf/E = get_step(src, d)
		shoot_projectile(E)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/telegraph()
	for(var/mob/M in range(10*scaling,src))
		if(M.client)
			M.client.color = rgb(200, 0, 0)
			spawn(1)
				M.client.color = initial(M.client.color)
			shake_camera(M, 4, 3)
	playsound(get_turf(src),'sound/magic/clockwork/narsie_attack.ogg', 200, 1)



/obj/item/projectile/colossus
	name ="death bolt"
	icon_state= "chronobolt"
	damage = 25
	armour_penetration = 100
	speed = 2
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE

/obj/item/projectile/colossus/on_hit(atom/target, blocked = 0)
	. = ..()
	if(istype(target,/turf/)||istype(target,/obj/structure/))
		target.ex_act(2)


/obj/item/device/gps/internal/lavaland/colossus
	icon_state = null
	gpstag = "Angelic Signal"
	desc = "Get in the fucking robot."
	invisibility = 100



//Black Box

/obj/machinery/smartfridge/black_box
	name = "black box"
	desc = "A completely indestructible chunk of crystal, rumoured to predate the start of this universe. It looks like you could store things inside it."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_on = "blackbox"
	icon_off = "blackbox"
	luminosity = 8
	max_n_of_items = 10
	pixel_y = -4
	use_power = 0
	var/duplicate = FALSE
	var/memory_saved = FALSE
	var/list/stored_items = list()
	var/list/blacklist = (/obj/item/weapon/spellbook)

/obj/machinery/smartfridge/black_box/accept_check(obj/item/O)
	if(O.type in blacklist)
		return
	if(istype(O, /obj/item))
		return 1
	return 0

/obj/machinery/smartfridge/black_box/New()
	..()
	for(var/obj/machinery/smartfridge/black_box/B in machines)
		if(B != src)
			duplicate = 1
			qdel(src)
	ReadMemory()

/obj/machinery/smartfridge/black_box/process()
	..()
	if(ticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		WriteMemory()

/obj/machinery/smartfridge/black_box/proc/WriteMemory()
	var/savefile/S = new /savefile("data/npc_saves/Blackbox.sav")
	stored_items = list()
	for(var/obj/I in component_parts)
		qdel(I)
	for(var/obj/O in contents)
		stored_items += O.type
	S["stored_items"]				<< stored_items
	memory_saved = TRUE

/obj/machinery/smartfridge/black_box/proc/ReadMemory()
	var/savefile/S = new /savefile("data/npc_saves/Blackbox.sav")
	S["stored_items"] 		>> stored_items

	if(isnull(stored_items))
		stored_items = list()

	for(var/item in stored_items)
		new item(src)


/obj/machinery/smartfridge/black_box/Destroy()
	if(duplicate)
		return ..()
	else
		return QDEL_HINT_LETMELIVE


//No taking it apart

/obj/machinery/smartfridge/black_box/default_deconstruction_screwdriver()
	return

/obj/machinery/smartfridge/black_box/exchange_parts()
	return


/obj/machinery/smartfridge/black_box/default_pry_open()
	return


/obj/machinery/smartfridge/black_box/default_unfasten_wrench()
	return

/obj/machinery/smartfridge/black_box/default_deconstruction_crowbar()
	return