//In this file: Summon Magic/Summon Guns/Summon Events

/proc/summon_guns(mob/user, survivor_probability)

	if(user)
		user << "<B>You summoned guns!</B>"
		message_admins("[key_name_admin(user, 1)] summoned guns!")
		log_game("[key_name(user)] summoned guns!")

	var/list/gunslist = list("taser","egun","laser","revolver","detective","c20r","nuclear","deagle","gyrojet","pulse","suppressed","cannon","doublebarrel","shotgun","combatshotgun","bulldog","mateba","sabr","crossbow","saw","car","boltaction","speargun","arg","uzi","alienpistol","dragnet","turret","pulsecarbine","decloner","mindflayer","hyperkinetic","advplasmacutter","wormhole","wt550","bulldog","grenadelauncher","goldenrevolver","sniper","medibeam","scatterbeam")
	var/list/candidates = ticker.mode.get_playing_crewmembers_for_role(0, null, 1)
	for(var/V in candidates)
		var/mob/living/carbon/human/H = V
		if(prob(survivor_probability))
			ticker.mode.traitors += H.mind
			var/datum/objective/summon_guns/guns = new
			guns.owner = H.mind
			H.mind.objectives += guns
			H.mind.special_role = "survivalist"
			var/datum/objective/survive/survive = new
			survive.owner = H.mind
			H.mind.objectives += survive
			H.attack_log += "\[[time_stamp()]\] <font color='red'>Was made into a survivalist, and trusts no one!</font>"
			H << "<B>You are the survivalist! Your own safety matters above all else, and the only way to ensure your safety is to stockpile weapons! Grab as many guns as possible, by any means necessary. Kill anyone who gets in your way.</B>"
			H.mind.show_memory()

		var/randomizeguns = pick(gunslist)
		var/obj/item/weapon/gun/G
		switch (randomizeguns)
			if("taser")
				G = new /obj/item/weapon/gun/energy/gun/advtaser(get_turf(H))
			if("egun")
				G = new /obj/item/weapon/gun/energy/gun(get_turf(H))
			if("laser")
				G = new /obj/item/weapon/gun/energy/laser(get_turf(H))
			if("revolver")
				G = new /obj/item/weapon/gun/projectile/revolver(get_turf(H))
			if("detective")
				G = new /obj/item/weapon/gun/projectile/revolver/detective(get_turf(H))
			if("deagle")
				G = new /obj/item/weapon/gun/projectile/automatic/pistol/deagle/camo(get_turf(H))
			if("gyrojet")
				G = new /obj/item/weapon/gun/projectile/automatic/gyropistol(get_turf(H))
			if("pulse")
				G = new /obj/item/weapon/gun/energy/pulse(get_turf(H))
			if("suppressed")
				G = new /obj/item/weapon/gun/projectile/automatic/pistol(get_turf(H))
				new /obj/item/weapon/suppressor(get_turf(H))
			if("doublebarrel")
				G = new /obj/item/weapon/gun/projectile/revolver/doublebarrel(get_turf(H))
			if("shotgun")
				G = new /obj/item/weapon/gun/projectile/shotgun(get_turf(H))
			if("combatshotgun")
				G = new /obj/item/weapon/gun/projectile/shotgun/automatic/combat(get_turf(H))
			if("arg")
				G = new /obj/item/weapon/gun/projectile/automatic/ar(get_turf(H))
			if("mateba")
				G = new /obj/item/weapon/gun/projectile/revolver/mateba(get_turf(H))
			if("boltaction")
				G = new /obj/item/weapon/gun/projectile/shotgun/boltaction(get_turf(H))
			if("speargun")
				G = new /obj/item/weapon/gun/projectile/automatic/speargun(get_turf(H))
			if("uzi")
				G = new /obj/item/weapon/gun/projectile/automatic/mini_uzi(get_turf(H))
			if("cannon")
				G = new /obj/item/weapon/gun/energy/lasercannon(get_turf(H))
			if("crossbow")
				G = new /obj/item/weapon/gun/energy/crossbow/large(get_turf(H))
			if("nuclear")
				G = new /obj/item/weapon/gun/energy/gun/nuclear(get_turf(H))
			if("sabr")
				G = new /obj/item/weapon/gun/projectile/automatic/proto(get_turf(H))
			if("bulldog")
				G = new /obj/item/weapon/gun/projectile/automatic/shotgun/bulldog(get_turf(H))
			if("c20r")
				G = new /obj/item/weapon/gun/projectile/automatic/c20r(get_turf(H))
			if("saw")
				G = new /obj/item/weapon/gun/projectile/automatic/l6_saw(get_turf(H))
			if("car")
				G = new /obj/item/weapon/gun/projectile/automatic/m90(get_turf(H))
			if("alienpistol")
				G = new /obj/item/weapon/gun/energy/alien(get_turf(H))
			if("dragnet")
				G = new /obj/item/weapon/gun/energy/gun/dragnet(get_turf(H))
			if("turret")
				G = new /obj/item/weapon/gun/energy/gun/turret(get_turf(H))
			if("pulsecarbine")
				G = new /obj/item/weapon/gun/energy/pulse/carbine(get_turf(H))
			if("decloner")
				G = new /obj/item/weapon/gun/energy/decloner(get_turf(H))
			if("mindflayer")
				G = new /obj/item/weapon/gun/energy/mindflayer(get_turf(H))
			if("hyperkinetic")
				G = new /obj/item/weapon/gun/energy/kinetic_accelerator/hyper(get_turf(H))
			if("advplasmacutter")
				G = new /obj/item/weapon/gun/energy/plasmacutter/adv(get_turf(H))
			if("wormhole")
				G = new /obj/item/weapon/gun/energy/wormhole_projector(get_turf(H))
			if("wt550")
				G = new /obj/item/weapon/gun/projectile/automatic/wt550(get_turf(H))
			if("bulldog")
				G = new /obj/item/weapon/gun/projectile/automatic/shotgun(get_turf(H))
			if("grenadelauncher")
				G = new /obj/item/weapon/gun/projectile/revolver/grenadelauncher(get_turf(H))
			if("goldenrevolver")
				G = new /obj/item/weapon/gun/projectile/revolver/golden(get_turf(H))
			if("sniper")
				G = new /obj/item/weapon/gun/projectile/automatic/sniper_rifle(get_turf(H))
			if("medibeam")
				G = new /obj/item/weapon/gun/medbeam(get_turf(H))
			if("scatterbeam")
				G = new /obj/item/weapon/gun/energy/laser/scatter(get_turf(H))
		G.unlock()
		playsound(get_turf(H),'sound/magic/Summon_guns.ogg', 50, 1)


/proc/summon_magic(mob/user, antag_probability)

	if(user) //in this case either someone holding a spellbook or a badmin
		user << "<B>You summoned magic!</B>"
		message_admins("[key_name_admin(user, 1)] summoned magic!")
		log_game("[key_name(user)] summoned magic!")

	var/list/magiclist 			= list("fireball","smoke","blind","mindswap","forcewall","knock","horsemask","charge", "summonitem", "wandnothing", "wanddeath", "wandresurrection", "wandpolymorph", "wandteleport", "wanddoor", "wandfireball", "staffchange", "staffhealing", "armor", "scrying","staffdoor","voodoo", "special")
	var/list/magicspeciallist	= list("staffchange","staffanimation", "wandbelt", "contract", "staffchaos", "necromantic")
	var/list/candidates = ticker.mode.get_playing_crewmembers_for_role(0, null, 1)
	for(var/V in candidates)
		var/mob/living/carbon/human/H = V
		if(prob(antag_probability))
			ticker.mode.traitors += H.mind
			var/datum/atom_hud/antag/antag_hud = huds[ANTAG_HUD_SUMMON_MAGIC]
			antag_hud.join_hud(H)
			ticker.mode.set_antag_hud(H, "summonmagic")
			var/datum/objective/summon_magic/obj = new
			obj.owner = H.mind
			H.mind.objectives += obj
			H.mind.special_role = "adept"
			H.attack_log += "\[[time_stamp()]\] <font color='red'>Was made into an adept, and trusts no one!</font>"
			H << "<B>You are an adept! Collect magical artifacts and defeat all other adepts on the station, marked by the yellow and red hud icon, and perhaps a space wizard will take you as an apprentice.</B>"
			H.mind.show_memory()

		var/randomizemagic 			= pick(magiclist)
		var/randomizemagicspecial 	= pick(magicspeciallist)
		switch (randomizemagic)
			if("fireball")
				new /obj/item/weapon/spellbook/oneuse/fireball(get_turf(H))
			if("smoke")
				new /obj/item/weapon/spellbook/oneuse/smoke(get_turf(H))
			if("blind")
				new /obj/item/weapon/spellbook/oneuse/blind(get_turf(H))
			if("mindswap")
				new /obj/item/weapon/spellbook/oneuse/mindswap(get_turf(H))
			if("forcewall")
				new /obj/item/weapon/spellbook/oneuse/forcewall(get_turf(H))
			if("knock")
				new /obj/item/weapon/spellbook/oneuse/knock(get_turf(H))
			if("horsemask")
				new /obj/item/weapon/spellbook/oneuse/barnyard(get_turf(H))
			if("charge")
				new /obj/item/weapon/spellbook/oneuse/charge(get_turf(H))
			if("summonitem")
				new /obj/item/weapon/spellbook/oneuse/summonitem(get_turf(H))
			if("wandnothing")
				new /obj/item/weapon/gun/magic/wand(get_turf(H))
			if("wanddeath")
				new /obj/item/weapon/gun/magic/wand/death(get_turf(H))
			if("wandresurrection")
				new /obj/item/weapon/gun/magic/wand/resurrection(get_turf(H))
			if("wandpolymorph")
				new /obj/item/weapon/gun/magic/wand/polymorph(get_turf(H))
			if("wandteleport")
				new /obj/item/weapon/gun/magic/wand/teleport(get_turf(H))
			if("wanddoor")
				new /obj/item/weapon/gun/magic/wand/door(get_turf(H))
			if("wandfireball")
				new /obj/item/weapon/gun/magic/wand/fireball(get_turf(H))
			if("staffhealing")
				new /obj/item/weapon/gun/magic/staff/healing(get_turf(H))
			if("staffdoor")
				new /obj/item/weapon/gun/magic/staff/door(get_turf(H))
			if("armor")
				new /obj/item/clothing/suit/space/hardsuit/wizard(get_turf(H))
			if("scrying")
				new /obj/item/weapon/scrying(get_turf(H))
				if (!(H.dna.check_mutation(XRAY)))
					H.dna.add_mutation(XRAY)
					H << "<span class='notice'>The walls suddenly disappear.</span>"
			if("voodoo")
				new /obj/item/voodoo(get_turf(H))
			if("special")
				magiclist -= "special" //only one super OP item per summoning max
				switch (randomizemagicspecial)
					if("staffchange")
						new /obj/item/weapon/gun/magic/staff/change(get_turf(H))
					if("staffanimation")
						new /obj/item/weapon/gun/magic/staff/animate(get_turf(H))
					if("wandbelt")
						new /obj/item/weapon/storage/belt/wands/full(get_turf(H))
					if("contract")
						new /obj/item/weapon/antag_spawner/contract(get_turf(H))
					if("staffchaos")
						new /obj/item/weapon/gun/magic/staff/chaos(get_turf(H))
					if("necromantic")
						new /obj/item/device/necromantic_stone(get_turf(H))
				H << "<span class='notice'>You suddenly feel lucky.</span>"
		playsound(get_turf(H),'sound/magic/Summon_Magic.ogg', 50, 1)

/proc/summonevents()
	if(!SSevent.wizardmode)
		SSevent.frequency_lower = 600									//1 minute lower bound
		SSevent.frequency_upper = 3000									//5 minutes upper bound
		SSevent.toggleWizardmode()
		SSevent.reschedule()

	else 																//Speed it up
		SSevent.frequency_upper -= 600	//The upper bound falls a minute each time, making the AVERAGE time between events lessen
		if(SSevent.frequency_upper < SSevent.frequency_lower) //Sanity
			SSevent.frequency_upper = SSevent.frequency_lower

		SSevent.reschedule()
		message_admins("Summon Events intensifies, events will now occur every [SSevent.frequency_lower / 600] to [SSevent.frequency_upper / 600] minutes.")
		log_game("Summon Events was increased!")
