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
local squapi    = require("scripts.SquishyAnims")
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
function events.RENDER(delta, context)
	
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
	:action( -1, texture.primaryPage)
	:action( -1, texture.secondaryPage)
	:action( -1, backAction)

-- Animation actions
pages.anims
	:action( -1, anims.rearUpPage)
	:action( -1, squapi.armsPage)
	:action( -1, backAction)