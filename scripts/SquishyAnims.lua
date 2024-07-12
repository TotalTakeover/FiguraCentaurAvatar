-- Required scripts
local centaurParts = require("lib.GroupIndex")(models.models.Centaur)
local squapi       = require("lib.SquAPI")
local ground       = require("lib.GroundCheck")
local pose         = require("scripts.Posing")
local effects      = require("scripts.SyncedVariables")

-- Animation setup
local anims = animations["models.Centaur"]

-- Calculate parent's rotations
local function calculateParentRot(m)
	
	local parent = m:getParent()
	if not parent then
		return m:getOffsetRot()
	end
	return calculateParentRot(parent) + m:getOffsetRot()
	
end

-- Squishy ears
local ears = squapi.ear:new(
	centaurParts.LeftEar,
	centaurParts.RightEar,
	0.5,   -- Range Multiplier (0.5)
	false, -- Horizontal (false)
	0.2,   -- Bend Strength (0.2)
	true,  -- Do Flick (true)
	400,   -- Flick Chance (400)
	0.05,  -- Stiffness (0.05)
	0.9    -- Bounce (0.9)
)

-- Tails table
local tailParts = {
	
	centaurParts.Tail
	
}

-- Squishy tail
local tail = squapi.tail:new(
	tailParts,
	0,    -- Intensity X (0)
	0,    -- Intensity Y (0)
	0,    -- Speed X (0)
	0,    -- Speed Y (0)
	2,    -- Bend (2)
	1,    -- Velocity Push (1)
	0,    -- Initial Offset (0)
	0,    -- Seg Offset (0)
	0.01, -- Stiffness (0.01)
	0.9,  -- Bounce (0.9)
	60,   -- Fly Offset (60)
	-90,  -- Down Limit (-15)
	25    -- Up Limit (25)
)

-- Squishy smooth torso
local head = squapi.smoothHead:new(
	centaurParts.UpperBody,
	0.3,  -- Strength (0.3)
	0.4,  -- Tilt (0.4)
	1,    -- Speed (1)
	false -- Keep Original Head Pos (false)
)

local frontLeftLeg = squapi.leg:new(
	centaurParts.FrontLeftLeg,
	0.5,   -- Strength (0.5)
	false, -- Right Leg (false)
	false  -- Keep Position (false)
)

local frontRightLeg = squapi.leg:new(
	centaurParts.FrontRightLeg,
	0.5,   -- Strength (0.5)
	true, -- Right Leg (true)
	false  -- Keep Position (false)
)

local backLeftLeg = squapi.leg:new(
	centaurParts.BackLeftLeg,
	0.5,   -- Strength (0.5)
	true, -- Right Leg (true)
	false  -- Keep Position (false)
)

local backRightLeg = squapi.leg:new(
	centaurParts.BackRightLeg,
	0.5,   -- Strength (0.5)
	false, -- Right Leg (false)
	false  -- Keep Position (false)
)

local taur = squapi.taur:new(
	centaurParts.LowerBody,
	centaurParts.FrontLegs,
	centaurParts.BackLegs
)

-- Squishy crouch
squapi.crouch(anims.crouch)

-- Leg strength variables
local legStrength = {
	{ object = frontLeftLeg,  strength = frontLeftLeg.strength  },
	{ object = frontRightLeg, strength = frontRightLeg.strength },
	{ object = backLeftLeg,   strength = backLeftLeg.strength   },
	{ object = backRightLeg,  strength = backRightLeg.strength  }
}

-- Lerp leg table
local legLerp = {
	current    = 0,
	nextTick   = 0,
	target     = 0,
	currentPos = 0
}

-- Set lerp start on init
function events.ENTITY_INIT()
	
	local apply = ground() and 1 or 0
	for k, v in pairs(legLerp) do
		legLerp[k] = apply
	end
	
end

function events.TICK()
	
	-- Control targets based on ground
	legLerp.target = (ground() or player:isInWater() or pose.elytra or effects.cF) and 1 or 0
	taur.target = (ground() or effects.cF) and 0 or taur.target
	
	-- Tick lerp
	legLerp.current = legLerp.nextTick
	legLerp.nextTick = math.lerp(legLerp.nextTick, legLerp.target, 0.5)
	
end

function events.RENDER(delta, context)
	
	-- Render lerp
	legLerp.currentPos = math.lerp(legLerp.current, legLerp.nextTick, delta)
	
	-- Adjust leg strength
	for _, index in ipairs(legStrength) do
		index.object.strength = index.strength * legLerp.currentPos
	end
	
	-- Set upper pivot to proper pos when crouching
	centaurParts.UpperBody:offsetPivot(anims.crouch:isPlaying() and -centaurParts.UpperBody:getAnimPos() or 0)
		:rot(-centaurParts.LowerBody:getRot())
	
	-- Offset smooth torso in various parts
	-- Note: acts strangely with `centaurParts.body`
	for _, group in ipairs(centaurParts.UpperBody:getChildren()) do
		if group ~= centaurParts.Body then
			group:offsetRot(-calculateParentRot(group:getParent()))
		end
	end
	
end