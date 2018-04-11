/*
Asset cache quick users guide:

Make a datum at the bottom of this file with your assets for your thing.
The simple subsystem will most like be of use for most cases.
Then call get_asset_datum() with the type of the datum you created and store the return
Then call .send(client) on that stored return value.

You can set verify to TRUE if you want send() to sleep until the client has the assets.
*/


// Amount of time(ds) MAX to send per asset, if this get exceeded we cancel the sleeping.
// This is doubled for the first asset, then added per asset after
#define ASSET_CACHE_SEND_TIMEOUT 7

//When sending mutiple assets, how many before we give the client a quaint little sending resources message
#define ASSET_CACHE_TELL_CLIENT_AMOUNT 8

//When passively preloading assets, how many to send at once? Too high creates noticable lag where as too low can flood the client's cache with "verify" files
#define ASSET_CACHE_PRELOAD_CONCURRENT 3

/client
	var/list/cache = list() // List of all assets sent to this client by the asset cache.
	var/list/completed_asset_jobs = list() // List of all completed jobs, awaiting acknowledgement.
	var/list/sending = list()
	var/last_asset_job = 0 // Last job done.

//This proc sends the asset to the client, but only if it needs it.
//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset(var/client/client, var/asset_name, var/verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return 0

		else
			return 0

	if(client.cache.Find(asset_name) || client.sending.Find(asset_name))
		return 0

	client << browse_rsc(SSasset.cache[asset_name], asset_name)
	if(!verify)
		client.cache += asset_name
		return 1

	client.sending |= asset_name
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = (ASSET_CACHE_SEND_TIMEOUT * client.sending.len) + ASSET_CACHE_SEND_TIMEOUT
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		stoplag(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= asset_name
		client.cache |= asset_name
		client.completed_asset_jobs -= job

	return 1

//This proc blocks(sleeps) unless verify is set to false
/proc/send_asset_list(var/client/client, var/list/asset_list, var/verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return 0

		else
			return 0

	var/list/unreceived = asset_list - (client.cache + client.sending)
	if(!unreceived || !unreceived.len)
		return 0
	if (unreceived.len >= ASSET_CACHE_TELL_CLIENT_AMOUNT)
		to_chat(client, "Sending Resources...")
	for(var/asset in unreceived)
		if (asset in SSasset.cache)
			client << browse_rsc(SSasset.cache[asset], asset)

	if(!verify) // Can't access the asset cache browser, rip.
		client.cache += unreceived
		return 1

	client.sending |= unreceived
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = ASSET_CACHE_SEND_TIMEOUT * client.sending.len
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		stoplag(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= unreceived
		client.cache |= unreceived
		client.completed_asset_jobs -= job

	return 1

//This proc will download the files without clogging up the browse() queue, used for passively sending files on connection start.
//The proc calls procs that sleep for long times.
/proc/getFilesSlow(var/client/client, var/list/files, var/register_asset = TRUE)
	var/concurrent_tracker = 1
	for(var/file in files)
		if (!client)
			break
		if (register_asset)
			register_asset(file, files[file])
		if (concurrent_tracker >= ASSET_CACHE_PRELOAD_CONCURRENT)
			concurrent_tracker = 1
			send_asset(client, file)
		else
			concurrent_tracker++
			send_asset(client, file, verify=FALSE)
		stoplag(0) //queuing calls like this too quickly can cause issues in some client versions

//This proc "registers" an asset, it adds it to the cache for further use, you cannot touch it from this point on or you'll fuck things up.
//if it's an icon or something be careful, you'll have to copy it before further use.
/proc/register_asset(var/asset_name, var/asset)
	SSasset.cache[asset_name] = asset

//Generated names do not include file extention.
//Used mainly for code that deals with assets in a generic way
//The same asset will always lead to the same asset name
/proc/generate_asset_name(var/file)
	return "asset.[md5(fcopy_rsc(file))]"

//These datums are used to populate the asset cache, the proc "register()" does this.

//all of our asset datums, used for referring to these later
/var/global/list/asset_datums = list()

//get a assetdatum or make a new one
/proc/get_asset_datum(var/type)
	if (!(type in asset_datums))
		return new type()
	return asset_datums[type]

/datum/asset/New()
	asset_datums[type] = src

/datum/asset/proc/register()
	return

/datum/asset/proc/send(client)
	return

//If you don't need anything complicated.
/datum/asset/simple
	var/assets = list()
	var/verify = FALSE

/datum/asset/simple/register()
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])
/datum/asset/simple/send(client)
	send_asset_list(client,assets,verify)


//DEFINITIONS FOR ASSET DATUMS START HERE.

//Generates assets based on iconstates of a single icon
/datum/asset/simple/icon_states
	var/icon
	var/direction = SOUTH
	var/frame = 1
	var/movement_states = FALSE

	var/prefix = "default" //asset_name = "[prefix].[icon_state_name].png"
	var/generic_icon_names = FALSE //generate icon filenames using generate_asset_name() instead the above format

	verify = FALSE

/datum/asset/simple/icon_states/register()
	for(var/icon_state_name in icon_states(icon))
		var/asset = icon(icon, icon_state_name, direction, frame, movement_states)
		if (!asset)
			continue
		asset = fcopy_rsc(asset) //dedupe
		var/asset_name = sanitize_filename("[prefix].[icon_state_name].png")
		if (generic_icon_names)
			asset_name = "[generate_asset_name(asset)].png"

		assets[asset_name] = asset

	..()

/datum/asset/simple/tgui
	assets = list(
		"tgui.css"	= 'tgui/assets/tgui.css',
		"tgui.js"	= 'tgui/assets/tgui.js'
	)

/datum/asset/simple/pda
	assets = list(
		"pda_atmos.png"			= 'icons/pda_icons/pda_atmos.png',
		"pda_back.png"			= 'icons/pda_icons/pda_back.png',
		"pda_bell.png"			= 'icons/pda_icons/pda_bell.png',
		"pda_blank.png"			= 'icons/pda_icons/pda_blank.png',
		"pda_boom.png"			= 'icons/pda_icons/pda_boom.png',
		"pda_bucket.png"		= 'icons/pda_icons/pda_bucket.png',
		"pda_medbot.png"		= 'icons/pda_icons/pda_medbot.png',
		"pda_floorbot.png"		= 'icons/pda_icons/pda_floorbot.png',
		"pda_cleanbot.png"		= 'icons/pda_icons/pda_cleanbot.png',
		"pda_crate.png"			= 'icons/pda_icons/pda_crate.png',
		"pda_cuffs.png"			= 'icons/pda_icons/pda_cuffs.png',
		"pda_eject.png"			= 'icons/pda_icons/pda_eject.png',
		"pda_flashlight.png"	= 'icons/pda_icons/pda_flashlight.png',
		"pda_honk.png"			= 'icons/pda_icons/pda_honk.png',
		"pda_mail.png"			= 'icons/pda_icons/pda_mail.png',
		"pda_medical.png"		= 'icons/pda_icons/pda_medical.png',
		"pda_menu.png"			= 'icons/pda_icons/pda_menu.png',
		"pda_mule.png"			= 'icons/pda_icons/pda_mule.png',
		"pda_notes.png"			= 'icons/pda_icons/pda_notes.png',
		"pda_power.png"			= 'icons/pda_icons/pda_power.png',
		"pda_rdoor.png"			= 'icons/pda_icons/pda_rdoor.png',
		"pda_reagent.png"		= 'icons/pda_icons/pda_reagent.png',
		"pda_refresh.png"		= 'icons/pda_icons/pda_refresh.png',
		"pda_scanner.png"		= 'icons/pda_icons/pda_scanner.png',
		"pda_signaler.png"		= 'icons/pda_icons/pda_signaler.png',
		"pda_status.png"		= 'icons/pda_icons/pda_status.png',
		"pda_botany.png"		= 'icons/pda_icons/pda_botany.png'
	)

/datum/asset/simple/paper
	assets = list(
		"large_stamp-clown.png" = 'icons/stamp_icons/large_stamp-clown.png',
		"large_stamp-deny.png" = 'icons/stamp_icons/large_stamp-deny.png',
		"large_stamp-ok.png" = 'icons/stamp_icons/large_stamp-ok.png',
		"large_stamp-hop.png" = 'icons/stamp_icons/large_stamp-hop.png',
		"large_stamp-cmo.png" = 'icons/stamp_icons/large_stamp-cmo.png',
		"large_stamp-ce.png" = 'icons/stamp_icons/large_stamp-ce.png',
		"large_stamp-hos.png" = 'icons/stamp_icons/large_stamp-hos.png',
		"large_stamp-rd.png" = 'icons/stamp_icons/large_stamp-rd.png',
		"large_stamp-cap.png" = 'icons/stamp_icons/large_stamp-cap.png',
		"large_stamp-qm.png" = 'icons/stamp_icons/large_stamp-qm.png',
		"large_stamp-law.png" = 'icons/stamp_icons/large_stamp-law.png'
	)

/datum/asset/simple/adware
	assets = list(
		"ad1.png" = 'icons/ads/ad1.png',
		"ad2.png" = 'icons/ads/ad2.png',
		"ad3.png" = 'icons/ads/ad3.png',
		"ad4.png" = 'icons/ads/ad4.png',
		"ad5.png" = 'icons/ads/ad5.png',
		"ad6.png" = 'icons/ads/ad6.png',
		"ad7.png" = 'icons/ads/ad7.png',
	)


/datum/asset/simple/goonchat
	verify = FALSE
	assets = list(
		"jquery.min.js"            = 'code/modules/html_interface/js/jquery.min.js',
		"json2.min.js"             = 'code/modules/goonchat/browserassets/js/json2.min.js',
		"errorHandler.js"          = 'code/modules/goonchat/browserassets/js/errorHandler.js',
		"browserOutput.js"         = 'code/modules/goonchat/browserassets/js/browserOutput.js',
		"fontawesome-webfont.eot"  = 'tgui/assets/fonts/fontawesome-webfont.eot',
		"fontawesome-webfont.svg"  = 'tgui/assets/fonts/fontawesome-webfont.svg',
		"fontawesome-webfont.ttf"  = 'tgui/assets/fonts/fontawesome-webfont.ttf',
		"fontawesome-webfont.woff" = 'tgui/assets/fonts/fontawesome-webfont.woff',
		"font-awesome.css"	       = 'code/modules/goonchat/browserassets/css/font-awesome.css',
		"browserOutput.css"	       = 'code/modules/goonchat/browserassets/css/browserOutput.css',
	)

/datum/asset/simple/icon_states/emojis
	icon = 'icons/emoji.dmi'
	generic_icon_names = TRUE

//Registers HTML Interface assets.
/datum/asset/HTML_interface/register()
	for(var/path in typesof(/datum/html_interface))
		var/datum/html_interface/hi = new path()
		hi.registerResources()
