
/obj/effect
	icon = 'icons/effects/effects.dmi'

/obj/effect/portal
	name = "portal"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	density = 1
	unacidable = 1//Can't destroy energy portals.
	var/obj/item/target = null
	var/creator = null
	anchored = 1
	var/precision = 1 // how close to the portal you will teleport. 0 = on the portal, 1 = adjacent

/obj/effect/portal/Bumped(mob/M as mob|obj)
	teleport(M)

/obj/effect/portal/New(loc, turf/target, creator, lifespan=300)
	portals += src
	loc = loc
	target = target
	creator = creator
	var/area/A = get_area(target)
	if(A && A.noteleport)
		destroy_effect()
		return
	for(var/mob/M in loc)
		teleport(M)
	if(lifespan > 0)
		spawn(lifespan)
			qdel(src)
	return

/obj/effect/portal/Destroy()
	portals -= src
	if(istype(creator, /obj/item/weapon/hand_tele))
		var/obj/item/weapon/hand_tele/O = creator
		O.active_portals--
	else if(istype(creator, /obj/item/weapon/gun/energy/wormhole_projector))
		var/obj/item/weapon/gun/energy/wormhole_projector/P = creator
		P.portal_destroyed(src)
	creator = null
	return ..()

/obj/effect/portal/proc/teleport(atom/movable/M as mob|obj)
	if(istype(M, /obj/effect)) //sparks don't teleport
		return
	if(M.anchored&&istype(M, /obj/mecha))
		return
	if (!( target ))
		qdel(src)
		return
	if (istype(M, /atom/movable))
		if(istype(M, /mob/living/simple_animal/hostile/megafauna))
			message_admins("[M] (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</A>) has teleported through [src].")
		do_teleport(M, target, precision) ///You will appear adjacent to the beacon


