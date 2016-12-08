/obj/item/clothing/mask/breath
	desc = "A close-fitting mask that can be connected to an air supply."
	name = "breath mask"
	icon_state = "breath"
	item_state = "m_mask"
	body_parts_covered = 0
	flags = MASKINTERNALS
	visor_flags = MASKINTERNALS
	w_class = 2
	gas_transfer_coefficient = 0.10
	permeability_coefficient = 0.50
	actions_types = list(/datum/action/item_action/adjust)
	flags_cover = MASKCOVERSMOUTH
	visor_flags_cover = MASKCOVERSMOUTH
	burn_state = FIRE_PROOF
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi'
		)

/obj/item/clothing/mask/breath/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/breath/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, be_close=TRUE))
		user << "<span class='warning'>You can't do that right now!</span>"
		return
	else
		adjustmask(user)

/obj/item/clothing/mask/breath/examine(mob/user)
	..()
	user << "<span class='notice'>Alt-click [src] to adjust it.</span>"

/obj/item/clothing/mask/breath/medical
	desc = "A close-fitting sterile mask that can be connected to an air supply."
	name = "medical mask"
	icon_state = "medical"
	item_state = "m_mask"
	permeability_coefficient = 0.01
	put_on_delay = 10

/*/obj/item/clothing/mask/breath/vox
	desc = "A weirdly-shaped breath mask."
	name = "vox breath mask"
	icon_state = "voxmask"
	permeability_coefficient = 0.01
	species_restricted = list("Vox")
	actions_types = list()*/
