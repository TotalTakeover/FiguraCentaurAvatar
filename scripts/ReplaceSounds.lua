-- Required scripts
local centaurParts = require("lib.GroupIndex")(models.models.Centaur)
local ground       = require("lib.GroundCheck")
local pose         = require("scripts.Posing")
local effects      = require("scripts.SyncedVariables")

-- Variables
local wasGround = false
local lastHeight = 0
local sprintTimer = 0

-- Leg ground pivots
local legGrounds = {
	
	{ part = centaurParts.FrontLeftGround,  wasGround = true },
	{ part = centaurParts.FrontRightGround, wasGround = true },
	{ part = centaurParts.BackLeftGround,   wasGround = true },
	{ part = centaurParts.BackRightGround,  wasGround = true }
	
}

local function playFootstep(p, b)
	
	-- Check for wood material
	local isWood = false
	for _, tag in ipairs(b:getTags()) do
		if #player:getPassengers() ~= 0 or tag == "apoli:material/wood" then
			isWood = true
			break
		end
	end
	
	-- Play sound
	sounds:playSound(
		"entity.horse."..(isWood and "step_wood" or "step"),
		p,
		0.25
	)
	
end

-- Box check
local function inBox(pos, box_min, box_max)
	return pos.x >= box_min.x and pos.x <= box_max.x and
		   pos.y >= box_min.y and pos.y <= box_max.y and
		   pos.z >= box_min.z and pos.z <= box_max.z
end

function events.TICK()
	
	-- Variables
	local vel       = player:getVelocity()
	local onGround  = ground()
	local sprinting = player:isSprinting() and not pose.crouch
	local inWater   = player:isInWater()
	
	-- Play jump sound
	if wasGround and not onGround and vel.y > 0 and not inWater then
		
		sounds:playSound("entity.horse.jump", player:getPos(), 0.25)
		
	end
	
	-- Play land sound based on distance fallen
	if onGround and player:getPos().y - lastHeight < -1 and not inWater then
		
		sounds:playSound("entity.horse.land", player:getPos(), 0.25)
		lastHeight = player:getPos().y
		
	elseif onGround or (player:getPos().y - lastHeight > 0) then
		
		lastHeight = player:getPos().y
		
	end
	
	-- Play footsteps based on placement
	if onGround and not sprinting and not inWater and not player:getVehicle() and not effects.cF then
		
		for _, leg in ipairs(legGrounds) do
			
			-- Block variables
			local groundPos   = leg.part:partToWorldMatrix():apply()
			local blockPos    = groundPos:copy():floor()
			local groundBlock = world.getBlockState(groundPos)
			local groundBoxes = groundBlock:getCollisionShape()
			
			-- Check for ground
			local grounded = false
			if groundBoxes then
				for i = 1, #groundBoxes do
					local box = groundBoxes[i]
					if inBox(groundPos, blockPos + box[1], blockPos + box[2]) then
						
						grounded = true
						break
						
					end
				end
			end
			
			-- Play footstep
			if grounded and not leg.wasGround then
				
				playFootstep(groundPos, groundBlock)
				
			end
			
			-- Store last ground
			leg.wasGround = grounded
			
		end
		
	else
		
		-- If conditions arent met, legs are considered previously on ground
		for _, leg in ipairs(legGrounds) do
			
			leg.wasGround = true
			
		end
		
	end
	
	-- Sprint timer
	sprintTimer = math.clamp(sprintTimer - 1, 0, 8)
	
	-- Play gallop sound
	if onGround and vel:length() ~= 0 and sprinting and sprintTimer == 0 and not inWater and not effects.cF then
		
		sprintTimer = 10
		sounds:playSound("entity.horse.gallop", player:getPos(), 0.25)
		
	end
	
	-- Store last ground
	wasGround = onGround
	
end

function events.ON_PLAY_SOUND(id, pos, vol, pitch, loop, cat, path)
	
	-- Don't trigger if the sound was played by Figura (prevent potential infinite loop)
	if not path then return end
	
	-- Don't do anything if the user isn't loaded
	if not player:isLoaded() then return end
	
	-- Make sure the sound is (most likely) played by the user
	if (player:getPos() - pos):length() > 0.05 then return end
	
	-- If sound contains ".step", stop the sound
	if id:find(".step") then
		
		return true
		
	end
	
end