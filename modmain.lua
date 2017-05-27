local ACTIONS = GLOBAL.ACTIONS

function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

-- List of actions not make sense while rideing
local exclude = Set {"HAUNT"}
for k, v in pairs(ACTIONS) do
  if not exclude[k]  then
    v.mount_valid = true
  end
end


-- fix pressing space not working
local function RiderPostInit(self)
  self.SetActionFilter = function(riding)
    end
end
AddClassPostConstruct("components/rider_replica",RiderPostInit)
