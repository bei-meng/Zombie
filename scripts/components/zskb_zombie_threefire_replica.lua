local ZombieThreeFire = Class(function(self, inst)
    self.inst = inst
    self._min = net_ushortint(inst.GUID, "zskb_zombie.threefire_min")
    self._max = net_ushortint(inst.GUID, "zskb_zombie.threefire_max")
    self._current = net_ushortint(inst.GUID, "zskb_zombie.threefire_current")
end, nil, {
})

function ZombieThreeFire:GetMin()
    return self._min:value() or 0
end

function ZombieThreeFire:GetMax()
    return self._max:value() or 0
end

function ZombieThreeFire:GetCurrent()
    return self._current:value() or 0
end

function ZombieThreeFire:GetPercent()
    if self.inst.replica.inventory ~= nil then
        local item = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if item ~= nil and item._lightstatus ~= nil and item._lightstatus:value() then
            return 0
        end
    end
    return self:GetCurrent() / self:GetMax()
end

return ZombieThreeFire
