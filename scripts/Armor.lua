-- Required scripts
local parts        = require("lib.PartsAPI")
local centaurArmor = require("lib.KattArmor")()
local sync         = require("lib.LetThatSyncFig")

-- Synced variables setup
local helmet     = sync.new("ArmorHelmet", true):config()
local chestplate = sync.new("ArmorChestplate", true):config()
local leggings   = sync.new("ArmorLeggings", true):config()
local boots      = sync.new("ArmorBoots", true):config()

-- Setting the leggings to layer 1
centaurArmor.Armor.Leggings:setLayer(1)

-- Armor parts
centaurArmor.Armor.Helmet
	:addParts(table.unpack(parts:createTable(function(part) return part:getName() == "Helmet" end)))
	:addTrimParts(table.unpack(parts:createTable(function(part) return part:getName() == "HelmetTrim" end)))
centaurArmor.Armor.Chestplate
	:addParts(table.unpack(parts:createTable(function(part) return part:getName() == "Chestplate" end)))
	:addTrimParts(table.unpack(parts:createTable(function(part) return part:getName() == "ChestplateTrim" end)))
centaurArmor.Armor.Leggings
	:addParts(table.unpack(parts:createTable(function(part) return part:getName() == "Leggings" end)))
	:addTrimParts(table.unpack(parts:createTable(function(part) return part:getName() == "LeggingsTrim" end)))
centaurArmor.Armor.Boots
	:addParts(table.unpack(parts:createTable(function(part) return part:getName() == "Boot" end)))
	:addTrimParts(table.unpack(parts:createTable(function(part) return part:getName() == "BootTrim" end)))

-- Leather armor
centaurArmor.Materials.leather
	:setTexture(textures["textures.armor.leatherArmor"] or textures["Centaur.leatherArmor"])
	:addParts(centaurArmor.Armor.Helmet,     table.unpack(parts:createTable(function(part) return part:getName() == "HelmetLeather" end)))
	:addParts(centaurArmor.Armor.Chestplate, table.unpack(parts:createTable(function(part) return part:getName() == "ChestplateLeather" end)))
	:addParts(centaurArmor.Armor.Leggings,   table.unpack(parts:createTable(function(part) return part:getName() == "LeggingsLeather" end)))
	:addParts(centaurArmor.Armor.Boots,      table.unpack(parts:createTable(function(part) return part:getName() == "BootLeather" end)))

-- Chainmail armor
centaurArmor.Materials.chainmail
	:setTexture(textures["textures.armor.chainmailArmor"] or textures["Centaur.chainmailArmor"])

-- Iron armor
centaurArmor.Materials.iron
	:setTexture(textures["textures.armor.ironArmor"] or textures["Centaur.ironArmor"])

-- Golden armor
centaurArmor.Materials.golden
	:setTexture(textures["textures.armor.goldenArmor"] or textures["Centaur.goldenArmor"])

-- Diamond armor
centaurArmor.Materials.diamond
	:setTexture(textures["textures.armor.diamondArmor"] or textures["Centaur.diamondArmor"])

-- Netherite armor
centaurArmor.Materials.netherite
	:setTexture(textures["textures.armor.netheriteArmor"] or textures["Centaur.netheriteArmor"])

-- Turtle helmet
centaurArmor.Materials.turtle
	:setTexture(textures["textures.armor.turtleHelmet"] or textures["Centaur.turtleHelmet"])

-- Trims
local trims = {
	"bolt",
	"coast",
	"dune",
	"eye",
	"flow",
	"host",
	"raiser",
	"rib",
	"sentry",
	"shaper",
	"silence",
	"snout",
	"spire",
	"tide",
	"vex",
	"ward",
	"wayfinder",
	"wild"
}

-- Apply trims
for _, trim in ipairs(trims) do
	local tex = textures["textures.armor.trims."..trim.."Trim"] or textures["Centaur."..trim.."Trim"] or false
	if tex then
		centaurArmor.TrimPatterns[trim]:setTexture(tex)
	end
end

-- Helmet parts
local helmetGroups = parts:createTable(function(part) return part:getName():find("ArmorHelmet") end)

-- Chestplate parts
local chestplateGroups = parts:createTable(function(part) return part:getName():find("ArmorChestplate") end)

-- Leggings parts
local leggingsGroups = parts:createTable(function(part) return part:getName():find("ArmorLeggings") end)

-- Boots parts
local bootsGroups = parts:createTable(function(part) return part:getName():find("ArmorBoot") end)

function events.RENDER(delta, context)
	
	-- Apply
	for _, part in ipairs(helmetGroups) do
		part:visible(helmet.curr)
	end
	
	for _, part in ipairs(chestplateGroups) do
		part:visible(chestplate.curr)
	end
	
	for _, part in ipairs(leggingsGroups) do
		part:visible(leggings.curr)
	end
	
	for _, part in ipairs(bootsGroups) do
		part:visible(boots.curr)
	end
	
	-- Increase saddle scale to fit armor
	parts.group.Saddle:scale(parts.group.MainArmorLeggings.Leggings:getVisible() and 1 or 0.95)
	
end

-- Play sound if toggling armor
local function equipSound()
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
end

-- Apply sound to sync updates
helmet:applyFunc(equipSound)
chestplate:applyFunc(equipSound)
leggings:applyFunc(equipSound)
boots:applyFunc(equipSound)

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local s, wheel, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.Player") -- Tries to find script, not required

-- Pages
local parentPage = action_wheel:getPage("Player") or action_wheel:getPage("Main")
local armorPage  = action_wheel:newPage("Armor")

-- Actions table setup
local a = {}

-- Actions
a.pageAct = parentPage:newAction()
	:item("iron_chestplate")
	:onLeftClick(function() wheel:descend(armorPage) end)

a.allAct = armorPage:newAction()
	:item("armor_stand")
	:toggleItem("netherite_chestplate")
	:onToggle(function(bool)
		helmet:update(bool)
		chestplate:update(bool)
		leggings:update(bool)
		boots:update(bool)
	end)

a.helmetAct = armorPage:newAction()
	:item("iron_helmet")
	:toggleItem("diamond_helmet")
	:onToggle(function(bool)
		helmet:update(bool)
	end)

a.chestplateAct = armorPage:newAction()
	:item("iron_chestplate")
	:toggleItem("diamond_chestplate")
	:onToggle(function(bool)
		chestplate:update(bool)
	end)

a.leggingsAct = armorPage:newAction()
	:item("iron_leggings")
	:toggleItem("diamond_leggings")
	:onToggle(function(bool)
		leggings:update(bool)
	end)

a.bootsAct = armorPage:newAction()
	:item("iron_boots")
	:toggleItem("diamond_boots")
	:onToggle(function(bool)
		boots:update(bool)
	end)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		a.pageAct
			:title(toJson(
				{text = "Armor Settings", bold = true, color = c.primary}
			))
		
		a.allAct
			:title(toJson(
				{
					"",
					{text = "Toggle All Armor\n\n", bold = true, color = c.primary},
					{text = "Toggles visibility of all armor parts.", color = c.secondary}
				}
			))
			:toggled(helmet.curr and chestplate.curr and leggings.curr and boots.curr)
		
		a.helmetAct
			:title(toJson(
				{
					"",
					{text = "Toggle Helmet\n\n", bold = true, color = c.primary},
					{text = "Toggles visibility of helmet parts.", color = c.secondary}
				}
			))
			:toggled(helmet.curr)
		
		a.chestplateAct
			:title(toJson(
				{
					"",
					{text = "Toggle Chestplate\n\n", bold = true, color = c.primary},
					{text = "Toggles visibility of chestplate parts.", color = c.secondary}
				}
			))
			:toggled(chestplate.curr)
		
		a.leggingsAct
			:title(toJson(
				{
					"",
					{text = "Toggle Leggings\n\n", bold = true, color = c.primary},
					{text = "Toggles visibility of leggings parts.", color = c.secondary}
				}
			))
			:toggled(leggings.curr)
		
		a.bootsAct
			:title(toJson(
				{
					"",
					{text = "Toggle Boots\n\n", bold = true, color = c.primary},
					{text = "Toggles visibility of boots.", color = c.secondary}
				}
			))
			:toggled(boots.curr)
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end