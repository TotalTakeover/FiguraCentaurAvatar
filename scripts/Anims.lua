-- Required scripts
require("lib.GSAnimBlend")
require("lib.Molang")
local parts   = require("lib.PartsAPI")
local pose    = require("scripts.Posing")
local origins = require("lib.OriginsAPI")

-- Animations setup
local anims = animations.Centaur

-- Variables
local canAct  = false
local canSit  = false
local canRear = false
local canKick = false
local prevKickData = 0

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
	
	prevKickData = origins.getPowerData(player, "centaur:horse_kick") or 0
	
end

function events.TICK()
	
	-- Variables
	local vel       = player:getVelocity()
	local sprinting = player:isSprinting()
	
	-- Animation states
	local sprint = sprinting and not pose.crouch and not pose.swim
	local extend = pose.swim or pose.elytra or pose.spin or pose.crawl
	local sleep  = pose.sleep
	local isAct  = anims.sit:isPlaying() or anims.rearUp:isPlaying() or anims.kick:isPlaying()
	
	-- Animation actions
	canAct  = pose.stand and not(vel:length() ~= 0 or player:getVehicle())
	canSit  = canAct and (not isAct or anims.sit:isPlaying())
	canRear = canAct and (not isAct or anims.rearUp:isPlaying())
	canKick = canAct and (not isAct or anims.kick:isPlaying())
	
	-- Stop Sit animation
	if not canSit then
		anims.sit:stop()
	end
	
	-- Stop Rear Up animation
	if not canRear then
		anims.rearUp:stop()
	end
	
	-- Animations
	anims.sprint:playing(sprint)
	anims.extend:playing(extend)
	anims.sleep:playing(sleep)
	
	-- Origins powers
	local hasKickPower = origins.hasPower(player, "centaur:horse_kick")
	local kickData = origins.getPowerData(player, "centaur:horse_kick") or 0
	
	-- Play kick if power is activated
	if hasKickPower and kickData ~= prevKickData then
		anims.kick:play()
	end
	
	prevKickData = kickData
	
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
		parrot:rot(-calculateParentRot(parrot:getParent()) - vanilla_model.BODY:getOriginRot())
	end
	
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
	blend.anim:blendTime(table.unpack(blend.ticks)):onBlend("easeOutQuad")
end

-- Fixing spyglass jank
function events.RENDER(delta, context)
	
	local rot = vanilla_model.HEAD:getOriginRot()
	rot.x = math.clamp(rot.x, -90, 30)
	parts.group.Spyglass:offsetRot(rot)
		:pos(pose.crouch and vec(0, -4, 0) or nil)
	
end

-- Play sit anim
function pings.setAnimToggleSit(boolean)
	
	anims.sit:playing(canSit and boolean)
	
end

-- Play rear up anim
function pings.animPlayRearUp()
	
	anims.rearUp:playing(canRear)
	
end

-- Play kick anim
function pings.animPlayKick()
	
	anims.kick:playing(canKick)
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local s, color = pcall(require, "scripts.ColorProperties")
if not s then color = {} end

-- Sit keybind
local sitBind   = config:load("AnimSitKeybind") or "key.keyboard.keypad.1"
local setSitKey = keybinds:newKeybind("Sit Animation"):onPress(function() pings.setAnimToggleSit(not anims.sit:isPlaying()) end):key(sitBind)

-- Rear Up keybind
local rearUpBind   = config:load("AnimRearUpKeybind") or "key.keyboard.keypad.2"
local setRearUpKey = keybinds:newKeybind("Rear Up Animation"):onPress(pings.animPlayRearUp):key(rearUpBind)

-- Kick keybind
local kickBind   = config:load("AnimKickKeybind") or "key.keyboard.keypad.3"
local setKickKey = keybinds:newKeybind("Kick Animation"):onPress(pings.animPlayKick):key(kickBind)

-- Keybind updaters
function events.TICK()
	
	local rearUpKey = setRearUpKey:getKey()
	local sitKey    = setSitKey:getKey()
	local kickKey   = setKickKey:getKey()
	if sitKey ~= sitBind then
		sitBind = sitKey
		config:save("AnimSitKeybind", sitKey)
	end
	if rearUpKey ~= rearUpBind then
		rearUpBind = rearUpKey
		config:save("AnimRearUpKeybind", rearUpKey)
	end
	if kickKey ~= kickBind then
		kickBind = kickKey
		config:save("AnimKickKeybind", kickKey)
	end
	
end

-- Table setup
local t = {}

-- Actions
t.sitAct = action_wheel:newAction()
	:item(itemCheck("scaffolding"))
	:toggleItem(itemCheck("saddle"))
	:onToggle(pings.setAnimToggleSit)

t.rearUpAct = action_wheel:newAction()
	:item(itemCheck("golden_axe"))
	:onLeftClick(pings.animPlayRearUp)

t.kickAct = action_wheel:newAction()
	:item(itemCheck("carrot"))
	:onLeftClick(pings.animPlayKick)

-- Update action
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.sitAct
			:title(toJson
				{text = "Play Sit animation", bold = true, color = color.primary}
			)
			:toggled(anims.sit:isPlaying())
		
		t.rearUpAct
			:title(toJson
				{text = "Play Rear Up animation", bold = true, color = color.primary}
			)
		
		t.kickAct
			:title(toJson
				{text = "Play Kick animation", bold = true, color = color.primary}
			)
		
		for _, page in pairs(t) do
			page:hoverColor(color.hover):toggleColor(color.active)
		end
		
	end
	
end

-- Returns action
return t