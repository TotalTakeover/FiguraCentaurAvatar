-- Required script
local centaurParts = require("lib.GroupIndex")(models.models.Centaur)

-- Blank texure
local blankTexture = textures:newTexture("Blank", 64, 64)
blankTexture:fill(0, 0, 64, 64, 0, 0, 0, 0)

-- Config setup
config:name("Centaur")
local primaryType   = config:load("TexturePrimary")   or 12
local secondaryType = config:load("TextureSecondary") or 6

-- All primary textures + settings
local primaryTypes = {
	
	{ path = "horse_white",     active = false },
	{ path = "horse_gray",      active = false },
	{ path = "horse_black",     active = false },
	{ path = "horse_creamy",    active = false },
	{ path = "horse_chestnut",  active = false },
	{ path = "horse_brown",     active = false },
	{ path = "horse_darkbrown", active = false },
	{ path = "horse_zombie",    active = false },
	{ path = "horse_skeleton",  active = false },
	{ path = "donkey",          active = false },
	{ path = "mule",            active = false },
	{ path = "default",         active = false }
	
}

-- All secondary textures + settings
local secondaryTypes = {
	
	{ path = "none",                      active = false },
	{ path = "horse_markings_white",      active = false },
	{ path = "horse_markings_whitefield", active = false },
	{ path = "horse_markings_whitedots",  active = false },
	{ path = "horse_markings_blackdots",  active = false },
	{ path = "default",                   active = false }
	
}

-- Init texture setup
primaryTypes[primaryType].active     = true
secondaryTypes[secondaryType].active = true

-- Texture parts
local textureParts = {
	
	-- Upper Body
	centaurParts.HorseLeftEar.Ear,
	centaurParts.HorseRightEar.Ear,
	centaurParts.MuleLeftEar.Ear,
	centaurParts.MuleRightEar.Ear,
	centaurParts.Mane.Mane,
	
	-- Skull
	centaurParts.HorseLeftEarSkull.Ear,
	centaurParts.HorseRightEarSkull.Ear,
	centaurParts.MuleLeftEarSkull.Ear,
	centaurParts.MuleRightEarSkull.Ear,
	
	-- Lower Body
	centaurParts.Main.Body,
	centaurParts.Saddle.Saddle,
	centaurParts.LeftBag.Bag,
	centaurParts.RightBag.Bag,
	centaurParts.FrontLeftLeg.Leg,
	centaurParts.FrontRightLeg.Leg,
	centaurParts.BackLeftLeg.Leg,
	centaurParts.BackRightLeg.Leg,
	centaurParts.Tail.Tail

}

-- Set render type start on init
for _, part in ipairs(textureParts) do
	
	part:secondaryRenderType("TRANSLUCENT")
	
end

-- Set size for ears
centaurParts.HorseLeftEar:scale(1.15)
centaurParts.HorseRightEar:scale(1.15)
centaurParts.HorseLeftEarSkull:scale(1.15)
centaurParts.HorseRightEarSkull:scale(1.15)

function events.TICK()
	
	-- Apply textures
	for _, part in ipairs(textureParts) do
		
		-- If set to use primary default (12), use primary
		if primaryType == 12 then
			
			part:primaryTexture("Primary")
			
		else
			
			part:primaryTexture("Resource", "textures/entity/horse/"..primaryTypes[primaryType].path..".png")
			
		end
		
		-- If set to use primaries between 8 and 11 (special varients), or if the secondary is none (1), set to blank texture
		-- else if secondary default (6), use secondary
		if (primaryType >= 8 and primaryType <= 11) or secondaryType == 1 then
			
			part:secondaryTexture("CUSTOM", blankTexture)
			
		elseif secondaryType == 6 then
			
			part:secondaryTexture("Secondary")
			
		else
			
			part:secondaryTexture("Resource", "textures/entity/horse/"..secondaryTypes[secondaryType].path..".png")
			
		end
		
		
	end
	
	-- Apply size, ears, and mane
	local horse = primaryType ~= 10 and primaryType ~= 11
	
	centaurParts.HorseLeftEar:visible(horse)
	centaurParts.HorseRightEar:visible(horse)
	centaurParts.MuleLeftEar:visible(not horse)
	centaurParts.MuleRightEar:visible(not horse)
	
	centaurParts.HorseLeftEarSkull:visible(horse)
	centaurParts.HorseRightEarSkull:visible(horse)
	centaurParts.MuleLeftEarSkull:visible(not horse)
	centaurParts.MuleRightEarSkull:visible(not horse)
	
	centaurParts.Mane:visible(horse)
	
	centaurParts.Player:scale(horse and 1.15 or 1)
	centaurParts.UpperBody:scale(horse and 0.85 or 1)
	
	renderer:shadowRadius(horse and 0.8 or 0.75)
	
end

-- Set the primary texture
function pings.setTexturesPrimary(v)
	
	-- Resets primary settings
	for _, setting in ipairs(primaryTypes) do
		setting.active = false
	end
	
	-- Chooses primary
	primaryTypes[v].active = true
	
	-- Saves primary
	primaryType = v
	config:save("TexturePrimary", primaryType)
	
end

-- Set the secondary texture
function pings.setTexturesSecondary(v)
	
	-- Resets secondary settings
	for _, setting in ipairs(secondaryTypes) do
		setting.active = false
	end
	
	-- Chooses secondary
	secondaryTypes[v].active = true
	
	-- Saves secondary
	secondaryType = v
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
local color     = require("scripts.ColorProperties")

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncTextures(primaryType, secondaryType)
	end
	
end

-- Table setup
local t = {}

-- Actions
t.horseWhitePage = action_wheel:newAction()
	:item(itemCheck("white_dye"))
	:onLeftClick(function() pings.setTexturesPrimary(1) end)

t.horseGrayPage = action_wheel:newAction()
	:item(itemCheck("gray_dye"))
	:onLeftClick(function() pings.setTexturesPrimary(2) end)

t.horseBlackPage = action_wheel:newAction()
	:item(itemCheck("black_dye"))
	:onLeftClick(function() pings.setTexturesPrimary(3) end)

t.horseCreamyPage = action_wheel:newAction()
	:item(itemCheck("rabbit_hide"))
	:onLeftClick(function() pings.setTexturesPrimary(4) end)

t.horseChestnutPage = action_wheel:newAction()
	:item(itemCheck("oak_log"))
	:onLeftClick(function() pings.setTexturesPrimary(5) end)

t.horseBrownPage = action_wheel:newAction()
	:item(itemCheck("brown_dye"))
	:onLeftClick(function() pings.setTexturesPrimary(6) end)

t.horseDarkBrownPage = action_wheel:newAction()
	:item(itemCheck("dark_oak_log"))
	:onLeftClick(function() pings.setTexturesPrimary(7) end)

t.horseZombiePage = action_wheel:newAction()
	:item(itemCheck("rotten_flesh"))
	:onLeftClick(function() pings.setTexturesPrimary(8) end)

t.horseSkeletonPage = action_wheel:newAction()
	:item(itemCheck("bone"))
	:onLeftClick(function() pings.setTexturesPrimary(9) end)

t.donkeyPage = action_wheel:newAction()
	:item(itemCheck("lead"))
	:onLeftClick(function() pings.setTexturesPrimary(10) end)

t.mulePage = action_wheel:newAction()
	:item(itemCheck("chest"))
	:onLeftClick(function() pings.setTexturesPrimary(11) end)

t.horseDefaultPage = action_wheel:newAction()
	:item(itemCheck("player_head{'SkullOwner':'"..avatar:getEntityName().."'}"))
	:onLeftClick(function() pings.setTexturesPrimary(12) end)

t.horseMarkingsBlankPage = action_wheel:newAction()
	:item(itemCheck("glass_bottle"))
	:onLeftClick(function() pings.setTexturesSecondary(1) end)

t.horseMarkingsWhitePage = action_wheel:newAction()
	:item(itemCheck("paper"))
	:onLeftClick(function() pings.setTexturesSecondary(2) end)

t.horseMarkingsWhiteFieldPage = action_wheel:newAction()
	:item(itemCheck("snow"))
	:onLeftClick(function() pings.setTexturesSecondary(3) end)

t.horseMarkingsWhiteDotsPage = action_wheel:newAction()
	:item(itemCheck("snowball"))
	:onLeftClick(function() pings.setTexturesSecondary(4) end)

t.horseMarkingsBlackDotsPage = action_wheel:newAction()
	:item(itemCheck("sculk_vein"))
	:onLeftClick(function() pings.setTexturesSecondary(5) end)

t.horseMarkingsDefaultPage = action_wheel:newAction()
	:item(itemCheck("player_head{'SkullOwner':'"..avatar:getEntityName().."'}"))
	:onLeftClick(function() pings.setTexturesSecondary(6) end)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		t.horseWhitePage
			:title(toJson
				{"",
				{text = "Set Primary Horse White\n\n", bold = true, color = color.primary},
				{text = "Sets the lower body to use the \"Horse White\" vanilla texture.", color = color.secondary}}
			)
			:toggled(primaryTypes[1].active)
		
		t.horseGrayPage
			:title(toJson
				{"",
				{text = "Set Primary Horse Gray\n\n", bold = true, color = color.primary},
				{text = "Sets the lower body to use the \"Horse Gray\" vanilla texture.", color = color.secondary}}
			)
			:toggled(primaryTypes[2].active)
		
		t.horseBlackPage
			:title(toJson
				{"",
				{text = "Set Primary Horse Black\n\n", bold = true, color = color.primary},
				{text = "Sets the lower body to use the \"Horse Black\" vanilla texture.", color = color.secondary}}
			)
			:toggled(primaryTypes[3].active)
		
		t.horseCreamyPage
			:title(toJson
				{"",
				{text = "Set Primary Horse Creamy\n\n", bold = true, color = color.primary},
				{text = "Sets the lower body to use the \"Horse Creamy\" vanilla texture.", color = color.secondary}}
			)
			:toggled(primaryTypes[4].active)
		
		t.horseChestnutPage
			:title(toJson
				{"",
				{text = "Set Primary Horse Chestnut\n\n", bold = true, color = color.primary},
				{text = "Sets the lower body to use the \"Horse Chestnut\" vanilla texture.", color = color.secondary}}
			)
			:toggled(primaryTypes[5].active)
		
		t.horseBrownPage
			:title(toJson
				{"",
				{text = "Set Primary Horse Brown\n\n", bold = true, color = color.primary},
				{text = "Sets the lower body to use the \"Horse Brown\" vanilla texture.", color = color.secondary}}
			)
			:toggled(primaryTypes[6].active)
		
		t.horseDarkBrownPage
			:title(toJson
				{"",
				{text = "Set Primary Horse Dark Brown\n\n", bold = true, color = color.primary},
				{text = "Sets the lower body to use the \"Horse Dark Brown\" vanilla texture.", color = color.secondary}}
			)
			:toggled(primaryTypes[7].active)
		
		t.horseZombiePage
			:title(toJson
				{"",
				{text = "Set Primary Horse Zombie\n\n", bold = true, color = color.primary},
				{text = "Sets the lower body to use the \"Horse Zombie\" vanilla texture.", color = color.secondary}}
			)
			:toggled(primaryTypes[8].active)
		
		t.horseSkeletonPage
			:title(toJson
				{"",
				{text = "Set Primary Horse Skeleton\n\n", bold = true, color = color.primary},
				{text = "Sets the lower body to use the \"Horse Skeleton\" vanilla texture.", color = color.secondary}}
			)
			:toggled(primaryTypes[9].active)
		
		t.donkeyPage
			:title(toJson
				{"",
				{text = "Set Primary Donkey\n\n", bold = true, color = color.primary},
				{text = "Sets the lower body to use the \"Donkey\" vanilla texture.", color = color.secondary}}
			)
			:toggled(primaryTypes[10].active)
		
		t.mulePage
			:title(toJson
				{"",
				{text = "Set Primary Mule\n\n", bold = true, color = color.primary},
				{text = "Sets the lower body to use the \"Mule\" vanilla texture.", color = color.secondary}}
			)
			:toggled(primaryTypes[11].active)
		
		t.horseDefaultPage
			:title(toJson
				{"",
				{text = "Set Primary Horse Default\n\n", bold = true, color = color.primary},
				{text = "Sets the lower body to use the default blockbench texture.", color = color.secondary}}
			)
			:toggled(primaryTypes[12].active)
		
		t.horseMarkingsBlankPage
			:title(toJson
				{"",
				{text = "Disable Secondary\n\n", bold = true, color = color.primary},
				{text = "Sets the lower body to not use a secondary texture.", color = color.secondary}}
			)
			:toggled(secondaryTypes[1].active)
		
		t.horseMarkingsWhitePage
			:title(toJson
				{"",
				{text = "Set Secondary White\n\n", bold = true, color = color.primary},
				{text = "Sets the lower body to use the \"White\" vanilla texture.", color = color.secondary}}
			)
			:toggled(secondaryTypes[2].active)
		
		t.horseMarkingsWhiteFieldPage
			:title(toJson
				{"",
				{text = "Set Secondary White Field\n\n", bold = true, color = color.primary},
				{text = "Sets the lower body to use the \"White Field\" vanilla texture.", color = color.secondary}}
			)
			:toggled(secondaryTypes[3].active)
		
		t.horseMarkingsWhiteDotsPage
			:title(toJson
				{"",
				{text = "Set Secondary White Dots\n\n", bold = true, color = color.primary},
				{text = "Sets the lower body to use the \"White Dots\" vanilla texture.", color = color.secondary}}
			)
			:toggled(secondaryTypes[4].active)
		
		t.horseMarkingsBlackDotsPage
			:title(toJson
				{"",
				{text = "Set Secondary Black Dots\n\n", bold = true, color = color.primary},
				{text = "Sets the lower body to use the \"Black Dots\" vanilla texture.", color = color.secondary}}
			)
			:toggled(secondaryTypes[5].active)
		
		t.horseMarkingsDefaultPage
			:title(toJson
				{"",
				{text = "Set Secondary Default\n\n", bold = true, color = color.primary},
				{text = "Sets the lower body to use the default blockbench texture.", color = color.secondary}}
			)
			:toggled(secondaryTypes[6].active)
		
		for _, page in pairs(t) do
			page:hoverColor(color.hover):toggleColor(color.active)
		end
		
	end
	
end

-- Return actions
return t