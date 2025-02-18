/obj/item/grab/plague_doctor
	type_name = GRAB_PLAGUE_DOCTOR
	start_grab_name = GRAB_PLAGUE_DOCTOR_PASSIVE

/obj/item/grab/plague_doctor/init()
	. = ..()
	if(!.)
		return
	visible_message(SPAN_WARNING("[assailant] has grabbed [affecting] passively!"))

/datum/grab/plague_doctor
	type_name = GRAB_PLAGUE_DOCTOR
	icon = 'icons/mob/screen1.dmi'

	can_absorb = 1
	point_blank_mult = 1
	ladder_carry = 1
	force_danger = 1
	can_grab_self = 0
	stop_move = 1
	reverse_facing = 0
	same_tile = 0

	/// When TRUE - blocks DoEffects() proc from continuing
	var/stop_effects = FALSE

// This causes the user to temporarily stun and weaken the target, dealing pain and slight brute damage
/datum/grab/plague_doctor/proc/AttemptCure(obj/item/grab/normal/G)
	var/mob/living/carbon/human/scp049/user = G.assailant
	var/mob/living/carbon/human/target = G.affecting

	if(isspecies(target, SPECIES_SCP049_1))
		// Heal em up!
		if(target.stat == DEAD)
			to_chat(user, SPAN_NOTICE("You swiftly restore bodily functions of [target]."))
			user.visible_message(SPAN_DANGER("[user] swiftly slices with the scalpel, causing [target] to rise again."))
			playsound(target, 'sounds/weapons/bladeslice.ogg', 50, TRUE, 7)
			target.revive()
			return
		to_chat(user, SPAN_WARNING("They have been thoroughly cured already."))
		return

	if(!target.humanStageHandler.getStage("Pestilence"))
		to_chat(user, SPAN_WARNING("They are not infected with the Pestilence."))
		return

	stop_effects = FALSE
	DoEffects(G)
	for(var/stage = 1, stage<=4, stage++)
		target.Weaken(10)
		switch(stage)
			if(1)
				to_chat(user, SPAN_NOTICE("The disease has taken hold. We must work quickly..."))
				user.visible_message(SPAN_DANGER("[user] looms over [target]!"))
				target.adjustBruteLoss(25)
				playsound(target, 'sounds/weapons/thudswoosh.ogg', 50, TRUE, 7)
			if(2)
				to_chat(user, SPAN_NOTICE("You gather your tools."))
				user.visible_message(SPAN_WARNING("[user] draws a rolled set of surgical equipment from their bag!"))
				var/voiceline = list('sounds/scp/voice/SCP049_Cure1.ogg','sounds/scp/voice/SCP049_Cure2.ogg')
				playsound(user, pick(voiceline), 30)
			if(3)
				to_chat(user, SPAN_NOTICE("You create your first incision."))
				user.visible_message(SPAN_DANGER("[user] begins slicing open [target] with a scalpel!"))
				to_chat(target, SPAN_DANGER("You feel a sharp stabbing pain as your life begins to wane."))
				new /obj/effect/decal/cleanable/blood/splatter(get_turf(target), target.species.blood_color)
				playsound(target, 'sounds/weapons/bladeslice.ogg', 50, TRUE, 7)
			if(4)
				to_chat(user, SPAN_NOTICE("You spend a great deal of time expertly curing this victim's disease."))
				user.visible_message(SPAN_DANGER("[user] begins performing a horrifying procedure on [target]!"))
				playsound(target, 'sounds/weapons/bladeslice.ogg', 50, TRUE, 7)

		if(!do_after(user, 10 SECONDS, target))
			to_chat(user, SPAN_WARNING("The procedure has been interrupted!"))
			stop_effects = TRUE
			return

	user.PlagueDoctorCure(target)
	stop_effects = TRUE
	to_chat(src, SPAN_NOTICE("You have cured [target]!"))
	admin_attack_log(user, target, "'Cured' their victim.", "Was 'cured'.", "'cured'")
	qdel(G)

// Splashes neat effect all around the target
/datum/grab/plague_doctor/proc/DoEffects(obj/item/grab/normal/G)
	if(QDELETED(G) || stop_effects)
		return

	var/mob/living/carbon/human/H = G.affecting
	if(QDELETED(H) || !ishuman(H))
		return

	// Just a fail-safe
	if(isspecies(H, SPECIES_SCP049_1))
		return

	H.adjustBruteLoss(2)
	var/obj/effect/temp_visual/bloodsplatter/B = new (get_turf(H), pick(GLOB.alldirs), H.species.blood_color)
	B.transform *= pick(0.3, 0.5, 0.7, 1)
	if(prob(20))
		var/sound_path = pickweight(list(\
		'sounds/weapons/bladeslice.ogg' = 50,\
		'sounds/weapons/pierce.ogg' = 25,\
		'sounds/weapons/circsawhit.ogg' = 25,\
		'sounds/effects/rip1.ogg' = 10,\
		'sounds/effects/rip2.ogg' = 10,\
		'sounds/effects/rustle1.ogg' = 10,\
		'sounds/effects/rustle2.ogg' = 10,\
		'sounds/effects/rustle3.ogg' = 10,\
		))
		playsound(get_turf(H), sound_path, rand(15, 35), TRUE)
		show_sound_effect(get_turf(H), H)

	addtimer(CALLBACK(src, .proc/DoEffects, G), rand(3, 8))
