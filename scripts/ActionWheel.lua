-- Disables code if not avatar host
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local avatar    = require("scripts.Player")
local armor     = require("scripts.Armor")
local camera    = require("scripts.CameraControl")
local accessory = require("scripts.Accessories")
local texture   = require("scripts.TextureSwap")
local anims     = require("scripts.Anims")
local arms      = require("scripts.Arms")
local color     = require("scripts.ColorProperties")

-- Logs pages for navigation
local navigation = {}

-- Go forward a page
local function descend(page)
	
	navigation[#navigation + 1] = action_wheel:getCurrentPage() 
	action_wheel:setPage(page)
	
end

-- Go back a page
local function ascend()
	
	action_wheel:setPage(table.remove(navigation, #navigation))
	
end

-- Page setups
local pages = {
	
	main             = action_wheel:newPage("Main"),
	avatar           = action_wheel:newPage("Avatar"),
	armor            = action_wheel:newPage("Armor"),
	camera           = action_wheel:newPage("Camera"),
	centaur          = action_wheel:newPage("Centaur"),
	texture          = action_wheel:newPage("Texture"),
	primaryTexture   = action_wheel:newPage("PrimaryTexture"),
	secondaryTexture = action_wheel:newPage("SecondaryTexture"),
	anims            = action_wheel:newPage("Anims")
	
}

-- Page actions
local pageActions = {
	
	avatar = action_wheel:newAction()
		:item(itemCheck("armor_stand"))
		:onLeftClick(function() descend(pages.avatar) end),
	
	centaur = action_wheel:newAction()
		:item(itemCheck("saddle"))
		:onLeftClick(function() descend(pages.centaur) end),
	
	texture = action_wheel:newAction()
		:item(itemCheck("brush"))
		:onLeftClick(function() descend(pages.texture) end),
	
	primaryTexture = action_wheel:newAction()
		:item(itemCheck("item_frame"))
		:onLeftClick(function() descend(pages.primaryTexture) end),
	
	secondaryTexture = action_wheel:newAction()
		:item(itemCheck("painting"))
		:onLeftClick(function() descend(pages.secondaryTexture) end),
	
	anims = action_wheel:newAction()
		:item(itemCheck("jukebox"))
		:onLeftClick(function() descend(pages.anims) end),
	
	armor = action_wheel:newAction()
		:item(itemCheck("iron_chestplate"))
		:onLeftClick(function() descend(pages.armor) end),
	
	camera = action_wheel:newAction()
		:item(itemCheck("redstone"))
		:onLeftClick(function() descend(pages.camera) end)
	
}

-- Update actions
function events.TICK()
	
	if action_wheel:isEnabled() then
		pageActions.avatar
			:title(toJson
				{text = "Avatar Settings", bold = true, color = color.primary}
			)
		
		pageActions.centaur
			:title(toJson
				{text = "Centaur Settings", bold = true, color = color.primary}
			)
		
		pageActions.texture
			:title(toJson
				{text = "Texture Settings", bold = true, color = color.primary}
			)
		
		pageActions.primaryTexture
			:title(toJson
				{text = "Primary Textures", bold = true, color = color.primary}
			)
		
		pageActions.secondaryTexture
			:title(toJson
				{text = "Secondary Textures", bold = true, color = color.primary}
			)
		
		pageActions.anims
			:title(toJson
				{text = "Animations", bold = true, color = color.primary}
			)
		
		pageActions.armor
			:title(toJson
				{text = "Armor Settings", bold = true, color = color.primary}
			)
		
		pageActions.camera
			:title(toJson
				{text = "Camera Settings", bold = true, color = color.primary}
			)
		
		for _, page in pairs(pageActions) do
			page:hoverColor(color.hover)
		end
		
	end
	
end

-- Action back to previous page
local backAction = action_wheel:newAction()
	:title(toJson
		{text = "Go Back?", bold = true, color = "red"}
	)
	:hoverColor(vectors.hexToRGB("FF5555"))
	:item(itemCheck("barrier"))
	:onLeftClick(function() ascend() end)

-- Set starting page to main page
action_wheel:setPage(pages.main)

-- Main actions
pages.main
	:action( -1, pageActions.avatar)
	:action( -1, pageActions.centaur)
	:action( -1, pageActions.anims)

-- Avatar actions
pages.avatar
	:action( -1, avatar.vanillaSkinPage)
	:action( -1, avatar.modelPage)
	:action( -1, pageActions.armor)
	:action( -1, pageActions.camera)
	:action( -1, backAction)

-- Armor actions
pages.armor
	:action( -1, armor.allPage)
	:action( -1, armor.bootsPage)
	:action( -1, armor.leggingsPage)
	:action( -1, armor.chestplatePage)
	:action( -1, armor.helmetPage)
	:action( -1, backAction)

-- Camera actions
pages.camera
	:action( -1, camera.posPage)
	:action( -1, camera.eyePage)
	:action( -1, backAction)

-- Centaur actions
pages.centaur
	:action( -1, accessory.saddlePage)
	:action( -1, accessory.bagsPage)
	:action( -1, pageActions.texture)
	:action( -1, backAction)

-- Texture actions
pages.texture
	:action( -1, pageActions.primaryTexture)
	:action( -1, pageActions.secondaryTexture)
	:action( -1, backAction)

-- Primary texture actions
pages.primaryTexture
	:action( 8, backAction)
	:action( -1, texture.horseWhitePage)
	:action( -1, texture.horseGrayPage)
	:action( -1, texture.horseBlackPage)
	:action( -1, texture.horseCreamyPage)
	:action( -1, texture.horseChestnutPage)
	:action( -1, texture.horseBrownPage)
	:action( -1, texture.horseDarkBrownPage)
	:action( -1, texture.horseZombiePage)
	:action( -1, texture.horseSkeletonPage)
	:action( -1, texture.donkeyPage)
	:action( -1, texture.mulePage)
	:action( -1, texture.horseDefaultPage)
	:action( -1, backAction)

-- Secondary texture actions
pages.secondaryTexture
	:action( -1, texture.horseMarkingsBlankPage)
	:action( -1, texture.horseMarkingsWhitePage)
	:action( -1, texture.horseMarkingsWhiteFieldPage)
	:action( -1, texture.horseMarkingsWhiteDotsPage)
	:action( -1, texture.horseMarkingsBlackDotsPage)
	:action( -1, texture.horseMarkingsDefaultPage)
	:action( -1, backAction)

-- Animation actions
pages.anims
	:action( -1, anims.rearUpPage)
	:action( -1, arms.movePage)
	:action( -1, backAction)