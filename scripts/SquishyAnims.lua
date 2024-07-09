-- Required scripts
local centaurParts = require("lib.GroupIndex")(models.models.Centaur)
local squapi       = require("lib.SquAPI")
local ground       = require("lib.GroundCheck")
local pose         = require("scripts.Posing")

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
	400,   -- Flick Chance (800)
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
	0,     -- Intensity X (0)
	0,     -- Intensity Y (0)
	0,     -- Speed X (0)
	0,     -- Speed Y (0)
	2,     -- Bend (2)
	1,     -- Velocity Push (1)
	0,     -- Initial Offset (0)
	0,     -- Seg Offset (0)
	0.01, -- Stiffness (0.015)
	0.9,  -- Bounce (0.95)
	60,    -- Fly Offset (60)
	-90,   -- Down Limit (-15)
	25     -- Up Limit (25)
)

-- Squishy smooth torso
local head = squapi.smoothHead:new(
	centaurParts.UpperBody,
	0.3,  -- Strength (0.3)
	0.4,  -- Tilt (0.4)
	1,    -- Speed (1)
	false -- Keep Original Head Pos (false)
)


local taur = squapi.taur:new(
	centaurParts.LowerBody,
	centaurParts.FrontLegs,
	centaurParts.BackLegs
)

-- Squishy crouch
squapi.crouch(anims.crouch)

function events.TICK()
	
	taur.target = ground() and 0 or taur.target
	
end

function events.RENDER(delta, context)
	
	-- Set upper pivot to proper pos when crouching
	centaurParts.UpperBody:offsetPivot(anims.crouch:isPlaying() and -centaurParts.UpperBody:getAnimPos() or 0)
		:rot(-centaurParts.LowerBody:getRot())
	
	-- Offset smooth torso in various parts
	-- Note: acts strangely with `centaurParts.body` and when sleeping
	for _, group in ipairs(centaurParts.UpperBody:getChildren()) do
		if group ~= centaurParts.Body and not pose.sleep then
			group:offsetRot(-calculateParentRot(group:getParent()))
		end
	end
	
end