-- Kills script if squAPI cannot be found
local s, squapi = pcall(require, "lib.SquAPI")
if not s then return {} end

-- Required scripts
local parts   = require("lib.PartsAPI")
local sync    = require("lib.LetThatSyncFig")
local lerp    = require("lib.LerpAPI")
local ground  = require("lib.GroundCheck")
local pose    = require("scripts.Posing")
local effects = require("scripts.SyncedVariables")

-- Animation setup
local anims = animations.Centaur

-- Synced variables setup
local earFlick = sync.new("AnimsEarFlicks", true):config()

-- Calculate parent's rotations
local function calculateParentRot(m)
	
	local parent = m:getParent()
	if not parent then
		return m:getOffsetRot()
	end
	return calculateParentRot(parent) + m:getOffsetRot()
	
end

-- Lerp table
local legLerp = lerp.new(1, 0.5)

-- Squishy ears
local ears = squapi.ear:new(
	parts.group.LeftEar,
	parts.group.RightEar,
	0,             -- Range Multiplier (0)
	false,         -- Horizontal (false)
	1,             -- Bend Strength (1)
	earFlick.curr, -- Do Flick (earFlick)
	400,           -- Flick Chance (400)
	0.05,          -- Stiffness (0.05)
	0.9            -- Bounce (0.9)
)

-- Tails table
local tailParts = {
	
	parts.group.Tail
	
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
	-90,  -- Down Limit (-90)
	25    -- Up Limit (25)
)

-- Head table
local headParts = {
	
	parts.group.UpperBody
	
}

-- Squishy smooth torso
local head = squapi.smoothHead:new(
	headParts,
	0.3,  -- Strength (0.3)
	0.4,  -- Tilt (0.4)
	1,    -- Speed (1)
	false -- Keep Original Head Pos (false)
)

-- Squishy vanilla legs
local frontLeftLeg = squapi.leg:new(
	parts.group.FrontLeftLeg,
	0.5,   -- Strength (0.5)
	false, -- Right Leg (false)
	false  -- Keep Position (false)
)

local frontRightLeg = squapi.leg:new(
	parts.group.FrontRightLeg,
	0.5,  -- Strength (0.5)
	true, -- Right Leg (true)
	false -- Keep Position (false)
)

local backLeftLeg = squapi.leg:new(
	parts.group.BackLeftLeg,
	0.5,  -- Strength (0.5)
	true, -- Right Leg (true)
	false -- Keep Position (false)
)

local backRightLeg = squapi.leg:new(
	parts.group.BackRightLeg,
	0.5,   -- Strength (0.5)
	false, -- Right Leg (false)
	false  -- Keep Position (false)
)

-- Leg strength variables
local frontLeftLegStrength  = frontLeftLeg.strength
local frontRightLegStrength = frontRightLeg.strength
local backLeftLegStrength   = backLeftLeg.strength
local backRightLegStrength  = backRightLeg.strength

-- Squishy taur
local taur = squapi.taur:new(
	parts.group.LowerBody,
	parts.group.FrontLegs,
	parts.group.BackLegs
)

function events.TICK()
	
	-- Variables
	local onGround = ground()
	local inWater  = player:isInWater()
	
	-- Control targets based on variables
	legLerp.target = (onGround or inWater or pose.elytra or effects.cF) and 1 or 0
	taur.target    = (onGround or player:getVehicle() or effects.cF) and 0 or taur.target
	
	-- Control ear flick based on variables
	ears.doEarFlick = earFlick.curr
	
end

function events.RENDER(delta, context)
	
	-- Adjust leg strengths
	frontLeftLeg.strength  = frontLeftLegStrength  * legLerp.currPos
	frontRightLeg.strength = frontRightLegStrength * legLerp.currPos
	backLeftLeg.strength   = backLeftLegStrength   * legLerp.currPos
	backRightLeg.strength  = backRightLegStrength  * legLerp.currPos
	
	-- Set upperbody to offset rot and crouching pivot point
	parts.group.UpperBody:rot(-parts.group.LowerBody:getRot())
	
	-- Offset smooth torso in various parts
	-- Note: acts strangely with `parts.group.body`
	for _, group in ipairs(parts.group.UpperBody:getChildren()) do
		if group ~= parts.group.Body then
			group:rot(-calculateParentRot(group:getParent()))
		end
	end
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local s, pageNav, acts, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.Anims") -- Tries to find script, not required

-- Check for if page already exists
local pageExists = action_wheel:getPage("Anims")

-- Pages
local parentPage = action_wheel:getPage("Main")
local animsPage  = pageExists or action_wheel:newPage("Anims")

-- Actions
if not pageExists then
	acts.animsPage = parentPage:newAction()
		:item("jukebox")
		:onLeftClick(function() pageNav.descend(animsPage) end)
end

acts.animsEarToggle = animsPage:newAction()
	:item("bone")
	:toggleItem("feather")
	:onToggle(function(bool)
		earFlick:update(bool)
	end)
	:toggled(earFlick.curr)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if acts.animsPage then
			acts.animsPage
				:title(toJson(
					{text = "Animation Settings", bold = true, color = c.primary}
				))
				:hoverColor(c.hover)
		end
		
		acts.animsEarToggle
			:title(toJson(
				{
					"",
					{text = "Ear Flick Toggle\n\n", bold = true, color = c.primary},
					{text = "Toggles the ability for the ears to flick.", color = c.secondary}
				}
			))
			:hoverColor(c.hover)
			:toggleColor(c.active)
		
	end
	
end