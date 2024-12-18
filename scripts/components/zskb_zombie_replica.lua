local function OnCanRainControlDirty(self, inst)
    local can_rain_control = self._can_rain_control:value() or false
    if ThePlayer and ThePlayer:HasTag("zskb_zombie") then
        if can_rain_control then
            ThePlayer.HUD.zskb_hud_icon.rain:Show()
        else
            ThePlayer.HUD.zskb_hud_icon.rain:Hide()
        end
    end
end

local function OnCanNightVisionDirty(self, inst)
    local can_night_vision = self._can_night_vision:value() or false
    if ThePlayer and ThePlayer:HasTag("zskb_zombie") then
        if can_night_vision then
            ThePlayer.HUD.zskb_hud_icon.nightvision:Show()
        else
            ThePlayer.HUD.zskb_hud_icon.nightvision:Hide()
        end
    end
end

local Zombie = Class(function(self, inst)
    self.inst = inst

    self._can_rain_control = net_bool(inst.GUID, "zskb_zombie.can_rain_control", "on_can_rain_control_dirty")
    self._can_night_vision = net_bool(inst.GUID, "zskb_zombie.can_night_vision", "on_can_night_vision_dirty")

    inst:ListenForEvent("on_can_rain_control_dirty", function(inst) OnCanRainControlDirty(self, inst) end)
    inst:ListenForEvent("on_can_night_vision_dirty", function(inst) OnCanNightVisionDirty(self, inst) end)

    -- delay 1 frame to make sure ThePlayer is ready in client side
    self.inst:DoTaskInTime(0, function()
        OnCanRainControlDirty(self, inst)
        OnCanNightVisionDirty(self, inst)
    end)
end, nil, {})

return Zombie
