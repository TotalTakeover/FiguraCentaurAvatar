-- Avatar color
avatar:color(vectors.hexToRGB("default"))

-- Host only instructions
if not host:isHost() then return end

-- Table setup
local colors = {}

-- Action variables
colors.hover     = vectors.hexToRGB("default")
colors.active    = vectors.hexToRGB("default")
colors.primary   = "#FFFFFF"
colors.secondary = "#FFFFFF"

-- Return variables
return colors