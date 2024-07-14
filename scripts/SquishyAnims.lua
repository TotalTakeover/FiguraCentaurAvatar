-- Required scripts
local centaurParts = require("lib.GroupIndex")(models.models.Centaur)
local squapi       = require("lib.SquAPI")
local ground       = require("lib.GroundCheck")
local pose         = require("scripts.Posing")
local effects      = require("scripts.SyncedVariables")

-- Animation setup
local anims = animations["models.Centaur"]

-- Config setup
config:name("Centaur")
local armsMove = config:load("SquapiArmsMove") or false

-- Calculate parent's rotations
local function calculateParentRot(m)
	
	local parent = m:getParent()
	if not parent then
		return m:getOffsetRot()
	end
	return calculateParentRot(parent) + m:getOffsetRot()
	
end

-- Lerp left arm table
local leftArmLerp = {
	current    = 0,
	nextTick   = 0,
	target     = 0,
	currentPos = 0
}

-- Lerp right arm table
local rightArmLerp = {
	current    = 0,
	nextTick   = 0,
	target     = 0,
	currentPos = 0
}

-- Lerp leg table
local legLerp = {
	current    = 0,
	nextTick   = 0,
	target     = 0,
	currentPos = 0
}

-- Set lerp starts on init
function events.ENTITY_INIT()
	
	local apply = armsMove and 1 or 0
	for k, v in pairs(leftArmLerp) do
		leftArmLerp[k] = apply
	end
	for k, v in pairs(rightArmLerp) do
		rightArmLerp[k] = apply
	end
	
	local apply = ground() and 1 or 0
	for k, v in pairs(legLerp) do
		legLerp[k] = apply
	end
	
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

local headParts = {
	
	centaurParts.UpperBody
	
}

-- Squishy smooth torso
local head = squapi.smoothHead:new(
	headParts,
	0.3,  -- Strength (0.3)
	0.4,  -- Tilt (0.4)
	1,    -- Speed (1)
	false -- Keep Original Head Pos (false)
)

-- Squishy vanilla arms
local leftArm = squapi.arm:new(
	centaurParts.LeftArm,
	1,     -- Strength (1)
	false, -- Right Arm (false)
	true   -- Keep Position (false)
)

local rightArm = squapi.arm:new(
	centaurParts.RightArm,
	1,    -- Strength (1)
	true, -- Right Arm (true)
	true  -- Keep Position (false)
)

-- Arm strength variables
local leftArmStrength = {
	object   = leftArm,
	strength = leftArm.strength
}

local rightArmStrength = {
	object   = rightArm,
	strength = rightArm.strength
}

-- Squishy vanilla legs
local frontLeftLeg = squapi.leg:new(
	centaurParts.FrontLeftLeg,
	0.5,   -- Strength (0.5)
	false, -- Right Leg (false)
	false  -- Keep Position (false)
)

local frontRightLeg = squapi.leg:new(
	centaurParts.FrontRightLeg,
	0.5,  -- Strength (0.5)
	true, -- Right Leg (true)
	false -- Keep Position (false)
)

local backLeftLeg = squapi.leg:new(
	centaurParts.BackLeftLeg,
	0.5,  -- Strength (0.5)
	true, -- Right Leg (true)
	false -- Keep Position (false)
)

local backRightLeg = squapi.leg:new(
	centaurParts.BackRightLeg,
	0.5,   -- Strength (0.5)
	false, -- Right Leg (false)
	false  -- Keep Position (false)
)

-- Leg strength variables
local legStrength = {
	{ object = frontLeftLeg,  strength = frontLeftLeg.strength  },
	{ object = frontRightLeg, strength = frontRightLeg.strength },
	{ object = backLeftLeg,   strength = backLeftLeg.strength   },
	{ object = backRightLeg,  strength = backRightLeg.strength  }
}

-- Squishy taur
local taur = squapi.taur:new(
	centaurParts.LowerBody,
	centaurParts.FrontLegs,
	centaurParts.BackLegs
)

-- Squishy crouch
squapi.crouch(anims.crouch)

function events.TICK()
	
	-- Variables
	local onGround = ground()
	local inWater  = player:isInWater()
	
	-- Arm variables
	local handedness  = player:isLeftHanded()
	local activeness  = player:getActiveHand()
	local leftActive  = not handedness and "OFF_HAND" or "MAIN_HAND"
	local rightActive = handedness and "OFF_HAND" or "MAIN_HAND"
	local leftSwing   = player:getSwingArm() == leftActive
	local rightSwing  = player:getSwingArm() == rightActive
	local leftItem    = player:getHeldItem(not handedness)
	local rightItem   = player:getHeldItem(handedness)
	local using       = player:isUsingItem()
	local usingL      = activeness == leftActive and leftItem:getUseAction() or "NONE"
	local usingR      = activeness == rightActive and rightItem:getUseAction() or "NONE"
	local bow         = using and (usingL == "BOW" or usingR == "BOW")
	local crossL      = leftItem.tag and leftItem.tag["Charged"] == 1
	local crossR      = rightItem.tag and rightItem.tag["Charged"] == 1
	
	-- Arm movement overrides
	local armShouldMove = pose.swim or pose.elytra or pose.crawl or pose.climb
	
	-- Control targets based on variables
	leftArmLerp.target  = (armsMove or armShouldMove or leftSwing  or bow or ((crossL or crossR) or (using and usingL ~= "NONE"))) and 1 or 0
	rightArmLerp.target = (armsMove or armShouldMove or rightSwing or bow or ((crossL or crossR) or (using and usingR ~= "NONE"))) and 1 or 0
	legLerp.target      = (onGround or inWater or pose.elytra or effects.cF) and 1 or 0
	taur.target         = (onGround or effects.cF) and 0 or taur.target
	
	-- Tick lerp
	leftArmLerp.current   = leftArmLerp.nextTick
	rightArmLerp.current  = rightArmLerp.nextTick
	legLerp.current       = legLerp.nextTick
	leftArmLerp.nextTick  = math.lerp(leftArmLerp.nextTick,  leftArmLerp.target,  0.5)
	rightArmLerp.nextTick = math.lerp(rightArmLerp.nextTick, rightArmLerp.target, 0.5)
	legLerp.nextTick      = math.lerp(legLerp.nextTick,      legLerp.target,      0.5)
	
end

function events.RENDER(delta, context)
	
	-- Variables
	local idleTimer   = world.getTime(delta)
	local idleRot     = vec(math.deg(math.sin(idleTimer * 0.067) * 0.05), 0, math.deg(math.cos(idleTimer * 0.09) * 0.05 + 0.05))
	local firstPerson = context == "FIRST_PERSON"
	
	-- Render lerp
	leftArmLerp.currentPos  = math.lerp(leftArmLerp.current,  leftArmLerp.nextTick,  delta)
	rightArmLerp.currentPos = math.lerp(rightArmLerp.current, rightArmLerp.nextTick, delta)
	legLerp.currentPos      = math.lerp(legLerp.current,      legLerp.nextTick,      delta)
	
	-- Adjust arm strengths
	leftArmStrength.object.strength  = leftArmStrength.strength  * leftArmLerp.currentPos
	rightArmStrength.object.strength = rightArmStrength.strength * rightArmLerp.currentPos
	
	-- Adjust leg strength
	for _, index in ipairs(legStrength) do
		index.object.strength = index.strength * legLerp.currentPos
	end
	
	-- Adjust arm characteristics after applied by squapi
	centaurParts.LeftArm
		:offsetRot(
			centaurParts.LeftArm:getOffsetRot()
			+ ((-idleRot + (vanilla_model.BODY:getOriginRot() * 0.75)) * math.map(leftArmLerp.currentPos, 0, 1, 1, 0))
			+ (centaurParts.LeftArm:getAnimRot() * math.map(leftArmLerp.currentPos, 0, 1, 0, -2))
		)
		:pos(centaurParts.LeftArm:getPos() * vec(1, 1, -1))
		:visible(not firstPerson)
	
	centaurParts.RightArm
		:offsetRot(
			centaurParts.RightArm:getOffsetRot()
			+ ((idleRot + (vanilla_model.BODY:getOriginRot() * 0.75)) * math.map(rightArmLerp.currentPos, 0, 1, 1, 0))
			+ (centaurParts.RightArm:getAnimRot() * math.map(rightArmLerp.currentPos, 0, 1, 0, -2))
		)
		:pos(centaurParts.RightArm:getPos() * vec(1, 1, -1))
		:visible(not firstPerson)
	
	-- Set visible if in first person
	centaurParts.LeftArmFP:visible(firstPerson)
	centaurParts.RightArmFP:visible(firstPerson)
	
	-- Set upperbody to offset rot and crouching pivot point
	centaurParts.UpperBody
		:rot(-centaurParts.LowerBody:getRot())
		:offsetPivot(anims.crouch:isPlaying() and -centaurParts.UpperBody:getAnimPos() or 0)
	
	-- Offset smooth torso in various parts
	-- Note: acts strangely with `centaurParts.body`
	for _, group in ipairs(centaurParts.UpperBody:getChildren()) do
		if group ~= centaurParts.Body then
			group:rot(-calculateParentRot(group:getParent()))
		end
	end
	
end

-- Arm movement toggle
function pings.setSquapiArmsMove(boolean)
	
	armsMove = boolean
	config:save("SquapiArmsMove", armsMove)
	
end

-- Sync variable
function pings.syncSquapi(a)
	
	armsMove = a
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local color     = require("scripts.ColorProperties")

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncSquapi(armsMove)
	end
	
end

-- Table setup
local t = {}

-- Action
t.armsPage = action_wheel:newAction()
	:item(itemCheck("red_dye"))
	:toggleItem(itemCheck("rabbit_foot"))
	:onToggle(pings.setSquapiArmsMove)
	:toggled(armsMove)

-- Update action
function events.TICK()
	
	if action_wheel:isEnabled() then
		t.armsPage
			:title(toJson
				{"",
				{text = "Arm Movement Toggle\n\n", bold = true, color = color.primary},
				{text = "Toggles the movement swing movement of the arms.\nActions are not effected.", color = color.secondary}}
			)
		
		for _, page in pairs(t) do
			page:hoverColor(color.hover):toggleColor(color.active)
		end
		
	end
	
end

-- Return action
return t