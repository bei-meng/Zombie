local function onmin(self, min)
    self.inst.replica.zskb_zombie_threefire._min:set(min)
end
local function onmax(self, max)
    self.inst.replica.zskb_zombie_threefire._max:set(max)
end
local function oncurrent(self, current)
    self.inst.replica.zskb_zombie_threefire._current:set(current)
end

local ZombieThreeFire = Class(function(self, inst)
    self.inst = inst
    self.min = 0
    self.max = 3
    self.current = 3
end, nil, {
    min = onmin,
    max = onmax,
    current = oncurrent,
})

function ZombieThreeFire:DoDelta(delta)
    local old = self.current
    self.current = math.clamp(self.current + delta, self.min, self.max)

    self.inst:PushEvent("zskb_zombie_threefire_delta", {
        current = self.current,
        oldpercent = old / self.max,
        percent = self.current / self.max,
        delta = self.current - old
    })
end

function ZombieThreeFire:GetCurrent()
    if self.inst.components.inventory ~= nil then
        local item = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if item ~= nil and item._lightstatus ~= nil and item._lightstatus:value() then
            return 0
        end
    end
    return self.current
end

function ZombieThreeFire:GetPercent()
    return self.current / self.max
end

function ZombieThreeFire:OnSave()
    return {
        current = self.current,
    }
end

function ZombieThreeFire:OnLoad(data)
    if data and data.current then
        self:DoDelta(data.current - self.current)
    end
end

return ZombieThreeFire
