/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	var/magboot_state = "magboots"
	var/magpulse = 0
	var/slowdown_active = 2
	actions_types = list(/datum/action/item_action/toggle)
	strip_delay = 70
	put_on_delay = 70
	burn_state = FIRE_PROOF
	origin_tech = "materials=3;magnets=4;engineering=4"

/obj/item/clothing/shoes/magboots/verb/toggle()
	set name = "Toggle Magboots"
	set category = "Object"
	set src in usr
	if(!can_use(usr))
		return
	attack_self(usr)


/obj/item/clothing/shoes/magboots/attack_self(mob/user)
	if(magpulse)
		flags &= ~SUPERNOSLIP
		slowdown = SHOES_SLOWDOWN
	else
		flags |= SUPERNOSLIP
		slowdown = slowdown_active
	magpulse = !magpulse
	icon_state = "[magboot_state][magpulse]"
	to_chat(user, "<span class='notice'>You [magpulse ? "enable" : "disable"] the mag-pulse traction system.</span>")
	user.update_inv_shoes()	//so our mob-overlays update
	user.update_gravity(user.mob_has_gravity())
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/shoes/magboots/negates_gravity()
	return flags & SUPERNOSLIP

/obj/item/clothing/shoes/magboots/examine(mob/user)
	..()
	to_chat(user, "Its mag-pulse traction system appears to be [magpulse ? "enabled" : "disabled"].")


/obj/item/clothing/shoes/magboots/advance
	desc = "Advanced magnetic boots that have a lighter magnetic pull, placing less burden on the wearer."
	name = "advanced magboots"
	icon_state = "advmag0"
	magboot_state = "advmag"
	slowdown_active = SHOES_SLOWDOWN
	origin_tech = null

/obj/item/clothing/shoes/magboots/syndie
	desc = "Reverse-engineered magnetic boots that have a heavy magnetic pull. Property of Gorlex Marauders."
	name = "blood-red magboots"
	icon_state = "syndiemag0"
	magboot_state = "syndiemag"
	origin_tech = "magnets=2;syndicate=3"

/obj/item/clothing/shoes/magboots/security
	name = "combat magboots"
	desc = "Combat-edition magboots issued by Nanotrasen Security for extravehicular missions. Unlike the Syndicates reverse engineered pair, these do not carry such a heavy burden on the wearer, however you may find that the advanced version carries much more mobility."
	icon_state = "cmagboots0"
	magboot_state = "cmagboots"
	slowdown_active = 1

/obj/item/clothing/shoes/magboots/vox
	name = "vox boots"
	desc = "A pair of heavy, jagged armored foot pieces. They seem suitable for a velociraptor."

	species_restricted = list(VOX_SHAPED)
	species_fit = list(VOX_SHAPED)
