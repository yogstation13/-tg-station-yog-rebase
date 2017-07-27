/obj/docking_port/mobile/assault_pod
	name = "assault pod"
	id = "steel_rain"
	dwidth = 3
	width = 7
	height = 7
	var/zlevel_stuck = TRUE

/obj/docking_port/mobile/assault_pod/request()
	if(zlevel_stuck)
		if(z == initial(src.z)) //No launching pods that have already launched
			return ..()
	else
		return ..()

/obj/docking_port/mobile/assault_pod/dock(obj/docking_port/stationary/S1)
	..()
	if(!istype(S1, /obj/docking_port/stationary/transit))
		playsound(get_turf(src.loc), 'sound/effects/Explosion1.ogg',50,1)

/obj/item/device/assault_pod
	name = "Assault Pod Targetting Device"
	icon_state = "gangtool-red"
	item_state = "walkietalkie"
	desc = "Used to select a landing zone for assault pods."
	var/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate_pod/console
	var/one_use = TRUE
	var/obj/docking_port/stationary/landing_zone

/obj/item/device/assault_pod/New()
	..()
	console = new /obj/machinery/computer/camera_advanced/shuttle_docker/syndicate_pod(src)

/obj/item/device/assault_pod/attack_self(mob/living/user)
	if(console.target_set)
		user << "<span class='warning'>Landing zone already set.</span>"
		return
	console.attack_hand(user)

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate_pod
	name = "Assault Pod Targetting Device"
	z_lock = ZLEVEL_STATION
	shuttleId = "steel_rain"
	shuttlePortId = "assault_pod"
	shuttlePortName = "assault pod location"
	x_offset = 0
	y_offset = 3
	rotate_action = null
	var/target_set = FALSE

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate_pod/check_eye(mob/user)
	if(!loc || (loc.loc != user) || user.eye_blind || user.incapacitated() )
		user.unset_machine()

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate_pod/is_interactable()
	return TRUE

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate_pod/checkLandingTurf(turf/T)
	if(..())
		return !target_set

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate_pod/placeLandingSpot()
	if(..())
		for(var/obj/machinery/computer/shuttle/S in machines)
			if(S.shuttleId == shuttleId)
				S.possible_destinations = "[my_port.id]"
		target_set = TRUE
		return TRUE

/obj/machinery/computer/shuttle/syndicate/drop_pod
	name = "syndicate assault pod control"
	icon = 'icons/obj/terminals.dmi'
	icon_state = "dorm_available"
	req_access = list(access_syndicate)
	shuttleId = "steel_rain"
	possible_destinations = null
	clockwork = TRUE //it'd look weird

/obj/machinery/computer/shuttle/syndicate/drop_pod/Topic(href, href_list)
	if(href_list["move"])
		if(z != ZLEVEL_CENTCOM)
			usr << "<span class='warning'>Pods are one way!</span>"
			return 0
	..()

#define PREDPOD_CD 900000 // 15 mins

/obj/docking_port/mobile/assault_pod/predator
	name = "predator pod"
	id = "pred"
	zlevel_stuck = FALSE

/obj/item/device/assault_pod/predator
	var/shuttle_id = "pred"
	var/cooldown
	var/dwidth = 3
	var/dheight = 0
	var/width = 7
	var/height = 7
	var/lz_dir = 1

/obj/item/device/assault_pod/predator/attack_self(mob/user)
	if(cooldown > world.time)
		user << "<span class='warning'>[src] is not ready.</span>"
		return
	var/target_area
	target_area = input("Area to land", "Select a Landing Zone", target_area) in teleportlocs
	var/area/picked_area = teleportlocs[target_area]
	if(!src || qdeleted(src))
		return

	var/turf/T = safepick(get_area_turfs(picked_area))
	if(!T)
		return
	var/obj/docking_port/stationary/landing_zone = new /obj/docking_port/stationary(T)
	landing_zone.id = shuttle_id
	landing_zone.name = "Landing Zone"
	landing_zone.dwidth = dwidth
	landing_zone.dheight = dheight
	landing_zone.width = width
	landing_zone.height = height
	landing_zone.dir = lz_dir

	for(var/obj/machinery/computer/shuttle/S in machines)
		if(S.shuttleId == shuttle_id)
			S.possible_destinations = "[landing_zone.id]"

	user << "Landing zone set."
	cooldown = world.time + PREDPOD_CD
	user << "<span class='warning'>[src] will be ready again in fifteen minutes.</span>"