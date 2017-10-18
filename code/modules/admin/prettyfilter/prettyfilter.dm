/var/list/pretty_filter_items = list()

// Append pretty filter items from file to a list
/proc/setup_pretty_filter(var/path = "config/pretty_filter.txt")
	var/list/filter_lines = file2list(path)

	for(var/line in filter_lines)
		if(findtextEx(line,"#",1,2) || length(line) == 0)
			continue

		if(!add_pretty_filter_line(line))
			continue

// reset the pretty filters to whatever is in the config file
/client/proc/reset_pretty_filter()
	set category = "Special Verbs"
	set name = "Pretty Filters - Reset"
	clearlist(pretty_filter_items)
	setup_pretty_filter()
	to_chat(usr, "Pretty filters reset.")

// Add a filter pair
/proc/add_pretty_filter_line(var/line)
	if(!length(line))
		return 0

	if(findtextEx(line,"#",1,2))
		return 0

	//Split the line at every "="
	var/list/parts = splittext(line, "=")
	if(!parts.len)
		return 0

	//pattern is before the first "="
	var/pattern = parts[1]
	if(!pattern)
		return 0

	//replacement follows the first "="
	var/replacement = ""
	if(parts.len >= 2)
		var/index = 2
		for(index = 2; index <= parts.len; index++)
			replacement += parts[index]
			if(index < parts.len)
				replacement += "="

	if(!replacement)
		return 0

	pretty_filter_items.Add(line)
	return 1

// List all filters that have been loaded
/client/proc/list_pretty_filters()
	set category = "Special Verbs"
	set name = "Pretty Filters - List"

	to_chat(usr, "<font size='3'><b>Pretty filters list</b></font>")
	for(var/line in pretty_filter_items)
		var/list/parts = splittext(line, "=")
		var/pattern = parts[1]
		var/replacement = ""
		if(parts.len >= 2)
			var/index = 2
			for(index = 2; index <= parts.len; index++)
				replacement += parts[index]
				if(index < parts.len)
					replacement += "="

		to_chat(usr, "&nbsp;&nbsp;&nbsp;<font color='#994400'><b>[pattern]</b></font> -> <font color='#004499'><b>[replacement]</b></font>")
	to_chat(usr, "<font size='3'><b>End of list</b></font>")

// Enter a piece of text and have it tested against the filter list
/client/proc/test_pretty_filters(msg as text)
	set category = "Special Verbs"
	set name = "Pretty Filters - Test"

	to_chat(usr, "\"[msg]\" becomes: \"[pretty_filter(msg)]\".")

// Enter a piece of text and have it tested against the filter list
/client/proc/add_pretty_filter(line as text)
	set category = "Special Verbs"
	set name = "Pretty Filters - Add Pattern"

	if(add_pretty_filter_line(line))
		to_chat(usr, "\"[line]\" was added for this round - It has not been added to the permanent file.")
	else
		to_chat(usr, "\"[line]\" was not added.")

//Filter out and replace unwanted words, prettify sentences
/proc/pretty_filter(var/text)
	for(var/line in pretty_filter_items)
		var/list/parts = splittext(line, "=")
		var/pattern = parts[1]
		var/replacement = ""
		if(parts.len >= 2)
			var/index = 2
			for(index = 2; index <= parts.len; index++)
				replacement += parts[index]
				if(index < parts.len)
					replacement += "="

		var/regex/R = new(pattern, "ig")
		text = R.Replace(text, replacement)

	return text