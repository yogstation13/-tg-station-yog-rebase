// A very special plant, deserving it's own file.

/obj/item/seeds/kudzu
	name = "pack of kudzu seeds"
	desc = "These seeds grow into a weed that grows incredibly fast."
	icon_state = "seed-kudzu"
	species = "kudzu"
	plantname = "Kudzu"
	product = /obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod
	lifespan = 20
	endurance = 10
	yield = 4
	growthstages = 4
	plant_type = PLANT_WEED
	rarity = 30
	var/list/mutations = list()
	var/admin_approved = FALSE
	reagents_add = list("charcoal" = 0.08, "nutriment" = 0.04)

/obj/item/seeds/kudzu/Copy()
	var/obj/item/seeds/kudzu/S = ..()
	S.mutations = mutations.Copy()
	return S

/obj/item/seeds/kudzu/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] swallows the pack of kudzu seeds! It looks like \he's trying to commit suicide..</span>")
	plant(user)
	return (BRUTELOSS)

/obj/item/seeds/kudzu/proc/plant(mob/user, turf/T)
	return
	/*message_admins("Kudzu planted by [key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) at ([T.x],[T.y],[T.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a>)",0,1)
	investigate_log("was planted by [key_name(user)] at ([T.x],[T.y],[T.z])","kudzu")
	new /obj/effect/spacevine_controller(user.loc, mutations, potency, production)
	qdel(src)*/

/obj/item/seeds/kudzu/attack_self(mob/user)
	to_chat(user, "Nothing happens.")
	if(istype(user.loc,/turf/open/space))
		return
	var/turf/T = get_turf(src)
	to_chat(user, "<span class='notice'>You start planting the kudzu...</span>")
	for(var/client/admeme in admins)
		if(admeme.prefs.toggles & SOUND_ADMINHELP)
			admeme << 'sound/effects/adminhelp.ogg'
	message_admins("[key_name_admin(user)] wants to place vines at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>(JMP)</a>. Click <A href='?src=\ref[src];approval=1'>HERE</a> to approve.")
	if(do_after(user, 100, target=src))
		if(admin_approved)
			plant(user, T)
			to_chat(user, "<span class='notice'>You plant the kudzu. You monster.</span>")
		else
			to_chat(user, "<span class='warning'>The seeds don't seem to be in the mood right now!</span>")

/obj/item/seeds/kudzu/Topic(href, list/href_list)
	if(..())
		return TRUE
	if(!check_rights())
		return
	if(href_list["approval"])
		admin_approved = TRUE
		message_admins("[key_name_admin(usr)] has allowed vines to be planted.")
		return TRUE

/obj/item/seeds/kudzu/get_analyzer_text()
	var/text = ..()
	var/text_string = ""
	for(var/datum/spacevine_mutation/SM in mutations)
		text_string += "[(text_string == "") ? "" : ", "][SM.name]"
	text += "\n- Plant Mutations: [(text_string == "") ? "None" : text_string]"
	return text

/obj/item/seeds/kudzu/on_chem_reaction(datum/reagents/S)
	var/list/temp_mut_list = list()

	if(S.has_reagent("sterilizine", 5))
		for(var/datum/spacevine_mutation/SM in mutations)
			if(SM.quality == NEGATIVE)
				temp_mut_list += SM
		if(prob(20))
			mutations.Remove(pick(temp_mut_list))
		temp_mut_list.Cut()
	if(S.has_reagent("welding_fuel", 5))
		for(var/datum/spacevine_mutation/SM in mutations)
			if(SM.quality == POSITIVE)
				temp_mut_list += SM
		if(prob(20))
			mutations.Remove(pick(temp_mut_list))
		temp_mut_list.Cut()
	if(S.has_reagent("phenol", 5))
		for(var/datum/spacevine_mutation/SM in mutations)
			if(SM.quality == MINOR_NEGATIVE)
				temp_mut_list += SM
		if(prob(20))
			mutations.Remove(pick(temp_mut_list))
	if(S.has_reagent("blood", 15))
		production += rand(15, -5)
	if(S.has_reagent("amatoxin", 5))
		production += rand(5, -15)
	if(S.has_reagent("plasma", 5))
		potency += rand(5, -15)
	if(S.has_reagent("holywater", 10))
		potency += rand(15, -5)


/obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod
	seed = /obj/item/seeds/kudzu
	name = "kudzu pod"
	desc = "<I>Pueraria Virallis</I>: An invasive species with vines that rapidly creep and wrap around whatever they contact."
	icon_state = "kudzupod"
	filling_color = "#6B8E23"
	bitesize_mod = 2
	foodtype = VEGETABLES | GROSS
