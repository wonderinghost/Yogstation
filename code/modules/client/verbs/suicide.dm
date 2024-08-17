GLOBAL_LIST_INIT(human_suicide_messages, list( \
	"%%SUICIDER%% is attempting to push %%P_THEIR%% own head off %%P_THEIR%% shoulders! It looks like %%P_THEYRE%% trying to commit suicide.", \
	"%%SUICIDER%% is pushing %%P_THEIR%% thumbs into %%P_THEIR%% eye sockets! It looks like %%P_THEYRE%% trying to commit suicide.", \
	"%%SUICIDER%% is ripping %%P_THEIR%% own arms off! It looks like %%P_THEYRE%% trying to commit suicide.", \
	"%%SUICIDER%% is attempting to pull %%P_THEIR%% own head off! It looks like %%P_THEYRE%% trying to commit suicide.", \
	"%%SUICIDER%% is aggressively grabbing %%P_THEIR%% own neck! It looks like %%P_THEYRE%% trying to commit suicide.", \
	"%%SUICIDER%% is pulling %%P_THEIR%% eyes out of their sockets! It looks like %%P_THEYRE%% trying to commit suicide.", \
	"%%SUICIDER%% is hugging %%P_THEM%%self to death! It looks like %%P_THEYRE%% trying to commit suicide.", \
	"%%SUICIDER%% is high-fiving %%P_THEM%%self to death! It looks like %%P_THEYRE%% trying to commit suicide.", \
	"%%SUICIDER%% is getting too high on life! It looks like %%P_THEYRE%% trying to commit suicide.", \
	"%%SUICIDER%% is attempting to bite %%P_THEIR%% tongue off! It looks like %%P_THEYRE%% trying to commit suicide.", \
	"%%SUICIDER%% is jamming %%P_THEIR%% thumbs into %%P_THEIR%% eye sockets! It looks like %%P_THEYRE%% trying to commit suicide.", \
	"%%SUICIDER%% is twisting %%P_THEIR%% own neck! It looks like %%P_THEYRE%% trying to commit suicide.", \
	"%%SUICIDER%% is holding %%P_THEIR%% breath! It looks like %%P_THEYRE%% trying to commit suicide.", \
))

/mob/var/suiciding = 0

/mob/proc/set_suicide(suicide_state)
	suiciding = suicide_state
	if(suicide_state)
		GLOB.suicided_mob_list += src
	else
		GLOB.suicided_mob_list -= src

/mob/living/carbon/set_suicide(suicide_state) //you thought that box trick was pretty clever, didn't you? well now hardmode is on, boyo.
	. = ..()
	var/obj/item/organ/brain/B = getorganslot(ORGAN_SLOT_BRAIN)
	if(B)
		B.suicided = suicide_state

/mob/living/silicon/robot/set_suicide(suicide_state)
	. = ..()
	if(mmi)
		if(mmi.brain)
			mmi.brain.suicided = suicide_state
		if(mmi.brainmob)
			mmi.brainmob.suiciding = suicide_state

/mob/living/carbon/human/virtual_reality/set_suicide(suicide_state)
	return

/mob/living/carbon/human/virtual_reality/canSuicide()
	to_chat(src, span_warning("I'm sorry [first_name()], I'm afraid you can't do that."))
	return

/mob/living/carbon/human/verb/suicide()
	set hidden = 1
	if(!canSuicide())
		return
	var/oldkey = ckey
	var/confirm = tgui_alert(usr, "Are you sure you want to commit suicide? This will prevent you from being revived!", "Confirm Suicide", list("Yes", "No"))
	if(ckey != oldkey)
		return
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE) //need to be called before calling suicide_act as fuck knows what suicide_act will do with your suicider
		var/obj/item/held_item = get_active_held_item()
		if(held_item)
			var/damagetype = SEND_SIGNAL(src, COMSIG_HUMAN_SUICIDE_ACT) || held_item?.suicide_act(src)
			if(damagetype)
				if(damagetype & SHAME)
					adjustStaminaLoss(200)
					set_suicide(FALSE)
					SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "shameful_suicide", /datum/mood_event/shameful_suicide)
					return

				if(damagetype & MANUAL_SUICIDE_NONLETHAL) //Make sure to call the necessary procs if it does kill later
					set_suicide(FALSE)
					return

				suicide_log()

				var/damage_mod = 0
				for(var/T in list(BRUTELOSS, FIRELOSS, TOXLOSS, OXYLOSS))
					damage_mod += (T & damagetype) ? 1 : 0
				damage_mod = max(1, damage_mod)

				//Do 200 damage divided by the number of damage types applied.
				if(damagetype & BRUTELOSS)
					adjustBruteLoss(200/damage_mod)

				if(damagetype & FIRELOSS)
					adjustFireLoss(200/damage_mod)

				if(damagetype & TOXLOSS)
					adjustToxLoss(200/damage_mod, TRUE, TRUE)//toxinlovers

				if(damagetype & OXYLOSS)
					adjustOxyLoss(200/damage_mod)

				if(damagetype & MANUAL_SUICIDE)	//Assume the object will handle the death.
					return

				//If something went wrong, just do normal oxyloss
				if(!(damagetype & (BRUTELOSS | FIRELOSS | TOXLOSS | OXYLOSS) ))
					adjustOxyLoss(max(200 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))

				death(FALSE)

				return

		var/list/suicide_messages = GLOB.human_suicide_messages.Copy()
		suicide_messages |= dna.species.suicide_messages
		var/chosen_message = pick(suicide_messages)
		var/list/text_replacements = list("%%SUICIDER%%" = "[src]", "%%P_THEIR%%" = "[p_their()]", "%%P_THEM%%" = "[p_them()]", "%%P_THEYRE%%" = "[p_theyre()]")
		for(var/find_text in text_replacements)
			chosen_message = replacetext(chosen_message, find_text, text_replacements[find_text])
		visible_message(span_danger(chosen_message), span_userdanger(chosen_message))

		suicide_log()

		adjustOxyLoss(max(200 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(FALSE)

/mob/living/brain/verb/suicide()
	set hidden = TRUE
	if(!canSuicide())
		return
	var/confirm = tgui_alert(usr,"Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE)
		visible_message(span_danger("[src]'s brain is growing dull and lifeless. [p_they(TRUE)] look[p_s()] like [p_theyve()] lost the will to live."), \
						span_userdanger("[src]'s brain is growing dull and lifeless. [p_they(TRUE)] look[p_s()] like [p_theyve()] lost the will to live."))

		suicide_log()

		death(FALSE)

/mob/living/carbon/monkey/verb/suicide()
	set hidden = TRUE
	if(!canSuicide())
		return
	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE)
		visible_message(span_danger("[src] is attempting to bite [p_their()] tongue. It looks like [p_theyre()] trying to commit suicide."), \
				span_userdanger("[src] is attempting to bite [p_their()] tongue. It looks like [p_theyre()] trying to commit suicide."))

		suicide_log()

		adjustOxyLoss(max(200- getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(FALSE)

/mob/living/silicon/ai/verb/suicide()
	set hidden = TRUE
	if(!canSuicide())
		return
	var/confirm = tgui_alert(usr,"Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE)
		visible_message(span_danger("[src] is powering down. It looks like [p_theyre()] trying to commit suicide."), \
				span_userdanger("[src] is powering down. It looks like [p_theyre()] trying to commit suicide."))

		suicide_log()

		//put em at -175
		adjustOxyLoss(max(maxHealth * 2 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(FALSE)

/mob/living/silicon/robot/verb/suicide()
	set hidden = TRUE
	if(!canSuicide())
		return
	var/confirm = tgui_alert(usr,"Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE)
		visible_message(span_danger("[src] is powering down. It looks like [p_theyre()] trying to commit suicide."), \
				span_userdanger("[src] is powering down. It looks like [p_theyre()] trying to commit suicide."))

		suicide_log()

		//put em at -175
		adjustOxyLoss(max(maxHealth * 2 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(FALSE)

/mob/living/silicon/pai/verb/suicide()
	set hidden = TRUE
	var/confirm = tgui_alert(usr,"Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))
	if(confirm == "Yes")
		var/turf/T = get_turf(src.loc)
		T.visible_message(span_notice("[src] flashes a message across its screen, \"Wiping core files. Please acquire a new personality to continue using pAI device functions.\""), null, \
		 span_notice("[src] bleeps electronically."))

		suicide_log()

		death(FALSE)
	else
		to_chat(src, "Aborting suicide attempt.")

/mob/living/carbon/alien/humanoid/verb/suicide()
	set hidden = TRUE
	if(!canSuicide())
		return
	var/confirm = tgui_alert(usr,"Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE)
		visible_message(span_danger("[src] is thrashing wildly! It looks like [p_theyre()] trying to commit suicide."), \
				span_userdanger("[src] is thrashing wildly! It looks like [p_theyre()] trying to commit suicide."), \
				span_italics("You hear thrashing."))

		suicide_log()

		//put em at -175
		adjustOxyLoss(max(200 - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		death(FALSE)

/mob/living/simple_animal/verb/suicide()
	set hidden = TRUE
	if(!canSuicide())
		return
	var/confirm = tgui_alert(usr,"Are you sure you want to commit suicide?", "Confirm Suicide", list("Yes", "No"))
	if(!canSuicide())
		return
	if(confirm == "Yes")
		set_suicide(TRUE)
		visible_message(span_danger("[src] begins to fall down. It looks like [p_theyve()] lost the will to live."), \
						span_userdanger("[src] begins to fall down. It looks like [p_theyve()] lost the will to live."))

		suicide_log()

		death(FALSE)

/mob/living/proc/suicide_log()
	last_damage = "self-inflicted"
	log_game("[key_name(src)] committed suicide at [AREACOORD(src)] as [src.type].")

/mob/living/carbon/human/suicide_log()
	last_damage = "self-inflicted"
	log_game("[key_name(src)] (job: [src.job ? "[src.job]" : "None"]) committed suicide at [AREACOORD(src)].")

//IS_IMPORTANT()
// Returns whether this player can be programmatically deemed to be important to the game. As of 5 Apr 2020, only used for canSuicide().
// Split into several type-specific implementations because I wanted to pretend that this programming language was Julia for dozen lines or so.
/mob/living/proc/is_important() 
	return (mind && mind.special_role)

/mob/living/carbon/alien/is_important() 
	return TRUE // :clap: all :clap: aliens :clap: are :clap: valid (and ergo shouldn't be fucking suiciding you pieces of shit)

/mob/living/carbon/human/is_important()
	return (..() || (job in GLOB.command_positions) || mind?.has_antag_datum(/datum/antagonist/ert))
//end IS_IMPORTANT()

/mob/living/proc/canSuicide()
	switch(stat)
		if(SOFT_CRIT)
			to_chat(src, span_warning("You can't commit suicide while in a critical condition!"))
			return FALSE
		if(UNCONSCIOUS)
			to_chat(src, span_warning("You need to be conscious to commit suicide!"))
			return FALSE
		if(DEAD)
			to_chat(src, span_warning("You're already dead!"))
			return FALSE
	//We're assuming they're CONSCIOUS
	if(is_important()) // If they are someone critical to the round, for some reason
		var/result = (alert("WARNING: You seem to be serving a critical role. Suiciding now may be against the rules. Consider using the AFK verb instead. Continue regardless?","Suicide Warning","Yes","No") == "Yes")
		if(!result)
			return FALSE
		message_admins("[key_name(src)] may be committing suicide as an important role!")
	return TRUE

/mob/living/carbon/canSuicide()
	if(!..())
		return
	if(!(mobility_flags & MOBILITY_USE))	//just while I finish up the new 'fun' suiciding verb. This is to prevent metagaming via suicide
		to_chat(src, "You can't commit suicide whilst immobile! ((You can type Ghost instead however.))")
		return
	if(has_horror_inside())
		to_chat(src, "Something inside your head stops your action!")
		return
	return TRUE
