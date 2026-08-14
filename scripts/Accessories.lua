-- Required scripts
local parts = require("lib.PartsAPI")
local sync  = require("lib.LetThatSyncFig")

-- Synced variables setup
local saddle = sync.new("AccessoriesSaddle", false):config()
local bags   = sync.new("AccessoriesBags", false):config()

-- Saddle parts
local saddleParts = {
	
	parts.group.Saddle
	
}

-- Bag parts
local bagParts = {
	
	parts.group.LeftBag,
	parts.group.RightBag
	
}

function events.RENDER(delta, context)
	
	-- Apply
	for _, part in ipairs(saddleParts) do
		part:visible(saddle.curr)
	end
	for _, part in ipairs(bagParts) do
		part:visible(bags.curr)
	end
	
end

-- Apply sound functions
saddle:addFunc(function()
	if player:isLoaded() then
		sounds:playSound("entity.horse.saddle", player:getPos(), 0.5)
	end
end)
bags:addFunc(function()
	if player:isLoaded() then
		sounds:playSound("item.armor.equip_generic", player:getPos(), 0.5)
	end
end)

-- Host only instructions
if not host:isHost() then return end

-- Required scripts
local s, pageNav, acts, colors = pcall(require, "scripts.ActionWheel")
if not s then return end -- Kills script early if ActionWheel.lua isnt found

-- Check for if page already exists
local pageExists = action_wheel:getPage("Centaur")

-- Pages
local parentPage  = action_wheel:getPage("Main")
local centaurPage = pageExists or action_wheel:newPage("Centaur")

-- Actions
if not pageExists then
	acts.centaurPage = parentPage:newAction()
		:item("saddle")
		:onLeftClick(function() pageNav.descend(centaurPage) end)
end

acts.centaurSaddleToggle = centaurPage:newAction()
	:item("leather")
	:toggleItem("saddle")
	:onToggle(function(bool)
		saddle:update(bool)
	end)
	:toggled(saddle.curr)

acts.centaurBagsToggle = centaurPage:newAction()
	:texture(textures:fromVanilla("BundleFilled", "textures/item/bundle_filled.png"))
	:toggleTexture(textures:fromVanilla("Bundle", "textures/item/bundle.png"))
	:onToggle(function(bool)
		bags:update(bool)
	end)
	:toggled(bags.curr)

-- Update actions
function events.RENDER(delta, context)
	
	if action_wheel:isEnabled() then
		if acts.centaurPage then
			acts.centaurPage
				:title(toJson(
					{text = "Centaur Settings", bold = true, color = colors.primary}
				))
				:hoverColor(colors.hover)
		end
		
		acts.centaurSaddleToggle
			:title(toJson(
				{
					"",
					{text = "Toggle Saddle\n\n", bold = true, color = colors.primary},
					{text = "Toggles visibility of the saddle.", color = colors.secondary}
				}
			))
			:hoverColor(colors.hover)
			:toggleColor(colors.active)
		
		acts.centaurBagsToggle
			:title(toJson(
				{
					"",
					{text = "Toggle Bags\n\n", bold = true, color = colors.primary},
					{text = "Toggles visibility of the bags.", color = colors.secondary}
				}
			))
			:hoverColor(colors.hover)
			:toggleColor(colors.active)
		
	end
	
end