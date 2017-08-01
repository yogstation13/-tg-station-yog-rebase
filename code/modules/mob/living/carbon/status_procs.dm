//Here are the procs used to modify status effects of a mob.
//The effects include: stunned, weakened, paralysis, sleeping, resting, jitteriness, dizziness, ear damage,
// eye damage, eye_blind, eye_blurry, druggy, BLIND disability, and NEARSIGHT disability.

/mob/living/carbon/damage_eyes(amount)
	if(amount>0)
		eye_damage = amount
		if(eye_damage > 20)
			if(eye_damage > 30)
				overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, 2)
			else
				overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, 1)

/mob/living/carbon/set_eye_damage(amount)
	eye_damage = max(amount,0)
	if(eye_damage > 20)
		if(eye_damage > 30)
			overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, 2)
		else
			overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, 1)
	else
		clear_fullscreen("eye_damage")

/mob/living/carbon/adjust_eye_damage(amount)
	eye_damage = max(eye_damage+amount, 0)
	if(eye_damage > 20)
		if(eye_damage > 30)
			overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, 2)
		else
			overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, 1)
	else
		clear_fullscreen("eye_damage")

/mob/living/carbon/adjust_drugginess(amount)
	var/old_druggy = druggy
	if(amount>0)
		druggy += amount
		if(!old_druggy)
			overlay_fullscreen("high", /obj/screen/fullscreen/high)
			throw_alert("high", /obj/screen/alert/high)
	else if(old_druggy)
		druggy = max(druggy+amount, 0)
		if(!druggy)
			clear_fullscreen("high")
			clear_alert("high")
/mob/living/carbon/set_drugginess(amount)
	var/old_druggy = druggy
	druggy = amount
	if(amount>0)
		if(!old_druggy)
			overlay_fullscreen("high", /obj/screen/fullscreen/high)
			throw_alert("high", /obj/screen/alert/high)
	else if(old_druggy)
		clear_fullscreen("high")
		clear_alert("high")

/mob/living/carbon/adjust_disgust(amount)
	var/old_disgust = disgust
	if(amount>0)
		disgust = min(disgust+amount, DISGUST_LEVEL_MAXEDOUT)
		switch(disgust)
			if(0 to DISGUST_LEVEL_GROSS)
				clear_alert("disgust")
			if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
				throw_alert("disgust", /obj/screen/alert/gross)
			if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
				throw_alert("disgust", /obj/screen/alert/verygross)
			if(DISGUST_LEVEL_DISGUSTED to INFINITY)
				throw_alert("disgust", /obj/screen/alert/disgusted)

	else if(old_disgust)
		disgust = max(disgust+amount, 0)
		switch(disgust)
			if(0 to DISGUST_LEVEL_GROSS)
				clear_alert("disgust")
			if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
				throw_alert("disgust", /obj/screen/alert/gross)
			if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
				throw_alert("disgust", /obj/screen/alert/verygross)
			if(DISGUST_LEVEL_DISGUSTED to INFINITY)
				throw_alert("disgust", /obj/screen/alert/disgusted)

/mob/living/carbon/set_disgust(amount)
	disgust = amount
	switch(disgust)
		if(0 to DISGUST_LEVEL_GROSS)
			clear_alert("disgust")
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			throw_alert("disgust", /obj/screen/alert/gross)
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			throw_alert("disgust", /obj/screen/alert/verygross)
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			throw_alert("disgust", /obj/screen/alert/disgusted)

/mob/living/carbon/cure_blind()
	if(disabilities & BLIND)
		disabilities &= ~BLIND
		adjust_blindness(-1)
		return 1
/mob/living/carbon/become_blind()
	if(!(disabilities & BLIND))
		disabilities |= BLIND
		blind_eyes(1)
		return 1

/mob/living/carbon/cure_nearsighted()
	if(disabilities & NEARSIGHT)
		disabilities &= ~NEARSIGHT
		clear_fullscreen("nearsighted")
		return 1

/mob/living/carbon/become_nearsighted()
	if(!(disabilities & NEARSIGHT))
		disabilities |= NEARSIGHT
		overlay_fullscreen("nearsighted", /obj/screen/fullscreen/impaired, 1)
		return 1
