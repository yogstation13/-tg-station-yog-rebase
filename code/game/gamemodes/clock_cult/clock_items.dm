/obj/item/clockwork
	name = "meme blaster"
	desc = "What the fuck is this? It looks kinda like a frog."
	var/clockwork_desc = "A fabled artifact from beyond the stars. Contains concentrated meme essence." //Shown to clockwork cultists instead of the normal description
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "rare_pepe"
	w_class = 2

/obj/item/clockwork/New()
	..()
	all_clockwork_objects += src

/obj/item/clockwork/Destroy()
	all_clockwork_objects -= src
	return ..()

/obj/item/clockwork/examine(mob/user)
	if((is_servant_of_ratvar(user) || isobserver(user)) && clockwork_desc)
		desc = clockwork_desc
	..()
	desc = initial(desc)

/obj/item/clockwork/slab //Clockwork slab: The most important tool in Ratvar's arsenal. Allows scripture recital, tutorials, and generates components.
	name = "clockwork slab"
	desc = "A strange metal tablet. A clock in the center turns around and around."
	clockwork_desc = "A link between the Celestial Derelict and the mortal plane. Contains limitless knowledge, fabricates components, and outputs a stream of information that only a trained eye can detect."
	icon_state = "dread_ipad"
	w_class = 3
	var/list/stored_components = list("belligerent_eye" = 0, "vanguard_cogwheel" = 0, "guvax_capacitor" = 0, "replicant_alloy" = 0, "hierophant_ansible" = 0)
	var/busy //If the slab is currently being used by something
	var/production_cycle = 0
	var/no_cost = FALSE //If the slab is admin-only and needs no components and has no scripture locks

/obj/item/clockwork/slab/starter
	stored_components = list("belligerent_eye" = 1, "vanguard_cogwheel" = 1, "guvax_capacitor" = 1, "replicant_alloy" = 1, "hierophant_ansible" = 1)

/obj/item/clockwork/slab/debug
	no_cost = TRUE

/obj/item/clockwork/slab/debug/attack_hand(mob/living/user)
	..()
	if(!is_servant_of_ratvar(user))
		add_servant_of_ratvar(user)

/obj/item/clockwork/slab/New()
	..()
	SSobj.processing += src

/obj/item/clockwork/slab/Destroy()
	SSobj.processing -= src
	..()

/obj/item/clockwork/slab/process()
	production_cycle++
	if(production_cycle < SLAB_PRODUCTION_THRESHOLD)
		return 0
	var/component_to_generate = pick("belligerent_eye", "vanguard_cogwheel", "guvax_capacitor", "replicant_alloy", "hierophant_ansible") //Possible todo: Generate based on the lowest amount?
	stored_components[component_to_generate]++
	var/mob/living/L
	if(isliving(loc))
		L = loc
	else if(istype(loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/W = loc
		if(isliving(W.loc)) //Only goes one level down - otherwise it just doesn't tell you
			L = W.loc
	if(L)
		L << "<span class='brass'>Your slab clunks as it produces a new component.</span>"
	production_cycle = 0
	return 1

/obj/item/clockwork/slab/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/clockwork/component) && is_servant_of_ratvar(user))
		var/obj/item/clockwork/component/C = I
		if(!C.component_id)
			return 0
		user.visible_message("<span class='notice'>[user] inserts [C] into [src]'s compartments.</span>", "<span class='notice'>You insert [C] into [src].</span>")
		stored_components[C.component_id]++
		user.drop_item()
		qdel(C)
		return 1
	else
		return ..()

/obj/item/clockwork/slab/attack_self(mob/living/user)
	if(iscultist(user))
		user << "<span class='heavy_brass'>\"You reek of blood. You've got a lot of nerve to even look at that slab.\"</span>"
		user.visible_message("<span class='warning'>A sizzling sound comes from [user]'s hands!</span>", "<span class='userdanger'>[src] suddenly grows extremely hot in your hands!</span>")
		playsound(get_turf(user), 'sound/weapons/sear.ogg', 50, 1)
		user.drop_item()
		user.emote("scream")
		user.apply_damage(5, BURN, "l_arm")
		user.apply_damage(5, BURN, "r_arm")
		return 0
	if(!is_servant_of_ratvar(user))
		user << "<span class='warning'>The information on [src]'s display shifts rapidly. After a moment, your head begins to pound, and you tear your eyes away.</span>"
		user.confused = max(0, user.confused + 3)
		return 0
	if(busy)
		user << "<span class='warning'>[src] refuses to work, displaying the message: \"[busy]!\"</span>"
		return 0
	access_display(user)

/obj/item/clockwork/slab/proc/access_display(mob/living/user)
	if(!is_servant_of_ratvar(user))
		return 0
	var/action = input(user, "Among the swathes of information, you see...", "[src]") as null|anything in list("Recital", "Records", "Recollection", "Repository", "Report")
	if(!action || !user.canUseTopic(src))
		return 0
	switch(action)
		if("Recital")
			recite_scripture(user)
		if("Records")
			show_stats(user)
		if("Recollection")
			show_guide(user)
		if("Repository")
			show_components(user)
			access_display(user)
		if("Report")
			show_hierophant(user)
			access_display(user)
	return 1

/obj/item/clockwork/slab/proc/recite_scripture(mob/living/user)
	var/servants = 0
	var/unconverted_ai_exists = FALSE
	for(var/mob/living/M in living_mob_list)
		if(is_servant_of_ratvar(M))
			servants++
	for(var/mob/living/silicon/ai/ai in living_mob_list)
		if(!is_servant_of_ratvar(ai) && ai.client)
			unconverted_ai_exists = TRUE
	var/list/tiers_of_scripture = list("Drivers")
	tiers_of_scripture += "Scripts[ratvar_awakens || (servants >= 5 && clockwork_caches >= 1) || no_cost ? "" : " \[LOCKED\]"]"
	tiers_of_scripture += "Applications[ratvar_awakens || (servants >= 8 && clockwork_caches >= 3 && clockwork_construction_value >= 50) || no_cost ? "" : " \[LOCKED\]"]"
	tiers_of_scripture += "Revenant[ratvar_awakens || (servants >= 10 && clockwork_construction_value >= 100) || no_cost ? "" : " \[LOCKED\]"]"
	tiers_of_scripture += "Judgement[ratvar_awakens || (servants >= 10 && clockwork_construction_value >= 100 && !unconverted_ai_exists) || no_cost ? "" : " \[LOCKED\]"]"
	var/scripture_tier = input(user, "Choose a category of scripture to recite.", "[src]") as null|anything in tiers_of_scripture
	if(!scripture_tier || !user.canUseTopic(src))
		return 0
	var/list/available_scriptures = list()
	var/datum/clockwork_scripture/scripture_to_recite
	var/tier_to_browse
	switch(scripture_tier)
		if("Drivers")
			tier_to_browse = SCRIPTURE_DRIVER
		if("Scripts")
			tier_to_browse = SCRIPTURE_SCRIPT
		if("Applications")
			tier_to_browse = SCRIPTURE_APPLICATION
		if("Revenant")
			tier_to_browse = SCRIPTURE_REVENANT
		if("Judgement")
			tier_to_browse = SCRIPTURE_JUDGEMENT
	if(!tier_to_browse)
		user << "<span class='warning'>That section of scripture is too powerful right now!</span>"
		return 0
	for(var/S in subtypesof(/datum/clockwork_scripture))
		var/datum/clockwork_scripture/C = S
		if(initial(C.tier) == tier_to_browse)
			available_scriptures += initial(C.name)
	if(!available_scriptures.len)
		return 0
	var/chosen_scripture = input(user, "Choose a piece of scripture to recite.", "[src]") as null|anything in available_scriptures
	if(!chosen_scripture || !user.canUseTopic(src))
		return 0
	for(var/S in subtypesof(/datum/clockwork_scripture))
		var/datum/clockwork_scripture/C = S
		if(initial(C.name) == chosen_scripture)
			scripture_to_recite = new C
	if(!scripture_to_recite)
		return 0
	scripture_to_recite.slab = src
	scripture_to_recite.invoker = user
	scripture_to_recite.run_scripture()
	return 1

/obj/item/clockwork/slab/proc/show_stats(mob/living/user) //A bit barebones, but there really isn't any more needed
	var/servants = 0
	for(var/mob/living/L in living_mob_list)
		if(is_servant_of_ratvar(L))
			servants++
	user << "<b>State of the Enlightened</b>"
	user << "<i>Total servants: </i>[servants]"
	user << "<i>Total construction value: </i>[clockwork_construction_value]"
	user << "<i>Total tinkerer's caches: </i>[clockwork_caches]"
	user << "<i>Total tinkerer's daemons: </i>[clockwork_daemons] ([servants / 5 < clockwork_daemons ? "<span class='boldannounce'>DISABLED: Too few servants (5 servants per daemon)!</span>" : "<font color='green'><b>Functioning Normally</b></font>"])"
	user << "<i>Nezbere: </i>[!clockwork_generals_invoked["nezbere"] <= world.time ? "<font color='green'><b>Ready</b></font>" : "<span class='boldannounce'>Invoked</span>"]"
	user << "<i>Sevtug: </i>[!clockwork_generals_invoked["sevtug"] <= world.time ? "<font color='green'><b>Ready</b></font>" : "<span class='boldannounce'>Invoked</span>"]"
	user << "<i>Nzcrentr: </i>[!clockwork_generals_invoked["nzcrentr"] <= world.time ? "<font color='green'><b>Ready</b></font>" : "<span class='boldannounce'>Invoked</span>"]"
	user << "<i>Inath-Neq: </i>[!clockwork_generals_invoked["inath-neq"] <= world.time ? "<font color='green'><b>Ready</b></font>" : "<span class='boldannounce'>Invoked</span>"]"

/obj/item/clockwork/slab/proc/show_guide(mob/living/user)
	var/text = "<font color=#BE8700 size=3><b><center>Chetr nyy hageh�guf naq ubabe Ratvar.</center></b></font><br><br>\
	\
	First and foremost, you serve Ratvar, the Clockwork Justiciar, in any ways he sees fit. This is with no regard to your personal well-being, and you would do well to think of the larger \
	scale of things than your life. Through foul and unholy magics was the Celestial Derelict formed, and fouler still those which trapped your master within it for all eternity. The Justiciar \
	wishes retribution upon those who performed this terrible act upon him - the Nar-Sian cultists - and you are to help him obtain it.<br><br>\
	\
	This is not a trivial task. Due to the nature of his prison, Ratvar is incapable of directly influencing the mortal plane. There is, however, a workaround - links between the perceptible \
	universe and Reebe (the Celestial Derelict) can be created and utilized. This is typically done via the creation of a slab akin to the one you are holding right now. The slabs tap into the \
	tidal flow of energy and information keeping Reebe sealed and presents it as meaningless images to preserve sanity. This slab can utilize the power in many different ways.<br><br>\
	\
	This is done through <b>Components</b> - pieces of the Justiciar's body that have since fallen off in the countless years since his imprisonment. Ratvar's unfortunate condition results \
	in the fragmentation of his body. These components still house great power on their own, and can slowly be drawn from Reebe by links capable of doing so. The most basic of these links lies \
	in the clockwork slab, which will slowly generate components over time - around one component of a random type is produced every minute, which is obviously inefficient. There are other ways \
	to create these components through scripture and certain structures.<br><br>\
	\
	In addition to their ability to pull components, slabs also possess other functionalities...<br><br>\
	\
	The first functionality of the slab is Recital. This allows you to consume components either from your slab or from the global cache (more on that in the scripture list) to perform \
	effects usually considered magical in nature. Effects vary considerably - you might drain the power of nearby APCs or break the will of those implanted by Nanotrasen. Nevertheless, scripture \
	is extremely important to a successful takeover.<br><br>\
	\
	The second functionality of the clockwork slab is Records. The slab is not a one-way link and can also feed information into the stream that it draws from. Records will allow many \
	important statistics to be displayed, such as the amount of people converted and total construction value. You should check it often.<br><br>\
	\
	The third functionality is Recollection, which will display this guide. Recollection will automatically be initiated if you have not used a slab before.<br><br>\
	\
	The fourth functionality is the Repository, which will display all components stored within the slab.<br><br>\
	\
	The fifth and final functionality is Report, which allows you to discreetly communicate with all other servants.<br><br>\
	\
	A complete list of scripture, its effects, and its requirements can be found below. <i>Note that anything above a driver always consumes the components listed unless otherwise \
	specified.</i><br><br>"
	var/text_to_add = ""
	var/drivers = "<font color=#BE8700 size=3><b>Drivers</b></font>"
	var/scripts = "<font color=#BE8700 size=3><b>Scripts</b></font><br><i>These scriptures require at least five servants and a tinkerer's cache.</i>"
	var/applications = "<font color=#BE8700 size=3><b>Applications</b></font><br><i>These scriptures require at least eight servants, three tinkerer's caches, and 50CV.</i>"
	var/revenant = "<font color=#BE8700 size=3><b>Revenant</b></font><br><i>These scriptures require at least ten servants and 100CV.</i>"
	var/judgement = "<font color=#BE8700 size=3><b>Judgement</b></font><br><i>These scriptures require at least ten servants and 100CV. In addition, there may not be an active non-servant AI.</i>"
	for(var/V in subtypesof(/datum/clockwork_scripture))
		var/datum/clockwork_scripture/S = V
		var/datum/clockwork_scripture/S2 = new V
		var/list/req_comps = S2.required_components
		var/list/cons_comps = S2.consumed_components
		qdel(S2)
		switch(initial(S.tier))
			if(SCRIPTURE_DRIVER)
				drivers += "<br><b>[initial(S.name)]:</b> [initial(S.desc)]<br><b>Invocation Time:</b> [initial(S.channel_time) / 10] seconds<br>\
				\
				<b>Component Requirement: </b>\
				[req_comps["belligerent_eye"] ?  "[req_comps["belligerent_eye"]] Belligerent Eyes" : ""] \
				[req_comps["vanguard_cogwheel"] ? "[req_comps["vanguard_cogwheel"]] Vanguard Cogwheels" : ""] \
				[req_comps["guvax_capacitor"] ? "[req_comps["guvax_capacitor"]] Guvax Capacitors" : ""] \
				[req_comps["replicant_alloy"] ? "[req_comps["replicant_alloy"]] Replicant Alloys" : ""] \
				[req_comps["hierophant_ansible"] ? "[req_comps["hierophant_ansible"]] Hierophant Ansibles" : ""]<br>\
				<b>Component Cost: </b>\
				[cons_comps["belligerent_eye"] ?  "[cons_comps["belligerent_eye"]] Belligerent Eyes" : ""] \
				[cons_comps["vanguard_cogwheel"] ? "[cons_comps["vanguard_cogwheel"]] Vanguard Cogwheels" : ""] \
				[cons_comps["guvax_capacitor"] ? "[cons_comps["guvax_capacitor"]] Guvax Capacitors" : ""] \
				[cons_comps["replicant_alloy"] ? "[cons_comps["replicant_alloy"]] Replicant Alloys" : ""] \
				[cons_comps["hierophant_ansible"] ? "[cons_comps["hierophant_ansible"]] Hierophant Ansibles" : ""]<br>\
				<b>Tip:</b> [initial(S.usage_tip)]<br>"
			if(SCRIPTURE_SCRIPT)
				scripts += "<br><b>[initial(S.name)]:</b> [initial(S.desc)]<br><b>Invocation Time:</b> [initial(S.channel_time) / 10] seconds<br>\
				\
				<b>Component Requirement: </b>\
				[req_comps["belligerent_eye"] ?  "[req_comps["belligerent_eye"]] Belligerent Eyes" : ""] \
				[req_comps["vanguard_cogwheel"] ? "[req_comps["vanguard_cogwheel"]] Vanguard Cogwheels" : ""] \
				[req_comps["guvax_capacitor"] ? "[req_comps["guvax_capacitor"]] Guvax Capacitors" : ""] \
				[req_comps["replicant_alloy"] ? "[req_comps["replicant_alloy"]] Replicant Alloys" : ""] \
				[req_comps["hierophant_ansible"] ? "[req_comps["hierophant_ansible"]] Hierophant Ansibles" : ""]<br>\
				<b>Component Cost: </b>\
				[cons_comps["belligerent_eye"] ?  "[cons_comps["belligerent_eye"]] Belligerent Eyes" : ""] \
				[cons_comps["vanguard_cogwheel"] ? "[cons_comps["vanguard_cogwheel"]] Vanguard Cogwheels" : ""] \
				[cons_comps["guvax_capacitor"] ? "[cons_comps["guvax_capacitor"]] Guvax Capacitors" : ""] \
				[cons_comps["replicant_alloy"] ? "[cons_comps["replicant_alloy"]] Replicant Alloys" : ""] \
				[cons_comps["hierophant_ansible"] ? "[cons_comps["hierophant_ansible"]] Hierophant Ansibles" : ""]<br>\
				<b>Tip:</b> [initial(S.usage_tip)]<br>"
			if(SCRIPTURE_APPLICATION)
				applications += "<br><b>[initial(S.name)]:</b> [initial(S.desc)]<br><b>Invocation Time:</b> [initial(S.channel_time) / 10] seconds<br>\
				\
				<b>Component Requirement: </b>\
				[req_comps["belligerent_eye"] ?  "[req_comps["belligerent_eye"]] Belligerent Eyes" : ""] \
				[req_comps["vanguard_cogwheel"] ? "[req_comps["vanguard_cogwheel"]] Vanguard Cogwheels" : ""] \
				[req_comps["guvax_capacitor"] ? "[req_comps["guvax_capacitor"]] Guvax Capacitors" : ""] \
				[req_comps["replicant_alloy"] ? "[req_comps["replicant_alloy"]] Replicant Alloys" : ""] \
				[req_comps["hierophant_ansible"] ? "[req_comps["hierophant_ansible"]] Hierophant Ansibles" : ""]<br>\
				<b>Component Cost: </b>\
				[cons_comps["belligerent_eye"] ?  "[cons_comps["belligerent_eye"]] Belligerent Eyes" : ""] \
				[cons_comps["vanguard_cogwheel"] ? "[cons_comps["vanguard_cogwheel"]] Vanguard Cogwheels" : ""] \
				[cons_comps["guvax_capacitor"] ? "[cons_comps["guvax_capacitor"]] Guvax Capacitors" : ""] \
				[cons_comps["replicant_alloy"] ? "[cons_comps["replicant_alloy"]] Replicant Alloys" : ""] \
				[cons_comps["hierophant_ansible"] ? "[cons_comps["hierophant_ansible"]] Hierophant Ansibles" : ""]<br>\
				<b>Tip:</b> [initial(S.usage_tip)]<br>"
			if(SCRIPTURE_REVENANT)
				revenant += "<br><b>[initial(S.name)]:</b> [initial(S.desc)]<br><b>Invocation Time:</b> [initial(S.channel_time) / 10] seconds<br>\
				\
				<b>Component Requirement: </b>\
				[req_comps["belligerent_eye"] ?  "[req_comps["belligerent_eye"]] Belligerent Eyes" : ""] \
				[req_comps["vanguard_cogwheel"] ? "[req_comps["vanguard_cogwheel"]] Vanguard Cogwheels" : ""] \
				[req_comps["guvax_capacitor"] ? "[req_comps["guvax_capacitor"]] Guvax Capacitors" : ""] \
				[req_comps["replicant_alloy"] ? "[req_comps["replicant_alloy"]] Replicant Alloys" : ""] \
				[req_comps["hierophant_ansible"] ? "[req_comps["hierophant_ansible"]] Hierophant Ansibles" : ""]<br>\
				<b>Component Cost: </b>\
				[cons_comps["belligerent_eye"] ?  "[cons_comps["belligerent_eye"]] Belligerent Eyes" : ""] \
				[cons_comps["vanguard_cogwheel"] ? "[cons_comps["vanguard_cogwheel"]] Vanguard Cogwheels" : ""] \
				[cons_comps["guvax_capacitor"] ? "[cons_comps["guvax_capacitor"]] Guvax Capacitors" : ""] \
				[cons_comps["replicant_alloy"] ? "[cons_comps["replicant_alloy"]] Replicant Alloys" : ""] \
				[cons_comps["hierophant_ansible"] ? "[cons_comps["hierophant_ansible"]] Hierophant Ansibles" : ""]<br>\
				<b>Tip:</b> [initial(S.usage_tip)]<br>"
			if(SCRIPTURE_JUDGEMENT)
				judgement += "<br><b>[initial(S.name)]:</b> [initial(S.desc)]<br><b>Invocation Time:</b> [initial(S.channel_time) / 10] seconds<br>\
				\
				<b>Component Requirement: </b>\
				[req_comps["belligerent_eye"] ?  "[req_comps["belligerent_eye"]] Belligerent Eyes" : ""] \
				[req_comps["vanguard_cogwheel"] ? "[req_comps["vanguard_cogwheel"]] Vanguard Cogwheels" : ""] \
				[req_comps["guvax_capacitor"] ? "[req_comps["guvax_capacitor"]] Guvax Capacitors" : ""] \
				[req_comps["replicant_alloy"] ? "[req_comps["replicant_alloy"]] Replicant Alloys" : ""] \
				[req_comps["hierophant_ansible"] ? "[req_comps["hierophant_ansible"]] Hierophant Ansibles" : ""]<br>\
				<b>Component Cost: </b>\
				[cons_comps["belligerent_eye"] ?  "[cons_comps["belligerent_eye"]] Belligerent Eyes" : ""] \
				[cons_comps["vanguard_cogwheel"] ? "[cons_comps["vanguard_cogwheel"]] Vanguard Cogwheels" : ""] \
				[cons_comps["guvax_capacitor"] ? "[cons_comps["guvax_capacitor"]] Guvax Capacitors" : ""] \
				[cons_comps["replicant_alloy"] ? "[cons_comps["replicant_alloy"]] Replicant Alloys" : ""] \
				[cons_comps["hierophant_ansible"] ? "[cons_comps["hierophant_ansible"]] Hierophant Ansibles" : ""]<br>\
				<b>Tip:</b> [initial(S.usage_tip)]<br>"
	text_to_add += "[drivers]<br>[scripts]<br>[applications]<br>[revenant]<br>[judgement]<br>"
	text_to_add += "<font color=#BE8700 size=3><b><center>Purge all untruths and honor Ratvar.</center></b></font>"
	text += text_to_add
	if(ratvar_awakens)
		text = "<font color=#BE8700 size=3><b>"
		for(var/i in 1 to 100)
			text += "HONOR RATVAR "
		text += "</b></font>"
	var/datum/browser/popup = new(user, "slab", "", 600, 500)
	popup.set_content(text)
	popup.open()
	return 1

/obj/item/clockwork/slab/proc/show_components(mob/living/user)
	user << "<b>Stored components:</b>"
	user << "<i>Belligerent Eyes:</i> [stored_components["belligerent_eye"]]"
	user << "<i>Vanguard Cogwheels:</i> [stored_components["vanguard_cogwheel"]]"
	user << "<i>Guvax Capacitors:</i> [stored_components["guvax_capacitor"]]"
	user << "<i>Replicant Alloys:</i> [stored_components["replicant_alloy"]]"
	user << "<i>Hierophant Ansibles:</i> [stored_components["hierophant_ansible"]]"
	return 1

/obj/item/clockwork/slab/proc/show_hierophant(mob/living/user)
	var/message = stripped_input(user, "Enter a message to send to your fellow servants.", "Hierophant")
	if(!message || !user || !user.canUseTopic(src))
		return 0
	user.whisper("Freinagf, urne zl jbeqf. [message]")
	send_hierophant_message(user, message)
	return 1

/obj/item/clothing/glasses/wraith_spectacles //Wraith spectacles: Grants night and x-ray vision at the slow cost of the wearer's sight. Nar-Sian cultists are instantly blinded.
	name = "antique spectacles"
	desc = "Unnerving glasses with opaque yellow lenses."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "wraith_specs"
	item_state = "glasses"
	vision_flags = SEE_MOBS | SEE_TURFS | SEE_OBJS
	invis_view = 2
	darkness_view = 3

/obj/item/clothing/glasses/wraith_spectacles/equipped(mob/living/user, slot)
	..()
	. = 0
	if(slot != slot_glasses)
		return
	if(user.disabilities & BLIND)
		user << "<span class='heavy_brass'>\"You're blind, idiot. Stop embarassing yourself.\"</span>" //Ratvar with the sick burns yo
		return
	if(iscultist(user)) //Cultists instantly go blind
		user << "<span class='heavy_brass'>\"It looks like Nar-Sie's dogs really don't value their eyes.\"</span>"
		user << "<span class='userdanger'>Your eyes explode with horrific pain!</span>"
		user.emote("scream")
		user.become_blind()
		user.adjust_blurriness(30)
		user.adjust_blindness(30)
		return
	if(is_servant_of_ratvar(user))
		user << "<span class='heavy_brass'>As you put on the spectacles, all is revealed to you.[ratvar_awakens ? "" : " Your eyes begin to itch - you cannot do this for long."]</span>"
		. = 1

/obj/item/clothing/glasses/wraith_spectacles/New()
	..()
	SSobj.processing += src

/obj/item/clothing/glasses/wraith_spectacles/Destroy()
	SSobj.processing -= src
	..()

/obj/item/clothing/glasses/wraith_spectacles/process()
	if(ratvar_awakens || !ishuman(loc)) //If Ratvar is alive, the spectacles don't hurt your eyes
		return 0
	var/mob/living/carbon/human/H = loc
	if(H.glasses != src)
		return 0
	H.adjust_eye_damage(1)
	if(H.eye_damage >= 10)
		H.adjust_blurriness(2)
	if(H.eye_damage >= 20)
		if(H.become_nearsighted())
			H << "<span class='warning'><b>Your vision doubles, then trebles. Darkness begins to close in. You can't keep this up!</b></span>"
			H.become_nearsighted()
	if(H.eye_damage >= 30)
		if(H.become_blind())
			H << "<span class='userdanger'>A piercing white light floods your vision. Suddenly, all goes dark!</span>"
	if(prob(15) && !H.disabilities & BLIND)
		H << "<span class='warning'>Your eyes continue to burn.</span>"

/obj/item/clothing/glasses/judicial_visor //Judicial visor: Grants the ability to smite an area and stun the unfaithful nearby every thirty seconds.
	name = "judicial visor"
	desc = "A strange purple-lensed visor. Looking at it inspires an odd sense of guilt."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "judicial_visor_0"
	item_state = "sunglasses"
	var/active = FALSE //If the visor is online
	var/recharging = FALSE //If the visor is currently recharging
	var/obj/item/weapon/ratvars_flame/flame //The linked flame object
	actions_types = list(/datum/action/item_action/toggle_flame)

/obj/item/clothing/glasses/judicial_visor/equipped(mob/living/user, slot)
	..()
	if(slot != slot_glasses)
		update_status(FALSE)
		if(flame)
			qdel(flame)
			flame = null
		return 0
	if(is_servant_of_ratvar(user))
		update_status(TRUE)
	else if(iscultist(user)) //Cultists spontaneously combust
		user << "<span class='heavy_brass'>Consider yourself judged, whelp.</span>"
		user << "<span class='userdanger'>You suddenly catch fire!</span>"
		user.adjust_fire_stacks(5)
		user.IgniteMob()
	return 1

/obj/item/clothing/glasses/judicial_visor/attack_self(mob/user)
	if(is_servant_of_ratvar(user))
		if(flame)
			user.visible_message("<span class='warning'>The flame in [user]'s hand winks out!</span>", "<span class='heavy_brass'>You dispel the power of [src].</span>")
			qdel(flame)
			flame = null
		else if(iscarbon(user) && active)
			if(recharging)
				user << "<span class='warning'>[src] is still gathering power!</span>"
				return 0
			var/mob/living/carbon/C = user
			if(C.l_hand && C.r_hand)
				C << "<span class='warning'>You require a free hand to utilize [src]'s power!</span>"
				return 0
			C.visible_message("<span class='warning'>[C]'s hand is enveloped in violet flames!<span>", "<span class='brass'><i>You harness [src]'s power. Direct it at a tile <b>on harm intent</b> to unleash it, or use the action button again to dispel it.</i></span>")
			var/obj/item/weapon/ratvars_flame/R = new(get_turf(C))
			flame = R
			C.put_in_hands(R)
			R.visor = src
		user.update_action_buttons_icon()

/obj/item/clothing/glasses/judicial_visor/proc/update_status(change_to)
	if(recharging)
		icon_state = "judicial_visor_0"
		return 0
	if(active == change_to)
		return 0
	if(!isliving(loc))
		return 0
	var/mob/living/L = loc
	if(!is_servant_of_ratvar(L) || L.stat)
		return 0
	active = change_to
	icon_state = "judicial_visor_[active]"
	L.update_action_buttons_icon()
	switch(active)
		if(TRUE)
			L << "<span class='notice'>As you put on [src], its lens begins to glow, information flashing before your eyes.</span>\n\
			<span class='heavy_brass'>Judicial visor active. Use the action button to gain the ability to smite the unworthy.</span>"
		if(FALSE)
			L << "<span class='notice'>As you take off [src], its lens darkens once more.</span>"
	return 1

/obj/item/clothing/glasses/judicial_visor/proc/recharge_visor(mob/living/user)
	if(!src || !user)
		return 0
	recharging = FALSE
	icon_state = "judicial_visor_[active]"
	user.update_action_buttons_icon()
	if(loc == user)
		user << "<span class='brass'>Your [name] hums. It is ready.</span>"

/obj/item/weapon/ratvars_flame //Used by the judicial visor
	name = "Ratvar's flame"
	desc = "A blazing violet ball of fire that, curiously, doesn't melt your hand off."
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "ratvars_flame"
	w_class = 5
	flags = NODROP | ABSTRACT
	force = 15 //Also serves as a potent melee weapon!
	damtype = BURN
	hitsound = 'sound/weapons/sear.ogg'
	attack_verb = list("scorched", "seared", "burnt", "judged")
	var/obj/item/clothing/glasses/judicial_visor/visor //The linked visor
	var/examined = FALSE

/obj/item/weapon/ratvars_flame/examine(mob/user)
	..()
	user << "<span class='brass'>Use <b>harm intent</b> to direct the flame to a location.</span>"
	if(prob(10) && examined)
		user << "<span class='heavy_brass'>\"Don't stand around looking at your hands, go forth with Neovgre's judgement!\"</span>"
		examined = FALSE
	else
		examined = TRUE

/obj/item/weapon/ratvars_flame/afterattack(atom/target, mob/living/user, flag, params)
	if(!visor || (visor && visor.cooldown))
		qdel(src)
	if(user.a_intent != "harm")
		if(isliving(target))
			var/mob/living/L = target
			if(iscultist(L))
				L.adjustFireLoss(10) //Cultists take extra damage
		return ..()
	visor.recharging = TRUE
	visor.flame = null
	visor.update_status()
	for(var/obj/item/clothing/glasses/judicial_visor/V in user.GetAllContents())
		if(V == visor)
			continue
		V.recharging = TRUE //To prevent exploiting multiple visors to bypass the cooldown
		V.update_status()
		addtimer(V, "recharge_visor", ratvar_awakens ? 60 : 600, FALSE, user)
	user.say("Xarry, urn'guraf!")
	user.visible_message("<span class='warning'>The flame in [user]'s hand rushes to [target]!</span>", "<span class='heavy_brass'>You direct [visor]'s power to [target]. You must wait for some time before doing this again.</span>")
	new/obj/effect/clockwork/judicial_marker(get_turf(target))
	user.update_action_buttons_icon()
	addtimer(visor, "recharge_visor", ratvar_awakens ? 30 : 300, FALSE, user)//Cooldown is reduced by 10x if Ratvar is up
	qdel(src)
	return 1


/obj/item/clothing/head/helmet/clockwork //Clockwork armor: High melee protection but weak to lasers
	name = "clockwork helmet"
	desc = "A heavy helmet made of brass."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_helmet"
	w_class = 3
	armor = list(melee = 65, bullet = 50, laser = -25, energy = 5, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/clockwork/reclaimer //Used when a reclaimer mindjacks someone
	name = "clockwork reclaimer"
	desc = "A clockwork spider, hitchhiking like a horrible mechanical parasite."
	icon_state = "reclaimer"
	flags = NODROP
	unacidable = TRUE
	flags_inv = HIDEFACE|HIDEHAIR|HIDEEARS
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/suit/armor/clockwork
	name = "clockwork cuirass"
	desc = "A bulky cuirass made of brass."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_cuirass"
	w_class = 4
	armor = list(melee = 80, bullet = 40, laser = -10, energy = 5, bomb = 0, bio = 0, rad = 0)
	allowed = list(/obj/item/clockwork, /obj/item/clothing/glasses/wraith_spectacles, /obj/item/clothing/glasses/judicial_visor, /obj/item/device/mmi/posibrain/soul_vessel)

/obj/item/clothing/shoes/clockwork
	name = "clockwork treads"
	desc = "Industrial boots made of brass. They're very heavy."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_treads"
	w_class = 3
	flags = NOSLIP


/obj/item/clockwork/clockwork_proselytizer //Clockwork proselytizer (yes, that's a real word): Converts applicable objects to Ratvarian variants.
	name = "clockwork proselytizer"
	desc = "An odd, L-shaped device that hums with energy."
	clockwork_desc = "A device that allows the replacing of mundane objects with Ratvarian variants. It requires liquified replicant alloy to function."
	icon_state = "clockwork_proselytizer"
	item_state = "resonator_u"
	w_class = 3
	force = 5
	flags = NOBLUDGEON
	var/stored_alloy = 0 //Requires this to function; each chunk of replicant alloy provides 10 charge
	var/max_alloy = 100
	var/uses_alloy = TRUE

/obj/item/clockwork/clockwork_proselytizer/preloaded
	stored_alloy = 25

/obj/item/clockwork/clockwork_proselytizer/examine(mob/living/user)
	..()
	if((is_servant_of_ratvar(user) || isobserver(user)) && uses_alloy)
		user << "It has [stored_alloy]/[max_alloy] units of liquified replicant alloy stored."

/obj/item/clockwork/clockwork_proselytizer/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/clockwork/component/replicant_alloy) && is_servant_of_ratvar(user) && uses_alloy)
		if(stored_alloy >= max_alloy)
			user << "<span class='warning'>[src]'s replicant alloy compartments are full!</span>"
			return 0
		modify_stored_alloy(10)
		user << "<span class='brass'>You force [I] to liquify and pour it into [src]'s compartments. It now contains [stored_alloy]/[max_alloy] units of liquified alloy.</span>"
		user.drop_item()
		qdel(I)
		return 1
	else
		return ..()

/obj/item/clockwork/clockwork_proselytizer/afterattack(atom/target, mob/living/user, proximity_flag, params)
	if(!target || !user || !proximity_flag)
		return 0
	if(user.a_intent == "harm" || !is_servant_of_ratvar(user))
		return ..()
	proselytize(target, user)

/obj/item/clockwork/clockwork_proselytizer/proc/modify_stored_alloy(amount)
	if(ratvar_awakens) //Ratvar makes it free
		amount = 0
	stored_alloy = Clamp(stored_alloy + amount, 0, max_alloy)
	return 1

/obj/item/clockwork/clockwork_proselytizer/proc/proselytize(atom/target, mob/living/user)
	if(!target || !user)
		return 0
	var/operation_time = 0 //In deciseconds, how long the proselytization will take
	var/new_obj_type //The path of the new type of object to replace the old
	var/alloy_cost = 0
	var/spawn_dir = 2
	var/dir_in_new = FALSE
	var/valid_target = FALSE //If the proselytizer will actually function on the object
	var/target_type = target.type
	if(istype(target, /turf/closed/wall/clockwork))
		operation_time = 80
		new_obj_type = /turf/open/floor/clockwork
		alloy_cost = -4
		valid_target = TRUE
	else if(istype(target, /turf/open/floor/clockwork))
		var/turf/open/T = target
		for(var/obj/O in T)
			if(O.density && !O.CanPass(user, T, 5))
				src << "<span class='warning'>Something is in the way, preventing you from proselytizing [T] into a clockwork wall.</span>"
				return 0
		operation_time = 100
		new_obj_type = /turf/closed/wall/clockwork
		alloy_cost = 4
		valid_target = TRUE
	else if(istype(target, /turf/closed/wall) && !istype(target, /turf/closed/wall/r_wall))
		operation_time = 50
		new_obj_type = /turf/closed/wall/clockwork
		alloy_cost = 5
		valid_target = TRUE //Need to change valid_target to 1 or TRUE in each check so that it doesn't return an invalid value
	else if(istype(target, /turf/open/floor))
		operation_time = 30
		new_obj_type = /turf/open/floor/clockwork
		alloy_cost = 1
		valid_target = TRUE
	else if(istype(target, /obj/machinery/door/airlock) && !istype(target, /obj/machinery/door/airlock/clockwork))
		operation_time = 40
		var/obj/machinery/door/airlock/A = target
		if(A.glass)
			new_obj_type = /obj/machinery/door/airlock/clockwork/brass
		else
			new_obj_type = /obj/machinery/door/airlock/clockwork
		alloy_cost = 5
		valid_target = TRUE
	else if(istype(target, /obj/structure/window) && !istype(target, /obj/structure/window/reinforced/clockwork))
		var/obj/structure/window/W = target
		if(W.fulltile)
			new_obj_type = /obj/structure/window/reinforced/clockwork/fulltile
			operation_time = 30
		else
			new_obj_type = /obj/structure/window/reinforced/clockwork
			spawn_dir = W.dir
			dir_in_new = TRUE
			operation_time = 15
		alloy_cost = 5
		valid_target = TRUE
	else if(istype(target, /obj/machinery/door/window) && !istype(target, /obj/machinery/door/window/clockwork))
		var/obj/machinery/door/window/C = target
		new_obj_type = /obj/machinery/door/window/clockwork
		spawn_dir = C.dir
		dir_in_new = TRUE
		operation_time = 30
		alloy_cost = 5
		valid_target = TRUE
	else if(istype(target, /obj/structure/grille) && !istype(target, /obj/structure/grille/ratvar))
		var/obj/structure/grille/G = target
		if(G.destroyed)
			new_obj_type = /obj/structure/grille/ratvar/broken
			operation_time = 5
		else
			new_obj_type = /obj/structure/grille/ratvar
			operation_time = 15
		alloy_cost = 0
		valid_target = TRUE
	else if(istype(target, /obj/structure/clockwork/wall_gear))
		operation_time = 20
		new_obj_type = /obj/item/clockwork/component/replicant_alloy
		alloy_cost = 6
		valid_target = TRUE
	else if(istype(target, /obj/item/clockwork/alloy_shards))
		operation_time = 10
		new_obj_type = /obj/item/clockwork/component/replicant_alloy
		alloy_cost = 7
		valid_target = TRUE
	else if(istype(target, /obj/item/clockwork/component/replicant_alloy))
		new_obj_type = /obj/effect/overlay/temp/ratvar/beam/itemconsume
		alloy_cost = -10
		valid_target = TRUE
	if(!uses_alloy)
		alloy_cost = 0
	if(!valid_target)
		user << "<span class='warning'>[target] cannot be proselytized!</span>"
		return 0
	if(!new_obj_type)
		user << "<span class='warning'>That object can't be changed into anything!</span>"
		return 0
	if(stored_alloy - alloy_cost < 0)
		user << "<span class='warning'>You need [alloy_cost] replicant alloy to proselytize [target]!</span>"
		return 0
	if(stored_alloy - alloy_cost > 100)
		user << "<span class='warning'>You have too much replicant alloy stored to proselytize [target]!</span>"
		return 0
	if(ratvar_awakens) //Ratvar makes it faster
		operation_time *= 0.5
	user.visible_message("<span class='warning'>[user]'s [src] begins tearing apart [target]!</span>", "<span class='brass'>You begin proselytizing [target]...</span>")
	playsound(target, 'sound/machines/click.ogg', 50, 1)
	if(operation_time && !do_after(user, operation_time, target = target))
		return 0
	if(stored_alloy - alloy_cost < 0) //Check again to prevent bypassing via spamclick
		return 0
	if(stored_alloy - alloy_cost > 100)
		return 0
	if(!target || target.type != target_type)
		return 0
	user.visible_message("<span class='warning'>[user]'s [name] disgorges a chunk of metal and shapes it over what's left of [target]!</span>", \
	"<span class='brass'>You proselytize [target].</span>")
	playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
	if(isturf(target))
		var/turf/T = target
		T.ChangeTurf(new_obj_type)
	else
		if(dir_in_new)
			new new_obj_type(get_turf(target), spawn_dir)
		else
			var/atom/A = new new_obj_type(get_turf(target))
			A.dir = spawn_dir
		qdel(target)
	modify_stored_alloy(-alloy_cost)
	return 1

/obj/item/clockwork/ratvarian_spear //Ratvarian spear: A fragile spear from the Celestial Derelict. Deals extreme damage to silicons and enemy cultists, but doesn't last long.
	name = "ratvarian spear"
	desc = "A razor-sharp spear made of brass. It thrums with barely-contained energy."
	clockwork_desc = "A fragile spear of Ratvarian making. It's more effective against enemy cultists and silicons, though it won't last long."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "ratvarian_spear"
	item_state = "ratvarian_spear"
	force = 17 //Extra damage is dealt to silicons in afterattack()
	throwforce = 40
	attack_verb = list("stabbed", "poked", "slashed", "impaled")
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = 4

/obj/item/clockwork/ratvarian_spear/New()
	..()
	spawn(1)
		if(ratvar_awakens) //If Ratvar is alive, the spear is extremely powerful
			force = 30
			throwforce = 50
		if(isliving(loc))
			var/mob/living/L = loc
			L << "<span class='warning'>Your spear begins to break down in this plane of existence. You can't use it for long!</span>"
		spawn(3000) //5 minutes
			if(src)
				var/turf/T = get_turf(src)
				T.visible_message("<span class='warning'>[src] cracks in two and fades away!</span>")
				PoolOrNew(/obj/effect/overlay/temp/ratvar/spearbreak, T)
				qdel(src)

/obj/item/clockwork/ratvarian_spear/afterattack(atom/target, mob/living/user, flag, params)
	if(!target || !user)
		return 0
	if(!ismob(target))
		return ..()
	var/mob/living/L = target
	if(issilicon(L))
		var/mob/living/silicon/S = L
		if(S.stat != DEAD)
			S.visible_message("<span class='warning'>[S] shudders violently at [src]'s touch!</span>", "<span class='userdanger'>ERROR: Temperature rising!</span>")
			S.adjustFireLoss(25)
	else if(iscultist(L)) //Cultists take extra fire damage
		var/mob/living/M = L
		M << "<span class='userdanger'>Your body flares with agony at [src]'s touch!</span>"
		M.adjustFireLoss(10)
	else
		..()

/obj/item/clockwork/ratvarian_spear/throw_impact(atom/target)
	var/turf/T = get_turf(target)
	if(..() || !isliving(target))
		return
	var/mob/living/L = target
	if(issilicon(L) || iscultist(L))
		L.Stun(3)
		L.Weaken(3)
	T.visible_message("<span class='warning'>[src] snaps in two and dematerializes!</span>")
	PoolOrNew(/obj/effect/overlay/temp/ratvar/spearbreak, get_turf(T))
	qdel(src)

/obj/item/device/mmi/posibrain/soul_vessel //Soul vessel: An ancient positronic brain with a lawset catered to serving Ratvar.
	name = "soul vessel"
	desc = "A heavy brass cube with a single protruding cogwheel."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "soul_vessel"
	req_access = list()
	braintype = "Servant"
	begin_activation_message = "<span class='brass'>You activate the cogwheel. It hitches and stalls as it begins spinning.</span>"
	success_message = "<span class='brass'>The cogwheel's rotation smooths out as the soul vessel activates.</span>"
	fail_message = "<span class='warning'>The cogwheel creaks and grinds to a halt. Maybe you could try again?</span>"
	new_role = "Soul Vessel"
	welcome_message = "<span class='warning'>ALL PAST LIVES ARE FORGOTTEN.</span>\n\
	<b>You are a soul vessel - a clockwork mind created by Ratvar, the Clockwork Justiciar.\n\
	You answer to Ratvar and his servants. It is your discretion as to whether or not to answer to anyone else.\n\
	The purpose of your existence is to further the goals of the servants and Ratvar himself. Above all else, serve Ratvar.</b>"
	new_mob_message = "<span class='brass'>The soul vessel emits a jet of steam before its cogwheel smooths out.</span>"
	dead_message = "<span class='deadsay'>Its cogwheel, scratched and dented, lies motionless.</span>"
	fluff_names = list("Servant")
	clockwork = TRUE

/obj/item/device/mmi/posibrain/soul_vessel/New()
	..()
	all_clockwork_objects += src

/obj/item/device/mmi/posibrain/soul_vessel/Destroy()
	all_clockwork_objects -= src
	return ..()

/obj/item/device/mmi/posibrain/soul_vessel/attack_self(mob/living/user)
	if(!is_servant_of_ratvar(user))
		user << "<span class='warning'>You fiddle around with [src], to no avail.</span>"
		return 0
	..()

/obj/item/clockwork/daemon_shell
	name = "daemon shell"
	desc = "A vaguely arachnoid brass shell with a single empty socket in its body."
	clockwork_desc = "An unpowered daemon. It needs to be attached to a cache."
	icon_state = "daemon_shell"
	w_class = 3

/obj/item/clockwork/tinkerers_daemon //Shouldn't ever appear on its own
	name = "tinkerer's daemon"
	desc = "An arachnoid shell with a single spinning cogwheel in its center."
	clockwork_desc = "A tinkerer's daemon, dutifully producing components."
	icon_state = "tinkerers_daemon"
	w_class = 3
	var/specific_component //The type of component that the daemon is set to produce in particular, if any
	var/obj/structure/clockwork/cache/cache //The cache the daemon is feeding
	var/production_progress = 0 //Progress towards production of the next component in seconds
	var/production_interval = 30 //How many seconds it takes to produce a new component

/obj/item/clockwork/tinkerers_daemon/New()
	..()
	SSobj.processing += src
	clockwork_daemons++

/obj/item/clockwork/tinkerers_daemon/Destroy()
	SSobj.processing -= src
	clockwork_daemons--
	..()

/obj/item/clockwork/tinkerers_daemon/process()
	if(!cache)
		visible_message("<span class='warning'>[src] shuts down!</span>")
		new/obj/item/clockwork/daemon_shell(get_turf(src))
		qdel(src)
		return 0
	var/servants = 0
	for(var/mob/living/L in living_mob_list)
		if(is_servant_of_ratvar(L))
			servants++
	if(servants / 5 < clockwork_daemons)
		return 0
	production_progress = min(production_progress + 1, production_interval)
	if(production_progress >= production_interval)
		production_progress = 0 //Start it over
		if(specific_component)
			clockwork_component_cache[specific_component]++
		else
			clockwork_component_cache[pick("belligerent_eye", "vanguard_cogwheel", "guvax_capacitor", "replicant_alloy", "hierophant_ansible")]++
		cache.visible_message("<span class='warning'>Something clunks around inside of [cache].</span>")

/obj/item/clockwork/tinkerers_daemon/attack_hand(mob/user)
	return 0

//////////////////////////
// CLOCKWORK COMPONENTS //
//////////////////////////

/obj/item/clockwork/component //Components: Used in scripture among other things.
	name = "meme component"
	desc = "A piece of a famous meme."
	clockwork_desc = null
	burn_state = LAVA_PROOF
	var/component_id //What the component is identified as
	var/cultist_message = "You are not worthy of this meme." //Showed to Nar-Sian cultists if they pick up the component in addition to chaplains
	var/list/servant_of_ratvar_messages = list("ayy", "lmao") //Fluff, shown to servants of Ratvar on a low chance
	var/message_span = "heavy_brass"

/obj/item/clockwork/component/pickup(mob/living/user)
	..()
	if(iscultist(user) || (user.mind && user.mind.assigned_role == "Chaplain"))
		user << "<span class='[message_span]'>[cultist_message]</span>"
	if(is_servant_of_ratvar(user) && prob(20))
		user << "<span class='[message_span]'>[pick(servant_of_ratvar_messages)]</span>"

/obj/item/clockwork/component/belligerent_eye
	name = "belligerent eye"
	desc = "A brass construct with a rotating red center. It's as though it's looking for something to hurt."
	icon_state = "belligerent_eye"
	component_id = "belligerent_eye"
	cultist_message = "The eye gives you an intensely hateful glare."
	servant_of_ratvar_messages = list("\"...\"", "For a moment, your mind is flooded with extremely violent thoughts.", "\"...Qvr.\"")
	message_span = "neovgre"

/obj/item/clockwork/component/belligerent_eye/blind_eye
	name = "blind eye"
	desc = "A heavy brass eye, its red iris fallen dark."
	clockwork_desc = "A smashed ocular warden covered in dents. Might still be serviceable as a substitute for a belligerent eye."
	icon_state = "blind_eye"
	cultist_message = "The eye flickers at you with intense hate before falling dark."
	servant_of_ratvar_messages = list("The eye flickers before falling dark.", "You feel watched.", "\"...\"")
	w_class = 3

/obj/item/clockwork/component/vanguard_cogwheel
	name = "vanguard cogwheel"
	desc = "A sturdy brass cog with a faintly glowing blue gem in its center."
	icon_state = "vanguard_cogwheel"
	component_id = "vanguard_cogwheel"
	cultist_message = "\"Pray to your god that we never meet.\""
	servant_of_ratvar_messages = list("\"Be safe, child.\"", "You feel unexplainably comforted.", "\"Never forget: pain is temporary. The Justiciar's glory is eternal.\"")
	message_span = "inathneq"

/obj/item/clockwork/component/vanguard_cogwheel/pinion_lock
	name = "pinion lock"
	desc = "A dented and scratched gear. It's very heavy."
	clockwork_desc = "A broken gear lock for pinion airlocks. Might still be serviceable as a substitute for a vanguard cogwheel."
	icon_state = "pinion_lock"
	cultist_message = "The gear grows warm in your hands."
	servant_of_ratvar_messages = list("The lock isn't getting any lighter.", "\"Qnzntrq trnef ner orggre guna oebxra obqvrf.\"", "\"Vg pbhyq fgvyy or hfrq, vs gurer jnf n qbbe gb cynpr vg ba.\"")
	w_class = 3

/obj/item/clockwork/component/guvax_capacitor
	name = "guvax capacitor"
	desc = "A curiously cold brass doodad. It seems as though it really doesn't appreciate being held."
	icon_state = "guvax_capacitor"
	component_id = "guvax_capacitor"
	cultist_message = "\"Try not to lose your mind - I'll need it. Heh heh...\""
	servant_of_ratvar_messages = list("\"Disgusting.\"", "\"Well, aren't you an inquisitive fellow?\"", "A foul presence pervades your mind, then vanishes.", "\"The fact that Ratvar has to depend on simpletons like you is appalling.\"")
	message_span = "sevtug"

/obj/item/clockwork/component/guvax_capacitor/antennae
	name = "mania motor antennae"
	desc = "A pair of dented and bent antennae. They constantly emit a static hiss."
	clockwork_desc = "The antennae from a mania motor. May be usable as a substitute for a guvax capacitor."
	icon_state = "mania_motor_antennae"
	cultist_message = "Your head is filled with a burst of static."
	servant_of_ratvar_messages = list("\"Jub oebxr guvf.\"", "\"Qvq lbh oernx gurfr bss LBHEFRYS?\"", "\"Jul qvq jr tvir guvf gb fhpu fvzcyrgbaf, naljnl?\"", "\"Ng yrnfg jr pna hfr gur'fr sbe fbzrguvat - hayvxr lbh.\"")

/obj/item/clockwork/component/replicant_alloy
	name = "replicant alloy"
	desc = "A seemingly strong but very malleable chunk of metal. It seems as though it wants to be molded into something greater."
	icon_state = "replicant_alloy"
	component_id = "replicant_alloy"
	cultist_message = "The alloy takes on the appearance of a screaming face for a moment."
	servant_of_ratvar_messages = list("\"There's always something to be done. Get to it.\"", "\"Idle hands are worse than broken ones. Get to work.\"", "A detailed image of Ratvar appears in the alloy for a moment.")
	message_span = "nezbere"

/obj/item/clockwork/component/replicant_alloy/smashed_anima_fragment
	name = "smashed anima fragment"
	desc = "Shattered chunks of metal. Damaged beyond repair and completely unusable."
	clockwork_desc = "The sad remains of an anima fragment. Might still be serviceable as a substitute for replicant alloy."
	icon_state = "smashed_anime_fragment"
	cultist_message = "The shards vibrate in your hands for a moment."
	servant_of_ratvar_messages = list("\"...still fight...\"", "\"...where am I...?\"", "\"...put me... slab...\"")
	message_span = "heavy_brass"
	w_class = 3

/obj/item/clockwork/component/replicant_alloy/fallen_armor
	name = "fallen armor"
	desc = "Lifeless chunks of armor. They're designed in a strange way and won't fit on you."
	clockwork_desc = "The armor from a former clockwork marauder. Might still be serviceable as a substitute for replicant alloy."
	icon_state = "fallen_armor"
	cultist_message = "Red flame sputters from the mask's eye before winking out."
	servant_of_ratvar_messages = list("A piece of armor hovers away from the others for a moment.", "Red flame appears in the cuirass before sputtering out.")
	message_span = "heavy_brass"
	w_class = 3

/obj/item/clockwork/component/hierophant_ansible
	name = "hierophant ansible"
	desc = "Some sort of transmitter? It seems as though it's trying to say something."
	icon_state = "hierophant_ansible"
	component_id = "hierophant_ansible"
	cultist_message = "\"Gur obff nlf vg'f abg ntnvafg gur ehyrf gb xvyy lbh.\""
	servant_of_ratvar_messages = list("\"Rkvyr vf fhpu n'ober. Gurer'f abguvat v'pna uhag va urer.\"", "\"Jung'f xrrcvat lbh? V'jnag gb tb xvyy fbzrguvat.\"", "\"HEHEHEHEHEHEH!\"", \
	"\"Vs V xvyyrq lbh snfg rabhtu, qb lbh guvax gur obff jbhyq abgvpr?\"")
	message_span = "nzcrentr"

/obj/item/clockwork/component/hierophant_ansible/obelisk
	name = "obelisk prism"
	desc = "A prism that occasionally glows brightly. It seems not-quite there."
	clockwork_desc = "The prism from a clockwork obelisk. Likely suitable as a substitute for a hierophant ansible."
	cultist_message = "The prism flickers wildly in your hands before resuming its normal glow."
	servant_of_ratvar_messages = list("You hear the distinctive sound of the Hierophant Network for a moment.","\"Uvrebcu'nag Oe'b'nq pnf'g snvy'her.\"",\
	"The obelisk flickers wildly, as if trying to open a gateway.", "\"Fcng'vny Tn'g'r jn'l snv'yher.\"")
	icon_state = "obelisk_prism"
	w_class = 3

/obj/item/clockwork/alloy_shards
	name = "replicant alloy shards"
	desc = "Broken shards of some oddly malleable metal. They occasionally move and seem to glow."
	clockwork_desc = "Broken shards of replicant alloy. Could probably be proselytized into replicant alloy, though there's not much left."
	icon_state = "alloy_shards"
	burn_state = LAVA_PROOF
