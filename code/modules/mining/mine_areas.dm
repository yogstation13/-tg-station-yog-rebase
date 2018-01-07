/**********************Mine areas**************************/

/area/mine
	icon_state = "mining"
	has_gravity = 1

/area/mine/explored
	name = "Mine"
	icon_state = "explored"
	music = null
	always_unpowered = 1
	requires_power = 1
	poweralm = 0
	power_environ = 0
	power_equip = 0
	power_light = 0
	outdoors = 1
	ambientsounds = list('sound/ambience/ambimine.ogg', 'sound/ambience/ambicave.ogg', 'sound/ambience/ambiruin.ogg',\
	 'sound/ambience/ambiruin2.ogg',  'sound/ambience/ambiruin3.ogg',  'sound/ambience/ambiruin4.ogg',\
	  'sound/ambience/ambiruin5.ogg',  'sound/ambience/ambiruin6.ogg',  'sound/ambience/ambiruin7.ogg',\
		'sound/ambience/ambidanger.ogg', 'sound/ambience/ambidanger2.ogg')

/area/mine/unexplored
	name = "Mine"
	icon_state = "unexplored"
	music = null
	always_unpowered = 1
	requires_power = 1
	poweralm = 0
	power_environ = 0
	power_equip = 0
	power_light = 0
	outdoors = 1
	ambientsounds = list('sound/ambience/ambimine.ogg', 'sound/ambience/ambicave.ogg', 'sound/ambience/ambiruin.ogg',\
	 'sound/ambience/ambiruin2.ogg',  'sound/ambience/ambiruin3.ogg',  'sound/ambience/ambiruin4.ogg',\
	  'sound/ambience/ambiruin5.ogg',  'sound/ambience/ambiruin6.ogg',  'sound/ambience/ambiruin7.ogg',\
		'sound/ambience/ambidanger.ogg', 'sound/ambience/ambidanger2.ogg')
	sound_env = CAVE // implies that lavaland has torn it into pieces.

/area/mine/lobby
	name = "Mining station"

/area/mine/storage
	name = "Mining station Storage"

/area/mine/production
	name = "Mining Station Starboard Wing"
	icon_state = "mining_production"

/area/mine/abandoned
	name = "Abandoned Mining Station"

/area/mine/living_quarters
	name = "Mining Station Port Wing"
	icon_state = "mining_living"

/area/mine/eva
	name = "Mining Station EVA"
	icon_state = "mining_eva"

/area/mine/maintenance
	name = "Mining Station Communications"

/area/mine/cafeteria
	name = "Mining station Cafeteria"

/area/mine/hydroponics
	name = "Mining station Hydroponics"

/area/mine/sleeper
	name = "Mining station Emergency Sleeper"

/area/mine/north_outpost
	name = "North Mining Outpost"

/area/mine/west_outpost
	name = "West Mining Outpost"

/area/mine/laborcamp
	name = "Labor Camp"

/area/mine/laborcamp/security
	name = "Labor Camp Security"
	icon_state = "security"


//LAVALAND STATION AREAS

/area/mine/lava/lobby
	name = "Lavaland mining station"

/area/mine/lava/storage
	name = "Lavaland Mining station Storage"

/area/mine/lava/production
	name = "Lavaland Mining Station Starboard Wing"
	icon_state = "mining_production"

/area/mine/lava/living_quarters
	name = "Lavaland Mining Station Port Wing"
	icon_state = "mining_living"

/area/mine/lava/eva
	name = "Lavaland Mining Station EVA"
	icon_state = "mining_eva"

/area/mine/lava/maintenance
	name = "Lavaland Mining Station Communications"

/area/mine/lava/cafeteria
	name = "Lavaland Mining station Cafeteria"

/area/mine/lava/hydroponics
	name = "Lavaland Mining station Hydroponics"

/area/mine/lava/sleeper
	name = "Lavaland Mining station Emergency Sleeper"

/area/mine/lava/laborcamp
	name = "Lavaland Labor Camp"

/area/mine/lava/laborcamp/security
	name = "Lavaland Labor Camp Security"
	icon_state = "security"
