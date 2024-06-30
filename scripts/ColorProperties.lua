-- Required scripts
local centaurParts = require("lib.GroupIndex")(models.models.Centaur)

-- Variables
local sum, count = vectors.vec3(), 0
local average = vectors.vec3()
local prevType, prevPrimary

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
	local type, primary = centaurParts.Main.Body:getPrimaryTexture()
	
	
	if type ~= prevType or primary ~= prevPrimary then
		
		-- Get/Create texture
		local tex = type == "RESOURCE" and textures:fromVanilla("Primary", primary) or textures["models.Centaur.horse"]
		
		-- Reset variables
		sum, count = vectors.vec3(), 0
		
		-- Find sum
		tex:applyFunc(0, 57, 64, 4, findSum)
		
	end
	
	-- Get Averages
	average = findAverage(sum, count)
	
	prevType, prevPrimary = centaurParts.Main.Body:getPrimaryTexture()
	
	-- Glowing outline
	renderer:outlineColor(average)
	
	-- Avatar color
	avatar:color(average)
	
end

-- Host only instructions
if not host:isHost() then return end

-- Table setup
local t = {}

t.hover     = vectors.vec3()
t.active    = vectors.vec3()
t.primary   = "#"..vectors.rgbToHex(vectors.vec3())
t.secondary = "#"..vectors.rgbToHex(vectors.vec3())

function events.TICK()
	
	-- Set colors
	t.hover     = average
	t.active    = (average + 0.25):applyFunc(function(a) return math.min(a, 1) end)
	t.primary   = "#"..vectors.rgbToHex(average)
	t.secondary = "#"..vectors.rgbToHex((average + 0.25):applyFunc(function(a) return math.min(a, 1) end))
	
end

-- Return table
return t