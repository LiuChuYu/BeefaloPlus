local ACTIONS = GLOBAL.ACTIONS

function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

local exclude = Set {"HAUNT"}
for k, v in pairs(ACTIONS) do
  if not exclude[k]  then
    v.mount_valid = true
  end
end
