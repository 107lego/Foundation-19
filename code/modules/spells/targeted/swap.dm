/datum/spell/targeted/swap
	name = "swap"
	desc = "This spell swaps the positions of the wizard and a target. Causes brain damage."
	feedback = "SW"
	school = "conjuration"

	charge_type = SPELL_HOLDVAR
	holder_var_type = "brainloss"
	holder_var_amount = 10

	invocation = "Joyo!"
	invocation_type = INVOKE_WHISPER

	level_max = list(UPGRADE_TOTAL = 2, UPGRADE_SPEED = 0, UPGRADE_POWER = 2)

	spell_flags = Z2NOCAST
	range = 6
	max_targets = 1
	compatible_mobs = list(/mob/living)

	hud_state = "wiz_swap"

	cast_sound = 'sounds/magic/mandswap.ogg'

/datum/spell/targeted/swap/cast(list/targets, mob/user)
	for(var/mob/T in targets)
		var/turf/aT = get_turf(T)
		var/turf/bT = get_turf(user)

		T.forceMove(bT)
		user.forceMove(aT)

		apply_spell_damage(T)

/datum/spell/targeted/swap/empower_spell()
	if(!..())
		return 0

	amt_eye_blind += 2

	return "This spell will now blind the target."
