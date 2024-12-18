--有该组件的实体,任何恢复生命值的手段均对其无效
local NoHeal = Class(function(self, inst)
    self.inst = inst
    self.duration = 0
    self.task = nil
end)

function NoHeal:SetDuration(duration)
    self.duration = duration
    if self.task then
        self.task:Cancel()
    end
    self.task = self.inst:DoTaskInTime(self.duration, function() self.inst:RemoveComponent("zskb_noheal") end)
end

--Hook 生命值恢复方法
local function HookHealthComponent(health)
    if not health._originalDoDelta then
        health._originalDoDelta = health.DoDelta
        health.DoDelta = function(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...)
            if amount > 0 and self.inst.components.zskb_noheal then
                --阻止恢复生命值
                return 0
            end
            return self:_originalDoDelta(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...)
        end
    end
end

function NoHeal:AttachToTarget(target)
    if target.components.health then
        HookHealthComponent(target.components.health)
    end
end

function NoHeal:OnRemoveFromEntity()
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

return NoHeal
