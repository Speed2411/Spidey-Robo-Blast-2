--[[		==================================================	
			=========          Globals 			        ==========			
			==================================================	
]]--

local webs = tbsrequire 'webs'
local sfx = tbsrequire 'sfx'

local wallThreshold = 50*FRACUNIT -- Adjust threshold based on gameplay testing
local timeRequired = 1*TICRATE
local climbTimer = 0
local climbSpeed = 20

--[[		==================================================	
			=========        Wall Crawling          ==========			
			==================================================	
]]--



local function wallClimb(mo, thing, line)
	if not mo.skin == "spider_man" then return end
  
    if line then
        climbTimer = climbTimer + 1
        if climbTimer >= timeRequired then
            --wallClimb(player) -- Start climbing if moving toward wall for 2 seconds
			--climbSpeed = $ * FRACUNIT
			
			local moveDirX = mo.x + 0
			local moveDirY = mo.y + 0
			local moveDirZ = (mo.z + (climbSpeed*FRACUNIT))			
			P_MoveOrigin(mo, moveDirX, moveDirY, moveDirZ)
			--print("Wall climbing")

        end
    else
        climbTimer = 0 -- Reset timer if not moving towards wall
    end
end

addHook("MobjMoveBlocked", wallClimb)




--[[		==================================================	
			=========             Main              ==========			
			==================================================	
]]--

local function cooldownManager(player)	
	if player.webSlingCooldown > 0 then
		player.webSlingCooldown = $ - 1
	end
	if player.webZipCooldown > 0 then
		player.webZipCooldown = $ - 1
	end
end





local function buttonManager(player)
	if player.cmd.buttons & BT_SPIN and (player.cmd.buttons & BT_JUMP) == 0 then
		webs.webSling(player)
    elseif player.cmd.buttons & BT_JUMP and player.cmd.buttons & BT_SPIN then
		webs.webZip(player)
    end	
end

local function checkDependencies()
	if not webs then 
		print("Missing webs")
		return false 
	end
	if not sfx then 
		print("Missing sfx")
		return false 
	end
	return true
end

local function playerInit(player)
	player.webSlingCooldown = 0
	player.webZipCooldown = 0
end
addHook("PlayerSpawn", playerInit)




local function main(player)
	if not player.mo.skin == "spider_man" then return end
	if not checkDependencies() then return end

	webs.handleWebSlingArc(player)
	buttonManager(player)
	cooldownManager(player)
	if not player.isSwinging then player.viewrollangle = 0 end
end
addHook("PlayerThink", main) 