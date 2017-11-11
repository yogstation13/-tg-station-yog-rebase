/obj/item/weapon/implant/mindslave
	name = "mindslave implant"
	desc = "Turn a crewmate into your eternal slave"
	activated = 0

/obj/item/weapon/implant/mindslave/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Syndicate Loyalty Implant<BR>
<b>Life:</b> Single use<BR>
<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Makes the injected a slave to the owner of the implant.<HR>"}
	return dat

/obj/item/weapon/implant/mindslave/implant(mob/source, var/mob/user)

	if(!source.mind)
		user.mind << "<span class='notice'>[source] doesn't posses the mental capabilities to be a slave.</span>"
		return 0

	var/mob/living/carbon/human/target = source.mind.current
	var/mob/living/carbon/human/holder = user.mind.current

	if(target == holder)
		holder << "<span class='notice'>You can't implant yourself!</span>"
		return 0

	var/obj/item/weapon/implant/mindslave/imp = locate(src.type) in source

	if(imp)
		holder << "<span class='warning'>[target] is already a slave!</span>"
		return 0

	if(isloyal(target))
		holder << "<span class='warning'>[target] seems to resist the implant!</span>"
		return 0

	if(target.mind.changeling)
		holder << "<span class='warning'>[target]'s skin thickens where you try to inject them. Odd...</span>"
		target << "<span class='warning'>We instinctively prevent [holder]'s injector from penetrating our skin.</span>"
		return 0

	target << "<span class='userdanger'><FONT size = 3>You feel a strange urge to serve [holder.real_name]. A simple thought about disobeying his/her commands makes your head feel like it is going to explode. You feel like you dont want to know what will happen if you actually disobey your new master.</FONT></span>"

	var/datum/objective/mindslave/serve_objective = new
	serve_objective.owner = target
	serve_objective.explanation_text = "Serve [holder.real_name] no matter what!"
	serve_objective.completed = 1
	source.mind.objectives += serve_objective
	if(!ticker.mode.traitors.Find(source.mind))
		ticker.mode.traitors += source.mind

	log_game("[holder.ckey] enslaved [target.ckey] with a Mindslave implant")

	return ..()

/obj/item/weapon/implant/mindslave/removed(mob/target)
	if(..())

		for(var/datum/objective/mindslave/objective in target.mind.objectives)
			target.mind.objectives -= objective

		if(target.mind.objectives.len == 0)
			ticker.mode.traitors -= target.mind

		if(target.stat != DEAD)
			target.visible_message("<span class='notice'>[target] looks like they have just been released from slavery!</span>", "<span class='boldnotice'>You feel as if you have just been released from eternal slavery. Yet you cant seem to remember anything at all!</span>")
		return 1

/obj/item/weapon/implant/mindslave/activate()
	var/turf/T = get_turf(src.loc)

	if (ismob(loc))
		var/mob/M = loc
		M << "<span class='danger'>Your master has decided to detonate you!</span>"

	if(T)
		T.hotspot_expose(1200,240)

		explosion(T, 1, 2, 3, 3)

	qdel(src)
	return

/obj/item/weapon/implanter/mindslave
	name = "implanter (freedom)"
	imptype = /obj/item/weapon/implant/mindslave

/datum/objective/mindslave
	martyr_compatible = 1