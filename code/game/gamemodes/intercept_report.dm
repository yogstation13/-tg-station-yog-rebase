/datum/intercept_text
	var/text
	/*
	var/prob_correct_person_lower = 20
	var/prob_correct_person_higher = 80
	var/prob_correct_job_lower = 20
	var/prob_correct_job_higher = 80
	var/prob_correct_prints_lower = 20
	var/prob_correct_print_higher = 80
	var/prob_correct_objective_lower = 20
	var/prob_correct_objective_higher = 80
	*/
	var/list/org_names_1 = list(
		"Blighted",
		"Defiled",
		"Unholy",
		"Murderous",
		"Ugly",
		"French",
		"Blue",
		"Farmer"
	)
	var/list/org_names_2 = list(
		"Reapers",
		"Swarm",
		"Rogues",
		"Menace",
		"Jeff Worshippers",
		"Drunks",
		"Strikers",
		"Creed"
	)
	var/list/anomalies = list(
		"Huge electrical storm",
		"Photon emitter",
		"Meson generator",
		"Blue swirly thing"
	)
	var/list/SWF_names = list(
		"Grand Wizard",
		"His Most Unholy Master",
		"The Most Angry",
		"Bighands",
		"Tall Hat",
		"Deadly Sandals"
	)
	var/list/changeling_names = list(
		"Odo",
		"The Thing",
		"Booga",
		"The Goatee of Wrath",
		"Tam Lin",
		"Species 3157",
		"Small Prick"
	)


/datum/intercept_text/proc/build(mode_type, datum/mind/correct_person)
	switch(mode_type)
		if("revolution")
			text = ""
			build_rev(correct_person)
			return text
		if("gang")
			text = ""
			build_gang(correct_person)
			return text
		if("cult")
			text = ""
			build_cult(correct_person)
			return text
		if("wizard")
			text = ""
			build_wizard(correct_person)
			return text
		if("nuke")
			text = ""
			build_nuke(correct_person)
			return text
		if("traitor")
			text = ""
			build_traitor(correct_person)
			return text
		if("changeling","traitorchan")
			text = ""
			build_changeling(correct_person)
			return text
		if("shadowling")
			text = ""
			build_shadowling(correct_person)
			return text
		else
			return null

// NOTE: Commentted out was the code which showed the chance of someone being an antag. If you want to re-add it, just uncomment the code.

/*
/datum/intercept_text/proc/pick_mob()
	var/list/dudes = list()
	for(var/mob/living/carbon/human/man in player_list)
		if (!man.mind) continue
		if (man.mind.assigned_role=="MODE") continue
		dudes += man
	if(dudes.len==0)
		return null
	return pick(dudes)


/datum/intercept_text/proc/pick_fingerprints()
	var/mob/living/carbon/human/dude = pick_mob()
	//if (!dude) return pick_fingerprints() //who coded that is totally crasy or just a traitor. -- rastaf0
	if(dude)
		return num2text(md5(dude.dna.uni_identity))
	else
		return num2text(md5(num2text(rand(1,10000))))
*/

/datum/intercept_text/proc/build_traitor(datum/mind/correct_person)
	var/name_1 = pick(org_names_1)
	var/name_2 = pick(org_names_2)

	/*
	var/fingerprints
	var/traitor_name
	var/prob_right_dude = rand(prob_correct_person_lower, prob_correct_person_higher)
	if(prob(prob_right_dude) && ticker.mode == "traitor")
		if(correct_person:assigned_role=="MODE")
			traitor_name = pick_mob()
		else
			traitor_name = correct_person:current
	else if(prob(prob_right_dude))
		traitor_name = pick_mob()
	else
		fingerprints = pick_fingerprints()
	*/

	text += "<BR><BR>The <B><U>[name_1] [name_2]</U></B> implied an undercover operative was acting on their behalf on the station currently."
	text += "It would be in your best interests to suspect everybody, as these undercover operatives could have implants which trigger them to have their memories removed until they are needed. He, or she, could even be a high ranking officer."
	text += "<BR><HR>"
	/*
	text += "After some investigation, we "
	if(traitor_name)
		text += "are [prob_right_dude]% sure that [traitor_name] may have been involved, and should be closely observed."
		text += "<BR>Note: This group are known to be untrustworthy, so do not act on this information without proper discourse."
	else
		text += "discovered the following set of fingerprints ([fingerprints]) on sensitive materials, and their owner should be closely observed."
		text += "However, these could also belong to a current Centcom employee, so do not act on this without reason."
	*/


/datum/intercept_text/proc/build_cult(datum/mind/correct_person)
	var/name_1 = pick(org_names_1)
	var/name_2 = pick(org_names_2)
	/*
	var/traitor_name
	var/traitor_job
	var/prob_right_dude = rand(prob_correct_person_lower, prob_correct_person_higher)
	var/prob_right_job = rand(prob_correct_job_lower, prob_correct_job_higher)
	if(prob(prob_right_job) && is_convertable_to_cult(correct_person))
		if (correct_person)
			if(correct_person:assigned_role=="MODE")
				traitor_job = pick(get_all_jobs())
			else
				traitor_job = correct_person:assigned_role
	else
		var/list/job_tmp = get_all_jobs()
		job_tmp.Remove("Captain", "Chaplain", "AI", "Cyborg", "Security Officer", "Detective", "Head Of Security", "Head of Personnel", "Chief Engineer", "Research Director", "Chief Medical Officer")
		traitor_job = pick(job_tmp)
	if(prob(prob_right_dude) && ticker.mode == "cult")
		if(correct_person:assigned_role=="MODE")
			traitor_name = pick_mob()
		else
			traitor_name = correct_person:current
	else
		traitor_name = pick_mob()
	*/
	text += "<BR><BR>It has been brought to our attention that the <B><U>[name_1] [name_2]</U></B> have stumbled upon some dark secrets. They apparently want to spread the dangerous knowledge onto as many stations as they can."
	text += "Watch out for the following: praying to an unfamilar god, preaching the word of \[REDACTED\], sacrifices, magical dark power, living constructs of evil and a portal to the dimension of the underworld."
	text += "<BR><HR>"
	/*
	text += "Based on our intelligence, we are [prob_right_job]% sure that if true, someone doing the job of [traitor_job] on your station may have been converted "
	text += "and instilled with the idea of the flimsiness of the real world, seeking to destroy it. "
	if(prob(prob_right_dude))
		text += "<BR> In addition, we are [prob_right_dude]% sure that [traitor_name] may have also some in to contact with this "
		text += "organisation."
	text += "<BR>However, if this information is acted on without substantial evidence, those responsible will face severe repercussions."
	*/


/datum/intercept_text/proc/build_rev(datum/mind/correct_person)
	var/name_1 = pick(org_names_1)
	var/name_2 = pick(org_names_2)
	/*
	var/traitor_name
	var/traitor_job
	var/prob_right_dude = rand(prob_correct_person_lower, prob_correct_person_higher)
	var/prob_right_job = rand(prob_correct_job_lower, prob_correct_job_higher)
	if(prob(prob_right_job) && is_convertable_to_rev(correct_person))
		if (correct_person)
			if(correct_person.assigned_role=="MODE")
				traitor_job = pick(get_all_jobs())
			else
				traitor_job = correct_person.assigned_role
	else
		var/list/job_tmp = get_all_jobs()
		job_tmp-=nonhuman_positions
		job_tmp-=command_positions
		job_tmp.Remove("Security Officer", "Detective", "Warden", "MODE")
		traitor_job = pick(job_tmp)
	if(prob(prob_right_dude) && ticker.mode.config_tag == "revolution")
		if(correct_person.assigned_role=="MODE")
			traitor_name = pick_mob()
		else
			traitor_name = correct_person.current
	else
		traitor_name = pick_mob()
	*/
	text += "<BR><BR>It has been brought to our attention that the <B><U>[name_1] [name_2]</U></B> are attempting to stir unrest on one of our stations in your sector."
	text += "Watch out for suspicious activity among the crew and make sure that all heads of staff report in periodically."
	text += "<BR><HR>"
	/*
	text += "Based on our intelligence, we are [prob_right_job]% sure that if true, someone doing the job of [traitor_job] on your station may have been brainwashed "
	text += "at a recent conference, and their department should be closely monitored for signs of mutiny. "
	if(prob(prob_right_dude))
		text += "<BR> In addition, we are [prob_right_dude]% sure that [traitor_name] may have also some in to contact with this "
		text += "organisation."
	text += "<BR>However, if this information is acted on without substantial evidence, those responsible will face severe repercussions."
	*/

/datum/intercept_text/proc/build_gang(datum/mind/correct_person)
	text += "<BR><BR>We have reports of criminal activity in close proximity to our operations within your sector."
	text += "Ensure law and order is maintained on the station and be on the lookout for territorial aggression within the crew."
	text += "In the event of a full-scale criminal takeover threat, sensitive research items are to be secured and the station evacuated ASAP."
	text += "<BR><HR>"

/datum/intercept_text/proc/build_wizard(datum/mind/correct_person)
	var/SWF_desc = pick(SWF_names)

	text += "<BR><BR>The evil Space Wizards Federation have recently broke their most feared wizard, known only as <B>\"[SWF_desc]\"</B> out of space jail. "
	text += "He is on the run, last spotted in a system near your present location. If anybody suspicious is located aboard, please "
	text += "approach with EXTREME caution. Centcom also recommends that it would be wise to not inform the crew of this, due to their fearful nature."
	text += "Known attributes include: Brown sandals, a large blue hat, a voluptous white beard, and an inclination to cast spells."
	text += "<BR><HR>"

/datum/intercept_text/proc/build_nuke(datum/mind/correct_person)
	text += "<BR><BR>Centcom recently received a report of a plot to destroy one of our stations in your area. We believe the Nuclear Authentication Disc "
	text += "that is standard issue aboard your vessel may be a target. We recommend removal of this object, and it's storage in a safe "
	text += "environment. As this may cause panic among the crew, all efforts should be made to keep this information a secret from all but "
	text += "the most trusted crew-members."
	text += "<BR><HR>"

/datum/intercept_text/proc/build_changeling(datum/mind/correct_person)
	var/cname = pick(changeling_names)
	var/orgname1 = pick(org_names_1)
	var/orgname2 = pick(org_names_2)
	/*
	var/changeling_name
	var/changeling_job
	var/prob_right_dude = rand(prob_correct_person_lower, prob_correct_person_higher)
	var/prob_right_job = rand(prob_correct_job_lower, prob_correct_job_higher)
	if(prob(prob_right_job))
		if(correct_person)
			if(correct_person:assigned_role=="MODE")
				changeling_job = pick(get_all_jobs())
			else
				changeling_job = correct_person:assigned_role
	else
		changeling_job = pick(get_all_jobs())
	if(prob(prob_right_dude) && ticker.mode == "changeling")
		if(correct_person:assigned_role=="MODE")
			changeling_name = correct_person:current
		else
			changeling_name = pick_mob()
	else
		changeling_name = pick_mob()
	*/

	text += "<BR><BR>We have received a report that a dangerous alien lifeform known only as <B><U>\"[cname]\"</U></B> may have infiltrated your crew.  "
	/*
	text += "Our intelligence suggests a [prob_right_job]% chance that a [changeling_job] on board your station has been replaced by the alien.  "
	text += "Additionally, the report indicates a [prob_right_dude]% chance that [changeling_name] may have been in contact with the lifeform at a recent social gathering.  "
	*/
	text += "These lifeforms are associated with the <B><U>[orgname1] [orgname2]</U></B> and may be attempting to acquire sensitive materials on their behalf.  "
	text += "Please take care not to alarm the crew, as <B><U>[cname]</U></B> may take advantage of a panic situation. Remember, they can be anybody, suspect everybody!"
	text += "<BR><HR>"

/datum/intercept_text/proc/build_shadowling(datum/mind/correct_person)
	text += "<br><br>Sightings of strange alien creatures have been observed in your area. These aliens supposedly possess the ability to enslave unwitting personnel and leech from their power. \
	Be wary of dark areas and ensure all lights are kept well-maintained. Closely monitor all crew for suspicious behavior and perform dethralling surgery if they have obvious tells. Investigate all \
	reports of odd or suspicious sightings in maintenance."
	text += "<br><br>"
