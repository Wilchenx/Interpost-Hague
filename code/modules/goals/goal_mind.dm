/datum/mind
	var/list/goals

/datum/mind/proc/show_roundend_summary(var/department_goals)
	if(department_goals && current.get_preference_value(/datum/client_preference/show_department_goals) == GLOB.PREF_SHOW)
		to_chat(current, SPAN_NOTICE(department_goals))
	if(LAZYLEN(goals))
		to_chat(current, SPAN_NOTICE("<br><br><b>You had the following personal goals this round:</b><br>[jointext(summarize_goals(TRUE), "<br>")]"))

/datum/mind/proc/summarize_goals(var/show_success = FALSE, var/allow_modification = FALSE, var/datum/admins/admin)
	. = list()
	if(LAZYLEN(goals))
		for(var/i = 1 to LAZYLEN(goals))
			var/datum/goal/goal = goals[i]
			. += "[i]. [goal.summarize(show_success, allow_modification, admin, position = i)]"

// Create and display personal goals for this round.
/datum/mind/proc/generate_goals(var/datum/job/job, var/adding_goals = FALSE, var/add_amount, var/is_spawning = FALSE)

	if(!adding_goals)
		goals = null

	var/pref_val = current.get_preference_value(/datum/client_preference/give_personal_goals)
	if(pref_val != GLOB.PREF_NEVER && (pref_val != GLOB.PREF_NON_ANTAG || !player_is_antag(src)))
		var/list/available_goals = SSgoals.global_personal_goals ? SSgoals.global_personal_goals.Copy() : list()
		var/list/new_goals = get_possible_personal_goals(job ? job.department_flag : null)
		if(LAZYLEN(new_goals))
			available_goals |= new_goals
		if(isnull(add_amount))
			var/min_goals = 1
			var/max_goals = 3
			if(job && LAZYLEN(job.possible_goals))
				available_goals |= job.possible_goals
				min_goals = job.min_goals
				max_goals = job.max_goals
			add_amount = rand(min_goals, max_goals)
		for(var/i = 1 to min(LAZYLEN(available_goals), add_amount))
			var/goal = pick_n_take(available_goals)
			new goal(src)
		return TRUE
	else
		if(!is_spawning)
			to_chat(src.current, "<span class='warning'>Your preferences do not allow you to add random goals.</span>")
		return FALSE

/datum/mind/proc/get_possible_personal_goals(var/department_flag)
	return