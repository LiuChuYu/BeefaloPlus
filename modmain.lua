
local function MountedActionFilter(inst, action)
  return action.mount_valid == true
end

local function RiderPostInit(self)
  self.SetActionFilter = function(riding)
    if self.inst.components.playercontroller ~= nil then
      if riding then
        self.inst.components.playeractionpicker:PushActionFilter(MountedActionFilter, 20)
      else
        self.inst.components.playeractionpicker:PopActionFilter(MountedActionFilter)
      end
    end
  end
end


AddClassPostConstruct("components/rider_replica",RiderPostInit)
local chop = GetModConfigData("Chopping",true) == "on"
local dig = GetModConfigData("Digging",true) == "on"
local hammer = GetModConfigData("Hammering",true) == "on"
local mine = GetModConfigData("Mining",true) == "on"
local mine = GetModConfigData("Jumping",true) == "on"

local COLLISION = GLOBAL.COLLISION
local function SGwilsonPostInit(self)
  if chop then
    self.states["chop_start"].onenter = function(inst)
      inst.components.locomotor:Stop()
      inst.AnimState:PlayAnimation(inst:HasTag("woodcutter") and "woodie_chop_pre" or "chop_pre")
      inst.sg:GoToState("chop")
    end
  end

  if mine then
    self.states["mine_start"].onenter =
      function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("pickaxe_pre")
        inst.sg:GoToState("mine")
      end
  end

  if dig then
    self.states["dig_start"].onenter =
      function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("shovel_pre")
        inst.sg:GoToState("dig")
      end
  end

  if hammer then
    self.states["hammer_start"].onenter =
      function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("hammer_pre")
        inst.sg:GoToState("hammer")
      end
  end

  self.states["bugnet_start"].onenter =
    function(inst)
      inst.components.locomotor:Stop()
      inst.AnimState:PlayAnimation("hammer_pre")
      inst.sg:GoToState("hammer")
    end
  if jump then
    self.states["jumpin_pre"].onenter =
      function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation(inst.components.inventory:IsHeavyLifting() and "heavy_jump_pre" or "jump_pre", false)

        if inst.bufferedaction ~= nil then
          inst:PerformBufferedAction()
        else
          inst.sg:GoToState("idle")
        end
      end
    self.states["jumpin"].onenter = function(inst, data)
      -- copy of the "ToggleOffPhysics" function
      inst.sg.statemem.isphysicstoggle = true
      inst.Physics:ClearCollisionMask()
      inst.Physics:CollidesWith(COLLISION.GROUND)

      inst.components.locomotor:Stop()
      inst.sg.statemem.target = data.teleporter
      inst.sg.statemem.heavy = inst.components.inventory:IsHeavyLifting()
      if data.teleporter ~= nil and data.teleporter.components.teleporter ~= nil then
        data.teleporter.components.teleporter:RegisterTeleportee(inst)
      end
      inst.AnimState:PlayAnimation(inst.sg.statemem.heavy and "heavy_jump" or "jump", false)
      local pos = data ~= nil and data.teleporter and data.teleporter:GetPosition() or nil
      local MAX_JUMPIN_DIST = 3
      local MAX_JUMPIN_DIST_SQ = MAX_JUMPIN_DIST*MAX_JUMPIN_DIST
      local MAX_JUMPIN_SPEED = 6
      local dist
      if pos ~= nil then
        inst:ForceFacePoint(pos:Get())
        local distsq = inst:GetDistanceSqToPoint(pos:Get())
        if distsq <= 0.25*0.25 then
          dist = 0
          inst.sg.statemem.speed = 0
        elseif distsq >= MAX_JUMPIN_DIST_SQ then
          dist = MAX_JUMPIN_DIST
          inst.sg.statemem.speed = MAX_JUMPIN_SPEED
        else
          dist = math.sqrt(distsq)
          inst.sg.statemem.speed = MAX_JUMPIN_SPEED * dist / MAX_JUMPIN_DIST
        end
      else
        inst.sg.statemem.speed = 0
        dist = 0
      end
      inst.Physics:SetMotorVel(inst.sg.statemem.speed * .5, 0, 0)
      inst.sg.statemem.teleportarrivestate = "jumpout"
      if inst.sg.statemem.target ~= nil and
        inst.sg.statemem.target:IsValid() and
      inst.sg.statemem.target.components.teleporter ~= nil then
        --Unregister first before actually teleporting
        inst.sg.statemem.target.components.teleporter:UnregisterTeleportee(inst)
        if inst.sg.statemem.target.components.teleporter:Activate(inst) then
          inst.sg.statemem.isteleporting = true
          inst.components.health:SetInvincible(true)
          if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(false)
          end
          inst:Hide()
          inst.DynamicShadow:Enable(false)
          return
        end
      end
      inst.sg:GoToState("jumpout")
    end
    self.states["jumpout"].onenter = function(inst)
      -- same as before
      inst.sg.statemem.isphysicstoggle = true
      inst.Physics:ClearCollisionMask()
      inst.Physics:CollidesWith(COLLISION.GROUND)

      inst.components.locomotor:Stop()

      inst.sg.statemem.heavy = inst.components.inventory:IsHeavyLifting()

      inst.AnimState:PlayAnimation(inst.sg.statemem.heavy and "heavy_jumpout" or "jumpout")

      inst.Physics:SetMotorVel(4, 0, 0)
      inst.sg:GoToState("idle")
    end
  end
end

AddStategraphPostInit("wilson",SGwilsonPostInit)

local ACTIONS = GLOBAL.ACTIONS
function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end
local exclude = Set {"HAUNT"}
if not jump then
  exclude["JUMPIN"] = true
end
for i,v in pairs(ACTIONS) do
  if not exclude[i] then
    v.mount_valid = true
  else
    v.mount_valid = false
  end
end
