/*
AI
*/
/datum/job/ai
	title = "AI"
	flag = AI
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	selection_color = "#ccffcc"
	supervisors = "your laws"
	req_admin_notify = 1
	minimal_player_age = 20
	whitelisted = 1

/datum/job/ai/equip(mob/living/carbon/human/H)
	if(!H)
		return 0

/datum/job/ai/config_check()
	if(config && config.allow_ai)
		return 1
	return 0

/*
Cyborg
*/
/datum/job/cyborg
	title = "Cyborg"
	flag = CYBORG
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 1
	supervisors = "your laws and the AI"	//Nodrak
	selection_color = "#ddffdd"
	minimal_player_age = 21

/datum/job/cyborg/equip(mob/living/carbon/human/H)
	if(!H)
		return 0
	var/needTicker
	if(H in ticker.livings)
		ticker.livings -= H
		H.notransform = FALSE
		needTicker = TRUE
	var/mob/living/living = H.Robotize()
	if(needTicker)
		living.notransform = TRUE
		var/obj/screen/splash/S = new(living.client, TRUE)
		S.Fade(TRUE)
		ticker.livings += living
