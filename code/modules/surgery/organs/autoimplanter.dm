#define AUTOIMPLANTER_INFINITE -1

/obj/item/device/autoimplanter
	name = "autoimplanter"
	desc = "A device that automatically injects a cyber-implant into the user without the hassle of extensive surgery. It has a slot to insert implants and a screwdriver slot for removing accidentally added implants."
	icon_state = "autoimplanter"
	item_state = "walkietalkie"//left as this so as to intentionally not have inhands
	w_class = 2
	var/obj/item/organ/cyberimp/storedorgan
	var/uses = AUTOIMPLANTER_INFINITE
	var/one_use = 0//separate var, as a 2-use device can have 1 use remaining if used once but not be a single-use device

/obj/item/device/autoimplanter/New()
	..()
	if(one_use)
		uses = 1
	if(storedorgan)
		storedorgan.loc = src

/obj/item/device/autoimplanter/attack_self(mob/user)//when the object it used...
	if(!uses)
		user << "<span class='warning'>[src] has already been used. The tools are dull and won't reactivate.</span>"
		return
	if(!storedorgan)
		user << "<span class='notice'>[src] currently has no implant stored.</span>"
		return
	storedorgan.Insert(user, 0, 0)//insert stored organ into the user
	user.visible_message("<span class='notice'>[user] presses a button on [src], and you hear a short mechanical noise.</span>", "<span class='notice'>You feel a sharp sting as [src] plunges into your body.</span>")
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, 1)
	storedorgan = null
	if(uses != AUTOIMPLANTER_INFINITE)
		uses --
	if(!uses)
		desc = "[initial(desc)] Looks like it's been used up."

/obj/item/device/autoimplanter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/organ/cyberimp))
		if(one_use && !storedorgan)
			user << "<span class='notice'>[src] doesn't accept implants. It must be a single-use device.</span>"
			return//prevents removing the intended implant to insert your own
		if(storedorgan)
			user << "<span class='notice'>[src] already has an implant stored.</span>"
			return
		if(!user.drop_item())
			return
		I.loc = src
		storedorgan = I
		user << "<span class='notice'>You insert the [I] into [src].</span>"
	else if(istype(I, /obj/item/weapon/screwdriver))
		if(!storedorgan)
			user << "<span class='notice'>There's no implant in [src] for you to remove.</span>"
		else
			var/turf/open/floorloc = get_turf(user)
			floorloc.contents += contents
			user << "<span class='notice'>You remove the [storedorgan] from [src].</span>"
			playsound(get_turf(user), 'sound/items/Screwdriver.ogg', 50, 1)
			storedorgan = null

/obj/item/device/autoimplanter/cmo
	name = "medical HUD autoimplanter"
	desc = "A single use autoimplanter that contains a medical heads-up display augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	storedorgan = new/obj/item/organ/cyberimp/eyes/hud/medical()
	one_use = 1
