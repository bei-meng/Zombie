local assets = {
    Asset("ANIM", "anim/zskb_mountain_spirit_mask.zip"),
    Asset("SOUNDPACKAGE", "sound/zskb_mountain_spirit.fev"),
    Asset("SOUND", "sound/zskb_mountain_spirit.fsb"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_hat", inst.prefab, "swap_hat")
    owner.AnimState:Show("HAT")
    -- owner.AnimState:Show("HAIR_HAT") -- 因为后脑勺会露出来
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
        owner.AnimState:Show("HEAD_HAT_NOHELM")
        owner.AnimState:Hide("HEAD_HAT_HELM")
    end

    inst.onattach(owner)
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("headbase_hat") --it might have been overriden by _onequip

    owner.AnimState:ClearOverrideSymbol("swap_hat")
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
        owner.AnimState:Hide("HEAD_HAT_NOHELM")
        owner.AnimState:Hide("HEAD_HAT_HELM")
    end

    inst.ondetach(owner)
end


-- local function ToggleAllAbsorptions(inst, enabled)
--     if inst.components.armor then
--         inst.components.armor:SetAbsorption(enabled and TUNING.ARMOR_ZSKB_MOUNTAIN_SPIRIT_MASK_ABSOPTION or 0)
--     end
--     if inst.components.planardefense then
--         inst.components.planardefense:SetBaseDefense(enabled and TUNING.ARMOR_ZSKB_MOUNTAIN_SPIRIT_MASK_PLANAR_DEF or 0)
--     end
-- end

local function onbroken(inst)
    if inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
        local owner = inst.components.inventoryitem.owner
        if owner ~= nil and owner.components.inventory ~= nil then
            local item = owner.components.inventory:Unequip(inst.components.equippable.equipslot)
            if item ~= nil then
                owner.components.inventory:GiveItem(item, nil, owner:GetPosition())
            end
        end
    end

    if inst.components.equippable ~= nil then
        inst:RemoveComponent("equippable")
        -- inst.AnimState:PlayAnimation("broken")
        -- inst.components.floater:SetSwapData()
        inst:AddTag("broken")
        inst.components.inspectable.nameoverride = "ZSKB_MOUNTAIN_SPIRIT_MASK_BROKEN"
    end
end

local function onrepaired(inst)
    if inst.components.equippable == nil then
        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)
        inst.AnimState:PlayAnimation("anim")
        -- inst.components.floater:SetSwapData(swap_data)
        inst:RemoveTag("broken")
        inst.components.inspectable.nameoverride = nil
    end
end

local function oneatfn(inst, food)
    if inst.components.armor then
        local foodtype = food.components.edible and food.components.edible.foodtype or nil
        local maxcondition = inst.components.armor.maxcondition or 100
        local amount = foodtype == FOODTYPE.MEAT and 0.5 * maxcondition or 0.25 * maxcondition
        local percent = inst.components.armor:GetPercent()
        if percent <= 0 then
            -- ToggleAllAbsorptions(inst, true)
            onrepaired(inst)
        end

        inst.components.armor:Repair(amount)
        if not inst.inlimbo then
            -- we have no eating animation yet
            -- inst.AnimState:PlayAnimation("eat")
            -- inst.AnimState:PushAnimation("anim", true)
            inst.SoundEmitter:PlaySound("terraria1/eyemask/eat")
        end
    end
end

local SCARE_HUNGRY_COST = 10
local SCARE_RANGE = 20
local SCARE_DURING = 6
local SCARE_CD = 8
local SCARE_EPICBOSS_DMGMUL = 0.85
local SCARE_MUST_TAGS = { "_combat", "_health" }
local SCARE_CANT_TAGS = { "INLIMBO", "structure", "butterfly", "wall", "balloon", "groundspike", "smashable", "companion" }

local function HasFriendlyLeader(inst, target, PVP_enabled)
    local target_leader = (target.components.follower ~= nil) and target.components.follower.leader or nil

    if target_leader and target_leader.components.inventoryitem then
        target_leader = target_leader.components.inventoryitem:GetGrandOwner()
        -- Don't attack followers if their follow object has no owner, unless its pvp, then there are no rules!
        if target_leader == nil then
            return not PVP_enabled
        end
    end

    return (target_leader ~= nil and (target_leader == inst or (not PVP_enabled and target_leader:HasTag("player"))))
        or (not PVP_enabled and target.components.domesticatable and target.components.domesticatable:IsDomesticated())
        or (not PVP_enabled and target.components.saltlicker and target.components.saltlicker.salted)
end

local function CanScare(inst, owner, target)
    return owner.components.combat and owner.components.combat:CanTarget(target)
        and not owner:HasTag("player")
        or (not HasFriendlyLeader(owner, target, TheNet:GetPVPEnabled()) and (not target:HasTag("prey") or (target:HasTag("prey") and target:HasTag("hostile"))))
end

local function AttachDMGReduceBuff(target)
    if target.components.debuffable == nil then
        target:AddComponent("debuffable")
    end

    if target.components.debuffable:HasDebuff("zskb_buff_damage_reduce") then
        target.components.debuffable:RemoveDebuff("zskb_buff_damage_reduce")
    end

    local buff = target.components.debuffable:AddDebuff("zskb_buff_damage_reduce", "zskb_buff_damage_reduce")
    buff.components.timer:SetTimeLeft("buffover", SCARE_DURING)
end


local function DoScare(inst, owner)
    local hunger = owner.components.hunger
    if hunger ~= nil then
        hunger:DoDelta(-SCARE_HUNGRY_COST)
        local x, y, z = owner.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, SCARE_RANGE, SCARE_MUST_TAGS, SCARE_CANT_TAGS)
        for _, v in ipairs(ents) do
            if CanScare(inst, owner, v) then
                if v.components.hauntable ~= nil and v.components.hauntable.panicable then
                    v.components.hauntable:Panic(SCARE_DURING)
                    v:DoTaskInTime(math.random() * 0.25, function()
                        local x, y, z = v.Transform:GetWorldPosition()
                        local fx = SpawnPrefab("battlesong_instant_taunt_fx")
                        if fx then
                            fx.Transform:SetPosition(x, y, z)
                        end
                    end)
                elseif v:HasTag("epic") then
                    AttachDMGReduceBuff(v)
                end
            end
        end
        if inst._scare_cd_task ~= nil then
            inst._scare_cd_task:Cancel()
        end
        inst._scare_cd_task = inst:DoTaskInTime(SCARE_CD, function() inst._scare_cd_task = nil end)

        -- play sound (optional )
        inst.SoundEmitter:PlaySound("zskb_mountain_spirit/mountain_spirit/taunt")
    end
end

local function TryScare(inst, owner, data)
    if inst._scare_cd_task == nil and -- not in cd
        not data.redirected then
        DoScare(inst, owner)
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("zskb_mountain_spirit_mask")
    inst.AnimState:SetBank("zskb_mountain_spirit_mask")
    inst.AnimState:PlayAnimation("anim")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)

    inst:AddTag("zskb_mountain_spirit_mask")
    inst:AddTag("hat")
    --waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")
    inst:AddTag("handfed") -- make it can be fed when holding
    -- inst:AddTag("fedbyall") -- make we can pick FEED action, or we can hook componentactions

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/zskb_inventoryimages.xml"

    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("eater")
    inst.components.eater:SetOnEatFn(oneatfn)

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMOR_ZSKB_MOUNTAIN_SPIRIT_MASK, TUNING.ARMOR_ZSKB_MOUNTAIN_SPIRIT_MASK_ABSOPTION)
    inst.components.armor:SetKeepOnFinished(true)
    inst.components.armor:SetOnFinished(function()
        -- ToggleAllAbsorptions(inst, false)
        onbroken(inst)
    end)

    -------------- scare enemies on attacked ------------------
    inst._owner = nil
    inst._scare_cd_task = nil
    inst.scarefn = function(owner, data) TryScare(inst, owner, data) end
    inst.onattach = function(owner)
        if inst._owner ~= nil then
            inst:RemoveEventCallback("attacked", inst.scarefn, inst._owner)
            inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
        end
        inst:ListenForEvent("attacked", inst.scarefn, owner)
        inst:ListenForEvent("onremove", inst.ondetach, owner)
        inst._owner = owner
        -- inst._fx = nil
    end
    inst.ondetach = function()
        if inst._owner ~= nil then
            inst:RemoveEventCallback("attacked", inst.scarefn, inst._owner)
            inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
            inst._owner = nil
            -- inst._fx = nil
        end
    end
    ----------------------------------------------------------

    -- inst:AddComponent("planardefense")
    -- inst.components.planardefense:SetBaseDefense(TUNING.ARMOR_ZSKB_MOUNTAIN_SPIRIT_MASK_PLANAR_DEF)
    inst:AddComponent("zskb_planar_armor") -- see cmphook inventory postinit
    inst.components.zskb_planar_armor:SetAbsorption(TUNING.ARMOR_ZSKB_MOUNTAIN_SPIRIT_MASK_PLANAR_ABSOPTION)

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("zskb_mountain_spirit_mask", fn, assets)
