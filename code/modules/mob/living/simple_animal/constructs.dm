/mob/living/simple_animal/hostile/construct
	name = "Construct"
	real_name = "Construct"
	desc = ""
	speak_emote = list("hisses")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	speak_chance = 1
	icon = 'icons/mob/mob.dmi'
	speed = 1
	a_intent = "harm"
	stop_automated_movement = 1
	status_flags = list(CANPUSH)
	attack_sound = 'sound/weapons/punch1.ogg'
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	healable = 0
	flying = 1
	pressure_resistance = 200
	unique_name = 1
	AIStatus = AI_OFF //normal constructs don't have AI
	loot = list(/obj/item/weapon/ectoplasm)
	del_on_death = 1
	deathmessage = "collapses in a shattered heap."
	var/list/construct_spells = list()
	var/playstyle_string = "<b>You are a generic construct! Your job is to not exist, and you should probably adminhelp this.</b>"
	var/phaser = FALSE
	var/affiliation = "Cult" // Cult, Wizard and Neutral. Or a color.


/mob/living/simple_animal/hostile/construct/New(var/loc, var/_affiliation)
	..()
	for(var/spell in construct_spells)
		AddSpell(new spell(null))
		if(_affiliation)
			affiliation = _affiliation
	addtimer(src, "set_affiliation", 1) //So the other code gets run first, which might change the affiliation

/mob/living/simple_animal/hostile/construct/proc/set_affiliation(var/_affiliation)
	if(_affiliation)
		affiliation = _affiliation
	overlays.Cut()
	var/image/I = image(icon, icon_state = "[icon_state]_o")
	switch(affiliation)
		if("Cult")
			faction |= list("cult")
			I.color = color2hex("red")
			overlays += I
		if("Wizard")
			faction |= list("wizard")
			ticker.mode.update_wiz_icons_added(mind)
			I.color = color2hex("blue")
			overlays += I
		if("Neutral")
			I.color = color2hex("lime")
			overlays += I
		else
			I.color = color2hex(affiliation)
			overlays += I

/mob/living/simple_animal/hostile/construct/examine(mob/user)
	var/msg = "<span cass='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n[desc]\n"
	if (src.health < src.maxHealth)
		msg += "<span class='warning'>"
		if (src.health >= src.maxHealth/2)
			msg += "It looks slightly dented.\n"
		else
			msg += "<b>It looks severely dented!</b>\n"
		msg += "</span>"
	msg += "*---------*</span>"

	to_chat(user, msg)

/mob/living/simple_animal/hostile/construct/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/hostile/construct/builder))
		var/mob/living/simple_animal/hostile/construct/builder/C = M
		if(affiliation == C.affiliation)//in the unlikely case that there's a wizard or a miner that got his hands on a soulstone
			if(health < maxHealth)
				adjustHealth(-5)
				if(src != M)
					Beam(M,icon_state="sendbeam",icon='icons/effects/effects.dmi',time=4)
					M.visible_message("<span class='danger'>[M] repairs some of \the <b>[src]'s</b> dents.</span>", \
							   "<span class='cult'>You repair some of <b>[src]'s</b> dents, leaving <b>[src]</b> at <b>[health]/[maxHealth]</b> health.</span>")
			else
				if(src != M)
					to_chat(M, "<span class='cult'>You cannot repair <b>[src]'s</b> dents, as it has none!</span>")
		else //if they aren't on our team, attack!
			..()
	else if(src != M)
		..()

/mob/living/simple_animal/hostile/construct/Process_Spacemove(movement_dir = 0)
	return 1

/mob/living/simple_animal/hostile/construct/narsie_act()
	return

/mob/living/simple_animal/construct/examine(mob/user)
	. = ..()
	if((iscultist(user) || iswizard(user)) && (!src.key || !src.client))
		to_chat(user, "<span class='danger'>You can tell that they've lost all concious awareness and have become as engaging as a blank wall.</span>")


/////////////////Juggernaut///////////////
/mob/living/simple_animal/hostile/construct/armored
	name = "Juggernaut"
	real_name = "Juggernaut"
	desc = "A massive, armored construct built to spearhead attacks and soak up enemy fire."
	icon_state = "behemoth"
	icon_living = "behemoth"
	maxHealth = 250
	health = 250
	response_harm = "harmlessly punches"
	harm_intent_damage = 0
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "smashes their armored gauntlet into"
	speed = 3
	environment_smash = 2
	attack_sound = 'sound/weapons/punch3.ogg'
	status_flags = list()
	mob_size = MOB_SIZE_LARGE
	force_threshold = 11
	construct_spells = list(/obj/effect/proc_holder/spell/aoe_turf/conjure/lesserforcewall)
	playstyle_string = "<b>You are a Juggernaut. Though slow, your shell can withstand extreme punishment, \
						create shield walls, rip apart enemies and walls alike, and even deflect energy weapons.</b>"

/mob/living/simple_animal/hostile/construct/armored/hostile //actually hostile, will move around, hit things
	AIStatus = AI_ON
	environment_smash = 1 //only token destruction, don't smash the cult wall NO STOP

/mob/living/simple_animal/hostile/construct/armored/bullet_act(obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam))
		var/reflectchance = 80 - round(P.damage/3)
		if(prob(reflectchance))
			apply_damage(P.damage * 0.5, P.damage_type)
			visible_message("<span class='danger'>The [P.name] is reflected by [src]'s armored shell!</span>", \
							"<span class='userdanger'>The [P.name] is reflected by your armored shell!</span>")

			// Find a turf near or on the original location to bounce to
			if(P.starting)
				var/new_x = P.starting.x + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
				var/new_y = P.starting.y + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
				var/turf/curloc = get_turf(src)

				// redirect the projectile
				P.original = locate(new_x, new_y, P.z)
				P.starting = curloc
				P.current = curloc
				P.firer = src
				P.yo = new_y - curloc.y
				P.xo = new_x - curloc.x

			return -1 // complete projectile permutation

	return (..(P))



////////////////////////Wraith/////////////////////////////////////////////
/mob/living/simple_animal/hostile/construct/wraith
	name = "Wraith"
	real_name = "Wraith"
	desc = "A wicked, clawed shell constructed to assassinate enemies and sow chaos behind enemy lines."
	icon_state = "floating"
	icon_living = "floating"
	maxHealth = 40
	health = 40
	melee_damage_lower = 25
	melee_damage_upper = 25
	retreat_distance = 2 //AI wraiths will move in and out of combat
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	construct_spells = list(/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift)
	playstyle_string = "<b>You are a Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls.</b>"
	phaser = TRUE

/mob/living/simple_animal/hostile/construct/wraith/hostile //actually hostile, will move around, hit things
	AIStatus = AI_ON



/////////////////////////////Artificer/////////////////////////
/mob/living/simple_animal/hostile/construct/builder
	name = "Artificer"
	real_name = "Artificer"
	desc = "A bulbous construct dedicated to building and maintaining the Cult of Nar-Sie's armies."
	icon_state = "artificer"
	icon_living = "artificer"
	maxHealth = 55
	health = 55
	response_harm = "viciously beats"
	speed = 2
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	retreat_distance = 10
	minimum_distance = 10 //AI artificers will flee like fuck
	attacktext = "rams"
	environment_smash = 2
	attack_sound = 'sound/weapons/punch2.ogg'
	construct_spells = list(/obj/effect/proc_holder/spell/aoe_turf/conjure/wall,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/floor,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser,
							/obj/effect/proc_holder/spell/targeted/projectile/magic_missile/lesser)
	playstyle_string = "<B>You are an Artificer. You are incredibly weak and fragile, but you are able to construct fortifications, \
						corrupt areas (click on floors and walls to corrupt them and allow you to phase through them), \
						use magic missile, repair allied constructs (by clicking on them), \
						</B><I>and most important of all create new constructs</I><B> \
						(Use your Artificer spell to summon a new construct shell and Summon Soulstone to create a new soulstone).</B>"
	phaser = TRUE

/mob/living/simple_animal/hostile/construct/builder/Found(atom/A) //what have we found here?
	if(isconstruct(A)) //is it a construct?
		var/mob/living/simple_animal/hostile/construct/C = A
		if(C.health < C.maxHealth) //is it hurt? let's go heal it if it is
			return 1
		else
			return 0
	else
		return 0

/mob/living/simple_animal/hostile/construct/builder/CanAttack(atom/the_target)
	if(see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return 0
	if(Found(the_target) || ..()) //If we Found it or Can_Attack it normally, we Can_Attack it as long as it wasn't invisible
		return 1 //as a note this shouldn't be added to base hostile mobs because it'll mess up retaliate hostile mobs

/mob/living/simple_animal/hostile/construct/builder/MoveToTarget(var/list/possible_targets)
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(isconstruct(L) && L.health >= L.maxHealth) //is this target an unhurt construct? stop trying to heal it
			LoseTarget()
			return 0
		if(L.health <= melee_damage_lower+melee_damage_upper) //ey bucko you're hurt as fuck let's go hit you
			retreat_distance = null
			minimum_distance = 1

/mob/living/simple_animal/hostile/construct/builder/Aggro()
	..()
	if(isconstruct(target)) //oh the target is a construct no need to flee
		retreat_distance = null
		minimum_distance = 1

/mob/living/simple_animal/hostile/construct/builder/LoseAggro()
	..()
	retreat_distance = initial(retreat_distance)
	minimum_distance = initial(minimum_distance)

/mob/living/simple_animal/hostile/construct/builder/hostile //actually hostile, will move around, hit things, heal other constructs
	AIStatus = AI_ON
	environment_smash = 1 //only token destruction, don't smash the cult wall NO STOP

/mob/living/simple_animal/hostile/construct/builder/AttackingSelf()
	if(health < maxHealth)
		adjustHealth(-5)
		visible_message("<span class='danger'>[src] repairs some of its own dents.</span>", \
					"<span class='cult'>You repair some of your own dents, leaving you at <b>[health]/[maxHealth]</b> health.</span>")
	else
		to_chat(src, "<span class='cult'>You cannot repair your own dents, as you have none!</span>")

/////////////////////////////Non-cult Artificer/////////////////////////
/mob/living/simple_animal/hostile/construct/builder/noncult
	construct_spells = list(/obj/effect/proc_holder/spell/aoe_turf/conjure/wall,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/floor,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone/noncult,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser,
							/obj/effect/proc_holder/spell/targeted/projectile/magic_missile/lesser)


/////////////////////////////Harvester/////////////////////////
/mob/living/simple_animal/hostile/construct/builder/harvester
	name = "Harvester"
	real_name = "Harvester"
	desc = "A long, thin construct built to herald Nar-Sie's rise. It'll be all over soon."
	icon_state = "harvester"
	icon_living = "harvester"
	maxHealth = 250
	health = 250
	melee_damage_lower = 25
	melee_damage_upper = 25
	speed = 0
	attacktext = "slams"
	environment_smash = 3
	attack_sound = 'sound/weapons/punch3.ogg'
	construct_spells = list(/obj/effect/proc_holder/spell/aoe_turf/conjure/wall,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/floor,
							/obj/effect/proc_holder/spell/targeted/smoke/disable,
							/obj/effect/proc_holder/spell/targeted/projectile/magic_missile/lesser)
	playstyle_string = "<B>You are a Harvester. You are strong and fast. \
						Bring those who still cling to this world of illusion back to the Geometer so they may know Truth.</B>"

/mob/living/simple_animal/hostile/construct/builder/harvester/hostile //actually hostile, will move around, hit things
	AIStatus = AI_ON
	environment_smash = 2 //SMASH IT ALL
