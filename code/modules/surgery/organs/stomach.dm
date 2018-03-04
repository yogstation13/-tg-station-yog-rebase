/obj/item/organ/stomach
	name = "stomach"
	icon_state = "stomach"
	origin_tech = "biotech=4"
	w_class = 3
	zone = "chest"
	slot = "stomach"
	attack_verb = list("gored", "squished", "slapped", "digested")
	desc = "Onaka ga suite imasu."

/obj/item/organ/stomach/on_life()
	var/mob/living/carbon/human/H = owner

	if(istype(H))
		H.dna.species.handle_digestion(H)
		H.dna.species.handle_disgust(H)

/obj/item/organ/stomach/Remove(mob/living/carbon/M, special = 0)
	var/mob/living/carbon/human/H = owner
	if(istype(H))
		H.clear_alert("disgust")

/obj/item/organ/stomach/fly
	name = "insectoid stomach"
	icon_state = "stomach-x" //xenomorph liver? It's just a black liver so it fits.
	desc = "A mutant stomach designed to handle the unique diet of a flyperson."
