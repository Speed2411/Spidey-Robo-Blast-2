local function createDebugHud(v, p, c)
	if not p then return end

	local txt_webSlingCD = "Web Sling CD: " .. p.webSlingCooldown
	local txt_webZipCD = "Web zip CD: " .. p.webZipCooldown

	v.drawString(240,10,txt_webSlingCD)
	v.drawString(240,20,txt_webZipCD)


end
hud.add(createDebugHud,"game")