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

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local s, c = pcall(require, "scripts.ColorProperties")
if not s then c = {} end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncAccessories(saddle, bags)
	end
	
end

-- Table setup
local t = {}

-- Actions
t.saddleAct = action_wheel:newAction()
	:item(itemCheck("leather"))
	:toggleItem(itemCheck("saddle"))
	:onToggle(pings.setAccessoriesSaddle)
	:toggled(saddle)

t.bagsAct = action_wheel:newAction()
	:texture(textures:fromVanilla("BundleFilled", "textures/item/bundle_filled.png"))
	:toggleTexture(textures:fromVanilla("Bundle", "textures/item/bundle.png"))
	:onToggle(pings.setAccessoriesBags)
	:toggled(bags)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.saddleAct
			:title(toJson
				{"",
				{text = "Toggle Saddle\n\n", bold = true, color = c.primary},
				{text = "Toggles visibility of the saddle.", color = c.secondary}}
			)
		
		t.bagsAct
			:title(toJson
				{"",
				{text = "Toggle Bags\n\n", bold = true, color = c.primary},
				{text = "Toggles visibility of the bags.", color = c.secondary}}
			)
		
		for _, page in pairs(t) do
			page:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end

-- Return actions
return t