-- Required scripts
local parts = require("lib.PartsAPI")
local origins = require("lib.OriginsAPI")

-- Blank texure
local blankTexture = textures:newTexture("Blank", 64, 64)
blankTexture:fill(0, 0, 64, 64, 0, 0, 0, 0)

-- All primary textures
local primaryTypes = {
	
	{
		name  = "default",
		color = vectors.hexToRGB(avatar:getColor() or "default")
	},
	{
		name  = "horse_white",
		color = vectors.hexToRGB("BDBDBD")
	},
	{
		name  = "horse_gray",
		color = vectors.hexToRGB("4B4B4B")
	},
	{
		name  = "horse_black",
		color = vectors.hexToRGB("1A1C21")
	},
	{
		name  = "horse_creamy",
		color = vectors.hexToRGB("744A1B")
	},
	{
		name  = "horse_chestnut",
		color = vectors.hexToRGB("642914")
	},
	{
		name  = "horse_brown",
		color = vectors.hexToRGB("431D09")
	},
	{
		name  = "horse_darkbrown",
		color = vectors.hexToRGB("23120B")
	},
	{
		name  = "horse_zombie",
		color = vectors.hexToRGB("578853")
	},
	{
		name  = "horse_skeleton",
		color = vectors.hexToRGB("D4D4D4")
	},
	{
		name  = "donkey",
		color = vectors.hexToRGB("736355")
	},
	{
		name  = "mule",
		color = vectors.hexToRGB("3A2017")
	}
	
}

-- All secondary textures
local secondaryTypes = {
	
	"default",
	"none",
	"horse_markings_white",
	"horse_markings_whitefield",
	"horse_markings_whitedots",
	"horse_markings_blackdots"
	
}

-- Config setup
config:name("Centaur")
local uuidSeed = vec(client.uuidToIntArray(avatar:getUUID()))
local primaryType   = config:load("TexturePrimary") or uuidSeed.x % (#primaryTypes - 1) + 2
local secondaryType = config:load("TextureSecondary") or uuidSeed.y % (#secondaryTypes - 1) + 2
local originType    = config:load("TextureOrigin")
if originType == nil then originType = true end

-- Reset if types is out of bounds
if primaryType > #primaryTypes then
	primaryType = 1
end
if secondaryType > #secondaryTypes then
	secondaryType = 1
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

-- Check origin
local function isOrigin(s)
	
	return origins.hasOrigin(player, s)
	
end

function events.RENDER(delta, context)
	
	-- Variables
	local primaryString = primaryTypes[primaryType].name
	local secondaryString = secondaryTypes[secondaryType]
	local isZombie, isSkeleton = isOrigin("centaur:zombified_centaur"), isOrigin("centaur:skeletonized_centaur")
	local originOverride = originType and (isZombie or isSkeleton)
	
	-- Apply textures
	for _, part in ipairs(textureParts) do
		
		-- If originOverride, use special varient
		-- else if set to use primary default, use primary
		if originOverride then
			
			part:primaryTexture("Resource", "textures/entity/horse/"..(isZombie and "horse_zombie" or isSkeleton and "horse_skeleton")..".png")
			
		elseif primaryString == "default" then
			
			part:primaryTexture("Primary")
			
		else
			
			part:primaryTexture("Resource", "textures/entity/horse/"..primaryString..".png")
			
		end
		
		-- If set to use primaries special varients, or if the secondary is none, set to blank texture
		-- else if secondary default, use secondary
		if originOverride or secondaryString == "none" or primaryString == "horse_zombie" or primaryString == "horse_skeleton" or primaryString == "donkey" or primaryString == "mule" then
			
			part:secondaryTexture("CUSTOM", blankTexture)
			
		elseif secondaryString == "default" then
			
			part:secondaryTexture("Secondary")
			
		else
			
			part:secondaryTexture("Resource", "textures/entity/horse/"..secondaryString..".png")
			
		end
		
		
	end
	
	-- Glowing outline
	renderer:outlineColor(primaryTypes[primaryType].color)
	
	-- Avatar color
	avatar:color(primaryTypes[primaryType].color)
	
	-- Apply size, ears, and mane
	local horse = originOverride or (primaryString ~= "donkey" and primaryString ~= "mule")
	
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

-- Set the origin toggle
function pings.setOriginTextures(boolean)
	
	originType = boolean
	config:save("TextureOrigin", originType)
	
end

-- Sync variables
function pings.syncTextures(a, b, c)
	
	primaryType   = a
	secondaryType = b
	originType    = c
	
end

-- Host only instructions
if not host:isHost() then return end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncTextures(primaryType, secondaryType, originType)
	end
	
end

-- Required scripts
local s, wheel, itemCheck, c = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found
pcall(require, "scripts.Accessories") -- Tries to find script, not required


-- Dont preform if color properties is empty
if next(c) ~= nil then
	
	-- Store init colors
	local initColors = {}
	for k, v in pairs(c) do
		initColors[k] = v
	end
	
	-- Update action wheel colors
	function events.RENDER(delta, context)
		
		-- Variable
		local color = primaryTypes[primaryType].color
		
		-- Create mermod colors
		local appliedColors = {
			hover     = color,
			active    = (color + 0.25):applyFunc(function(a) return math.min(a, 1) end),
			primary   = "#"..vectors.rgbToHex(color),
			secondary = "#"..vectors.rgbToHex((color):applyFunc(function(a) return math.min(a, 1) end))
		}
		
		-- Update action wheel colors
		for k in pairs(c) do
			c[k] = appliedColors[k]
		end
		
	end
	
end

-- Pages
local parentPage  = action_wheel:getPage("Centaur") or action_wheel:getPage("Main")
local texturePage = action_wheel:newPage("Texture")

-- Actions table setup
local a = {}

-- Actions
a.pageAct = parentPage:newAction()
	:item(itemCheck("brush"))
	:onLeftClick(function() wheel:descend(texturePage) end)

a.primaryAct = texturePage:newAction()
	:onLeftClick(function() pings.setTexturesPrimary(1) end)
	:onRightClick(function() pings.setTexturesPrimary(-1) end)
	:onScroll(pings.setTexturesPrimary)

a.secondaryAct = texturePage:newAction()
	:onLeftClick(function() pings.setTexturesSecondary(1) end)
	:onRightClick(function() pings.setTexturesSecondary(-1) end)
	:onScroll(pings.setTexturesSecondary)

a.originAct = texturePage:newAction()
	:item(itemCheck("ender_pearl"))
	:toggleItem(itemCheck("origins:orb_of_origin", "snowball"))
	:onToggle(pings.setOriginTextures)
	:toggled(originType)

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
		title = "Donkey",
		text  = "the \"Donkey\" vanilla",
		item  = itemCheck("chest")
	},
	{
		title = "Mule",
		text  = "the \"Mule\" vanilla",
		item  = itemCheck("lead")
	}
}

-- Secondary info table
local secondaryInfo = {
	{
		title = "Default",
		text  = "use its default",
		item  = itemCheck("player_head{SkullOwner:"..avatar:getEntityName().."}")
	},
	{
		title = "Disabled",
		text  = "not use a",
		item  = itemCheck("glass_bottle")
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
		a.pageAct
			:title(toJson(
				{text = "Texture Settings", bold = true, color = c.primary}
			))
		
		a.primaryAct
			:title(toJson(
				{
					"",
					{text = ("Primary: %s\n\n"):format(primaryInfo[primaryType].title), bold = true, color = c.primary},
					{text = ("Sets the lower body to use %s primary texture."):format(primaryInfo[primaryType].text), color = c.secondary}
				}
			))
			:item(primaryInfo[primaryType].item)
		
		a.secondaryAct
			:title(toJson(
				{
					"",
					{text = ("Secondary: %s\n\n"):format(secondaryInfo[secondaryType].title), bold = true, color = c.primary},
					{text = ("Sets the lower body to %s secondary texture."):format(secondaryInfo[secondaryType].text), color = c.secondary}
				}
			))
			:item(secondaryInfo[secondaryType].item)
		
		a.originAct
			:title(toJson(
				{
					"",
					{text = "Toggle Origin Override\n\n", bold = true, color = c.primary},
					{text = "Allow your origin to override your chosen texture.", color = c.secondary}
				}
			))
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover)
		end
		
	end
	
end