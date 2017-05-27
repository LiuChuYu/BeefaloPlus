
local function RiderPostInit(self)
  self.SetActionFilter = function(riding)
    end
end
AddClassPostConstruct("components/rider_replica",RiderPostInit)
local chop = GetModConfigData("Chopping",true) == "on"
local dig = GetModConfigData("Digging",true) == "on"
local hammer = GetModConfigData("Hammering",true) == "on"
local mine = GetModConfigData("Mining",true) == "on"

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
end

AddStategraphPostInit("wilson",SGwilsonPostInit)
