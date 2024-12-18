local PlanarArmor = Class(function(self, inst)
    self.inst = inst
    self.tags = nil
end)

function PlanarArmor:GetArmorCmp()
    return self.inst.components.armor
end

function PlanarArmor:CanResist(attacker, weapon)
    if self:GetArmorCmp() == nil then return false end
    if self.tags == nil then
        return true
    elseif attacker ~= nil then
        for i, v in ipairs(self.tags) do
            if attacker:HasTag(v) or (weapon ~= nil and weapon:HasTag(v)) then
                return true
            end
        end
    end
    return false
end

function PlanarArmor:SetTags(tags)
    self.tags = tags
end

function PlanarArmor:SetAbsorption(absorb_percent)
    self.absorb_percent = absorb_percent
end

function PlanarArmor:GetAbsorption(attacker, weapon)
    return self:CanResist(attacker, weapon) and self.absorb_percent or nil
end

function PlanarArmor:TakeDamage(damage_amount)
    local armor = self:GetArmorCmp()
    if armor ~= nil then
        armor:TakeDamage(damage_amount)
    end
    -- print(" take dmg :", damage_amount)
end

return PlanarArmor
