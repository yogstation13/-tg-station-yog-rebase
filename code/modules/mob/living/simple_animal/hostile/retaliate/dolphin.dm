/mob/living/simple_animal/hostile/retaliate/dolphin
	name = "space dolphin"
	desc = "A dolphin in space."
	icon_state = "dolphin"
	icon_living = "dolphin"
	icon_dead = "dolphin_dead"
	icon_gib = "dolphin_gib"
	speak_chance = 0
	turns_per_move = 5
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/dolphinmeat = 2)
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"
	emote_taunt = list("gnashes")
	taunt_chance = 30
	speed = 0
	maxHealth = 25
	health = 25
	a_intent = "harm"
	environment_smash = 0
	harm_intent_damage = 8
	melee_damage_lower = 15
	melee_damage_upper = 15
	pass_flags = PASSTABLE //secretly a tactical dolphin buff.
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("Chitters", "Squeeks", "Clicks")

	//Space dolphins aren't affected by cold.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500

	faction = list("dolphin")//why do carps not attack dolphins again? //i dunno now they do
	flying = 1

/mob/living/simple_animal/hostile/retaliate/dolphin/Process_Spacemove(movement_dir = 0)
	return 1	//No drifting in space for space dolphins!	//original comments do not steal //Too late.

/mob/living/simple_animal/hostile/retaliate/dolphin/AttackingTarget()
	..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.adjustStaminaLoss(8)

/mob/living/simple_animal/hostile/retaliate/dolphin/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(istype(W, /obj/item/weapon/reagent_containers/food/snacks/grown/apple) && stat == DEAD)
		new /obj/item/weapon/reagent_containers/food/snacks/youmonster(src.loc)
		qdel(W)
		qdel(src)

/mob/living/simple_animal/hostile/retaliate/dolphin/handle_automated_action()
	if(..())	
		for(var/mob/living/simple_animal/hostile/carp/C in view(src, 10))
			if(C.stat != DEAD)
				enemies |= C
