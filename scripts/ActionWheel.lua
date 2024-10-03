-- Disables code if not avatar host
if not host:isHost() then return end

-- Required scripts
local itemCheck = require("lib.ItemCheck")

local s, avatar = pcall(require, "scripts.Player")
if not s then avatar = {} end

local s, armor = pcall(require, "scripts.Armor")
if not s then armor = {} end

local s, camera = pcall(require, "scripts.CameraControl")
if not s then camera = {} end

local s, accessory = pcall(require, "scripts.Accessories")
if not s then accessory = {} end

local s, texture = pcall(require, "scripts.TextureSwap")
if not s then texture = {} end

local s, anims = pcall(require, "scripts.Anims")
if not s then anims = {} end

local s, squapi = pcall(require, "scripts.SquishyAnims")
if not s then squapi = {} end

local s, color = pcall(require, "scripts.ColorProperties")
if not s then color = {} end

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
	
	main    = action_wheel:newPage("Main"),
	avatar  = action_wheel:newPage("Avatar"),
	armor   = action_wheel:newPage("Armor"),
	camera  = action_wheel:newPage("Camera"),
	centaur = action_wheel:newPage("Centaur"),
	texture = action_wheel:newPage("Texture"),
	anims   = action_wheel:newPage("Anims")
	
}

-- Page actions
local pageActs = {
	
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
		pageActs.avatar
			:title(toJson
				{text = "Avatar Settings", bold = true, color = color.primary}
			)
		
		pageActs.centaur
			:title(toJson
				{text = "Centaur Settings", bold = true, color = color.primary}
			)
		
		pageActs.texture
			:title(toJson
				{text = "Texture Settings", bold = true, color = color.primary}
			)
		
		pageActs.anims
			:title(toJson
				{text = "Animations", bold = true, color = color.primary}
			)
		
		pageActs.armor
			:title(toJson
				{text = "Armor Settings", bold = true, color = color.primary}
			)
		
		pageActs.camera
			:title(toJson
				{text = "Camera Settings", bold = true, color = color.primary}
			)
		
		for _, page in pairs(pageActs) do
			page:hoverColor(color.hover)
		end
		
	end
	
end

-- Action back to previous page
local backAct = action_wheel:newAction()
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
	:action( -1, pageActs.avatar)
	:action( -1, pageActs.centaur)
	:action( -1, pageActs.anims)

-- Avatar actions
pages.avatar
	:action( -1, avatar.vanillaSkinAct)
	:action( -1, avatar.modelAct)
	:action( -1, pageActs.armor)
	:action( -1, pageActs.camera)
	:action( -1, backAct)

-- Armor actions
pages.armor
	:action( -1, armor.allAct)
	:action( -1, armor.bootsAct)
	:action( -1, armor.leggingsAct)
	:action( -1, armor.chestplateAct)
	:action( -1, armor.helmetAct)
	:action( -1, backAct)

-- Camera actions
pages.camera
	:action( -1, camera.posAct)
	:action( -1, camera.eyeAct)
	:action( -1, backAct)

-- Centaur actions
pages.centaur
	:action( -1, accessory.saddleAct)
	:action( -1, accessory.bagsAct)
	:action( -1, pageActs.texture)
	:action( -1, backAct)

-- Texture actions
pages.texture
	:action( -1, texture.primaryAct)
	:action( -1, texture.secondaryAct)
	:action( -1, backAct)

-- Animation actions
pages.anims
	:action( -1, anims.sitAct)
	:action( -1, anims.rearUpAct)
	:action( -1, squapi.earsAct)
	:action( -1, squapi.armsAct)
	:action( -1, backAct)