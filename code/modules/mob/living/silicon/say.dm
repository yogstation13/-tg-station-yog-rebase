
/mob/living/silicon/get_spans()
	return ..() | SPAN_ROBOT

/mob/living/proc/robot_talk(message)
	log_say("[key_name(src)] : [message]", "BINARY")
	var/desig = "Default Cyborg" //ezmode for taters
	if(istype(src, /mob/living/silicon))
		var/mob/living/silicon/S = src
		desig = trim_left(S.designation + " " + S.job)
	var/message_a = say_quote(message, get_spans())
	var/rendered = "<i><span class='game say'>Robotic Talk, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i>"
	for(var/mob/M in player_list)
		if(M.binarycheck())
			if(istype(M, /mob/living/silicon/ai))
				var/renderedAI = "<i><span class='game say'>Robotic Talk, <a href='?src=\ref[M];track=[html_encode(name)]'><span class='name'>[name] ([desig])</span></a> <span class='message'>[message_a]</span></span></i>"
				to_chat(M, renderedAI)
			else
				to_chat(M, rendered)
		if(isobserver(M))
			var/following = src
			// If the AI talks on binary chat, we still want to follow
			// it's camera eye, like if it talked on the radio
			if(istype(src, /mob/living/silicon/ai))
				var/mob/living/silicon/ai/ai = src
				following = ai.eyeobj
			var/link = FOLLOW_LINK(M, following)
			to_chat(M, "[link] [rendered]")

/mob/living/silicon/robot/robot_talk(message)
	..()
	//cyborgs "leak" a bit when they binary talk
	var/garbled_message = Gibberish(message, 70, list("1", "0"))
	var/list/spans = list("robot")
	var/rendered = compose_message(src, ROBOT, garbled_message, , spans)
	for(var/atom/movable/AM in get_hearers_in_view(1, src))
		var/mob/M = null
		if(ismob(AM))
			M = AM
		if(!M || !M.binarycheck())
			AM.Hear(rendered, src, ROBOT, garbled_message, , spans)

/mob/living/silicon/binarycheck()
	return 1

/mob/living/silicon/lingcheck()
	return 0 //Borged or AI'd lings can't speak on the ling channel.

/mob/living/silicon/radio(message, message_mode, list/spans)
	. = ..()
	if(. != 0)
		return .

	if(message_mode == "robot")
		if (radio)
			radio.talk_into(src, message, , spans)
		return REDUCE_RANGE

	else if(message_mode in radiochannels)
		if(radio)
			radio.talk_into(src, message, message_mode, spans)
			return ITALICS | REDUCE_RANGE

	return 0

/mob/living/silicon/get_message_mode(message)
	. = ..()
	if(..() == MODE_HEADSET)
		return MODE_ROBOT
	else
		return .

/mob/living/silicon/handle_inherent_channels(message, message_mode)
	. = ..()
	if(.)
		return .

	if(message_mode == MODE_BINARY)
		if(binarycheck())
			robot_talk(message)
			return 1
	if(message_mode == MODE_SPOKEN_BINARY)
		say(message, , list("robot"), ROBOT)
		return 1
	return 0
