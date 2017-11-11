//Used for all kinds of weather, ex. lavaland ash storms.

var/datum/subsystem/weather/SSweather
/datum/subsystem/weather
	name = "Weather"
	flags = SS_BACKGROUND
	wait = 10
	var/list/processing = list()
	var/list/existing_weather = list()
	var/list/eligible_zlevels = list(ZLEVEL_LAVALAND)
	var/list/next_hit_by_zlevel = list() //Used by barometers to know when the next storm is coming

/datum/subsystem/weather/New()
	NEW_SS_GLOBAL(SSweather)

/datum/subsystem/weather/fire()
	for(var/V in processing)
		var/datum/weather/W = V
		if(W.aesthetic)
			continue
		for(var/mob/living/L in mob_list)
			var/area/A = get_area(L)
			if((L.z == W.target_z) && !(W.immunity_type in L.weather_immunities) && (A in W.impacted_areas))
				W.impact(L)
	for(var/Z in eligible_zlevels)
		var/list/possible_weather_for_this_z = list()
		for(var/V in existing_weather)
			var/datum/weather/WE = V
			if(WE.target_z == Z && WE.probability) //Another check so that it doesn't run extra weather
				possible_weather_for_this_z[WE] = WE.probability
		var/datum/weather/W = pickweight(possible_weather_for_this_z)
		if(!W)
			continue
		run_weather(W.name)
		eligible_zlevels -= Z
		var/randTime = rand(3000, 6000) //Around 5-10 minutes between weathers
		addtimer(src, "make_z_eligible", randTime, TRUE, Z)
		next_hit_by_zlevel["[Z]"] = world.time + randTime + W.telegraph_duration

/datum/subsystem/weather/Initialize(start_timeofday)
	..()
	for(var/V in subtypesof(/datum/weather))
		var/datum/weather/W = V
		existing_weather |= new W

/datum/subsystem/weather/proc/run_weather(weather_name)
	if(!weather_name)
		return
	for(var/V in existing_weather)
		var/datum/weather/W = V
		if(W.name == weather_name)
			W.telegraph()

/datum/subsystem/weather/proc/make_z_eligible(zlevel)
	eligible_zlevels |= zlevel
	next_hit_by_zlevel["[zlevel]"] = null