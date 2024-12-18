local BlockBodyEquip = Class(function(self, inst)
    self.inst = inst
    self:EnableBlock(true)
end)

function BlockBodyEquip:EnableBlock(enable)
    if enable then
        --强制移除已经装备的身体栏物品
        self:RemoveEquippedBodyItem()
        self.inst.AnimState:OverrideSymbol("backpack", "zskb_ghost_backpack", "backpack")
        self.inst.AnimState:OverrideSymbol("swap_body", "zskb_ghost_backpack", "swap_body")
    else
        self.inst.AnimState:ClearOverrideSymbol("swap_body")
        self.inst.AnimState:ClearOverrideSymbol("backpack")
    end
end

function BlockBodyEquip:RemoveEquippedBodyItem()
    local body_item = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    local back_item = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BACK)
    local neck_item = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.NECK)
    if body_item then
        self.inst.components.inventory:DropItem(body_item, true, true)
    end
    if back_item then
        self.inst.components.inventory:DropItem(back_item, true, true)
    end
    if neck_item then
        self.inst.components.inventory:DropItem(neck_item, true, true)
    end
end

return BlockBodyEquip
