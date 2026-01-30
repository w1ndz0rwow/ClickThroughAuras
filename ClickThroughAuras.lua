local function CT(f)
  if not f then return end
  if f.EnableMouse then f:EnableMouse(false) end
  for _,c in ipairs({f:GetChildren()}) do CT(c) end
end

local function HookCC(cc)
  if not cc or cc._ctHook then return end
  cc._ctHook = true

  -- Re-apply after layout builds the dynamic .<id>.Cooldown frames
  if type(cc.Layout)=="function" then
    hooksecurefunc(cc, "Layout", function(self) CT(self) end)
  end

  -- Some builds rebuild on dirty->clean cycles
  if type(cc.MarkDirty)=="function" then
    hooksecurefunc(cc, "MarkDirty", function(self) C_Timer.After(0, function() CT(self) end) end)
  end

  -- Also cover show/recycle
  cc:HookScript("OnShow", function(self) C_Timer.After(0, function() CT(self) end) end)
end

local function FixPlate(plate)
  local uf = plate and plate.UnitFrame
  local cc = uf and uf.AurasFrame and uf.AurasFrame.CrowdControlListFrame
  if not cc then return end
  HookCC(cc)
  CT(cc)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
f:SetScript("OnEvent", function(_, e, unit)
  if e=="PLAYER_LOGIN" then
    for i=1,80 do FixPlate(_G["NamePlate"..i]) end
  else
    C_Timer.After(0, function()
      FixPlate(C_NamePlate.GetNamePlateForUnit(unit))
    end)
  end
end)
