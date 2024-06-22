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