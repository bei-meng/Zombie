local ZombieGas = Class(function(self, inst)
    self.inst = inst
    self._min = net_ushortint(inst.GUID, "zskb_zombie.min")
    self._max = net_ushortint(inst.GUID, "zskb_zombie.max")
    self._current = net_ushortint(inst.GUID, "zskb_zombie.current")
end, nil, {
})

function ZombieGas:GetMin()
    return self._min:value() or 0
end

function ZombieGas:GetMax()
    return self._max:value() or 0
end

function ZombieGas:GetCurrent()
    return self._current:value() or 0
end

function ZombieGas:GetPercent()
    return self:GetCurrent() / self:GetMax()
end

return ZombieGas
