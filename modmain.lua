local ACTIONS = GLOBAL.ACTIONS

local function RiderPostInit(self)
  self.SetActionFilter = function(riding)
    end
end
AddClassPostConstruct("components/rider_replica",RiderPostInit)
