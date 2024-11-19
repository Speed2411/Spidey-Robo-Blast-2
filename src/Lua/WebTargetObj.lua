freeslot("MT_WEBTARGET", "SPR_SWEB", "S_INIT_WEBLINE", "S_WEBLINE1")


mobjinfo[MT_WEBTARGET] = {
	--$Name Web Target
	--$Category SPIDERMAN Utility
	doomednum = 12345,
	spawnstate = S_INVISIBLE,
	spawnhealth = 1,
	flags = MF_NOCLIP|MF_NOGRAVITY
}

mobjinfo[MT_WEBLINE] = {
	--$Name Web Target
	--$Category SPIDERMAN Utility
	doomednum = 12346,
	spawnstate = S_INIT_WEBLINE,
	spawnhealth = 1,
	flags = MF_NOCLIP|MF_NOGRAVITY
}

states[S_INIT_WEBLINE] = {
	sprite = SPR_SWEB,
	frame = A,
	tics = 1,
	nextstate = S_WEBLINE1
}


states[S_WEBLINE1] = {
	sprite = SPR_SWEB,
	frame = A,
	tics = 60,
	nextstate = S_WEBLINE1
}