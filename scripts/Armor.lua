-- Required scripts
local centaurParts = require("lib.GroupIndex")(models.models.Centaur)
local kattArmor    = require("lib.KattArmor")()
local itemCheck    = require("lib.ItemCheck")
local color        = require("scripts.ColorProperties")

-- Setting the leggings to layer 1
kattArmor.Armor.Leggings:setLayer(1)

-- Armor parts
kattArmor.Armor.Chestplate
	:addParts(
		centaurParts.ManeArmorChestplate.Chestplate
	)
kattArmor.Armor.Leggings
	:addParts(
		centaurParts.MainArmorLeggings.Leggings
	)
kattArmor.Armor.Boots
	:addParts(
		centaurParts.FrontLeftLegArmorBoot.Boot,
		centaurParts.FrontRightLegArmorBoot.Boot,
		centaurParts.BackLeftLegArmorBoot.Boot,
		centaurParts.BackRightLegArmorBoot.Boot
	)

-- Leather armor
kattArmor.Materials.leather
	:setTexture("textures/entity/horse/armor/horse_armor_leather.png")

-- Chainmail armor
kattArmor.Materials.chainmail
	:setTexture()

-- Iron armor
kattArmor.Materials.iron
	:setTexture("textures/entity/horse/armor/horse_armor_iron.png")

-- Golden armor
kattArmor.Materials.golden
	:setTexture("textures/entity/horse/armor/horse_armor_gold.png")

-- Diamond armor
kattArmor.Materials.diamond
	:setTexture("textures/entity/horse/armor/horse_armor_diamond.png")

-- Netherite armor
kattArmor.Materials.netherite
	:setTexture()

-- Config setup
config:name("Centaur")
local helmet     = config:load("ArmorHelmet")
local chestplate = config:load("ArmorChestplate")
local leggings   = config:load("ArmorLeggings")
local boots      = config:load("ArmorBoots")
if helmet     == nil then helmet     = true end
if chestplate == nil then chestplate = true end
if leggings   == nil then leggings   = true end
if boots      == nil then boots      = true end

-- All helmet parts
local helmetGroups = {
	
	vanilla_model.HELMET
	
}

-- All chestplate parts
local chestplateGroups = {
	
	vanilla_model.CHESTPLATE,
	centaurParts.ManeArmorChestplate
	
}

-- All leggings parts
local leggingsGroups = {
	
	centaurParts.MainArmorLeggings
	
}

-- All boots parts
local bootsGroups = {
	
	centaurParts.FrontLeftLegArmorBoot,
	centaurParts.FrontRightLegArmorBoot,
	centaurParts.BackLeftLegArmorBoot,
	centaurParts.BackRightLegArmorBoot
	
}

function events.TICK()
	
	for _, part in ipairs(helmetGroups) do
		part:visible(helmet)
	end
	
	for _, part in ipairs(chestplateGroups) do
		part:visible(chestplate)
	end
	
	for _, part in ipairs(leggingsGroups) do
		part:visible(leggings)
	end
	
	for _, part in ipairs(bootsGroups) do
		part:visible(boots)
	end
	
	-- Increase saddle scale to fit armor
	centaurParts.Saddle:scale(centaurParts.MainArmorLeggings.Leggings:getVisible() and 1 or 0.95)
	
end

-- Armor all toggle
function pings.setArmorAll(boolean)
	
	helmet     = boolean
	chestplate = boolean
	leggings   = boolean
	boots      = boolean
	config:save("ArmorHelmet", helmet)
	config:save("ArmorChestplate", chestplate)
	config:save("ArmorLeggings", leggings)
	config:save("ArmorBoots", boots)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor helmet toggle
function pings.setArmorHelmet(boolean)
	
	helmet = boolean
	config:save("ArmorHelmet", helmet)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor chestplate toggle
function pings.setArmorChestplate(boolean)
	
	chestplate = boolean
	config:save("ArmorChestplate", chestplate)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor leggings toggle
function pings.setArmorLeggings(boolean)
	
	leggings = boolean
	config:save("ArmorLeggings", leggings)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Armor boots toggle
function pings.setArmorBoots(boolean)
	
	boots = boolean
	config:save("ArmorBoots", boots)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Sync variables
function pings.syncArmor(a, b, c, d)
	
	helmet     = a
	chestplate = b
	leggings   = c
	boots      = d
	
end

-- Host only instructions
if not host:isHost() then return end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncArmor(helmet, chestplate, leggings, boots)
	end
	
end

-- Setup table
local t = {}

-- Action wheel pages
t.allPage = action_wheel:newAction()
	:item(itemCheck("armor_stand"))
	:toggleItem(itemCheck("netherite_chestplate"))
	:onToggle(pings.setArmorAll)

t.helmetPage = action_wheel:newAction()
	:item(itemCheck("iron_helmet"))
	:toggleItem(itemCheck("diamond_helmet"))
	:onToggle(pings.setArmorHelmet)

t.chestplatePage = action_wheel:newAction()
	:item(itemCheck("iron_chestplate"))
	:toggleItem(itemCheck("diamond_chestplate"))
	:onToggle(pings.setArmorChestplate)

t.leggingsPage = action_wheel:newAction()
	:item(itemCheck("iron_leggings"))
	:toggleItem(itemCheck("diamond_leggings"))
	:onToggle(pings.setArmorLeggings)

t.bootsPage = action_wheel:newAction()
	:item(itemCheck("iron_boots"))
	:toggleItem(itemCheck("diamond_boots"))
	:onToggle(pings.setArmorBoots)

-- Update action page info
function events.TICK()
	
	if action_wheel:isEnabled() then
		t.allPage
			:title(toJson
				{"",
				{text = "Toggle All Armor\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of all armor parts.", color = color.secondary}}
			)
			:hoverColor(color.hover)
			:toggleColor(color.active)
			:toggled(helmet and chestplate and leggings and boots)
		
		t.helmetPage
			:title(toJson
				{"",
				{text = "Toggle Helmet\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of helmet parts.", color = color.secondary}}
			)
			:hoverColor(color.hover)
			:toggleColor(color.active)
			:toggled(helmet)
		
		t.chestplatePage
			:title(toJson
				{"",
				{text = "Toggle Chestplate\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of chestplate parts.", color = color.secondary}}
			)
			:hoverColor(color.hover)
			:toggleColor(color.active)
			:toggled(chestplate)
		
		t.leggingsPage
			:title(toJson
				{"",
				{text = "Toggle Leggings\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of leggings parts.", color = color.secondary}}
			)
			:hoverColor(color.hover)
			:toggleColor(color.active)
			:toggled(leggings)
		
		t.bootsPage
			:title(toJson
				{"",
				{text = "Toggle Boots\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of boots.", color = color.secondary}}
			)
			:hoverColor(color.hover)
			:toggleColor(color.active)
			:toggled(boots)
	end
	
end

-- Return action wheel pages
return t