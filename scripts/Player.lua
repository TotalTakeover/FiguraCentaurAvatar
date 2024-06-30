-- Required script
local centaurParts = require("lib.GroupIndex")(models.models.Centaur)

-- Config setup
config:name("Centaur")
local vanillaSkin = config:load("AvatarVanillaSkin")
local slim        = config:load("AvatarSlim") or false
if vanillaSkin == nil then vanillaSkin = true end

-- Set skull and portrait groups to visible (incase disabled in blockbench)
centaurParts.Skull   :visible(true)
centaurParts.Portrait:visible(true)

-- All vanilla skin parts
local skin = {
	
	centaurParts.Head.Head,
	centaurParts.Head.Layer,
	
	centaurParts.Body.Body,
	centaurParts.Body.Layer,
	
	centaurParts.leftArmDefault,
	centaurParts.leftArmSlim,
	centaurParts.leftArmDefaultFP,
	centaurParts.leftArmSlimFP,
	
	centaurParts.rightArmDefault,
	centaurParts.rightArmSlim,
	centaurParts.rightArmDefaultFP,
	centaurParts.rightArmSlimFP,
	
	centaurParts.Portrait.Head,
	centaurParts.Portrait.Layer,
	
	centaurParts.Skull.Head,
	centaurParts.Skull.Layer
	
}

-- All layer parts
local layer = {

	HAT = {
		centaurParts.Head.Layer,
		centaurParts.HorseLeftEar.Layer,
		centaurParts.HorseRightEar.Layer,
		centaurParts.MuleLeftEar.Layer,
		centaurParts.MuleRightEar.Layer
	},
	JACKET = {
		centaurParts.Body.Layer,
		centaurParts.Mane.Layer
	},
	LEFT_SLEEVE = {
		centaurParts.leftArmDefault.Layer,
		centaurParts.leftArmSlim.Layer,
		centaurParts.leftArmDefaultFP.Layer,
		centaurParts.leftArmSlimFP.Layer
	},
	RIGHT_SLEEVE = {
		centaurParts.rightArmDefault.Layer,
		centaurParts.rightArmSlim.Layer,
		centaurParts.rightArmDefaultFP.Layer,
		centaurParts.rightArmSlimFP.Layer
	},
	LEFT_PANTS_LEG = {
		centaurParts.FrontLeftLeg.Layer,
		centaurParts.BackLeftLeg.Layer
	},
	RIGHT_PANTS_LEG = {
		centaurParts.FrontRightLeg.Layer,
		centaurParts.BackRightLeg.Layer
	},
	CAPE = {
		centaurParts.Cape
	},
	LOWER_BODY = {
		centaurParts.Main.Layer,
		centaurParts.Saddle.Layer,
		centaurParts.LeftBag.Layer,
		centaurParts.RightBag.Layer,
		centaurParts.Tail.Layer
	}
	
}

-- Determine vanilla player type on init
local vanillaAvatarType
function events.ENTITY_INIT()
	
	vanillaAvatarType = player:getModelType()
	
end

-- Misc tick required events
function events.TICK()
	
	-- Model shape
	local slimShape = (vanillaSkin and vanillaAvatarType == "SLIM") or (slim and not vanillaSkin)
	
	centaurParts.leftArmDefault:visible(not slimShape)
	centaurParts.rightArmDefault:visible(not slimShape)
	centaurParts.leftArmDefaultFP:visible(not slimShape)
	centaurParts.rightArmDefaultFP:visible(not slimShape)
	
	centaurParts.leftArmSlim:visible(slimShape)
	centaurParts.rightArmSlim:visible(slimShape)
	centaurParts.leftArmSlimFP:visible(slimShape)
	centaurParts.rightArmSlimFP:visible(slimShape)
	
	-- Skin textures
	local skinType = vanillaSkin and "SKIN" or "PRIMARY"
	for _, part in ipairs(skin) do
		part:primaryTexture(skinType)
	end
	
	-- Cape textures
	centaurParts.Cape:primaryTexture(vanillaSkin and "CAPE" or "PRIMARY")
	
	-- Layer toggling
	for layerType, parts in pairs(layer) do
		local enabled = enabled
		if layerType == "LOWER_BODY" then
			enabled = player:isSkinLayerVisible("RIGHT_PANTS_LEG") or player:isSkinLayerVisible("LEFT_PANTS_LEG")
		else
			enabled = player:isSkinLayerVisible(layerType)
		end
		for _, part in ipairs(parts) do
			part:visible(enabled)
		end
	end
	
end

-- Vanilla skin toggle
function pings.setAvatarVanillaSkin(boolean)
	
	vanillaSkin = boolean
	config:save("AvatarVanillaSkin", vanillaSkin)
	
end

-- Model type toggle
function pings.setAvatarModelType(boolean)
	
	slim = boolean
	config:save("AvatarSlim", slim)
	
end

-- Sync variables
function pings.syncPlayer(a, b)
	
	vanillaSkin = a
	slim = b
	
end

-- Host only instructions
if not host:isHost() then return end

-- Sync on tick
function events.TICK()
	
	if world.getTime() % 200 == 0 then
		pings.syncPlayer(vanillaSkin, slim)
	end
	
end

-- Table setup
local t = {}

-- Required scripts
local itemCheck = require("lib.ItemCheck")
local color     = require("scripts.ColorProperties")

-- Action wheel pages
t.vanillaSkinPage = action_wheel:newAction()
	:item(itemCheck("player_head{'SkullOwner':'"..avatar:getEntityName().."'}"))
	:onToggle(pings.setAvatarVanillaSkin)
	:toggled(vanillaSkin)

t.modelPage = action_wheel:newAction()
	:item(itemCheck("player_head"))
	:toggleItem(itemCheck("player_head{'SkullOwner':'MHF_Alex'}"))
	:onToggle(pings.setAvatarModelType)
	:toggled(slim)

-- Update action page info
function events.TICK()
	
	if action_wheel:isEnabled() then
		t.vanillaSkinPage
			:title(toJson
				{"",
				{text = "Toggle Vanilla Texture\n\n", bold = true, color = color.primary},
				{text = "Toggles the usage of your vanilla skin.", color = color.secondary}}
			)
		
		t.modelPage
			:title(toJson
				{"",
				{text = "Toggle Model Shape\n\n", bold = true, color = color.primary},
				{text = "Adjust the model shape to use Default or Slim Proportions.\nWill be overridden by the vanilla skin toggle.", color = color.secondary}}
			)
		
		for _, page in pairs(t) do
			page:hoverColor(color.hover):toggleColor(color.active)
		end
		
	end
	
end

-- Return action wheel pages
return t