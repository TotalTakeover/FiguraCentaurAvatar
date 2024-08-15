-- Required scripts
require("lib.GSAnimBlend")
local parts  = require("lib.PartsAPI")
local ground = require("lib.GroundCheck")
local pose   = require("scripts.Posing")

-- Animations setup
local anims = animations.Centaur

-- Variables
local wasGround = false
local canRear   = false
local holdJump  = 0

-- Parrot pivots
local parrots = {
	
	parts.group.LeftParrotPivot,
	parts.group.RightParrotPivot
	
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
	local sprint = sprinting and not pose.crouch and not pose.swim
	local extend = pose.swim or pose.elytra or pose.spin or pose.crawl
	local sleep  = pose.sleep
	canRear = vel:length() == 0 and (pose.stand or pose.crouch)
	
	-- Control rearing up animation
	holdJump = not canRear and 0 or math.max(holdJump - 1, 0)
	
	-- Animations
	anims.sprint:playing(sprint)
	anims.extend:playing(extend)
	anims.sleep:playing(sleep)
	anims.rearUp:playing(canRear and holdJump ~= 0)
	
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
	{ anim = anims.sprint, ticks = {7,7} },
	{ anim = anims.extend, ticks = {7,7} },
	{ anim = anims.rearUp, ticks = {5,5} }
}

-- Apply GS Blending
for _, blend in ipairs(blendAnims) do
	blend.anim:blendTime(table.unpack(blend.ticks)):onBlend("easeOutQuad")
end

-- Fixing spyglass jank
function events.RENDER(delta, context)
	
	local rot = vanilla_model.HEAD:getOriginRot()
	rot.x = math.clamp(rot.x, -90, 30)
	parts.group.Spyglass:rot(rot)
		:pos(pose.crouch and vec(0, -4, 0) or nil)
	
end

-- Play rear up anim
function pings.animPlayRearUp()
	
	if canRear then
		holdJump = 20
	end
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local s, color = pcall(require, "scripts.ColorProperties")
if not s then color = {} end

-- Rear Up keybind
local rearUpBind   = config:load("AnimRearUpKeybind") or "key.keyboard.keypad.1"
local setRearUpKey = keybinds:newKeybind("Rear Up Animation"):onPress(pings.animPlayRearUp):key(rearUpBind)

-- Keybind updaters
function events.TICK()
	
	local rearUpKey = setRearUpKey:getKey()
	if rearUpKey ~= rearUpBind then
		rearUpBind = rearUpKey
		config:save("AnimRearUpKeybind", rearUpKey)
	end
	
end

-- Table setup
local t = {}

-- Action
t.rearUpAct = action_wheel:newAction()
	:item(itemCheck("golden_axe"))
	:onLeftClick(pings.animPlayRearUp)

-- Update action
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.rearUpAct
			:title(toJson
				{text = "Play Rear Up animation", bold = true, color = color.primary}
			)
		
		for _, page in pairs(t) do
			page:hoverColor(color.hover):toggleColor(color.active)
		end
		
	end
	
end

-- Returns action
return t