freeslot("sfx_weba", "sfx_webb", "sfx_webzip")

local sfx = {}

function sfx.webSlingFX(mo)
	local sx
	local mod = leveltime % 2
	
	if mod == 0 then sx = sfx_weba
	else sx = sfx_webb end
	
	S_StartSound(mo, sx)
end

function sfx.webZipFX(mo)
	S_StartSound(mo, sfx_webzip)
end

return sfx