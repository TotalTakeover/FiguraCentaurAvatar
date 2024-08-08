-- Required scripts
local parts   = require("lib.PartsAPI")
local carrier = require("lib.GSCarrier")

-- GSCarrier rider
carrier.rider.addRoots(models)
carrier.rider.addTag("gscarrier:taur")
carrier.rider.controller.setGlobalOffset(vec(0, -10, 0))
carrier.rider.controller.setModifyCamera(false)
carrier.rider.controller.setModifyEye(false)
carrier.rider.controller.setAimEnabled(false)

-- GSCarrier vehicle
carrier.vehicle.addTag("gscarrier:taur", "gscarrier:land")

-- Seat 1
carrier.vehicle.newSeat("Seat1", parts.group.Seat1, {
	priority = 2,
	tags = {["gscarrier:mounted"] = true}
})

-- Seat 2
carrier.vehicle.newSeat("Seat2", parts.group.Seat2, {
	priority = 1,
	tags = {["gscarrier:mounted"] = true}
})