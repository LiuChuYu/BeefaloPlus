local ACTIONS = GLOBAL.ACTIONS
local CanEntitySeeTarget = GLOBAL.CanEntitySeeTarget
local BufferedAction = GLOBAL.BufferedAction
local TARGET_EXCLUDE_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }
local PICKUP_TARGET_EXCLUDE_TAGS = { "catchable", "mineactive", "intense" }
local HAUNT_TARGET_EXCLUDE_TAGS = { "haunted", "catchable" }
for i, v in ipairs(TARGET_EXCLUDE_TAGS) do
    table.insert(PICKUP_TARGET_EXCLUDE_TAGS, v)
    table.insert(HAUNT_TARGET_EXCLUDE_TAGS, v)
end

local function GetPickupAction(inst, target)
    if target:HasTag("smolder") then
        return ACTIONS.SMOTHER
    elseif target:HasTag("quagmireharvestabletree") and not target:HasTag("fire") then
        return ACTIONS.HARVEST_TREE
    elseif target:HasTag("trapsprung") then
        return ACTIONS.CHECKTRAP
    elseif target:HasTag("minesprung") then
        return ACTIONS.RESETMINE
    elseif target:HasTag("inactive") then
        return (not target:HasTag("wall") or inst:IsNear(target, 2.5)) and ACTIONS.ACTIVATE or nil
    elseif target.replica.inventoryitem ~= nil and
        target.replica.inventoryitem:CanBePickedUp() and
        not (target:HasTag("heavy") or target:HasTag("fire") or target:HasTag("catchable")) then
        return (inst.components.playercontroller:HasItemSlots() or target.replica.equippable ~= nil) and ACTIONS.PICKUP or nil
    elseif target:HasTag("pickable") and not target:HasTag("fire") then
        return ACTIONS.PICK
    elseif target:HasTag("harvestable") then
        return ACTIONS.HARVEST
    elseif target:HasTag("readyforharvest") or
        (target:HasTag("notreadyforharvest") and target:HasTag("withered")) then
        return ACTIONS.HARVEST
    elseif target:HasTag("tapped_harvestable") and not target:HasTag("fire") then
    return ACTIONS.HARVEST
    elseif target:HasTag("dried") and not target:HasTag("burnt") then
        return ACTIONS.HARVEST
    elseif target:HasTag("donecooking") and not target:HasTag("burnt") then
        return ACTIONS.HARVEST
    elseif tool ~= nil and tool:HasTag("unsaddler") and target:HasTag("saddled") and (not target.replica.health or not target.replica.health:IsDead()) then
        return ACTIONS.UNSADDLE
    elseif tool ~= nil and tool:HasTag("brush") and target:HasTag("brushable") and (not target.replica.health or not target.replica.health:IsDead()) then
        return ACTIONS.BRUSH
    elseif inst.components.revivablecorpse ~= nil and target:HasTag("corpse") and ValidateCorpseReviver(target, inst) then
        return ACTIONS.REVIVE_CORPSE
    end
end
local MOUNTED_PICKUP_TAGS = {
  "_inventoryitem",
  "pickable",
  "donecooking",
  "readyforharvest",
  "notreadyforharvest",
  "harvestable",
  "trapsprung",
  "minesprung",
  "dried",
  "inactive",
  "smolder",
  "saddled",
  "brushable",
  "tapped_harvestable",
}

local function MountedActionButton(inst, force_target)

    --catching
    if inst:HasTag("cancatch") and not inst.components.playercontroller:IsDoingOrWorking() then
        if force_target == nil then
            local target = GLOBAL.FindEntity(inst, 10, nil, { "catchable" }, TARGET_EXCLUDE_TAGS)
            if CanEntitySeeTarget(inst, target) then
                return BufferedAction(inst, target, ACTIONS.CATCH)
            end
        elseif inst:GetDistanceSqToInst(force_target) <= 100 and
            force_target:HasTag("catchable") then
            return BufferedAction(inst, force_target, ACTIONS.CATCH)
        end
    end

    --unstick
    -- if force_target == nil then
    --     local target = GLOBAL.FindEntity(inst, 10, nil, { "pinned" }, TARGET_EXCLUDE_TAGS)
    --     if CanEntitySeeTarget(inst, target) then
    --         return BufferedAction(inst, target, ACTIONS.UNPIN)
    --     end
    -- elseif inst:GetDistanceSqToInst(force_target) <= (inst.components.playercontroller.directwalking and 9 or 36) and
    --     force_target:HasTag("pinned") then
    --     return BufferedAction(inst, force_target, ACTIONS.UNPIN)
    -- end

    --pickup
    if not inst.components.playercontroller:IsDoingOrWorking() then
        if force_target == nil then
            local x, y, z = inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, inst.components.playercontroller.directwalking and 3 or 6, nil, PICKUP_TARGET_EXCLUDE_TAGS, MOUNTED_PICKUP_TAGS)
            for i, v in ipairs(ents) do
                if v ~= inst and v.entity:IsVisible() and CanEntitySeeTarget(inst, v) then
                    local action = GetPickupAction(inst,v)
                    if action ~= nil then
                        return BufferedAction(inst, v, action)
                    end
                end
            end
        elseif inst:GetDistanceSqToInst(force_target) <= (inst.components.playercontroller.directwalking and 9 or 36) then
            local action = GetPickupAction(inst,force_target)
            if action ~= nil then
                return BufferedAction(inst, force_target, action)
            end
        end
    end
end

local function MountedActionFilter(inst, action)
  if action ~= nil then
    -- print(MountedActionFilter, GLOBAL.dumptable(action))
    return action.mount_valid == true
  end
end

local function RiderPostInit(self)
  self.SetActionFilter = function(self,riding)
    if self.inst.components.playercontroller ~= nil then
      if riding then
          self.inst.components.playercontroller.actionbuttonoverride = MountedActionButton
          self.inst.components.playeractionpicker:PushActionFilter(MountedActionFilter, 20)
      else
          self.inst.components.playercontroller.actionbuttonoverride = nil
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
local jump = GetModConfigData("Jumping",true) == "on"
local feed = GetModConfigData("Feeding",true) == "on"

local COLLISION = GLOBAL.COLLISION
local function SGwilsonPostInit(self)
 
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
    self.states["heavylifting_start"].onenter = function(inst)
      inst.components.locomotor:Stop()
      inst.AnimState:PlayAnimation("heavy_mount")
    end
    self.states["exittownportal"].onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("heavy_mount")
    end
  end
end

AddStategraphPostInit("wilson",SGwilsonPostInit)

function Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end
local valid_action = {
    PICK = true,
    PICKUP = true,
    GIVE = true,
    JUMPIN = true,
    TELEPORT = true,
}
for i,v in pairs(ACTIONS) do
  if valid_action[i] then
    v.mount_valid = true
  end
end


-- Feeding the bird

local function tradablefn(inst, doer, target, actions)
  if target:HasTag("trader") and
    not (target:HasTag("player") or target:HasTag("ghost")) and
    (doer.replica.rider ~= nil and doer.replica.rider:IsRiding() and
     not (target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsGrandOwner(doer))) then
      table.insert(actions, ACTIONS.GIVE)
  end
end
if feed then
  AddComponentAction("USEITEM","tradable",tradablefn)
end

-- attack
-- ThePlayer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS):HasTag("rangedweapon"))
