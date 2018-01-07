/////SINGULARITY SPAWNER
/obj/machinery/the_singularitygen/
	name = "gravitational singularity generator"
	desc = "An odd device which produces a gravitational singularity when set up."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = 0
	density = 1
	use_power = 0
	var/energy = 0
	var/creation_type = /obj/singularity

/obj/machinery/the_singularitygen/process()
	var/turf/T = get_turf(src)
	if(energy >= 200)
		feedback_add_details("engine_started","[type]")
		var/obj/singularity/S = new creation_type(T, 50)
		transfer_fingerprints_to(S)
		qdel(src)

/obj/machinery/the_singularitygen/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))

		if(!anchored && !isinspace())
			user.visible_message("[user.name] secures [name] to the floor.", \
				"<span class='notice'>You secure the [name] to the floor.</span>", \
				"<span class='italics'>You hear a ratchet.</span>")
			playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
			anchored = 1
		else if(anchored)
			user.visible_message("[user.name] unsecures [name] from the floor.", \
				"<span class='notice'>You unsecure the [name] from the floor.</span>", \
				"<span class='italics'>You hear a ratchet.</span>")
			playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
			anchored = 0
	else
		return ..()
