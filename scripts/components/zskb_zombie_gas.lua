local function onmin(self, min)
    self.inst.replica.zskb_zombie_gas._min:set(min)
end
local function onmax(self, max)
    self.inst.replica.zskb_zombie_gas._max:set(max)
end
local function oncurrent(self, current)
    self.inst.replica.zskb_zombie_gas._current:set(current)
end

local function OnTaskTick(inst, self, period)
    self:DoDelta(-TUNING.ZSKB.ONE_DAY_DELTA / TUNING.TOTAL_DAY_TIME, nil, false)
end

local ZombieGas = Class(function(self, inst)
    self.inst = inst
    self.min = 0
    self.max = 100
    self.current = 0

    local period = 1
    self.inst:DoPeriodicTask(period, OnTaskTick, nil, self, period)
end, nil, {
    min = onmin,
    max = onmax,
    current = oncurrent,
})

function ZombieGas:DoDelta(delta, overtime, ignore_invincible, focus)
    if not focus and
        (not ignore_invincible and self.inst.components.health and self.inst.components.health:IsInvincible() or
            self.inst.is_teleporting or
            self.inst:HasTag("playerghost") or
            self.inst.components.inventory:EquipHasTag("zskb_keep_zombie_gas")) then
        return
    end

    if delta < 0 and self.inst:HasTag("zskb_copper_coin_mask") then
        return
    end

    local old = self.current
    self.current = math.clamp(self.current + delta, self.min, self.max)

    self.inst:PushEvent("zskb_zombie_gas_delta", {
        oldpercent = old / self.max,
        percent = self.current / self.max,
        overtime = overtime,
        delta = self.current - old
    })
end

function ZombieGas:GetPercent()
    return self.current / self.max
end

function ZombieGas:OnSave()
    return {
        current = self.current,
    }
end

function ZombieGas:OnLoad(data)
    if data and data.current then
        self:DoDelta(data.current, nil, false, true)
    end
end

function ZombieGas:LongUpdate(dt)
    self:DoDelta(-TUNING.ZSKB.ONE_DAY_DELTA, nil, false, true)
end

function ZombieGas:OnUpdate(dt)

end

return ZombieGas
