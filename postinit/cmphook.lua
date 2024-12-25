local RADIUS = 16 * 1.414
local upvaluehelper = require "zskb_upvaluehelper"
local ZombieGasBadge = require("widgets/zskb_zombie_gas")
local ZombieThreeFireBadge = require("widgets/zskb_zombie_threefire")
local HUD_UI = require("widgets/zskb_hud_ui")
local PaperUI = require("screens/zskb_paper_ui")
local TechTree = require("techtree")

local actions = upvaluehelper.Get(EntityScript.CollectActions, "COMPONENT_ACTIONS")
if actions then
    -- SCENE		using an object in the world
    -- USEITEM		using an inventory item on an object in the world
    -- POINT		using an inventory item on a point in the world
    -- EQUIPPED		using an equiped item on yourself or a target object in the world
    -- INVENTORY	using an inventory item
    if actions.SCENE and actions.SCENE.sleepingbag then
        local old_sleepingbag = actions.SCENE.sleepingbag
        actions.SCENE.sleepingbag = function(inst, doer, actions, right)
            if inst:HasTag("zskb_coffin") and doer.prefab == "zskb_zombie" and right then
                table.insert(actions, ACTIONS.SLEEPIN)
            end
            if (doer:HasTag("player") and not doer:HasTag("insomniac") and not inst:HasTag("hassleeper")) and
                (not inst:HasTag("spiderden") or doer:HasTag("spiderwhisperer")) and not inst:HasTag("zskb_coffin") and not right then
                table.insert(actions, ACTIONS.SLEEPIN)
            end
        end
    end

    if actions.USEITEM and actions.USEITEM.edible then
        local old_edible = actions.USEITEM.edible
        actions.USEITEM.edible = function(inst, doer, target, actions, right)
            local is_mountain_spirit_mask = target:HasTag("zskb_mountain_spirit_mask")
            if not (target.replica.rider ~= nil and target.replica.rider:IsRiding()) and
                not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding() and
                    not (target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsGrandOwner(doer))) and
                not target:HasTag("wereplayer") then
                if right and is_mountain_spirit_mask
                    and (inst:HasTag("preparedfood") or inst:HasTag("pre-preparedfood"))
                    and (inst:HasTag("edible_MEAT") or inst:HasTag("edible_VEGGIE")) then
                    table.insert(actions, ACTIONS.FEED)
                    return
                end
            end
            return old_edible(inst, doer, target, actions, right)
        end
    end
end

AddClassPostConstruct("widgets/statusdisplays", function(self, owner)
    local threefire_ptx = 42
    local threefire_pty = -175

    if KnownModIndex:IsModEnabledAny("workshop-376333686") then --Combined Status
        threefire_ptx = -125
        threefire_pty = -52
    end

    self.zskb_zombie_threefire_badge = self:AddChild(ZombieThreeFireBadge(owner))
    self.zskb_zombie_threefire_badge:SetPosition(threefire_ptx, threefire_pty, 0)

    local _ShowStatusNumbers = self.ShowStatusNumbers
    function self:ShowStatusNumbers()
        _ShowStatusNumbers(self)
        self.zskb_zombie_threefire_badge.num:Show()
    end

    local _HideStatusNumbers = self.HideStatusNumbers
    function self:HideStatusNumbers()
        _HideStatusNumbers(self)
        self.zskb_zombie_threefire_badge.num:Hide()
    end

    local _SetGhostMode = self.SetGhostMode
    function self:SetGhostMode(ghostmode)
        _SetGhostMode(self, ghostmode)
        if ghostmode then
            self.zskb_zombie_threefire_badge:Hide()
            self.zskb_zombie_threefire_badge:StopWarning()
        else
            self.zskb_zombie_threefire_badge:Show()
        end
    end
end)

AddClassPostConstruct("widgets/statusdisplays", function(self, owner)
    if not owner:HasTag("zskb_zombie") then
        return
    end

    local gas_ptx = 42
    local gas_pty = -100

    if KnownModIndex:IsModEnabledAny("workshop-376333686") then --Combined Status
        gas_ptx = -60
        gas_pty = -52
    end

    self.zskb_zombie_gas_badge = self:AddChild(ZombieGasBadge(owner))
    self.zskb_zombie_gas_badge:SetPosition(gas_ptx, gas_pty, 0)

    local _ShowStatusNumbers = self.ShowStatusNumbers
    function self:ShowStatusNumbers()
        _ShowStatusNumbers(self)
        self.zskb_zombie_gas_badge.num:Show()
    end

    local _HideStatusNumbers = self.HideStatusNumbers
    function self:HideStatusNumbers()
        _HideStatusNumbers(self)
        self.zskb_zombie_gas_badge.num:Hide()
    end

    local _SetGhostMode = self.SetGhostMode
    function self:SetGhostMode(ghostmode)
        _SetGhostMode(self, ghostmode)
        if ghostmode then
            self.zskb_zombie_gas_badge:Hide()
            self.zskb_zombie_gas_badge:StopWarning()
        else
            self.zskb_zombie_gas_badge:Show()
        end
    end
end)


AddClassPostConstruct("components/debuff", function(self)
    local old_OnSave = self.OnSave
    function self:OnSave()
        local result
        if old_OnSave then
            result = old_OnSave(self)
        end
        if result == nil then
            result = {}
        end
        result.data = self.data
        return result
    end

    local old_OnLoad = self.OnLoad
    function self:OnLoad(data)
        if old_OnLoad then
            old_OnLoad(self, data)
        end
        if data then
            self.data = data.data
        end
    end

    local old_AttachTo = self.AttachTo
    function self:AttachTo(name, target, followsymbol, followoffset, data)
        if data ~= nil then
            self.data = data
        end
        if old_AttachTo then
            data = data == nil and self.data or data
            old_AttachTo(self, name, target, followsymbol, followoffset, data)
        end
    end

    local old_Extend = self.Extend
    function self:Extend(followsymbol, followoffset, data)
        if data ~= nil then
            self.data = data
        end
        if old_Extend then
            data = data == nil and self.data or data
            old_Extend(self, followsymbol, followoffset, data)
        end
    end
end)

AddClassPostConstruct("components/combat", function(self)
    local old_GetAttacked = self.GetAttacked
    function self:GetAttacked(attacker, damage, weapon, stimuli, spdamage)
        -- 如果装备了符咒，伤害固定为1
        if attacker ~= nil and attacker:HasTag("player") and attacker.components.inventory ~= nil and attacker.components.inventory:EquipHasTag("zskb_fireproof_runepaper") then
            damage = 1
            if spdamage ~= nil then
                for t, d in pairs(spdamage) do
                    spdamage[t] = 0
                end
            end
        end
        old_GetAttacked(self, attacker, damage, weapon, stimuli, spdamage)
    end
end)

AddClassPostConstruct("screens/playerhud", function(self)
    local old_CreateOverlays = self.CreateOverlays
    local old_OnUpdate = self.OnUpdate
    local Zskb_leafcanopy = require "widgets/zskb_leafcanopy"
    function self:CreateOverlays(owner)
        if old_CreateOverlays then
            old_CreateOverlays(self, owner)
        end

        if owner and owner:HasTag("zskb_zombie") then
            self.zskb_hud_icon = self.root:AddChild(HUD_UI(self, owner))
        end

        function self:ZskbPaperUIShow()
            self.zskb_paper = self.overlayroot:AddChild(PaperUI(owner))
            self.zskb_paper:SetScaleMode(SCALEMODE_PROPORTIONAL)
            self.zskb_paper:SetHAnchor(ANCHOR_MIDDLE)
            self.zskb_paper:SetVAnchor(ANCHOR_MIDDLE)
            -- 在OpenScreenUnderPause中打开，滚动不会影响游戏视角的缩放
            self:OpenScreenUnderPause(self.zskb_paper)
        end

        function self:CloseZskbPaperUIScreen()
            if self.zskb_paper ~= nil then
                if self.zskb_paper.inst:IsValid() then
                    TheFrontEnd:PopScreen(self.zskb_paper)
                end
                self.zskb_paper = nil
            end
        end

        --榕树树荫
        self.zskb_leafcanopy = self.overlayroot:AddChild(Zskb_leafcanopy(owner))
    end

    function self:OnUpdate(dt)
        if old_OnUpdate then
            old_OnUpdate(self, dt)
        end
        --榕树树荫
        if self.zskb_leafcanopy then
            self.zskb_leafcanopy:OnUpdate(dt)
        end
    end
end)

-- this is for temp techbonus count of coffin buff
AddClassPostConstruct("components/builder", function(self, inst)
    local old_ConsumeTempTechBonuses = self.ConsumeTempTechBonuses
    self.ConsumeTempTechBonuses = function(self)
        if self.inst.components.debuffable and self.inst.components.debuffable:HasDebuff("zskb_buff_craft") then
            return -- cost craftbuff_count here rather than temp techbonus
        end
        return old_ConsumeTempTechBonuses and old_ConsumeTempTechBonuses(self)
    end
end)
--quick fix for green amulet but not yet for other mod items
AddPrefabPostInit("greenamulet", function(inst)
    if not (TheWorld and TheWorld.ismastersim) then return end
    local modify_onitembuild = function(inst)
        local old_onitembuild = inst.onitembuild
        inst.onitembuild = function(owner, ...)
            if owner.components.zskb_zombie and owner.components.zskb_zombie:HasCraftModifier() then
                return
            end
            return old_onitembuild and old_onitembuild(owner, ...)
        end
    end

    local old_onequipfn = inst.components.equippable and inst.components.equippable.onequipfn
    if old_onequipfn then
        inst.components.equippable.onequipfn = function(inst, owner, ...)
            if old_onequipfn then
                old_onequipfn(inst, owner, ...)
                modify_onitembuild(inst)
            end
        end
    end

    local old_onunequipfn = inst.components.equippable.onunequipfn
    if old_onunequipfn then
        inst.components.equippable.onunequipfn = function(inst, owner, ...)
            if old_onunequipfn then
                old_onunequipfn(inst, owner, ...)
                if owner.components.zskb_zombie and owner.components.zskb_zombie:HasCraftModifier() then
                    if owner.components.builder then
                        owner.components.builder.ingredientmod = TUNING.GREENAMULET_INGREDIENTMOD
                    end
                end
            end
        end
    end
end)

AddClassPostConstruct("components/health", function(self)
    local old_SetVal = self.SetVal
    function self:SetVal(val, cause, afflicter)
        if val <= 0 and self.inst.components.inventory and self.inst.components.inventory:EquipHasTag("zskb_bead") then
            local bead = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
            if bead then
                if bead.components.fueled ~= nil then
                    bead.components.fueled:MakeEmpty()
                end
                bead:ruinshat_proc(self.inst)
                val = self.currenthealth
            end
        end
        if old_SetVal then
            old_SetVal(self, val, cause, afflicter)
        end
    end
end)

AddClassPostConstruct("components/temperature", function(self)
    local old_OnUpdate = self.OnUpdate
    function self:OnUpdate(dt, ...)
        -- 装备黑菩提锁定温度
        if self.inst:HasTag("player") and
            not self.inst:HasTag("playerghost") and
            self.inst.components.inventory ~= nil and
            self.inst.components.inventory:EquipHasTag("zskb_bead") then
            return
        end
        old_OnUpdate(self, dt, ...)
    end
end)
AddClassPostConstruct("components/builder_replica", function(self)
    local old_CanLearn = self.CanLearn
    function self:CanLearn(recipename)
        local machine = self.classified.current_prototyper:value()
        local recipe = GetValidRecipe(recipename)
        if machine ~= nil and machine:HasTag("zskb_copper_crane_platform") then
            if recipe ~= nil and recipe.level ~= nil and ((machine:HasTag("lvl_1") and recipe.level["ZSKB_CCP_ONE"] == 1) or (machine:HasTag("lvl_2") and recipe.level["ZSKB_CCP_TWO"] == 1)) then
                return true
            end
            return false
        else
            return old_CanLearn(self, recipename)
        end
    end
end)

AddClassPostConstruct("components/inventoryitem", function(self)
    local old_RemoveFromOwner = self.RemoveFromOwner
    function self:RemoveFromOwner(...)
        if self.inst.prefab == "zskb_brightly_light" and self.owner ~= nil then
            self.owner:RemoveTag("ghostlyfriend")
        end
        return old_RemoveFromOwner(self, ...)
    end
end)

AddClassPostConstruct("components/growable", function(self)
    local old_StartGrowing = self.StartGrowing
    function self:StartGrowing(time)
        old_StartGrowing(self, time)

        if self.inst:HasTag("zskb_farmplant_qinglong") and self.targettime then
            local timeToGrow = self.targettime - GetTime()
            self:ExtendGrowTime(-(timeToGrow * 0.15))
        end
    end
end)
AddClassPostConstruct("components/workable", function(self)
    local old_CanBeWorked = self.CanBeWorked
    function self:CanBeWorked(...)
        local ix, iy, iz = self.inst.Transform:GetWorldPosition()
        local nearby_structures = TheSim:FindEntities(ix, iy, iz, RADIUS, { "zskb_statue" })
        local can_hammer = true
        for _, structure in pairs(nearby_structures) do
            if structure.prefab == "zskb_xuanwu" and self.inst.prefab ~= "zskb_xuanwu" then
                can_hammer = false
                break
            end
        end
        return can_hammer and old_CanBeWorked(self, ...)
    end
end)

AddClassPostConstruct("components/explosive", function(self)
    local old_OnBurnt = self.OnBurnt
    function self:OnBurnt(...)
        local CANT_TAGS = { "INLIMBO" }
        local x, y, z = self.inst.Transform:GetWorldPosition()
        local stacksize = self.inst.components.stackable ~= nil and self.inst.components.stackable:StackSize() or 1
        local totaldamage = self.explosivedamage * stacksize
        local ents = TheSim:FindEntities(x, y, z, self.explosiverange * 2, nil, CANT_TAGS)
        for i, v in ipairs(ents) do
            if v.prefab == "zskb_cedartree" then
                v.components.health:DoDelta(-totaldamage, nil, self.inst.prefab, true)
            end
        end

        old_OnBurnt(self, ...)
    end
end)


-- 应用位面吸收甲组件
AddComponentPostInit("inventory", function(self)
    local old_ApplyDamage = self.ApplyDamage
    self.ApplyDamage = function(self, damage, attacker, weapon, spdamage, ...)
        local planar_damage = spdamage ~= nil and type(spdamage) == "table" and spdamage["planar"] or nil
        if planar_damage ~= nil then
            local planar_absorbers = {}
            local damagetypemult = 1
            for k, v in pairs(self.equipslots) do
                --check resistance
                if v.components.resistance ~= nil and
                    v.components.resistance:HasResistance(attacker, weapon) and
                    v.components.resistance:ShouldResistDamage() then
                    v.components.resistance:ResistDamage(damage)
                    return 0, nil
                elseif v.components.zskb_planar_armor ~= nil then
                    -- just assume we are the only one planar absorber component
                    planar_absorbers[v.components.zskb_planar_armor] = v.components.zskb_planar_armor:GetAbsorption(attacker, weapon) or 0
                end
                if v.components.damagetyperesist ~= nil then
                    damagetypemult = damagetypemult * v.components.damagetyperesist:GetResist(attacker, weapon)
                end
            end

            planar_damage = planar_damage * damagetypemult

            -- these are planar damage absorptions
            local absorbed_percent = 0
            local total_absorption = 0
            for armor, amt in pairs(planar_absorbers) do
                -- print("\t", armor.inst, "absorbs", amt)
                absorbed_percent = math.max(amt, absorbed_percent)
                total_absorption = total_absorption + amt
            end

            local absorbed_damage = planar_damage * absorbed_percent
            local leftover_damage = planar_damage - absorbed_damage
            spdamage["planar"] = leftover_damage

            local planar_armor_damage = {}
            if total_absorption > 0 then
                -- ProfileStatsAdd("armor_absorb", absorbed_damage)

                for armor, amt in pairs(planar_absorbers) do
                    planar_armor_damage[armor] = absorbed_damage * amt / total_absorption
                end
            end

            -- Apply planar armor durability loss
            for armor, dmg in pairs(planar_armor_damage) do
                armor:TakeDamage(dmg)
            end
        end
        return old_ApplyDamage(self, damage, attacker, weapon, spdamage, ...)
    end
end)

-- 玩家死亡重生后不消失的debuff
AddComponentPostInit("debuffable", function(self, inst)
    local function RegisterDebuff(self, name, ent, data)
        if ent.components.debuff ~= nil then
            self.debuffs[name] =
            {
                inst = ent,
                onremove = function(debuff)
                    self.debuffs[name] = nil
                    if self.ondebuffremoved ~= nil then
                        self.ondebuffremoved(self.inst, name, debuff)
                    end
                end,
            }
            self.inst:ListenForEvent("onremove", self.debuffs[name].onremove, ent)
            ent.persists = false
            ent.components.debuff:AttachTo(name, self.inst, self.followsymbol, self.followoffset, data)
            if self.ondebuffadded ~= nil then
                self.ondebuffadded(self.inst, name, ent, data)
            end
        else
            ent:Remove()
        end
    end

    if inst == nil or not inst:HasTag("player") then return end
    local old_Enable = self.Enable
    self.Enable = function(self, enable)
        if not enable then
            self.zskb_tmp_debuffs = {}
            for k, v in pairs(self.debuffs) do
                -- print(v or "nil", v.inst or "nil", v.inst.zskb_dontremoveondeath and "true" or "false")
                if v and v.inst and v.inst.zskb_dontremoveondeath then
                    local saved --[[, refs]] = v.inst:GetSaveRecord()
                    self.zskb_tmp_debuffs[k] = saved
                end
            end
        else
            if self.zskb_tmp_debuffs ~= nil then
                for k, v in pairs(self.zskb_tmp_debuffs) do
                    if self.debuffs[k] == nil then
                        local ent = SpawnSaveRecord(v)
                        if ent ~= nil then
                            RegisterDebuff(self, k, ent)
                        end
                    end
                end
                self.zskb_tmp_debuffs = nil
            end
        end
        return old_Enable(self, enable)
    end

    self.PauseDebuff = function(name)
        local debuff = self:GetDebuff(name)
        if debuff ~= nil and debuff.inst ~= nil then
            debuff.inst.components.timer:PauseTimer("buffover")
        end
    end

    self.ResumeDebuff = function(name)
        local debuff = self:GetDebuff(name)
        if debuff ~= nil and debuff.inst ~= nil then
            debuff.inst.components.timer:ResumeTimer("buffover")
        end
    end

    local old_OnSave = self.OnSave
    self.OnSave = function(self)
        local data = old_OnSave(self)
        if data ~= nil then
            data.zskb_tmp_debuffs = self.zskb_tmp_debuffs
        end
        return data
    end

    local old_OnLoad = self.OnLoad
    self.OnLoad = function(self, data)
        if data ~= nil then
            self.zskb_tmp_debuffs = data.zskb_tmp_debuffs
        end
        return old_OnLoad(self, data)
    end
end)

-- 僵尸见光持久燃烧
AddComponentPostInit("burnable", function(self, inst)
    self.ZSKB_IgniteForLastingBurning = function(self)
        -- HACK
        self.zskb_lastingburning = true
        local origin_burntime = self.burntime
        self.burntime = math.huge
        self.inst.components.burnable:Ignite(true, TheWorld)
        self.burntime = origin_burntime
    end

    local old_Extinguish = self.Extinguish
    self.Extinguish = function(...)
        old_Extinguish(...)
        if self.zskb_lastingburning then
            self.zskb_lastingburning = false
        end
    end
end)

-- 可堆叠的东西给予火盆，直接全部给火盆
local function FireBasin_AcceptDecor(self)
    local _OldAcceptDecor = self.AcceptDecor

    function self:AcceptDecor(item, giver)
        if self.inst.prefab == "zskb_fire_basin" then
            local stackable = item.components.stackable
            if stackable and stackable:IsStack() then
                item.components.inventoryitem:RemoveFromOwner(true)
            else
                item.components.inventoryitem:RemoveFromOwner(true)
            end

            if self.ondecorgiven then
                self.ondecorgiven(self.inst, item, giver)
            end

            self.decor_item = item
            self.enabled = false

            self.inst:ListenForEvent("onremove", self._on_decor_item_removed, item)
            self.inst:ListenForEvent("onpickup", self._on_decor_item_picked_up, item)

            local item_furnituredecor = item.components.furnituredecor
            if item_furnituredecor then
                item_furnituredecor:PutOnFurniture(self.inst)
            end

            return true
        else
            return _OldAcceptDecor(self, item, giver)
        end
    end
end
AddComponentPostInit("furnituredecortaker", FireBasin_AcceptDecor)
