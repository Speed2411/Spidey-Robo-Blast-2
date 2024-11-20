freeslot("sfx_weba", "sfx_webb", "sfx_webzipa")

--[[		==================================================	
			=========      Global variables         ==========			
			==================================================	
]]--


local wallThreshold = 50*FRACUNIT -- Adjust threshold based on gameplay testing
local timeRequired = 1*TICRATE
local climbTimer = 0
local climbSpeed = 20

local webSlingCooldown = 0
local webZipCooldown = 0


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







local function aud_webSlingFX(mo)
	local sfx
	local nutweb = 0
	local mod = leveltime % 2
	
	if mod == 0 then sfx = sfx_weba
	else sfx = sfx_webb end
	
	S_StartSound(mo, sfx)
end

local function aud_webZipFX(mo)
	local sfx
	local nutweb = 0
	local mod = leveltime % 2
	
	if mod == 0 then sfx = sfx_webzipa
	else sfx = sfx_webzipa end
	
	S_StartSound(mo, sfx)
end




--[[		==================================================	
			=========          Web Sling            ==========			
			==================================================	
]]--

local function spawnWebTarget(player)
    local webDistance = 2000 * FRACUNIT -- Max distance for web
    local angle = player.mo.angle
    local offsetX = FixedMul(cos(angle), webDistance)
    local offsetY = FixedMul(sin(angle), webDistance)

    local targetZ = 500*FRACUNIT


	local validWebSpot = false
	while validWebSpot == false do
		if not P_CheckPosition(player.mo, offsetX, offsetY) then
			webDistance = $ - (10 * FRACUNIT)
			offsetX = FixedMul(cos(angle), webDistance)
			offsetY = FixedMul(sin(angle), webDistance)
			targetZ = $ + 100*FRACUNIT
			
		else
			validWebSpot = true
		end
	end

    -- Spawn the web target
    local webTarget = P_SpawnMobjFromMobj(player.mo, offsetX, offsetY, targetZ, MT_WEBTARGET)
	
	local debugObj = P_SpawnMobjFromMobj(player.mo, offsetX, offsetY, targetZ, MT_BSZBUSH_RED)
	debugObj.fuse = 3*TICRATE
	
    return webTarget
end

local function webSling(player)
    if webSlingCooldown > 0 then return end

    -- Spawn the web target
    local webTarget = spawnWebTarget(player)
    player.webTarget = webTarget

    -- Set initial swing momentum
    if P_IsObjectOnGround(player.mo) then
        player.mo.momx = FixedMul(cos(player.mo.angle), 20 * FRACUNIT)
        player.mo.momy = FixedMul(sin(player.mo.angle), 20 * FRACUNIT)
        player.mo.momz = 10 * FRACUNIT
		player.swingTime = 50
    else
        player.mo.momz = player.mo.momz + 5 * FRACUNIT -- Slight boost for air swings
		player.swingTime = 0
    end

    player.isSwinging = true
    webSlingCooldown = 2 * TICRATE
	aud_webSlingFX(player.mo)
	player.mo.state = S_PLAY_RIDE
end

local function handleWebSlingArc(player)
    if not player.isSwinging or not player.webTarget then return end

    local webTarget = player.webTarget
    local dx = webTarget.x - player.mo.x
    local dy = webTarget.y - player.mo.y
    local dz = webTarget.z - player.mo.z

    -- Calculate distance to web target
    local distance = FixedHypot(dx, dy)
    local totalDistance = FixedHypot(distance, dz)

    -- Apply gravity-like pull toward the web target
    if totalDistance > 500 * FRACUNIT then
        local pullForce = FixedDiv(2 * FRACUNIT, totalDistance)

        player.mo.momx = player.mo.momx + FixedMul(dx, pullForce)
        player.mo.momy = player.mo.momy + FixedMul(dy, pullForce)
        player.mo.momz = player.mo.momz + FixedMul(dz, pullForce)
    end

    -- Apply inertia damping for realistic swing motion
    player.mo.momx = FixedMul(player.mo.momx, FRACUNIT - (FRACUNIT / 20)) -- Damping factor
    player.mo.momy = FixedMul(player.mo.momy, FRACUNIT - (FRACUNIT / 20))

    -- Allow player to adjust direction during swing
    if player.cmd.sidemove ~= 0 then
        player.mo.momx = player.mo.momx + FixedMul(cos(player.mo.angle), FixedDiv(player.cmd.sidemove * FRACUNIT, 256 * FRACUNIT))
        player.mo.momy = player.mo.momy + FixedMul(sin(player.mo.angle), FixedDiv(player.cmd.sidemove * FRACUNIT, 256 * FRACUNIT))
    end

    -- Adjust spriteroll based on angle towards the web target and vertical position
    local angleToTarget = R_PointToAngle2(player.mo.x, player.mo.y, webTarget.x, webTarget.y)
    local relativeAngle = angleToTarget - player.mo.angle

    -- Normalize relativeAngle to the range -180° to 180°
    if relativeAngle > ANGLE_180 then
        relativeAngle = relativeAngle - ANGLE_MAX
    elseif relativeAngle < -ANGLE_180 then
        relativeAngle = relativeAngle + ANGLE_MAX
    end

    -- Calculate vertical difference (z-axis)
    local verticalDifference = player.mo.z - webTarget.z

    -- Adjust spriteroll
    local baseRoll = FixedMul(relativeAngle, FRACUNIT / 12) -- Roll based on horizontal angle
    local verticalFactor = FixedMul(verticalDifference, FRACUNIT / 128) -- Roll more when above the target

    -- Combine horizontal and vertical roll adjustments
    player.mo.spriteroll = baseRoll + verticalFactor

	player.viewrollangle = baseRoll + verticalFactor

    -- End swing if distance is too small or player is grounded
    if player.cmd.buttons & BT_JUMP or P_IsObjectOnGround(player.mo) then
		player.mo.state = S_PLAY_SPRING
        player.isSwinging = false
        player.webTarget = nil
		player.mo.spriteroll = 0
    end
end



--[[		==================================================	
			=========            WebZIP             ==========			
			==================================================	
]]--

local function webZip(player)
	if webZipCooldown > 0 then return end
	
	player.mo.momx = FixedMul(cos(player.mo.angle), 75*FRACUNIT)
    player.mo.momy = FixedMul(sin(player.mo.angle), 75*FRACUNIT)
	player.mo.momz = FRACUNIT / 2
	webZipCooldown = 2*TICRATE
	print("WebZip")
	aud_webZipFX(player)
end


--[[		==================================================	
			=========             Main              ==========			
			==================================================	
]]--

local function cooldownManager()
	if webSlingCooldown > 0 then
		webSlingCooldown = $ - 1
	end
	if webZipCooldown > 0 then
		webZipCooldown = $ - 1
	end
end

local function buttonManager(player)
	if player.cmd.buttons & BT_SPIN and (player.cmd.buttons & BT_JUMP) == 0 then
		webSling(player)
    elseif player.cmd.buttons & BT_JUMP and player.cmd.buttons & BT_SPIN then
		webZip(player)
    end	
end

local function main(player)
	if not player.mo.skin == "spider_man" then return end

	handleWebSlingArc(player)
	cooldownManager()
	buttonManager(player)
	
	if not player.isSwinging then player.viewrollangle = 0 end
end
addHook("PlayerThink", main) 