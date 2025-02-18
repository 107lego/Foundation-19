/datum/spell/targeted/harvest
	name = "Harvest"
	desc = "Back to where I come from, and you're coming with me."

	school = "transmutation"
	charge_max = 200
	spell_flags = Z2NOCAST | CONSTRUCT_CHECK | INCLUDEUSER
	invocation = ""
	invocation_type = INVOKE_NONE
	range = 0
	max_targets = 0

	overlay = 1
	overlay_icon = 'icons/effects/effects.dmi'
	overlay_icon_state = "rune_teleport"
	overlay_lifespan = 0

	hud_state = "const_harvest"

/datum/spell/targeted/harvest/cast(list/targets, mob/user)//because harvest is already a proc
	..()

	var/destination = null
	for(var/obj/singularity/scarletking/large/N in scarletking_list)
		destination = N.loc
		break
	if(destination)
		var/prey = 0
		for(var/mob/living/M in targets)
			if(!findNullRod(M))
				M.forceMove(destination)
				if(M != user)
					prey = 1
		to_chat(user, SPAN_CLASS("sinister","You warp back to the Scarlet King[prey ? " along with your prey":""]."))
	else
		to_chat(user, SPAN_DANGER("...something's wrong!"))//There shouldn't be an instance of Harvesters when the Scarlet King isn't in the world.

