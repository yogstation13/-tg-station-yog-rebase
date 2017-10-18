//debride wounds
/datum/surgery_step/debride
	name = "clean wound"
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/kitchen/knife = 65, /obj/item/weapon/shard = 45)
	time = 40

/datum/surgery_step/debride/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to cut off dead flesh around the wound upon [target]'s [parse_zone(target_zone)].", "<span class='notice'>You begin cutting away the dead and damaged tissue on [target]'s [parse_zone(target_zone)], creating a cleaner wound bed...</span>")

/datum/surgery_step/debride/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if (ishuman(target))
		var/mob/living/carbon/human/H = target
		H.apply_damage(15, "brute", "[target_zone]")

	user.visible_message("[user] scrapes [tool] across [target]'s wounds with surgical precision, cleaning the area.", "<span class='notice'>You scrape away the detritus and scarred flesh from [target]'s [parse_zone(target_zone)]. The wound is now fully debrided and ready for dressing.</span>")
	return 1

//add dressing to wounds
/datum/surgery_step/apply_dressing //brute
	name = "apply gauze"
	implements = list(/obj/item/stack/medical/gauze = 100, /obj/item/stack/medical/gauze/improvised = 65, /obj/item/clothing/torncloth = 35)
	time = 24
	var/dressing_type = "brute"

/datum/surgery_step/apply_dressing/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] starts dressing [target]'s [parse_zone(target_zone)] wounds with [tool]..", "<span class='notice'>You start wrapping and dressing [target]'s [parse_zone(target_zone)] with [tool]..")

/datum/surgery_step/apply_dressing/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if (ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/bodypart/heal_limb = H.get_bodypart(check_zone(target_zone))

		if (heal_limb)
			switch (dressing_type)
				if ("brute")
					heal_limb.heal_damage(85, 0, 0) //brute
				if ("burn")
					heal_limb.heal_damage(0, 85, 0) //burn
				if ("both")
					heal_limb.heal_damage(65, 65, 0) //both
		else
			to_chat(user, "There's no limb there to dress!")
			return 0

		if(locate(/datum/surgery_step/debride) in surgery.steps)
			H.heal_organ_damage(15, 0)

		if (istype(tool, /obj/item/stack/medical/gauze/))
			var/obj/item/stack/medical/gauze/G = tool
			G.use(2)
		else
			qdel(tool)

	user.visible_message("[user] dresses [target]'s wounds with [tool], securing them tightly.", "<span class='notice'>You bind [target]'s [parse_zone(target_zone)] wound tightly with [tool].</span>")
	return 1

/datum/surgery_step/apply_dressing/burn
	name = "apply bandage"
	implements = list(/obj/item/medical/bandage/burn = 100, /obj/item/medical/bandage/improvised_soaked = 65, /obj/item/clothing/torncloth = 25)
	time = 24
	dressing_type = "burn"

/datum/surgery_step/apply_dressing/superior
	name = "apply superior dressing"
	implements = list(/obj/item/medical/bandage/quality = 100)
	time = 24
	dressing_type = "both"

//surgeries go here
/datum/surgery/heal_brute
	name = "patch wounds"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/debride, /datum/surgery_step/apply_dressing, /datum/surgery_step/close)
	possible_locs = list("r_arm","l_arm","r_leg","l_leg","chest","head")

/datum/surgery/heal_burn
	name = "treat burns"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/debride, /datum/surgery_step/apply_dressing/burn, /datum/surgery_step/close)
	possible_locs = list("r_arm","l_arm","r_leg","l_leg","chest","head")
