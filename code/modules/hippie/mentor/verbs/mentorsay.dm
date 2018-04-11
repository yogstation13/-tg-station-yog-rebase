/client/proc/cmd_mentor_say(msg as text)
	set category = "Mentor"
	set name = "Msay" //Gave this shit a shorter name so you only have to time out "msay" rather than "mentor say" to use it --NeoFite
	set hidden = 1
	if(!check_mentor())
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	if(!msg)
		return

	msg = emoji_parse(msg)
	log_mentor("MSAY: [key_name(src)] : [msg]")


	if(check_rights(R_ADMIN,0))
		msg = "<span class='mentoradmin'>MENTOR-ADMIN: <EM>[key_name(src, 0, 0)]</EM>: [msg]</span>"
		to_chat(mentors, msg)
		to_chat(admins, msg)

	else
		msg = "<span class='mentor'>MENTOR: <EM>[key_name(src, 0, 0)]</EM>: [msg]</span>"
		to_chat(mentors, msg)
		to_chat(admins, msg)

/client/verb/msay_popup(message as text)
	set name = "msay"
	set category = "Mentor"
	set hidden = 1
	src.cmd_mentor_say(message)