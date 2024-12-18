local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local GasBadge = Class(Badge, function(self, owner, art)
    Badge._ctor(self, nil, owner, { 219 / 255, 89 / 255, 64 / 255, 1.0 }, "zskb_zombie_gas_badge", nil, nil, true)

    self.gasarrow = self.underNumber:AddChild(UIAnim())
    self.gasarrow:GetAnimState():SetBank("sanity_arrow")
    self.gasarrow:GetAnimState():SetBuild("sanity_arrow")
    self.gasarrow:GetAnimState():PlayAnimation("neutral")
    self.gasarrow:SetClickable(false)
    self.gasarrow:GetAnimState():AnimateWhilePaused(false)

    -- self.backing:GetAnimState():OverrideSymbol("bg", "swap_odoy_status_meter", "bg")

    self:StartUpdating()
end)


function GasBadge:OnUpdate(dt)
    if TheNet:IsServerPaused() then return end

    local anim = "neutral"

    if anim ~= nil and self.arrowdir ~= anim then
        self.arrowdir = anim
        self.gasarrow:GetAnimState():PlayAnimation(anim, true)
    end

    if self.owner.replica.zskb_zombie_gas then
        local percent = self.owner.replica.zskb_zombie_gas:GetPercent()
        local max = self.owner.replica.zskb_zombie_gas._max:value()
        self:SetPercent(percent, max)
    end
end

return GasBadge
