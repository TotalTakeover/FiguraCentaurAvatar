-- Required scripts
local centaurParts = require("lib.GroupIndex")(models.models.Centaur)
local squapi       = require("lib.SquAPI")
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
squapi.ear(
	centaurParts.LeftEar,
	centaurParts.RightEar,
	true,  -- Do Flick (True)
	800,   -- Flick Chance (800)
	0.5,   -- Range Multiplier (0.5)
	false, -- Horizontal Ears (False)
	0.2,   -- Bend Strength (0.2)
	0.025, -- Stiffness (0.025)
	0.05   -- Bounce (0.05)
)

-- Squishy tail
squapi.tails(
	{centaurParts.Tail},
	2,      -- Intensity (2)
	0,      -- Intensity Y (0)
	0,      -- Intensity X (0)
	0,      -- Speed Y (0)
	0,      -- Speed X (0)
	1,      -- Tail Vel Bend (1)
	0,      -- Initial Tail Offset (0)
	1,      -- Seg Offset Multiplier (1)
	0.0025, -- Stiffness (0.0025)
	0.05,   -- Bounce (0.05)
	0,      -- Fly Offset (0)
	10,     -- Down Limit (10)
	40      -- Up Limit (40)
)

-- Squishy smooth torso
squapi.smoothTorso(centaurParts.UpperBody, 0.3)

-- Squishy crounch
squapi.crouch(anims.crouch)

function events.RENDER(delta, context)
	
	-- Set upper pivot to proper pos when crouching
	centaurParts.UpperBody:offsetPivot(anims.crouch:isPlaying() and -centaurParts.UpperBody:getAnimPos() or 0)
	
	-- Offset smooth torso in various parts
	-- Note: acts strangely with `centaurParts.body` and when sleeping
	for _, group in ipairs(centaurParts.UpperBody:getChildren()) do
		if group ~= centaurParts.Body and not pose.sleep then
			group:offsetRot(-calculateParentRot(group:getParent()))
		end
	end
	
end