/obj/vehicle/car //Non-buckle vehicles in which you can't see the driver. More like a real vehicle.
	name = "car"
	icon_state = "car"
	vehicle_move_delay = 1
	anchored = 1
	layer = ABOVE_ALL_MOB_LAYER

	var/mob/living/carbon/driver
	var/driver_visible =	FALSE  //Driver visible uses buckling, driver not visible uses contents. Using contents is preferable
	var/on = FALSE //whether the car is started or not
	var/maxhealth = 150
	var/health = 150

	var/horn_sound = null //Leave empty to have no horn on the car
	var/horn_spam_time = 20 //Cooldown inbetween indiviudal honks

	var/last_enginesound_time //To prevent sound spam
	var/engine_sound_length = 20 //Set this to the length of the engine sound
	var/engine_sound = 'sound/effects/carrev.ogg'

	var/ramming = FALSE //Whether or not this car is ramming people.
	var/last_crash_time //to prevent double-crashing into walls.
	var/list/ramming_sounds = list() //Sounds for when you hit a person
	var/list/crash_sounds = list()  //Sounds for when you crash into a structure

	var/can_load_people = FALSE //Whether or not this car can have people in it's trunk, for meme vehicles
	var/list/load_sounds = list() //Sounds for when you load people into your car
	var/mob/list/loaded_humans = list() //Loaded people

	//Action datums
	var/datum/action/innate/car/car_eject/eject_action = new
	var/datum/action/innate/car/car_start/start_action = new
	var/datum/action/innate/car/car_horn/horn_action = new
	var/datum/action/innate/car/dump_load/dump_action = new
	var/datum/action/innate/car/kidnap_count/count_action = new

/obj/vehicle/car/Destroy()
	exit_car()

/obj/vehicle/car/examine(mob/user)
	..()
	if(driver)
		user << "It seems to be occupied"

/obj/vehicle/car/Bump(atom/movable/M)
	. = ..()
	if(auto_door_open && istype(M, /obj/machinery/door))
		M.Bumped(driver)
	if(ramming)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			src.visible_message("<span class='danger'>[src] rams into [H] and knocks them down!</span>")
			H.Weaken(3)
			if(ramming_sounds.len)
				playsound(loc, pick(ramming_sounds), 75)
		else if(world.time - last_crash_time > 20 && !istype(M, /obj/machinery/door) && (istype(M, /obj) || istype(M, /turf/closed)))
			last_crash_time = world.time
			src.visible_message("<span class='warning'>[src] rams into [M] and crashes!</span>")
			if(crash_sounds.len)
				playsound(loc, pick(crash_sounds), 75)
			if(driver) //avoid nasty runtimes
				driver.Weaken(3)
			exit_car()
			dump_contents()

/obj/vehicle/car/MouseDrop_T(mob/living/carbon/human/target, mob/user)
	if(user.incapacitated() || user.lying	|| !ishuman(user))
		return
	if(!istype(target) || target.buckled)
		return
	if(user == target)
		if(driver)
			user << "<span class='warning'>[name] is already occupied!</span>"
			return
		user.visible_message("<span class='danger'>[user] starts getting into [src]</span>")
		if(do_after(user, 20, target = src))
			if(driver)//inb4 someone got in sneaky peaky like
				return
			user.visible_message("<span class='danger'>[user] gets into [src]</span>")
			enter_car(user)
	else if(can_load_people && user == driver)
		user.visible_message("<span class='danger'>[user] starts stuffing [target] into [src]</span>")
		if(do_after(user, 20, target = src))
			if(load_sounds.len)
				playsound(loc, pick(load_sounds), 75)
			user.visible_message("<span class='danger'>[user] stuffs [target] into [src]</span>")
			load_human(target)

/obj/vehicle/car/MouseDrop(atom/over_object)
	if(driver)
		usr.visible_message("<span class='danger'>[usr] starts dragging [driver] out of [src]</span>")
		if(do_after(usr, 20, target = src))
			usr.visible_message("<span class='danger'>[usr] drags [driver] out of [src]</span>")
			exit_car()
			dump_contents()

/obj/vehicle/car/relaymove(mob/user, direction)
	if(user != driver) //don't want our victims driving off now do we
		return 0
	if(!on)
		return 0
	if(world.time - last_enginesound_time > engine_sound_length && engine_sound)
		last_enginesound_time = world.time
		playsound(src, engine_sound, 75)
	.=..()

/obj/vehicle/car/container_resist(mob/living/user)
	if(user == driver)
		exit_car()
	else
		user << "<span class='notice'>You push against the back of [src] trunk to try and get out.</span>"
		if(do_after(user, 200, target = src))
			user.visible_message("<span class='danger'>[user] gets out of [src]</span>")
			unload_human(user)

/obj/vehicle/car/proc/enter_car(mob/living/carbon/human/H)
	if(H && H.client && H in range(1))
		driver = H
		GrantActions(H)

		if(driver_visible) //Buckling
			user_buckle_mob(H, H, FALSE)
		else //Using contents
			H.forceMove(src)
			forceMove(loc)
			add_fingerprint(H)
		return 1
	else
		return 0

/obj/vehicle/car/proc/exit_car(var/forced, var/atom/newloc = loc)
	if(!driver)
		return
	if(!ishuman(driver))
		return
	RemoveActions(driver)
	if(driver_visible) //Buckling
		driver.unbuckle_mob(driver, forced)
	else //Using contents
		driver.forceMove(newloc)
	driver = null

/obj/vehicle/car/proc/load_human(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(H && H in range(1, src))
		loaded_humans += H
		H.forceMove(src)
		count_action.UpdateButtonIcon()

/obj/vehicle/car/proc/unload_human(mob/living/carbon/human/H)
	var/targetturf = get_turf(src)
	H.forceMove(targetturf)
	loaded_humans -= H
	count_action.UpdateButtonIcon()

/obj/vehicle/car/proc/unload_all_humans()
	for(var/mob/living/carbon/human/H in loaded_humans)
		H.Weaken(3)
		unload_human(H)

/obj/vehicle/car/proc/CanStart() //This exists if you want to add more conditions to starting up the car later on
	if(keycheck(driver))
		return 1
	else
		driver << "<span class='warning'>You need to hold the key to start [src]</span>"

/obj/vehicle/car/proc/dump_contents()
	if(loaded_humans.len)
		unload_all_humans()
	empty_object_contents()
