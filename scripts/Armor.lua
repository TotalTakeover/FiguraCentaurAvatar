-- Required scripts
local centaurParts = require("lib.GroupIndex")(models.models.Centaur)
local kattArmor    = require("lib.KattArmor")()

-- Setting the leggings to layer 1
kattArmor.Armor.Leggings:setLayer(1)

-- Armor parts
kattArmor.Armor.Helmet
	:addParts(centaurParts.headArmorHelmet.Helmet)
	:addTrimParts(centaurParts.headArmorHelmet.Trim)
kattArmor.Armor.Chestplate
	:addParts(
		centaurParts.bodyArmorChestplate.Chestplate,
		centaurParts.leftArmArmorChestplate.Chestplate,
		centaurParts.rightArmArmorChestplate.Chestplate,
		centaurParts.leftArmArmorChestplateFP.Chestplate,
		centaurParts.rightArmArmorChestplateFP.Chestplate
	)
	:addTrimParts(
		centaurParts.bodyArmorChestplate.Trim,
		centaurParts.leftArmArmorChestplate.Trim,
		centaurParts.rightArmArmorChestplate.Trim,
		centaurParts.leftArmArmorChestplateFP.Trim,
		centaurParts.rightArmArmorChestplateFP.Trim
	)
kattArmor.Armor.Leggings
	:addParts(
		centaurParts.bodyArmorLeggings.Leggings,
		centaurParts.MainArmorLeggings.Leggings
	)
	:addTrimParts(
		centaurParts.bodyArmorLeggings.Trim,
		centaurParts.MainArmorLeggings.Trim
	)
kattArmor.Armor.Boots
	:addParts(
		centaurParts.FrontLeftLegArmorBoot.Boot,
		centaurParts.FrontRightLegArmorBoot.Boot,
		centaurParts.BackLeftLegArmorBoot.Boot,
		centaurParts.BackRightLegArmorBoot.Boot
	)
	:addTrimParts(
		centaurParts.FrontLeftLegArmorBoot.Trim,
		centaurParts.FrontRightLegArmorBoot.Trim,
		centaurParts.BackLeftLegArmorBoot.Trim,
		centaurParts.BackRightLegArmorBoot.Trim
	)

-- Leather armor
kattArmor.Materials.leather
	:setTexture(textures["models.Centaur.leatherArmor"])
	:addParts(kattArmor.Armor.Helmet,
		centaurParts.headArmorHelmet.Leather
	)
	:addParts(kattArmor.Armor.Chestplate,
		centaurParts.bodyArmorChestplate.Leather,
		centaurParts.leftArmArmorChestplate.Leather,
		centaurParts.rightArmArmorChestplate.Leather,
		centaurParts.leftArmArmorChestplateFP.Leather,
		centaurParts.rightArmArmorChestplateFP.Leather
	)
	:addParts(kattArmor.Armor.Leggings,
		centaurParts.bodyArmorLeggings.Leather,
		centaurParts.MainArmorLeggings.Leather
	)
	:addParts(kattArmor.Armor.Boots,
		centaurParts.FrontLeftLegArmorBoot.Leather,
		centaurParts.FrontRightLegArmorBoot.Leather,
		centaurParts.BackLeftLegArmorBoot.Leather,
		centaurParts.BackRightLegArmorBoot.Leather
	)

-- Chainmail armor
kattArmor.Materials.chainmail
	:setTexture(textures["models.Centaur.chainmailArmor"])

-- Iron armor
kattArmor.Materials.iron
	:setTexture(textures["models.Centaur.ironArmor"])

-- Golden armor
kattArmor.Materials.golden
	:setTexture(textures["models.Centaur.goldenArmor"])

-- Diamond armor
kattArmor.Materials.diamond
	:setTexture(textures["models.Centaur.diamondArmor"])

-- Netherite armor
kattArmor.Materials.netherite
	:setTexture(textures["models.Centaur.netheriteArmor"])

-- Turtle helmet
kattArmor.Materials.turtle
	:setTexture(textures["models.Centaur.turtleHelmet"])

-- Trims
-- Coast
kattArmor.TrimPatterns.coast
	:setTexture(textures["models.Centaur.coastTrim"])

-- Dune
kattArmor.TrimPatterns.dune
	:setTexture(textures["models.Centaur.duneTrim"])

-- Eye
kattArmor.TrimPatterns.eye
	:setTexture(textures["models.Centaur.eyeTrim"])

-- Host
kattArmor.TrimPatterns.host
	:setTexture(textures["models.Centaur.hostTrim"])

-- Raiser
kattArmor.TrimPatterns.raiser
	:setTexture(textures["models.Centaur.raiserTrim"])

-- Rib
kattArmor.TrimPatterns.rib
	:setTexture(textures["models.Centaur.ribTrim"])

-- Sentry
kattArmor.TrimPatterns.sentry
	:setTexture(textures["models.Centaur.sentryTrim"])

-- Shaper
kattArmor.TrimPatterns.shaper
	:setTexture(textures["models.Centaur.shaperTrim"])

-- Silence
kattArmor.TrimPatterns.silence
	:setTexture(textures["models.Centaur.silenceTrim"])

-- Snout
kattArmor.TrimPatterns.snout
	:setTexture(textures["models.Centaur.snoutTrim"])

-- Spire
kattArmor.TrimPatterns.spire
	:setTexture(textures["models.Centaur.spireTrim"])

-- Tide
kattArmor.TrimPatterns.tide
	:setTexture(textures["models.Centaur.tideTrim"])

-- Vex
kattArmor.TrimPatterns.vex
	:setTexture(textures["models.Centaur.vexTrim"])

-- Ward
kattArmor.TrimPatterns.ward
	:setTexture(textures["models.Centaur.wardTrim"])

-- Wayfinder
kattArmor.TrimPatterns.wayfinder
	:setTexture(textures["models.Centaur.wayfinderTrim"])

-- Wild
kattArmor.TrimPatterns.wild
	:setTexture(textures["models.Centaur.wildTrim"])

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

-- Helmet parts
local helmetGroups = {
	
	centaurParts.headArmorHelmet,
	centaurParts.HelmetItemPivot
	
}

-- Chestplate parts
local chestplateGroups = {
	
	centaurParts.bodyArmorChestplate,
	centaurParts.leftArmArmorChestplate,
	centaurParts.rightArmArmorChestplate,
	centaurParts.leftArmArmorChestplateFP,
	centaurParts.rightArmArmorChestplateFP
	
}

-- Leggings parts
local leggingsGroups = {
	
	centaurParts.bodyArmorLeggings,
	centaurParts.MainArmorLeggings
	
}

-- Boots parts
local bootsGroups = {
	
	centaurParts.FrontLeftLegArmorBoot,
	centaurParts.FrontRightLegArmorBoot,
	centaurParts.BackLeftLegArmorBoot,
	centaurParts.BackRightLegArmorBoot
	
}

function events.RENDER(delta, context)
	
	-- Apply
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

-- All toggle
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

-- Helmet toggle
function pings.setArmorHelmet(boolean)
	
	helmet = boolean
	config:save("ArmorHelmet", helmet)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Chestplate toggle
function pings.setArmorChestplate(boolean)
	
	chestplate = boolean
	config:save("ArmorChestplate", chestplate)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Leggings toggle
function pings.setArmorLeggings(boolean)
	
	leggings = boolean
	config:save("ArmorLeggings", leggings)
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
	
end

-- Boots toggle
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

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local color     = require("scripts.ColorProperties")

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncArmor(helmet, chestplate, leggings, boots)
	end
	
end

-- Table setup
local t = {}

-- Actions
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

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.allPage
			:title(toJson
				{"",
				{text = "Toggle All Armor\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of all armor parts.", color = color.secondary}}
			)
			:toggled(helmet and chestplate and leggings and boots)
		
		t.helmetPage
			:title(toJson
				{"",
				{text = "Toggle Helmet\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of helmet parts.", color = color.secondary}}
			)
			:toggled(helmet)
		
		t.chestplatePage
			:title(toJson
				{"",
				{text = "Toggle Chestplate\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of chestplate parts.", color = color.secondary}}
			)
			:toggled(chestplate)
		
		t.leggingsPage
			:title(toJson
				{"",
				{text = "Toggle Leggings\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of leggings parts.", color = color.secondary}}
			)
			:toggled(leggings)
		
		t.bootsPage
			:title(toJson
				{"",
				{text = "Toggle Boots\n\n", bold = true, color = color.primary},
				{text = "Toggles visibility of boots.", color = color.secondary}}
			)
			:toggled(boots)
		
		for _, page in pairs(t) do
			page:hoverColor(color.hover):toggleColor(color.active)
		end
		
	end
	
end

-- Return actions
return t