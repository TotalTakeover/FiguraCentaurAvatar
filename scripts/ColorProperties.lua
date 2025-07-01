-- Avatar color
avatar:color(vectors.hexToRGB("default"))

-- Host only instructions
if not host:isHost() then return end

-- Table setup
local c = {}

-- Action variables
c.hover     = vectors.hexToRGB("default")
c.active    = vectors.hexToRGB("default")
c.primary   = "#FFFFFF"
c.secondary = "#FFFFFF"

-- Return variables
return c