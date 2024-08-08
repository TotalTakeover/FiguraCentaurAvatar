-- Required scripts
local parts = require("lib.PartsAPI")
local lerp  = require("lib.LerpAPI")

-- Variables
local sum, count = vectors.vec3(), 0
local average = vectors.vec3()
local prevType, prevPrimary

-- Lerp
local color = lerp:new(1, vec(1, 1, 1))

-- Add up primary colors
local function findSum(color)
	if color[4] ~= 0 then
		sum = sum + color.xyz
		count = count + 1
	end
end

-- Find an average
local function findAverage(s, c)
	return c ~= 0 and s / c or vec(1, 1, 1)
end

function events.TICK()
	
	-- Variables
	local type, primary = parts.group.Main.Body:getPrimaryTexture()
	
	-- If texture changed
	if type ~= prevType or primary ~= prevPrimary then
		
		-- Get/Create texture
		local tex = type == "RESOURCE" and textures:fromVanilla("Primary", primary) or textures["models.Centaur.horse"]
		
		-- Reset variables
		sum, count = vectors.vec3(), 0
		
		-- Find sum
		tex:applyFunc(0, 57, 64, 4, findSum)
		
	end
	
	-- Get average
	average = findAverage(sum, count)
	
	-- Store previous textures
	prevType, prevPrimary = parts.group.Main.Body:getPrimaryTexture()
	
	-- Set color target
	color.target = average
	
end

-- Host only instructions
if not host:isHost() then return end

-- Table setup
local t = {}

-- Action variables
t.hover     = vectors.vec3()
t.active    = vectors.vec3()
t.primary   = "#"..vectors.rgbToHex(vectors.vec3())
t.secondary = "#"..vectors.rgbToHex(vectors.vec3())

function events.RENDER(delta, context)
	
	-- Set colors
	t.hover     = color.currPos
	t.active    = (color.currPos + 0.25):applyFunc(function(a) return math.min(a, 1) end)
	t.primary   = "#"..vectors.rgbToHex(color.currPos)
	t.secondary = "#"..vectors.rgbToHex((color.currPos + 0.25):applyFunc(function(a) return math.min(a, 1) end))
	
	-- Glowing outline
	renderer:outlineColor(color.currPos)
	
	-- Avatar color
	avatar:color(color.currPos)
	
end

-- Return variables
return t