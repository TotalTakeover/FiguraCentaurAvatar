-- Required script
local parts = require("lib.PartsAPI")

-- Config setup
config:name("Centaur")
local saddle = config:load("AccessoriesSaddle") or false
local bags   = config:load("AccessoriesBags")   or false

-- Saddle parts
local saddleParts = {
	
	parts.group.Saddle
	
}

-- Bag parts
local bagParts = {
	
	parts.group.LeftBag,
	parts.group.RightBag
	
}

function events.RENDER(delta, context)
	
	-- Apply
	for _, part in ipairs(saddleParts) do
		part:visible(saddle)
	end
	for _, part in ipairs(bagParts) do
		part:visible(bags)
	end
	
end

-- Saddle toggle
function pings.setAccessoriesSaddle(boolean)
	
	saddle = boolean
	config:save("AccessoriesSaddle", saddle)
	if player:isLoaded() then
		sounds:playSound("entity.horse.saddle", player:getPos(), 0.5)
	end
	
end

-- Bags toggle
function pings.setAccessoriesBags(boolean)
	
	bags = boolean
	config:save("AccessoriesBags", bags)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Sync variables
function pings.syncAccessories(a, b)
	
	saddle = a
	bags   = b
	
end

-- Host only instructions
if not host:isHost() then return end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncAccessories(saddle, bags)
	end
	
end

-- Required scripts
local s, wheel, itemCheck, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found

-- Check for if page already exists
local pageExists = action_wheel:getPage("Centaur")

-- Pages
local parentPage  = action_wheel:getPage("Main")
local centaurPage = pageExists or action_wheel:newPage("Centaur")

-- Actions table setup
local a = {}

-- Actions
if not pageExists then
	a.pageAct = parentPage:newAction()
		:item(itemCheck("saddle"))
		:onLeftClick(function() wheel:descend(centaurPage) end)
end

a.saddleAct = centaurPage:newAction()
	:item(itemCheck("leather"))
	:toggleItem(itemCheck("saddle"))
	:onToggle(pings.setAccessoriesSaddle)
	:toggled(saddle)

a.bagsAct = centaurPage:newAction()
	:texture(textures:fromVanilla("BundleFilled", "textures/item/bundle_filled.png"))
	:toggleTexture(textures:fromVanilla("Bundle", "textures/item/bundle.png"))
	:onToggle(pings.setAccessoriesBags)
	:toggled(bags)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if a.pageAct then
			a.pageAct
				:title(toJson(
					{text = "Centaur Settings", bold = true, color = c.primary}
				))
		end
		
		a.saddleAct
			:title(toJson(
				{
					"",
					{text = "Toggle Saddle\n\n", bold = true, color = c.primary},
					{text = "Toggles visibility of the saddle.", color = c.secondary}
				}
			))
		
		a.bagsAct
			:title(toJson(
				{
					"",
					{text = "Toggle Bags\n\n", bold = true, color = c.primary},
					{text = "Toggles visibility of the bags.", color = c.secondary}
				}
			))
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end