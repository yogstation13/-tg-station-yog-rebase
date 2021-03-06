var/const/CALL_SHUTTLE_REASON_LENGTH = 12

// The communications computer
/obj/machinery/computer/communications
	name = "communications console"
	desc = "This can be used for various important functions. Still under developement."
	icon_screen = "comm"
	icon_keyboard = "tech_key"
	req_access = list(access_heads)
	circuit = /obj/item/weapon/circuitboard/computer/cooldown_holder/communications
	var/authenticated = 0
	var/auth_id = "Unknown" //Who is currently logged in?
	var/list/messagetitle = list()
	var/list/messagetext = list()
	var/currmsg = 0
	var/aicurrmsg = 0
	var/state = STATE_DEFAULT
	var/aistate = STATE_DEFAULT
	var/message_cooldown = 0
	var/ai_message_cooldown = 0
	var/tmp_alertlevel = 0
	var/z_lock = TRUE//Var that admins can change to 0 if they need to use a comms console for some crap, I dunno, because it's basically like I didn't change it.
	var/const/STATE_DEFAULT = 1
	var/const/STATE_CALLSHUTTLE = 2
	var/const/STATE_CANCELSHUTTLE = 3
	var/const/STATE_MESSAGELIST = 4
	var/const/STATE_VIEWMESSAGE = 5
	var/const/STATE_DELMESSAGE = 6
	var/const/STATE_STATUSDISPLAY = 7
	var/const/STATE_ALERT_LEVEL = 8
	var/const/STATE_CONFIRM_LEVEL = 9
	var/const/STATE_TOGGLE_EMERGENCY = 10
	var/const/STATE_PURCHASE = 11

	var/status_display_freq = "1435"
	var/stat_msg1
	var/stat_msg2


/obj/machinery/computer/communications/New()
	shuttle_caller_list += src
	..()

/obj/machinery/computer/communications/process()
	if(..())
		if(state != STATE_STATUSDISPLAY)
			updateDialog()


/obj/machinery/computer/communications/Topic(href, href_list)
	if(..())
		return
	if(z_lock) //Can only be used on SS13 unless z_lock is changed..
		if(z != ZLEVEL_STATION)
			to_chat(usr, "<span class='boldannounce'>Unable to establish a connection</span>: \black You're too far away from the station!")
			return
	usr.set_machine(src)

	if(!href_list["operation"])
		return
	var/obj/item/weapon/circuitboard/computer/cooldown_holder/communications/CM = circuit
	switch(href_list["operation"])
		// main interface
		if("main")
			state = STATE_DEFAULT
		if("login")
			var/mob/living/carbon/human/M = usr
			var/obj/item/weapon/card/id/I = M.get_idcard()
			if (istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/pda = I
				I = pda.id
			if(allowed(M) && M.wear_id)
				if(check_access(I))
					authenticated = 1
					auth_id = "[I.registered_name] ([I.assignment])"
					if((20 in I.access))
						authenticated = 2
			if(emagged)
				authenticated = 2
				auth_id = "Unknown"
			else if(!M.wear_id && !emagged)
				return
		if("logout")
			authenticated = 0

		if("swipeidseclevel")
			var/mob/M = usr
			var/obj/item/weapon/card/id/I = M.get_active_hand()
			if (istype(I, /obj/item/device/pda))
				var/obj/item/device/pda/pda = I
				I = pda.id
			if (I && istype(I))
				if(access_captain in I.access)
					var/old_level = security_level
					if(!tmp_alertlevel) tmp_alertlevel = SEC_LEVEL_GREEN
					if(tmp_alertlevel < SEC_LEVEL_GREEN) tmp_alertlevel = SEC_LEVEL_GREEN
					if(tmp_alertlevel > SEC_LEVEL_BLUE) tmp_alertlevel = SEC_LEVEL_BLUE //Cannot engage delta with this
					set_security_level(tmp_alertlevel)
					if(security_level != old_level)
						//Only notify the admins if an actual change happened
						log_game("[key_name(usr)] has changed the security level to [get_security_level()].")
						message_admins("[key_name_admin(usr)] has changed the security level to [get_security_level()].")
						switch(security_level)
							if(SEC_LEVEL_GREEN)
								feedback_inc("alert_comms_green",1)
							if(SEC_LEVEL_BLUE)
								feedback_inc("alert_comms_blue",1)
					tmp_alertlevel = 0
				else:
					to_chat(usr, "<span class='warning'>You are not authorized to do this!</span>")
					tmp_alertlevel = 0
				state = STATE_DEFAULT
			else
				to_chat(usr, "<span class='warning'>You need to swipe your ID!</span>")

		if("announce")
			if(check_auth() && authenticated==2 && !message_cooldown)
				make_announcement(usr)
			else if (authenticated==2 && message_cooldown)
				to_chat(usr, "Intercomms recharging. Please stand by.")

		if("purchase_menu")
			state = STATE_PURCHASE

		if("buyshuttle")
			if(src.authenticated==2)
				var/list/shuttles = flatten_list(SSmapping.shuttle_templates)
				var/datum/map_template/shuttle/S = locate(href_list["chosen_shuttle"]) in shuttles
				if(S && istype(S))
					if((SSshuttle.shuttle_purchased && !emagged) || SSshuttle.emag_shuttle_purchased)
						usr << "A replacement shuttle has already been purchased."
					else
						if(SSshuttle.points >= S.credit_cost)
							var/obj/machinery/shuttle_manipulator/M  = locate() in machines

							if(M && SSshuttle.emergency.mode != SHUTTLE_DOCKED && SSshuttle.emergency.mode != SHUTTLE_ESCAPE)
								SSshuttle.shuttle_purchased = TRUE
								if(emagged)
									SSshuttle.emag_shuttle_purchased = TRUE
								M.unload_preview()
								M.load_template(S)
								M.existing_shuttle = SSshuttle.emergency
								M.action_load(S)
								SSshuttle.points -= S.credit_cost
								if(!emagged)
									minor_announce("[usr.name] has purchased [S.name] for [S.credit_cost] credits." , "Shuttle Purchase")
								else
									minor_announce("Unknown has purchased [S.name] for [S.credit_cost] credits." , "Shuttle Purchase")
								message_admins("[key_name_admin(usr)] purchased [S.name].")
								feedback_add_details("shuttle_manipulator", S.name)
							else
								usr << "Something went wrong! The shuttle exchange system seems to be down."
						else
							usr << "Not enough credits."


		if("callshuttle")
			state = STATE_DEFAULT
			if(check_auth())
				state = STATE_CALLSHUTTLE
		if("callshuttle2")
			if(check_auth())
				SSshuttle.requestEvac(usr, href_list["call"])
				if(SSshuttle.emergency.timer)
					post_status("shuttle")
			state = STATE_DEFAULT
		if("cancelshuttle")
			state = STATE_DEFAULT
			if(check_auth())
				state = STATE_CANCELSHUTTLE
		if("cancelshuttle2")
			if(check_auth())
				SSshuttle.cancelEvac(usr)
			state = STATE_DEFAULT
		if("messagelist")
			if(check_auth())
				currmsg = 0
				state = STATE_MESSAGELIST
		if("viewmessage")
			if(check_auth())
				state = STATE_VIEWMESSAGE
				if (!currmsg)
					if(href_list["message-num"])
						currmsg = text2num(href_list["message-num"])
					else
						state = STATE_MESSAGELIST
		if("delmessage")
			if(check_auth())
				state = (currmsg) ? STATE_DELMESSAGE : STATE_MESSAGELIST
		if("delmessage2")
			if(check_auth())
				if(currmsg)
					var/title = messagetitle[currmsg]
					var/text  = messagetext[currmsg]
					messagetitle.Remove(title)
					messagetext.Remove(text)
					if(currmsg == aicurrmsg)
						aicurrmsg = 0
					currmsg = 0
				state = STATE_MESSAGELIST
			else
				state = STATE_VIEWMESSAGE
		if("status")
			state = STATE_STATUSDISPLAY

		if("securitylevel")
			if(check_auth())
				tmp_alertlevel = text2num( href_list["newalertlevel"] )
				if(!tmp_alertlevel) tmp_alertlevel = 0
				state = STATE_CONFIRM_LEVEL
		if("changeseclevel")
			if(check_auth())
				state = STATE_ALERT_LEVEL

		if("emergencyaccess")
			if(check_auth())
				state = STATE_TOGGLE_EMERGENCY
		if("enableemergency")
			if(check_auth())
				make_maint_all_access()
				log_game("[key_name(usr)] enabled emergency maintenance access.")
				message_admins("[key_name_admin(usr)] enabled emergency maintenance access.")
				state = STATE_DEFAULT
		if("disableemergency")
			if(check_auth())
				revoke_maint_all_access()
				log_game("[key_name(usr)] disabled emergency maintenance access.")
				message_admins("[key_name_admin(usr)] disabled emergency maintenance access.")
				state = STATE_DEFAULT

		// Status display stuff
		if("setstat")
			if(check_auth())
				switch(href_list["statdisp"])
					if("message")
						post_status("message", stat_msg1, stat_msg2)
					if("alert")
						post_status("alert", href_list["alert"])
					else
						post_status(href_list["statdisp"])

		if("setmsg1")
			if(check_auth() || check_silicon())
				stat_msg1 = reject_bad_text(stripped_input(usr, "Line 1", "Enter Message Text", stat_msg1), 40)
				updateDialog()
		if("setmsg2")
			if(check_auth() || check_silicon())
				stat_msg2 = reject_bad_text(stripped_input(usr, "Line 2", "Enter Message Text", stat_msg2), 40)
				updateDialog()

		// OMG CENTCOM LETTERHEAD
		if("MessageCentcomm")
			if(check_auth() && authenticated==2)
				if(CM.cooldownLeft())
					to_chat(usr, "Arrays recycling.  Please stand by.")
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to Centcom via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination.  Transmission does not guarantee a response.", "Send a message to Centcomm.", "")
				if(!input || !(usr in view(1,src)))
					return
				Centcomm_announce(input, usr)
				to_chat(usr, "Message transmitted.")
				log_say("[key_name(usr)] has made a Centcom announcement: [input]")
				CM.nextAllowedTime = world.time + 600


		// OMG SYNDICATE ...LETTERHEAD
		if("MessageSyndicate")
			if((check_auth() && authenticated==2) && (emagged))
				if(CM.cooldownLeft())
					to_chat(usr, "Arrays recycling.  Please stand by.")
					return
				var/input = stripped_input(usr, "Please choose a message to transmit to \[ABNORMAL ROUTING COORDINATES\] via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination. Transmission does not guarantee a response.", "Send a message to /??????/.", "")
				if(!input || !(usr in view(1,src)))
					return
				Syndicate_announce(input, usr)
				to_chat(usr, "Message transmitted.")
				log_say("[key_name(usr)] has made a Syndicate announcement: [input]")
				CM.nextAllowedTime = world.time + 600

		if("RestoreBackup")
			if(check_auth())
				to_chat(usr, "Backup routing data restored!")
				emagged = 0
				updateDialog()

		if("nukerequest") //When there's no other way
			if(check_auth() && authenticated==2)
				if(CM.cooldownLeft())
					to_chat(usr, "Arrays recycling. Please stand by.")
					return
				var/input = stripped_input(usr, "Please enter the reason for requesting the nuclear self-destruct codes. Misuse of the nuclear request system will not be tolerated under any circumstances.  Transmission does not guarantee a response.", "Self Destruct Code Request.","")
				if(!input || !(usr in view(1,src)))
					return
				Nuke_request(input, usr)
				to_chat(usr, "Request sent.")
				log_say("[key_name(usr)] has requested the nuclear codes from Centcomm")
				priority_announce("The codes for the on-station nuclear self-destruct have been requested by [usr]. Confirmation or denial of this request will be sent shortly.", "Nuclear Self Destruct Codes Requested",'sound/AI/commandreport.ogg')
				CM.nextAllowedTime = world.time + 600


		// AI interface
		if("ai-main")
			if(check_silicon())
				aicurrmsg = 0
				aistate = STATE_DEFAULT
		if("ai-callshuttle")
			if(check_silicon())
				aistate = STATE_CALLSHUTTLE
		if("ai-callshuttle2")
			if(check_silicon())
				SSshuttle.requestEvac(usr, href_list["call"])
				aistate = STATE_DEFAULT
		if("ai-messagelist")
			if(check_silicon())
				aicurrmsg = 0
				aistate = STATE_MESSAGELIST
		if("ai-viewmessage")
			if(check_silicon())
				aistate = STATE_VIEWMESSAGE
				if (!aicurrmsg)
					if(href_list["message-num"])
						aicurrmsg = text2num(href_list["message-num"])
					else
						aistate = STATE_MESSAGELIST
		if("ai-delmessage")
			if(check_silicon())
				aistate = (aicurrmsg) ? STATE_DELMESSAGE : STATE_MESSAGELIST
		if("ai-delmessage2")
			if(check_silicon())
				if(aicurrmsg)
					var/title = messagetitle[aicurrmsg]
					var/text  = messagetext[aicurrmsg]
					messagetitle.Remove(title)
					messagetext.Remove(text)
					if(currmsg == aicurrmsg)
						currmsg = 0
					aicurrmsg = 0
				aistate = STATE_MESSAGELIST
		if("ai-status")
			if(check_silicon())
				aistate = STATE_STATUSDISPLAY
		if("ai-announce")
			if(check_silicon())
				if(!ai_message_cooldown)
					make_announcement(usr, 1)
		if("ai-securitylevel")
			if(check_silicon())
				tmp_alertlevel = text2num( href_list["newalertlevel"] )
				if(!tmp_alertlevel) tmp_alertlevel = 0
				var/old_level = security_level
				if(!tmp_alertlevel) tmp_alertlevel = SEC_LEVEL_GREEN
				if(tmp_alertlevel < SEC_LEVEL_GREEN) tmp_alertlevel = SEC_LEVEL_GREEN
				if(tmp_alertlevel > SEC_LEVEL_BLUE) tmp_alertlevel = SEC_LEVEL_BLUE //Cannot engage delta with this
				set_security_level(tmp_alertlevel)
				if(security_level != old_level)
					//Only notify the admins if an actual change happened
					log_game("[key_name(usr)] has changed the security level to [get_security_level()].")
					message_admins("[key_name_admin(usr)] has changed the security level to [get_security_level()].")
					switch(security_level)
						if(SEC_LEVEL_GREEN)
							feedback_inc("alert_comms_green",1)
						if(SEC_LEVEL_BLUE)
							feedback_inc("alert_comms_blue",1)
				tmp_alertlevel = 0
				aistate = STATE_DEFAULT
		if("ai-changeseclevel")
			if(check_silicon())
				aistate = STATE_ALERT_LEVEL

		if("ai-emergencyaccess")
			if(check_silicon())
				aistate = STATE_TOGGLE_EMERGENCY
		if("ai-enableemergency")
			if(check_silicon())
				make_maint_all_access()
				log_game("[key_name(usr)] enabled emergency maintenance access.")
				message_admins("[key_name_admin(usr)] enabled emergency maintenance access.")
				aistate = STATE_DEFAULT
		if("ai-disableemergency")
			if(check_silicon())
				revoke_maint_all_access()
				log_game("[key_name(usr)] disabled emergency maintenance access.")
				message_admins("[key_name_admin(usr)] disabled emergency maintenance access.")
				aistate = STATE_DEFAULT

	updateUsrDialog()

/obj/machinery/computer/communications/proc/check_silicon()
	if(!isaiorborg(usr))
		message_admins("EXPLOIT: [usr] attempted to perform a silicon function on [src] without being a silicon.")
		return FALSE
	return TRUE

/obj/machinery/computer/communications/proc/check_auth()
	if(!authenticated)
		message_admins("EXPLOIT: [usr] attempted to interact with [src] while not authenticated.")
		return FALSE
	return TRUE

/obj/machinery/computer/communications/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/weapon/card/id))
		attack_hand(user)
	else
		return ..()

/obj/machinery/computer/communications/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		if(authenticated == 1)
			authenticated = 2
		to_chat(user, "<span class='notice'>You scramble the communication routing circuits.</span>")

/obj/machinery/computer/communications/attack_hand(mob/user)
	if(..())
		return
	if(z_lock)
		if (z != ZLEVEL_STATION)
			to_chat(user, "<span class='boldannounce'>Unable to establish a connection</span>: \black You're too far away from the station!")
			return

	user.set_machine(src)
	var/dat = ""
	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/timeleft = SSshuttle.emergency.timeLeft()
		dat += "<B>Emergency shuttle</B>\n<BR>\nETA: [timeleft / 60 % 60]:[add_zero(num2text(timeleft % 60), 2)]"


	var/datum/browser/popup = new(user, "communications", "Communications Console", 400, 500)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))

	if (istype(user, /mob/living/silicon))
		var/dat2 = interact_ai(user) // give the AI a different interact proc to limit its access
		if(dat2)
			dat +=  dat2
			//user << browse(dat, "window=communications;size=400x500")
			//onclose(user, "communications")

			popup.set_content(dat)
			popup.open()
		return

	switch(state)
		if(STATE_DEFAULT)
			if (authenticated)
				if(SSshuttle.emergencyLastCallLoc)
					dat += "<BR>Most recent shuttle call/recall traced to: <b>[format_text(SSshuttle.emergencyLastCallLoc.name)]</b>"
				else
					dat += "<BR>Unable to trace most recent shuttle call/recall signal."
				dat += "<BR>Logged in as: [auth_id]"
				dat += "<BR>"
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=logout'>Log Out</A> \]<BR>"
				dat += "<BR><B>General Functions</B>"
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=messagelist'>Message List</A> \]"
				switch(SSshuttle.emergency.mode)
					if(SHUTTLE_IDLE, SHUTTLE_RECALL)
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=callshuttle'>Call Emergency Shuttle</A> \]"
					else
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=cancelshuttle'>Cancel Shuttle Call</A> \]"

				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=status'>Set Status Display</A> \]"
				if (authenticated==2)
					dat += "<BR><BR><B>Captain Functions</B>"
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=announce'>Make a Captain's Announcement</A> \]"
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=purchase_menu'>Purchase Shuttle</A> \]"
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=changeseclevel'>Change Alert Level</A> \]"
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=emergencyaccess'>Emergency Maintenance Access</A> \]"
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=nukerequest'>Request Nuclear Authentication Codes</A> \]"
					if(emagged == 0)
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=MessageCentcomm'>Send Message to Centcom</A> \]"
					else
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=MessageSyndicate'>Send Message to \[UNKNOWN\]</A> \]"
						dat += "<BR>\[ <A HREF='?src=\ref[src];operation=RestoreBackup'>Restore Backup Routing Data</A> \]"
			else
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=login'>Log In</A> \]"
		if(STATE_CALLSHUTTLE)
			dat += get_call_shuttle_form()
		if(STATE_CANCELSHUTTLE)
			dat += get_cancel_shuttle_form()
		if(STATE_MESSAGELIST)
			dat += "Messages:"
			for(var/i = 1; i<=messagetitle.len; i++)
				dat += "<BR><A HREF='?src=\ref[src];operation=viewmessage;message-num=[i]'>[messagetitle[i]]</A>"
		if(STATE_VIEWMESSAGE)
			if (currmsg)
				dat += "<B>[messagetitle[currmsg]]</B><BR><BR>[messagetext[currmsg]]"
				if (authenticated)
					dat += "<BR><BR>\[ <A HREF='?src=\ref[src];operation=delmessage'>Delete \]"
			else
				state = STATE_MESSAGELIST
				attack_hand(user)
				return
		if(STATE_DELMESSAGE)
			if (currmsg)
				dat += "Are you sure you want to delete this message? \[ <A HREF='?src=\ref[src];operation=delmessage2'>OK</A> | <A HREF='?src=\ref[src];operation=viewmessage'>Cancel</A> \]"
			else
				state = STATE_MESSAGELIST
				attack_hand(user)
				return
		if(STATE_STATUSDISPLAY)
			dat += "Set Status Displays<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=blank'>Clear</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=message'>Message</A> \]"
			dat += "<ul><li> Line 1: <A HREF='?src=\ref[src];operation=setmsg1'>[ stat_msg1 ? stat_msg1 : "(none)"]</A>"
			dat += "<li> Line 2: <A HREF='?src=\ref[src];operation=setmsg2'>[ stat_msg2 ? stat_msg2 : "(none)"]</A></ul><br>"
			dat += "\[ Alert: <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=default'>None</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=redalert'>Red Alert</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=lockdown'>Lockdown</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR><HR>"
		if(STATE_ALERT_LEVEL)
			dat += "Current alert level: [get_security_level()]<BR>"
			if(security_level == SEC_LEVEL_DELTA)
				dat += "<font color='red'><b>The self-destruct mechanism is active. Find a way to deactivate the mechanism to lower the alert level or evacuate.</b></font>"
			else
				dat += "<A HREF='?src=\ref[src];operation=securitylevel;newalertlevel=[SEC_LEVEL_BLUE]'>Blue</A><BR>"
				dat += "<A HREF='?src=\ref[src];operation=securitylevel;newalertlevel=[SEC_LEVEL_GREEN]'>Green</A>"
		if(STATE_CONFIRM_LEVEL)
			dat += "Current alert level: [get_security_level()]<BR>"
			dat += "Confirm the change to: [num2seclevel(tmp_alertlevel)]<BR>"
			dat += "<A HREF='?src=\ref[src];operation=swipeidseclevel'>Swipe ID</A> to confirm change.<BR>"
		if(STATE_TOGGLE_EMERGENCY)
			if(emergency_access == 1)
				dat += "<b>Emergency Maintenance Access is currently <font color='red'>ENABLED</font></b>"
				dat += "<BR>Restore maintenance access restrictions? <BR>\[ <A HREF='?src=\ref[src];operation=disableemergency'>OK</A> | <A HREF='?src=\ref[src];operation=viewmessage'>Cancel</A> \]"
			else
				dat += "<b>Emergency Maintenance Access is currently <font color='green'>DISABLED</font></b>"
				dat += "<BR>Lift access restrictions on maintenance and external airlocks? <BR>\[ <A HREF='?src=\ref[src];operation=enableemergency'>OK</A> | <A HREF='?src=\ref[src];operation=viewmessage'>Cancel</A> \]"
		if(STATE_PURCHASE)
			dat += "Budget: [SSshuttle.points] Credits.<BR>"
			for(var/shuttle_id in SSmapping.shuttle_templates)
				var/datum/map_template/shuttle/S = SSmapping.shuttle_templates[shuttle_id]
				if(!emagged && S.emag_buy)
					continue
				if(S.credit_cost < INFINITY)
					dat += "[S.name] | [S.credit_cost] Credits<BR>"
					if(S.description)
						dat += "[S.description]<BR>"
					dat += "<A href='?src=\ref[src];operation=buyshuttle;chosen_shuttle=\ref[S]'>(<font color=red><i>Purchase</i></font>)</A><BR><BR>"

	dat += "<BR><BR>\[ [(state != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=main'>Main Menu</A> | " : ""]<A HREF='?src=\ref[user];mach_close=communications'>Close</A> \]"
	//user << browse(dat, "window=communications;size=400x500")
	//onclose(user, "communications")
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/communications/proc/get_javascript_header(form_id)
	var/dat = {"<script type="text/javascript">
						function getLength(){
							var reasonField = document.getElementById('reasonfield');
							if(reasonField.value.length >= [CALL_SHUTTLE_REASON_LENGTH]){
								reasonField.style.backgroundColor = "#DDFFDD";
							}
							else {
								reasonField.style.backgroundColor = "#FFDDDD";
							}
						}
						function submit() {
							document.getElementById('[form_id]').submit();
						}
					</script>"}
	return dat

/obj/machinery/computer/communications/proc/get_call_shuttle_form(ai_interface = 0)
	var/form_id = "callshuttle"
	var/dat = get_javascript_header(form_id)
	dat += "<form name='callshuttle' id='[form_id]' action='?src=\ref[src]' method='get' style='display: inline'>"
	dat += "<input type='hidden' name='src' value='\ref[src]'>"
	dat += "<input type='hidden' name='operation' value='[ai_interface ? "ai-callshuttle2" : "callshuttle2"]'>"
	dat += "<b>Nature of emergency:</b><BR> <input type='text' id='reasonfield' name='call' style='width:250px; background-color:#FFDDDD; onkeydown='getLength() onkeyup='getLength()' onkeypress='getLength()'>"
	dat += "<BR>Are you sure you want to call the shuttle? \[ <a href='#' onclick='submit()'>Call</a> \]"
	return dat

/obj/machinery/computer/communications/proc/get_cancel_shuttle_form()
	var/form_id = "cancelshuttle"
	var/dat = get_javascript_header(form_id)
	dat += "<form name='cancelshuttle' id='[form_id]' action='?src=\ref[src]' method='get' style='display: inline'>"
	dat += "<input type='hidden' name='src' value='\ref[src]'>"
	dat += "<input type='hidden' name='operation' value='cancelshuttle2'>"

	dat += "<BR>Are you sure you want to cancel the shuttle? \[ <a href='#' onclick='submit()'>Cancel</a> \]"
	return dat

/obj/machinery/computer/communications/proc/interact_ai(mob/living/silicon/ai/user)
	var/dat = ""
	switch(aistate)
		if(STATE_DEFAULT)
			if(SSshuttle.emergencyLastCallLoc)
				dat += "<BR>Latest emergency signal trace attempt successful.<BR>Last signal origin: <b>[format_text(SSshuttle.emergencyLastCallLoc.name)]</b>.<BR>"
			else
				dat += "<BR>Latest emergency signal trace attempt failed.<BR>"
			if(authenticated)
				dat += "Current login: [auth_id]"
			else
				dat += "Current login: None"
			dat += "<BR><BR><B>General Functions</B>"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-messagelist'>Message List</A> \]"
			if(SSshuttle.emergency.mode == SHUTTLE_IDLE)
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-callshuttle'>Call Emergency Shuttle</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-status'>Set Status Display</A> \]"
			dat += "<BR><BR><B>Special Functions</B>"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-announce'>Make an Announcement</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-changeseclevel'>Change Alert Level</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-emergencyaccess'>Emergency Maintenance Access</A> \]"
		if(STATE_CALLSHUTTLE)
			dat += get_call_shuttle_form(1)
		if(STATE_MESSAGELIST)
			dat += "Messages:"
			for(var/i = 1; i<=messagetitle.len; i++)
				dat += "<BR><A HREF='?src=\ref[src];operation=ai-viewmessage;message-num=[i]'>[messagetitle[i]]</A>"
		if(STATE_VIEWMESSAGE)
			if (aicurrmsg)
				dat += "<B>[messagetitle[aicurrmsg]]</B><BR><BR>[messagetext[aicurrmsg]]"
				dat += "<BR><BR>\[ <A HREF='?src=\ref[src];operation=ai-delmessage'>Delete</A> \]"
			else
				aistate = STATE_MESSAGELIST
				attack_hand(user)
				return null
		if(STATE_DELMESSAGE)
			if(aicurrmsg)
				dat += "Are you sure you want to delete this message? \[ <A HREF='?src=\ref[src];operation=ai-delmessage2'>OK</A> | <A HREF='?src=\ref[src];operation=ai-viewmessage'>Cancel</A> \]"
			else
				aistate = STATE_MESSAGELIST
				attack_hand(user)
				return

		if(STATE_STATUSDISPLAY)
			dat += "Set Status Displays<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=blank'>Clear</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=message'>Message</A> \]"
			dat += "<ul><li> Line 1: <A HREF='?src=\ref[src];operation=setmsg1'>[ stat_msg1 ? stat_msg1 : "(none)"]</A>"
			dat += "<li> Line 2: <A HREF='?src=\ref[src];operation=setmsg2'>[ stat_msg2 ? stat_msg2 : "(none)"]</A></ul><br>"
			dat += "\[ Alert: <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=default'>None</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=redalert'>Red Alert</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=lockdown'>Lockdown</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR><HR>"

		if(STATE_ALERT_LEVEL)
			dat += "Current alert level: [get_security_level()]<BR>"
			if(security_level == SEC_LEVEL_DELTA)
				dat += "<font color='red'><b>The self-destruct mechanism is active. Find a way to deactivate the mechanism to lower the alert level or evacuate.</b></font>"
			else
				dat += "<A HREF='?src=\ref[src];operation=ai-securitylevel;newalertlevel=[SEC_LEVEL_BLUE]'>Blue</A><BR>"
				dat += "<A HREF='?src=\ref[src];operation=ai-securitylevel;newalertlevel=[SEC_LEVEL_GREEN]'>Green</A>"

		if(STATE_TOGGLE_EMERGENCY)
			if(emergency_access == 1)
				dat += "<b>Emergency Maintenance Access is currently <font color='red'>ENABLED</font></b>"
				dat += "<BR>Restore maintenance access restrictions? <BR>\[ <A HREF='?src=\ref[src];operation=ai-disableemergency'>OK</A> | <A HREF='?src=\ref[src];operation=ai-viewmessage'>Cancel</A> \]"
			else
				dat += "<b>Emergency Maintenance Access is currently <font color='green'>DISABLED</font></b>"
				dat += "<BR>Lift access restrictions on maintenance and external airlocks? <BR>\[ <A HREF='?src=\ref[src];operation=ai-enableemergency'>OK</A> | <A HREF='?src=\ref[src];operation=ai-viewmessage'>Cancel</A> \]"

	dat += "<BR><BR>\[ [(aistate != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=ai-main'>Main Menu</A> | " : ""]<A HREF='?src=\ref[user];mach_close=communications'>Close</A> \]"
	return dat

/obj/machinery/computer/communications/proc/make_announcement(mob/living/user, is_silicon)
	var/input = stripped_input(user, "Please choose a message to announce to the station crew.", "What?")
	if(!input || !user.canUseTopic(src))
		return
	if(ai_message_cooldown || message_cooldown)
		return
	if(is_silicon)
		minor_announce(input,"[user.name] Announces:")
		ai_message_cooldown = 1
		spawn(600)//One minute cooldown
			ai_message_cooldown = 0
	else
		priority_announce(html_decode(input), null, 'sound/misc/announce.ogg', "Captain")
		message_cooldown = 1
		spawn(600)//One minute cooldown
			message_cooldown = 0
	log_say("[key_name(user)] has made a priority announcement: [input]")
	message_admins("[key_name_admin(user)] has made a priority announcement.")



/obj/machinery/computer/communications/proc/post_status(command, data1, data2)

	var/datum/radio_frequency/frequency = SSradio.return_frequency(1435)

	if(!frequency) return

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = TRANSMISSION_RADIO
	status_signal.data["command"] = command

	switch(command)
		if("message")
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
		if("alert")
			status_signal.data["picture_state"] = data1

	frequency.post_signal(src, status_signal)


/obj/machinery/computer/communications/Destroy()
	shuttle_caller_list -= src
	SSshuttle.autoEvac()
	return ..()

/obj/machinery/computer/communications/proc/overrideCooldown()
	var/obj/item/weapon/circuitboard/computer/cooldown_holder/communications/CM = circuit
	CM.nextAllowedTime = 0
