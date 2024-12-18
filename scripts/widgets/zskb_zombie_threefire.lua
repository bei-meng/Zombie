local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local ThreeFireBadge = Class(Badge, function(self, owner, art)
    Badge._ctor(self, nil, owner, { 141 / 255, 141 / 255, 207 / 255, 1.0 }, "zskb_zombie_threefire_badge", nil, nil, true)

    self.threefire_arrow = self.underNumber:AddChild(UIAnim())
    self.threefire_arrow:GetAnimState():SetBank("sanity_arrow")
    self.threefire_arrow:GetAnimState():SetBuild("sanity_arrow")
    self.threefire_arrow:GetAnimState():PlayAnimation("neutral")
    self.threefire_arrow:SetClickable(false)
    self.threefire_arrow:GetAnimState():AnimateWhilePaused(false)

    -- self.backing:GetAnimState():OverrideSymbol("bg", "swap_odoy_status_meter", "bg")

    self:StartUpdating()
end)


function ThreeFireBadge:OnUpdate(dt)
    if TheNet:IsServerPaused() then return end

    local anim = "neutral"

    if anim ~= nil and self.arrowdir ~= anim then
        self.arrowdir = anim
        self.threefire_arrow:GetAnimState():PlayAnimation(anim, true)
    end

    if self.owner.replica.zskb_zombie_threefire then
        local percent = self.owner.replica.zskb_zombie_threefire:GetPercent()
        local max = self.owner.replica.zskb_zombie_threefire._max:value()
        self:SetPercent(percent, max)
    end
end

return ThreeFireBadge
