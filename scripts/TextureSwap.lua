-- Required script
local parts = require("lib.PartsAPI")

-- Blank texure
local blankTexture = textures:newTexture("Blank", 64, 64)
blankTexture:fill(0, 0, 64, 64, 0, 0, 0, 0)

-- Config setup
config:name("Centaur")
local primaryType   = config:load("TexturePrimary")   or 1
local secondaryType = config:load("TextureSecondary") or 2

-- All primary textures
local primaryTypes = {
	
	"default",
	"horse_white",
	"horse_gray",
	"horse_black",
	"horse_creamy",
	"horse_chestnut",
	"horse_brown",
	"horse_darkbrown",
	"horse_zombie",
	"horse_skeleton",
	"donkey",
	"mule"
	
}

-- All secondary textures
local secondaryTypes = {
	
	"none",
	"default",
	"horse_markings_white",
	"horse_markings_whitefield",
	"horse_markings_whitedots",
	"horse_markings_blackdots"
	
}

-- Reset if types is out of bounds
if primaryType > #primaryTypes then
	primaryType = 1
end
if secondaryType > #secondaryTypes then
	secondaryType = 2
end

-- Texture parts
local textureParts = parts:createTable(function(part) return part:getName():find("_[sS]wap") end)

-- Set render type start on init
for _, part in ipairs(textureParts) do
	
	part:secondaryRenderType("TRANSLUCENT")
	
end

-- Set size for ears
parts.group.HorseLeftEar:scale(1.15)
parts.group.HorseRightEar:scale(1.15)
parts.group.HorseLeftEarSkull:scale(1.15)
parts.group.HorseRightEarSkull:scale(1.15)

function events.TICK()
	
	-- Apply textures
	for _, part in ipairs(textureParts) do
		
		-- If set to use primary default (1), use primary
		if primaryType == 1 then
			
			part:primaryTexture("Primary")
			
		else
			
			part:primaryTexture("Resource", "textures/entity/horse/"..primaryTypes[primaryType]..".png")
			
		end
		
		-- If set to use primaries between 8 and 11 (special varients), or if the secondary is none (1), set to blank texture
		-- else if secondary default (6), use secondary
		if primaryType >= 9 or secondaryType == 1 then
			
			part:secondaryTexture("CUSTOM", blankTexture)
			
		elseif secondaryType == 2 then
			
			part:secondaryTexture("Secondary")
			
		else
			
			part:secondaryTexture("Resource", "textures/entity/horse/"..secondaryTypes[secondaryType]..".png")
			
		end
		
		
	end
	
	-- Apply size, ears, and mane
	local horse = primaryType < 11
	
	parts.group.HorseLeftEar:visible(horse)
	parts.group.HorseRightEar:visible(horse)
	parts.group.MuleLeftEar:visible(not horse)
	parts.group.MuleRightEar:visible(not horse)
	
	parts.group.HorseLeftEarSkull:visible(horse)
	parts.group.HorseRightEarSkull:visible(horse)
	parts.group.MuleLeftEarSkull:visible(not horse)
	parts.group.MuleRightEarSkull:visible(not horse)
	
	parts.group.Mane:visible(horse)
	
	parts.group.Player:scale(horse and 1.15 or 1)
	parts.group.UpperBody:scale(horse and 0.85 or 1)
	
	renderer:shadowRadius(horse and 0.8 or 0.75)
	
end

-- Set the primary texture
function pings.setTexturesPrimary(i)
	
	-- Saves primary
	primaryType = ((primaryType + i - 1) % #primaryTypes) + 1
	config:save("TexturePrimary", primaryType)
	
end

-- Set the secondary texture
function pings.setTexturesSecondary(i)
	
	-- Saves secondary
	secondaryType = ((secondaryType + i - 1) % #secondaryTypes) + 1
	config:save("TextureSecondary", secondaryType)
	
end

-- Sync variables
function pings.syncTextures(a, b)
	
	primaryType   = a
	secondaryType = b
	
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
		pings.syncTextures(primaryType, secondaryType)
	end
	
end

-- Table setup
local t = {}

-- Actions
t.primaryAct = action_wheel:newAction()
	:onLeftClick(function() pings.setTexturesPrimary(1) end)
	:onRightClick(function() pings.setTexturesPrimary(-1) end)
	:onScroll(pings.setTexturesPrimary)

t.secondaryAct = action_wheel:newAction()
	:onLeftClick(function() pings.setTexturesSecondary(1) end)
	:onRightClick(function() pings.setTexturesSecondary(-1) end)
	:onScroll(pings.setTexturesSecondary)

-- Primary info table
local primaryInfo = {
	{
		title = "Default",
		text  = "its default",
		item  = itemCheck("player_head{SkullOwner:"..avatar:getEntityName().."}")
	},
	{
		title = "White",
		text  = "the \"Horse White\" vanilla",
		item  = itemCheck("white_dye")
	},
	{
		title = "Gray",
		text  = "the \"Horse Gray\" vanilla",
		item  = itemCheck("gray_dye")
	},
	{
		title = "Black",
		text  = "the \"Horse Black\" vanilla",
		item  = itemCheck("black_dye")
	},
	{
		title = "Creamy",
		text  = "the \"Horse Creamy\" vanilla",
		item  = itemCheck("rabbit_hide")
	},
	{
		title = "Chestnut",
		text  = "the \"Horse Chestnut\" vanilla",
		item  = itemCheck("oak_log")
	},
	{
		title = "Brown",
		text  = "the \"Horse Brown\" vanilla",
		item  = itemCheck("brown_dye")
	},
	{
		title = "Dark Brown",
		text  = "the \"Horse Dark Brown\" vanilla",
		item  = itemCheck("dark_oak_log")
	},
	{
		title = "Zombie",
		text  = "the \"Zombie\" vanilla",
		item  = itemCheck("rotten_flesh")
	},
	{
		title = "Skeleton",
		text  = "the \"Skeleton\" vanilla",
		item  = itemCheck("bone")
	},
	{
		title = "Mule",
		text  = "the \"Mule\" vanilla",
		item  = itemCheck("lead")
	},
	{
		title = "Donkey",
		text  = "the \"Donkey\" vanilla",
		item  = itemCheck("chest")
	}
}

-- Secondary info table
local secondaryInfo = {
	{
		title = "Disabled",
		text  = "not use a",
		item  = itemCheck("glass_bottle")
	},
	{
		title = "Default",
		text  = "use its default",
		item  = itemCheck("player_head{SkullOwner:"..avatar:getEntityName().."}")
	},
	{
		title = "White",
		text  = "use the \"White\" vanilla",
		item  = itemCheck("paper")
	},
	{
		title = "White Field",
		text  = "use the \"White Field\" vanilla",
		item  = itemCheck("snow")
	},
	{
		title = "White Dots",
		text  = "use the \"White Dots\" vanilla",
		item  = itemCheck("snowball")
	},
	{
		title = "Black Dots",
		text  = "use the \"Black Dots\" vanilla",
		item  = itemCheck("sculk_vein")
	}
}

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.primaryAct
			:title(toJson(
				{
					"",
					{text = ("Primary: %s\n\n"):format(primaryInfo[primaryType].title), bold = true, color = c.primary},
					{text = ("Sets the lower body to use %s primary texture."):format(primaryInfo[primaryType].text), color = c.secondary}
				}
			))
			:item(primaryInfo[primaryType].item)
		
		t.secondaryAct
			:title(toJson(
				{
					"",
					{text = ("Secondary: %s\n\n"):format(secondaryInfo[secondaryType].title), bold = true, color = c.primary},
					{text = ("Sets the lower body to %s secondary texture."):format(secondaryInfo[secondaryType].text), color = c.secondary}
				}
			))
			:item(secondaryInfo[secondaryType].item)
		
		for _, act in pairs(t) do
			act:hoverColor(c.hover)
		end
		
	end
	
end

-- Return actions
return t