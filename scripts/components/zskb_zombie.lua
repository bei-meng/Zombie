local function on_rain_contorl(self, can_rain_control)
    self.inst.replica.zskb_zombie._can_rain_control:set(can_rain_control)
end
local function on_can_night_vision(self, can_night_vision)
    self.inst.replica.zskb_zombie._can_night_vision:set(can_night_vision)
end

local function CheckImmuneToSunShine(self)
    return TheWorld.state.israining or
        TheWorld.state.isnight or
        TheWorld:HasTag("cave") or
        self.inst.sleepingbag ~= nil or
        self.inst:HasTag("spawnprotection") or
        (self.inst.canopytrees ~= nil and self.inst.canopytrees > 0) or -- 水中木
        -- (self.inst.components.sheltered and self.inst.components.sheltered.sheltered) or -- 树边乘凉
        (self.inst.components.inventory:EquipHasTag("zskb_zombie_umbrella") and not self.inst.components.inventory:EquipHasTag("zskb_copper_coin_umbrella_close")) or
        self.inst.components.inventory:EquipHasTag("zskb_fireproof_runepaper") or
        self.inst.components.health:IsInvincible() or
        self.under_copper_coin_umbrella or
        self.inst:IsPointInRoom() or -- 在山神庙里
        self.inst.components.debuffable:HasDebuff("zskb_buff_return_life_pill")
end

local function OnTaskTick(inst, self, period)
    local burnable = self.inst.components.burnable
    if burnable ~= nil then
        if CheckImmuneToSunShine(self) then
            self.burning_timer = 0
            if burnable:IsBurning() and burnable.zskb_lastingburning then
                inst.components.burnable:Extinguish()
            end
        elseif not burnable:IsBurning() then
            self.burning_timer = self.burning_timer + period
            if self.burning_timer > self.burning_threshold and burnable.ZSKB_IgniteForLastingBurning then
                burnable:ZSKB_IgniteForLastingBurning() -- see postinit/cmphook.lua
            end
        end
    end
end

local Zombie = Class(function(self, inst)
    self.inst = inst

    self.under_copper_coin_umbrella = false
    self.craftbuff_count = 0
    self.can_rain_control = false
    self.can_night_vision = false
    self.burning_threshold = 2 -- 超过时间则开始燃烧
    self.burning_timer = 0

    local period = 1
    self.inst:DoPeriodicTask(period, OnTaskTick, nil, self, period)
    self.inst:DoTaskInTime(0, function()
        local debuffable = self.inst.components.debuffable
        if self:HasCraftModifier() and debuffable and not debuffable:HasDebuff("zskb_buff_craft") then
            local prev_count = self.craftbuff_count
            debuffable:AddDebuff("zskb_buff_craft", "zskb_buff_craft")
            self:SetCraftModifierCount(prev_count)
        end
    end)
end, nil, {
    can_rain_control = on_rain_contorl,
    can_night_vision = on_can_night_vision,
})

function Zombie:OnSave()
    return {
        craftbuff_count = self.craftbuff_count,
        can_rain_control = self.can_rain_control,
        can_night_vision = self.can_night_vision,
    }
end

function Zombie:OnLoad(data)
    if data then
        self.craftbuff_count = data.craftbuff_count or 0
        self.can_rain_control = data.can_rain_control or false
        self.can_night_vision = data.can_night_vision or false
    end

    self.inst.replica.zskb_zombie._can_rain_control:set(self.can_rain_control or false)
    self.inst.replica.zskb_zombie._can_night_vision:set(self.can_night_vision or false)
end

local function GetEquippedGreenAmulet(inst)
    return inst.components.inventory:GetEquippedItem(EQUIPSLOTS.AMULET or EQUIPSLOTS.BODY) == "greenamulet"
end

local function KeyTableContains(table_large, table_tiny)
    -- lazy to write sanity check here
    for k, v in pairs(table_tiny) do
        if table_large[k] ~= v then
            return false
        end
    end
    return true
end

local TechTree = require("techtree")
local function ConsumeTempTechBonuses(self)
    self.temptechbonus_count = (self.temptechbonus_count or 1) - 1
    if self.temptechbonus_count < 1 then
        for i, v in ipairs(TechTree.BONUS_TECH) do
            if self[string.lower(v) .. "_tempbonus"] ~= nil then
                self[string.lower(v) .. "_tempbonus"] = nil
            end
        end

        self.temptechbonus_count = nil
    end
end

function Zombie:SetCraftModifierCount(count)
    -- IngredientMod must be one of the following values
    -- INGREDIENT_MOD_LOOKUP =
    -- {
    --     [0] = 0,
    --     [1] = 0.25,
    --     [2] = 0.5,
    --     [3] = 0.75,
    --     [4] = 1.0,
    -- }
    local tech_tbl, mod = { SCIENCE = 2, MAGIC = 2, SEAFARING = 2 }, TUNING.GREENAMULET_INGREDIENTMOD
    local builder = self.inst.components.builder
    if builder == nil then return end
    self.craftbuff_count = count
    if count < 1 then
        if KeyTableContains(builder:GetTempTechBonuses(), tech_tbl) then
            ConsumeTempTechBonuses(builder)
        end
        builder.ingredientmod = GetEquippedGreenAmulet(self.inst) and TUNING.GREENAMULET_INGREDIENTMOD or 1
    else
        if not KeyTableContains(builder:GetTempTechBonuses(), tech_tbl) then
            builder:GiveTempTechBonus(tech_tbl)
        end
        builder.ingredientmod = mod
    end
    self.craftbuff_count = count
end

function Zombie:HasCraftModifier()
    return type(self.craftbuff_count) == "number" and self.craftbuff_count >= 1
end

function Zombie:SetCanRainControl(can_rain_control)
    self.can_rain_control = can_rain_control
end

function Zombie:SetCanNightVision(can_night_vision)
    self.can_night_vision = can_night_vision
end

return Zombie
