-- Required script
local centaurParts = require("lib.GroupIndex")(models.models.Centaur)

-- Config setup
config:name("Centaur")
local saddle = config:load("AccessoriesSaddle") or false
local bags   = config:load("AccessoriesBags")   or false

-- All saddle parts
local saddleParts = {
	
	centaurParts.Saddle
	
}

-- All bag parts
local bagParts = {
	
	centaurParts.LeftBag,
	centaurParts.RightBag
	
}

function events.TICK()
	
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
local color     = require("scripts.ColorProperties")

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncAccessories(saddle, bags)
	end
	
end

-- Setup table
local t = {}

-- Action wheel pages
t.saddlePage = action_wheel:newAction()
	:item(itemCheck("leather"))
	:toggleItem(itemCheck("saddle"))
	:onToggle(pings.setAccessoriesSaddle)
	:toggled(saddle)

t.bagsPage = action_wheel:newAction()
	:texture(textures:fromVanilla("BundleFilled", "textures/item/bundle_filled.png"))
	:toggleTexture(textures:fromVanilla("Bundle", "textures/item/bundle.png"))
	:onToggle(pings.setAccessoriesBags)
	:toggled(bags)

-- Update action page info
function events.TICK()
	
	if action_wheel:isEnabled() then
		t.saddlePage
			:title(toJson
				{"",
				{text = "Toggle Saddle\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of the saddle.", color = color.secondary}}
			)
		
		t.bagsPage
			:title(toJson
				{"",
				{text = "Toggle Bags\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of the bags.", color = color.secondary}}
			)
		
		for _, page in pairs(t) do
			page:hoverColor(color.hover):toggleColor(color.active)
		end
		
	end
	
end

-- Return action wheel pages
return t