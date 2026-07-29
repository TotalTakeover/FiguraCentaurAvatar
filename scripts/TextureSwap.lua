-- Required scripts
local parts   = require("lib.PartsAPI")
local sync    = require("lib.LetThatSyncFig")
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

-- Synced variables setup
local uuidSeed      = vec(client.uuidToIntArray(avatar:getUUID()))
local primaryType   = sync.new("TexturePrimary",   uuidSeed.x % (#primaryTypes   - 1) + 2):config()
local secondaryType = sync.new("TextureSecondary", uuidSeed.y % (#secondaryTypes - 1) + 2):config()
local originType    = sync.new("TextureOrigin", true):config()

-- Reset if types is out of bounds
if primaryType.curr > #primaryTypes then
	primaryType.curr = 1
end
if secondaryType.curr > #secondaryTypes then
	secondaryType.curr = 1
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

function events.RENDER(delta, context)
	
	-- Variables
	local primaryString = primaryTypes[primaryType.curr].name
	local secondaryString = secondaryTypes[secondaryType.curr]
	local isZombie, isSkeleton = origins.hasOrigin(player, "centaur:zombified_centaur"), origins.hasOrigin(player, "centaur:skeletonized_centaur")
	local originOverride = originType.curr and (isZombie or isSkeleton)
	
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
	renderer:outlineColor(primaryTypes[primaryType.curr].color)
	
	-- Avatar color
	avatar:color(primaryTypes[primaryType.curr].color)
	
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
	primaryType.curr = ((primaryType.curr + i - 1) % #primaryTypes) + 1
	config:save("TexturePrimary", primaryType.curr)
	
end

-- Set the secondary texture
function pings.setTexturesSecondary(i)
	
	-- Saves secondary
	secondaryType.curr = ((secondaryType.curr + i - 1) % #secondaryTypes) + 1
	config:save("TextureSecondary", secondaryType.curr)
	
end

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local s, pageNav, c = pcall(require, "scripts.ActionWheel")
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
		local color = primaryTypes[primaryType.curr].color
		
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

-- Set texture
local function setTexture(tex, limit, i)
	return ((tex + i - 1) % limit) + 1
end

-- Actions
a.pageAct = parentPage:newAction()
	:item("brush")
	:onLeftClick(function() pageNav.descend(texturePage) end)

a.primaryAct = texturePage:newAction()
	:onLeftClick(function() primaryType:update(setTexture(primaryType.curr, #primaryTypes, 1)) end)
	:onRightClick(function() primaryType:update(setTexture(primaryType.curr, #primaryTypes, 1)) end)
	:onScroll(function(x) primaryType:update(setTexture(primaryType.curr, #primaryTypes, x), 20) end)

a.secondaryAct = texturePage:newAction()
	:onLeftClick(function() secondaryType:update(setTexture(secondaryType.curr, #secondaryTypes, 1)) end)
	:onRightClick(function() secondaryType:update(setTexture(secondaryType.curr, #secondaryTypes, 1)) end)
	:onScroll(function(x) secondaryType:update(setTexture(secondaryType.curr, #secondaryTypes, x), 20) end)

a.originAct = texturePage:newAction()
	:item("ender_pearl")
	:toggleItem("origins:orb_of_origin", "snowball")
	:onToggle(function(bool)
		originType:update(bool)
	end)
	:toggled(originType.curr)

-- Primary info table
local primaryInfo = {
	{
		title = "Default",
		text  = "its default",
		item  = "player_head{SkullOwner:"..avatar:getEntityName().."}"
	},
	{
		title = "White",
		text  = "the \"Horse White\" vanilla",
		item  = "white_dye"
	},
	{
		title = "Gray",
		text  = "the \"Horse Gray\" vanilla",
		item  = "gray_dye"
	},
	{
		title = "Black",
		text  = "the \"Horse Black\" vanilla",
		item  = "black_dye"
	},
	{
		title = "Creamy",
		text  = "the \"Horse Creamy\" vanilla",
		item  = "rabbit_hide"
	},
	{
		title = "Chestnut",
		text  = "the \"Horse Chestnut\" vanilla",
		item  = "oak_log"
	},
	{
		title = "Brown",
		text  = "the \"Horse Brown\" vanilla",
		item  = "brown_dye"
	},
	{
		title = "Dark Brown",
		text  = "the \"Horse Dark Brown\" vanilla",
		item  = "dark_oak_log"
	},
	{
		title = "Zombie",
		text  = "the \"Zombie\" vanilla",
		item  = "rotten_flesh"
	},
	{
		title = "Skeleton",
		text  = "the \"Skeleton\" vanilla",
		item  = "bone"
	},
	{
		title = "Donkey",
		text  = "the \"Donkey\" vanilla",
		item  = "chest"
	},
	{
		title = "Mule",
		text  = "the \"Mule\" vanilla",
		item  = "lead"
	}
}

-- Secondary info table
local secondaryInfo = {
	{
		title = "Default",
		text  = "use its default",
		item  = "player_head{SkullOwner:"..avatar:getEntityName().."}"
	},
	{
		title = "Disabled",
		text  = "not use a",
		item  = "glass_bottle"
	},
	{
		title = "White",
		text  = "use the \"White\" vanilla",
		item  = "paper"
	},
	{
		title = "White Field",
		text  = "use the \"White Field\" vanilla",
		item  = "snow"
	},
	{
		title = "White Dots",
		text  = "use the \"White Dots\" vanilla",
		item  = "snowball"
	},
	{
		title = "Black Dots",
		text  = "use the \"Black Dots\" vanilla",
		item  = "sculk_vein"
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
					{text = ("Primary: %s\n\n"):format(primaryInfo[primaryType.curr].title), bold = true, color = c.primary},
					{text = ("Sets the lower body to use %s primary texture."):format(primaryInfo[primaryType.curr].text), color = c.secondary}
				}
			))
			:item(primaryInfo[primaryType.curr].item)
		
		a.secondaryAct
			:title(toJson(
				{
					"",
					{text = ("Secondary: %s\n\n"):format(secondaryInfo[secondaryType.curr].title), bold = true, color = c.primary},
					{text = ("Sets the lower body to %s secondary texture."):format(secondaryInfo[secondaryType.curr].text), color = c.secondary}
				}
			))
			:item(secondaryInfo[secondaryType.curr].item)
		
		a.originAct
			:title(toJson(
				{
					"",
					{text = "Toggle Origin Override\n\n", bold = true, color = c.primary},
					{text = "Allow your origin to override your chosen texture.", color = c.secondary}
				}
			))
		
		for _, act in pairs(a) do
			act:hoverColor(c.hover):toggleColor(c.active)
		end
		
	end
	
end