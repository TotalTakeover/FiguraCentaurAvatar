-- Setup table
local t = {
	cF = false
}

-- Creative flight check
local wasCF = t.cF
function pings.cFPing(boolean)
	
	t.cF = boolean
	
end

if host:isHost() then
	function events.TICK()
		
		t.cF = host:isFlying()
		if t.cF ~= wasCF then
			pings.cFPing(t.cF)
		end
		wasCF = t.cF
		
	end
end

-- Returns table
return t