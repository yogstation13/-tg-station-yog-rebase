/datum/round_event_control/anomaly/anomaly_grav
	name = "Anomaly: Gravitational"
	typepath = /datum/round_event/anomaly/anomaly_grav
	max_occurrences = 5
	weight = 20

/datum/round_event/anomaly/anomaly_grav
	startWhen = 3
	announceWhen = 20
	endWhen = 120
	ghost_announce = "An Gravitational Anomaly has spawned."
	ghostAutoAnnounce = FALSE

/datum/round_event/anomaly/anomaly_grav/announce()
	priority_announce("Gravitational anomaly detected on long range scanners. Expected location: [impact_area.name].", "Anomaly Alert")

/datum/round_event/anomaly/anomaly_grav/start()
	var/turf/T = safepick(get_area_turfs(impact_area))
	if(T)
		newAnomaly = new /obj/effect/anomaly/grav(T)
		interest = newAnomaly
		announceGhost()