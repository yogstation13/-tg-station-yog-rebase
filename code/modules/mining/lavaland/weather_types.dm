///The floor is lava

/datum/weather/floor_is_lava
	name = "floor is lava"
	start_up_time = 30 //3 seconds
	start_up_message = "The ground begins to bubble."
	duration_lower = 45
	duration_upper = 60 //1 minute
	duration_message = "The floor is lava!"
	wind_down = 30// 3 seconds
	wind_down_message = "The ground begins to cool."

	target_z = 1
	exclude_walls = TRUE
	area_type = /area

	start_up_overlay = "lava"
	duration_overlay = "lava"
	overlay_layer = ABOVE_OPEN_TURF_LAYER //Covers floors only

	immunity_type = "lava"


/datum/weather/floor_is_lava/storm_act(mob/living/L)
	if(immunity_type in L.weather_immunities)
		return

	var/turf/F = get_turf(L)
	for(var/obj/structure/O in F.contents)
		if(O.level > F.level && !istype(O, /obj/structure/window)) // Something to stand on and it isn't under the floor!
			return
	L.adjustFireLoss(3)



/datum/weather/advanced_darkness
	name = "advanced darkness"
	start_up_time = 100 //10 seconds
	start_up_message = "The lights begin to dim... is power going out?"
	duration_lower = 45
	duration_upper = 60 //1 minute
	duration_message = "This isn't average everyday darkness... this is advanced darkness!"
	wind_down = 100 // 10 seconds
	wind_down_message = "The darkness recedes."
	purely_aesthetic = TRUE

	target_z = 1
	exclude_walls = TRUE
	area_type = /area

	start_up_overlay = ""
	duration_overlay = ""
	overlay_layer = AREA_LAYER

/datum/weather/advanced_darkness/update_areas()
	for(var/area/A in impacted_areas)
		if(stage == MAIN_STAGE)
			A.invisibility = 0
			A.opacity = 1
			A.layer = overlay_layer
			A.icon = 'icons/effects/weather_effects.dmi'
			A.icon_state = start_up_overlay
		else
			A.invisibility = INVISIBILITY_MAXIMUM
			A.opacity = 0
//Ash storms

/datum/weather/ash_storm
	name = "ash storm"
	start_up_time = 300 //30 seconds
	start_up_message = "An eerie moan rises on the wind. Sheets of burning ash blacken the horizon. Seek shelter."
	start_up_sound = 'sound/lavaland/ash_storm_windup.ogg'
	duration_lower = 60 //1 minute
	duration_upper = 150 //2.5 minutes
	duration_message = "Smoldering clouds of scorching ash billow down around you! Get inside!"
	duration_sound = 'sound/lavaland/ash_storm_start.ogg'
	wind_down = 300 // 30 seconds
	wind_down_message = "The shrieking wind whips away the last of the ash and falls to its usual murmur. It should be safe to go outside now."
	wind_down_sound = 'sound/lavaland/ash_storm_end.ogg'

	target_z = ZLEVEL_LAVALAND
	area_type = /area/lavaland/surface/outdoors

	start_up_overlay = "light_ash"
	duration_overlay = "ash_storm"
	overlay_layer = AREA_LAYER

	immunity_type = "ash"


/datum/weather/ash_storm/false_alarm //No storm, just light ember fall
	purely_aesthetic = TRUE
	duration_overlay = "light_ash"
	duration_message = "<span class='notice'>Gentle ashfall surrounds you like grotesque snow. The storm seems to have passed you by.</span>"
	wind_down_message = "The ashfall quietly slows, then stops. Another layer of hardened soot to the volcanic rock beneath you."

/datum/weather/ash_storm/storm_act(mob/living/L)
	if(immunity_type in L.weather_immunities)
		return

	if(istype(L.loc, /obj/mecha))
		return
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/thermal_protection = H.get_thermal_protection()
		if(thermal_protection >= FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT)
			return
	L.adjustFireLoss(4)
