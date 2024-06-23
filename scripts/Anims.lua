-- Required scripts
require("lib.GSAnimBlend")
local centaurParts = require("lib.GroupIndex")(models.models.Centaur)
local ground       = require("lib.GroundCheck")
local itemCheck    = require("lib.ItemCheck")
local pose         = require("scripts.Posing")
local color        = require("scripts.ColorProperties")

-- Config setup
config:name("Centaur")
local tailSwish = config:load("AnimsTailSwish")
local earFlick  = config:load("AnimsEarFlick")
if tailSwish == nil then tailSwish = true end
if earFlick  == nil then earFlick  = true end

-- Animations setup
local anims = animations["models.Centaur"]

-- Variables
local wasGround = false
local canRear   = false
local holdJump  = 0
local swishTailTimer = math.random(20, 400)
local flickEarTimer  = math.random(20, 400)

-- Parrot pivots
local parrots = {
	
	centaurParts.LeftParrotPivot,
	centaurParts.RightParrotPivot
	
}

-- Calculate parent's rotations
local function calculateParentRot(m)
	
	local parent = m:getParent()
	if not parent then
		return m:getTrueRot()
	end
	return calculateParentRot(parent) + m:getTrueRot()
	
end

function events.TICK()
	
	-- Variables
	local vel       = player:getVelocity()
	local onGround  = ground()
	local sprinting = player:isSprinting()
	local inWater   = player:isInWater()
	
	-- Animation states
	local sprint  = sprinting and not pose.crouch and not pose.swim
	local stretch = pose.swim or pose.elytra or pose.spin or pose.crawl
	local sleep   = pose.sleep
	canRear = not pose.swim and not pose.elytra and not pose.sleep
	
	-- Control rearing up animation
	holdJump = math.max(holdJump - 1, 0)
	if wasGround and not onGround and sprint and vel.y > 0 and not inWater then
		
		holdJump = 20
		
	end
	
	-- Animations
	anims.sprint:playing(sprint)
	anims.stretch:playing(stretch)
	anims.sleep:playing(sleep)
	anims.rearUp:playing(canRear and holdJump ~= 0)
	
	if host:isHost() then
		
		if tailSwish then
			
			-- Decrease timer
			swishTailTimer = math.max(swishTailTimer - 1, 0)
			
			if swishTailTimer == 0 then
				
				-- Create new timer + play animation
				swishTailTimer = math.random(20, 400)
				pings.animPlayTailSwish(math.random(1, 2))
				
			end
		
		end
		
		if earFlick then
			
			-- Decrease timer
			flickEarTimer = math.max(flickEarTimer - 1, 0)
			
			if flickEarTimer == 0 then
				
				-- Create new timer + play animation
				flickEarTimer = math.random(20, 400)
				pings.animPlayEarFlick(math.random(1, 3))
				
			end
			
		end
		
	end
	
	-- Store ground state
	wasGround = onGround
	
end

-- Sleep rotations
local dirRot = {
	north = 0,
	east  = 270,
	south = 180,
	west  = 90
}

function events.RENDER(delta, context)
	
	-- Leg movement
	centaurParts.FrontLeftLeg:rot(vanilla_model.LEFT_LEG:getOriginRot()/2)
	centaurParts.FrontRightLeg:rot(vanilla_model.RIGHT_LEG:getOriginRot()/2)
	centaurParts.BackLeftLeg:rot(vanilla_model.RIGHT_LEG:getOriginRot()/2)
	centaurParts.BackRightLeg:rot(vanilla_model.LEFT_LEG:getOriginRot()/2)
	
	-- Sleep rotations
	if pose.sleep then
		
		-- Disable vanilla rotation
		renderer:rootRotationAllowed(false)
		
		-- Find block
		local block = world.getBlockState(player:getPos())
		local sleepRot = dirRot[block.properties["facing"]]
		
		-- Apply
		models:rot(0, sleepRot, 0)
		
	else
		
		-- Enable vanilla rotation
		renderer:rootRotationAllowed(true)
		
		-- Reset
		models:rot(0)
		
	end
	
	-- Parrot rot offset
	for _, parrot in pairs(parrots) do
		parrot:rot(-calculateParentRot(parrot:getParent()))
	end
	
end

-- GS Blending Setup
local blendAnims = {
	{ anim = anims.sprint,  ticks = {7,7} },
	{ anim = anims.stretch, ticks = {7,7} },
	{ anim = anims.rearUp,  ticks = {5,5} }
}
	
for _, blend in ipairs(blendAnims) do
	blend.anim:blendTime(table.unpack(blend.ticks)):onBlend("easeOutQuad")
end

-- Fixing spyglass jank
function events.RENDER(delta, context)
	
	local rot = vanilla_model.HEAD:getOriginRot()
	rot.x = math.clamp(rot.x, -90, 30)
	centaurParts.Spyglass:rot(rot)
		:pos(pose.crouch and vec(0, -4, 0) or nil)
	
end

-- Play rear up anim
function pings.animPlayRearUp()
	
	if canRear then
		holdJump = 20
	end
	
end

-- Toggle random tail swish
function pings.setAnimsTailSwish(boolean)
	
	tailSwish = boolean
	config:save("AnimsTailSwish", tailSwish)
	
end

-- Play tail swish anim
function pings.animPlayTailSwish(dir)
	
	local swishAnims = {
		anims.tailSwishLeft,
		anims.tailSwishRight
	}
	
	swishAnims[dir]:play()
	
end

-- Toggle random ear flick
function pings.setAnimsEarFlick(boolean)
	
	earFlick = boolean
	config:save("AnimsEarFlick", earFlick)
	
end

-- Play ear flick anim
function pings.animPlayEarFlick(type)
	
	local flickAnims = {
		anims.earFlickLeft,
		anims.earFlickRight
	}
	
	if type == 3 then
		
		for _, anim in ipairs(flickAnims) do
			anim:play()
		end
		
	else
		
		flickAnims[type]:play()
		
	end
	
end

-- Host only instructions
if not host:isHost() then return end

-- Rear Up keybind
local rearUpBind   = config:load("AnimRearUpKeybind") or "key.keyboard.keypad.1"
local setRearUpKey = keybinds:newKeybind("Rear Up Animation"):onPress(pings.animPlayRearUp):key(rearUpBind)

-- Tail Swish keybind
local tailSwishBind   = config:load("AnimTailSwishKeybind") or "key.keyboard.keypad.2"
local setTailSwishKey = keybinds:newKeybind("Tail Swish Animation"):onPress(function() pings.animPlayTailSwish(math.random(1,2)) end):key(tailSwishBind)

-- Ear Flick keybind
local earFlickBind   = config:load("AnimEarFlickKeybind") or "key.keyboard.keypad.3"
local setEarFlickKey = keybinds:newKeybind("Ear Flick Animation"):onPress(function() pings.animPlayEarFlick(math.random(1,3)) end):key(earFlickBind)

-- Keybind updaters
function events.TICK()
	
	local rearUpKey    = setRearUpKey:getKey()
	local tailSwishKey = setTailSwishKey:getKey()
	local earFlickKey  = setEarFlickKey:getKey()
	if rearUpKey ~= rearUpBind then
		rearUpBind = rearUpKey
		config:save("AnimRearUpKeybind", rearUpKey)
	end
	if tailSwishKey ~= earFlickBind then
		earFlickBind = tailSwishKey
		config:save("AnimEarFlickKeybind", tailSwishKey)
	end
	if earFlickKey ~= earFlickBind then
		earFlickBind = earFlickKey
		config:save("AnimEarFlickKeybind", earFlickKey)
	end
	
end

-- Setup table
local t = {}

-- Action wheel pages
t.rearUpPage = action_wheel:newAction()
	:item(itemCheck("golden_axe"))
	:onLeftClick(pings.animPlayRearUp)

t.tailSwishPage = action_wheel:newAction()
	:item(itemCheck("bamboo"))
	:toggleItem(itemCheck("brush"))
	:onToggle(pings.setAnimsTailSwish)
	:onRightClick(function() pings.animPlayTailSwish(math.random(1,2)) end)
	:toggled(tailSwish)

t.earFlickPage = action_wheel:newAction()
	:item(itemCheck("carrot"))
	:toggleItem(itemCheck("golden_carrot"))
	:onToggle(pings.setAnimsEarFlick)
	:onRightClick(function() pings.animPlayEarFlick(math.random(1,3)) end)
	:toggled(earFlick)

-- Update action page info
function events.TICK()
	
	if action_wheel:isEnabled() then
		t.rearUpPage
			:title(toJson
				{text = "Play Rear Up animation", bold = true, color = color.primary}
			)
			:hoverColor(color.hover)
		
		t.tailSwishPage
			:title(toJson
				{"",
				{text = "Toggle Tail Swish\n\n", bold = true, color = color.primary},
				{text = "Allow the tail to idly swish at random intervals.\nRight click to manually swish the tail.", color = color.secondary}}
			)
			:hoverColor(color.hover)
			:toggleColor(color.active)
		
		t.earFlickPage
			:title(toJson
				{"",
				{text = "Toggle Ear Flick\n\n", bold = true, color = color.primary},
				{text = "Allow the ears to idly flick at random intervals.\nRight click to manually flick an ear.", color = color.secondary}}
			)
			:hoverColor(color.hover)
			:toggleColor(color.active)
	end
	
end

-- Returns animation variables/action wheel pages
return t