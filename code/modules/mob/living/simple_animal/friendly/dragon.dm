//HOLA MI AMIGOS OLE!

/mob/living/simple_animal/pet/dragon
	name = "Red Dragon"
	desc = "A dragon so red and evil in nature that it makes your blood boil..  or maybe that's just the mask. Beneath its head you see a fancy collar, probably what they used to tame it."
	icon = 'icons/mob/pets.dmi'
	icon_state = "dragon"
	icon_living = "dragon"
	icon_dead = "dragon_dead"
	health = 110
	maxHealth = 110
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_sound = 'sound/magic/demon_attack1.ogg'
	response_help  = "pets"
	response_disarm = "nudges"
	response_harm   = "kicks"
	speak = list("OLE", "DELICIOUS", "WILL MAKE GOOD SANDWICH", "AHAHAHAHAHA")
	speak_emote = list("hisses", "re-adjusts its mask before yelling")
	emote_hear = list("hisses.", "HISSES.", "hisses a lot.")
	emote_see = list("bathes itself in flames.", "chases its tail.","glares.")
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab = 2, /obj/item/clothing/mask/luchador/rudos = 1)
	var/mob/living/simple_animal/pet/cat/mimekitty/movement_target
	see_in_dark = 8
	speak_chance = 1
	sentience_type = null // ha no
	turns_per_move = 5
	var/turns_since_scan = 0
	var/following = 0
	gold_core_spawnable = 2
	var/list/uneatable = list(
		/obj/item/weapon/gun/energy/laser/captain,
		/obj/item/weapon/gun/energy/gun/hos,
		/obj/item/weapon/hand_tele,
		/obj/item/weapon/tank/jetpack/oxygen/captain,
		/obj/item/clothing/shoes/magboots/advance,
		/obj/item/clothing/tie/medal/gold/captain,
		/obj/item/weapon/reagent_containers/hypospray/CMO,
		/obj/item/weapon/disk/nuclear,
		/obj/item/clothing/suit/armor/laserproof,
		/obj/item/clothing/suit/armor/reactive,
		/obj/item/documents,//Any documents at all, seeing as they're all high risk, basically.  Along with all being valid for objectives.
		/obj/item/nuke_core,
		/obj/item/device/aicard,//Intelicard to prevent AIs getting deleted, though it'd be a cool way to kill a rogue AI. le sigh.
		/obj/item/areaeditor/blueprints,
		/obj/item/weapon/pinpointer//Pinpointer because if you can't feed it the disk, you shouldn't be able to feed it one of the very limited few devices able to locate the disk.
		)



/mob/living/simple_animal/pet/dragon/Life()
	if(!stat && !buckled && !client)
		if(prob(1))
			emote("me", 1, pick("breathes a small circle of fire and rolls in it.", "sharpens its claws.", "swishes its tail around."))

	if((src.loc) && isturf(src.loc))
		if(!stat && !resting && !buckled)
			for(var/mob/living/simple_animal/pet/cat/mimekitty/M in view(1,src))
				if(!M.stat && Adjacent(M))
					emote("me", 1, "devours \the [M]!") //Out-snowflake this.
					M.gib()
					movement_target = null
					stop_automated_movement = 0
					break
	..()

	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			walk_to(src,0)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/mob/living/simple_animal/pet/cat/mimekitty/snack in oview(src,3))
					if(isturf(snack.loc) && !snack.stat)
						movement_target = snack
						break
			if(movement_target)
				stop_automated_movement = 1
				walk_to(src,movement_target,0,3)

	if (following)
		return ..()
	for(var/mob/living/carbon/M in view(7, src))
		if (istype(M) && M.name == "Red Dragon")
			var/mob/living/target = M
			following = 1
			spawn(0)
				while(target in view(7, src))
					if(!target.Adjacent(src))
						step_to(src,target)
					sleep(3)
				following = 0
			break;
	return ..()

/mob/living/simple_animal/pet/dragon/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == "harm")
		M << "<span class='warning'>You don't think it'd be wise to attack [src]...</span>"
		return 0
	else
		if(M && stat != DEAD)
			flick_overlay(image('icons/mob/animal.dmi',src,"heart-ani2",MOB_LAYER+1), list(M.client), 20)
			emote("me", 1, "eyes blaze with fire for a moment!")
	. = ..()


/mob/living/simple_animal/pet/dragon/attackby(obj/item/weapon/W, mob/user)
	if(user && stat != DEAD)
		if(W.type in uneatable)
			user << "<span class='warning'>You probably shouldn't feed [src] something so valuable..</span>"
			return
		if(istype(W,/obj/item/weapon/card/emag))
			user << "<span class='danger'>You break the mechanism keeping the collar on [src]'s neck.</span>"
			emote("me",1,"devours [W].  Its eyes blaze with pure hellfire...")
			qdel(W)
			new /mob/living/simple_animal/hostile/megafauna/dragon/reddragon(loc)
			qdel(src)// I don't imagine the inside of a dragon is a very hospitable place for items, so they wont be getting dropped.
			return
		else if(istype(W,/obj/item/weapon/card/))
			user << "<span class='warning'>[src] does not want to eat [W]. </span>"
			return
		else if(istype(W,/obj/item/) && W.w_class < 3)
			emote("me",1,"devours [W]. Its eyes blaze with immense heat...")
			qdel(W)
			return
		user << "<span class='warning'>[src] does not want to eat [W].</span>"
