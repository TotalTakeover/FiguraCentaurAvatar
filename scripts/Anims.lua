-- Required scripts
require("lib.GSAnimBlend")
require("lib.Molang")
local parts   = require("lib.PartsAPI")
local sync    = require("lib.LetThatSyncFig")
local lerp    = require("lib.LerpAPI")
local origins = require("lib.OriginsAPI")
local pose    = require("scripts.Posing")

-- Animations setup
local anims = animations.Centaur

-- Synced variables setup
local armsMove = sync.new("AnimsArms", false):config()
local sitting  = sync.new("AnimsSit", false)

-- Variables
local canSit  = false
local canRear = false
local canKick = false
local _kickData = 0

-- Arms setup
local leftArmLerp  = lerp.new(armsMove.curr and 1 or 0, 0.5)
local rightArmLerp = lerp.new(armsMove.curr and 1 or 0, 0.5)

-- Gets the origin rotation of a part, clamped
local function getOriginRot(part, delta)
	return (vanilla_model[part]:getOriginRot(delta) + 180) % 360 - 180
end

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

-- Store previous origins data
function events.ENTITY_INIT()
	
	_kickData = origins.getPowerData(player)["centaur:horse_kick"]
	
end

function events.TICK()
	
	-- Variables
	local vel       = player:getVelocity()
	local sprinting = player:isSprinting()
	
	-- Animation states
	local sprint = sprinting and not (pose.crouch or pose.swim)
	local extend = pose.swim or pose.elytra or pose.spin or pose.crawl
	local sleep  = pose.sleep
	local canAct = pose.stand and not(vel:length() ~= 0 or player:getVehicle())
	local isAct  = anims.sit:isPlaying() or anims.rearUp:isPlaying() or anims.kick:isPlaying()
	
	-- Animation actions
	canSit  = canAct and (not isAct or anims.sit:isPlaying())
	canRear = canAct and (not isAct or anims.rearUp:isPlaying())
	canKick = canAct and (not isAct or anims.kick:isPlaying())
	
	-- Stop Sitting animation
	if sitting.curr and not canSit then
		sitting:update(false)
	end
	
	-- Stop Rear Up animation
	if not canRear then
		anims.rearUp:stop()
	end
	
	-- Animations
	anims.sprint:playing(sprint)
	anims.extend:playing(extend)
	anims.sleep:playing(sleep)
	
	-- Origins power
	local kickData = origins.getPowerData(player)["centaur:horse_kick"]
	
	-- Play kick if power is activated
	if kickData ~= nil and _kickData ~= nil and kickData ~= _kickData then
		anims.kick:play()
	end
	
	-- Arm variables
	local handedness = player:isLeftHanded()
	local mainL = not handedness and "OFF_HAND" or "MAIN_HAND"
	local mainR = handedness and "OFF_HAND" or "MAIN_HAND"
	local swingL = player:getSwingArm() == mainL
	local swingR = player:getSwingArm() == mainR
	local using = player:isUsingItem()
	local active = player:getActiveHand()
	local itemL = player:getHeldItem(not handedness)
	local itemR = player:getHeldItem(handedness)
	local usingL = using and active == mainL and itemL:getUseAction()
	local usingR = using and active == mainR and itemR:getUseAction()
	local bow = (usingL or usingR or ""):find("BOW") or (itemL:getTag().Charged or itemR:getTag().Charged) == 1
	
	-- Arms movement override
	local armShouldMove = pose.swim or pose.elytra or pose.crawl or pose.climb
	
	-- Arms movement targets
	leftArmLerp.target  = (armsMove.curr or armShouldMove or swingL or usingL or bow) and 0 or -1
	rightArmLerp.target = (armsMove.curr or armShouldMove or swingR or usingR or bow) and 0 or -1
	
	-- Store data
	_kickData = kickData
	
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
	
	-- Arm idle rotation
	local idleTimer = world.getTime(delta)
	local idleRot   = vec(math.deg(math.sin(idleTimer * 0.067) * 0.05), 0, math.deg(math.cos(idleTimer * 0.09) * 0.05 + 0.05))
	
	-- Apply arm rotations
	parts.group.LeftArm:offsetRot((getOriginRot("LEFT_ARM", delta) + idleRot) * leftArmLerp.currPos)
	parts.group.RightArm:offsetRot((getOriginRot("RIGHT_ARM", delta) - idleRot) * rightArmLerp.currPos)
	
	-- Parrot rot offset
	for _, parrot in pairs(parrots) do
		parrot:rot(-calculateParentRot(parrot:getParent()) - getOriginRot("BODY", delta))
	end
	
	-- Crouch offset
	local bodyRot = getOriginRot("BODY", delta)
	local crouchPos = vec(0, -math.sin(math.rad(bodyRot.x)) * 2, -math.sin(math.rad(bodyRot.x)) * 12)
	parts.group.UpperBody:offsetPivot(crouchPos):pos(-crouchPos.x_z + crouchPos._y_ * 2)
	parts.group.LowerBody:pos(crouchPos)
	
	-- Spyglass rotations
	local headRot = getOriginRot("HEAD", delta)
	headRot.x = math.clamp(headRot.x, -90, 30)
	parts.group.Spyglass:offsetRot(headRot)
		:pos(pose.crouch and vec(0, -4, 0) or nil)
	
end

-- GS Blending Setup
local blendAnims = {
	{ anim = anims.sprint, ticks = {7,7}  },
	{ anim = anims.extend, ticks = {7,7}  },
	{ anim = anims.sit,    ticks = {14,7} },
	{ anim = anims.rearUp, ticks = {5,5}  },
	{ anim = anims.kick,   ticks = {5,5}  }
}

-- Apply GS Blending
for _, blend in ipairs(blendAnims) do
	if blend.anim ~= nil then
		blend.anim:blendTime(table.unpack(blend.ticks)):blendCurve("easeOutQuad")
	end
end

-- Play rear up anim
function pings.animPlayRearUp()
	
	anims.rearUp:playing(canRear)
	
end

-- Play kick anim
function pings.animPlayKick()
	
	anims.kick:playing(canKick)
	
end

-- Apply anims to sync updates
sitting:applyFunc(function()
	anims.sit:playing(sitting.curr and canSit)
end)

-- Host only instructions
if not host:isHost() then return end

-- Required script
local keybound = require("lib.Keybound")

-- Setup keybinds
local sitKeybind = keybound.new(
	keybinds
		:newKeybind("Sit Animation", "key.keyboard.keypad.1")
		:onPress(function() sitting:update(not sitting.curr) end),
	"AnimsSitKeybind"
)
local rearUpKeybind = keybound.new(
	keybinds
		:newKeybind("Rear Up Animation", "key.keyboard.keypad.2")
		:onPress(pings.animPlayRearUp),
	"AnimsRearUpKeybind"
)
local kickKeybind = keybound.new(
	keybinds
		:newKeybind("Kick Animation", "key.keyboard.keypad.3")
		:onPress(pings.animPlayKick),
	"AnimsKickKeybind"
)

-- Table setup
local t = {}

-- Required scripts
local s, pageNav, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.Accessories") -- Tries to find script, not required

-- Check for if page already exists
local pageExists = action_wheel:getPage("Anims")

-- Pages
local parentPage = action_wheel:getPage("Main")
local animsPage  = pageExists or action_wheel:newPage("Anims")

-- Actions table setup
local a = {}

-- Actions
if not pageExists then
	a.pageAct = parentPage:newAction()
		:item("jukebox")
		:onLeftClick(function() pageNav.descend(animsPage) end)
end

a.sitAct = animsPage:newAction()
	:item("scaffolding")
	:toggleItem("saddle")
	:onToggle(function(bool)
		sitting:update(bool)
	end)

a.rearUpAct = animsPage:newAction()
	:item("golden_axe")
	:onLeftClick(pings.animPlayRearUp)

a.kickAct = animsPage:newAction()
	:item("carrot")
	:onLeftClick(pings.animPlayKick)

a.armsAct = animsPage:newAction()
	:item("red_dye")
	:toggleItem("rabbit_foot")
	:onToggle(function(bool)
		armsMove:update(bool)
	end)
	:toggled(armsMove.curr)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if a.pageAct then
			a.pageAct
				:title(toJson(
					{text = "Animation Settings", bold = true, color = c.primary}
				))
		end
		
		a.sitAct
			:title(toJson(
				{text = "Play Sit animation", bold = true, color = c.primary}
			))
			:toggled(anims.sit:isPlaying())
		
		a.rearUpAct
			:title(toJson(
				{text = "Play Rear Up animation", bold = true, color = c.primary}
			))
		
		a.kickAct
			:title(toJson(
				{text = "Play Kick animation", bold = true, color = c.primary}
			))
		
		a.armsAct
			:title(toJson(
				{
					"",
					{text = "Arm Movement Toggle\n\n", bold = true, color = c.primary},
					{text = "Toggles the movement swing movement of the arms.\nActions are not effected.", color = c.secondary}
				}
			))
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end