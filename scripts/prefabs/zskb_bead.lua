local assets = {
    Asset("ANIM", "anim/zskb_bead.zip"),
    Asset("ANIM", "anim/swap_zskb_bead.zip"),
}

local function onequip(inst, owner)
    if owner == nil then
        return
    end
    owner.AnimState:OverrideSymbol("swap_body", "swap_zskb_bead", "bead")
    if owner.components.health then
        owner.components.health.externalabsorbmodifiers:SetModifier(inst, 0.05)
    end
    if owner.components.temperature ~= nil then
        owner.components.temperature:SetTemperature(20)
    end
    if inst.components.fueled ~= nil then
        inst.components.fueled:StartConsuming()
    end
end

local function onunequip(inst, owner)
    if owner == nil then
        return
    end
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if owner.components.health then
        owner.components.health.externalabsorbmodifiers:RemoveModifier(inst)
    end
    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end
end

local function onequiptomodel(inst, owner, from_ground)

end

local function ruinshat_fxanim(inst)
    inst._fx.AnimState:PlayAnimation("hit")
    inst._fx.AnimState:PushAnimation("idle_loop")
end

local function _onbroken(inst)
    local owner = inst.components.inventoryitem.owner
    inst:ruinshat_unproc(owner)
end

local function ruinshat_unproc(inst, owner)
    if inst:HasTag("forcefield") then
        inst:RemoveTag("forcefield")
        if inst._fx ~= nil then
            inst._fx:kill_fx()
            inst._fx = nil
        end
        inst:RemoveEventCallback("armordamaged", ruinshat_fxanim)
        inst:RemoveComponent("armor")

        if inst._task ~= nil then
            inst._task:Cancel()
            inst._task = nil
        end
    end
end

local function ruinshat_proc(inst, owner)
    inst:AddTag("forcefield")
    if inst._fx ~= nil then
        inst._fx:kill_fx()
    end
    inst._fx = SpawnPrefab("forcefieldfx")
    inst._fx.entity:SetParent(owner.entity)
    inst._fx.Transform:SetPosition(0, 0.2, 0)

    inst:AddComponent("armor")
    inst.components.armor:SetKeepOnFinished(true)
    inst.components.armor:SetOnFinished(_onbroken)
    inst:ListenForEvent("armordamaged", ruinshat_fxanim)
    inst.components.armor:SetAbsorption(TUNING.FULL_ABSORPTION)

    if inst._task ~= nil then
        inst._task:Cancel()
    end
    inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_DURATION, ruinshat_unproc, owner)
end

local function OnDepleted(inst)
    if inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
        local owner = inst.components.inventoryitem.owner
        if owner ~= nil and owner.components.inventory ~= nil then
            local item = owner.components.inventory:Unequip(inst.components.equippable.equipslot)
            if item ~= nil then
                owner.components.inventory:GiveItem(item, nil, owner:GetPosition())
            end
        end
        inst.components.equippable.restrictedtag = "mod_zskb_unbroken"
    end
end

local function accepttest(inst, item, giver)
    return item.prefab == "livinglog"
end

local function onacceptitem(inst, giver, item)
    if inst.components.fueled ~= nil then
        local owner = inst.components.inventoryitem.owner
        inst.components.fueled:DoDelta(TUNING.TOTAL_DAY_TIME, owner)
    end
end

local function OnPercentUsedChange(inst, data)
    if data.percent ~= nil and data.percent > 0 then
        inst.components.equippable.restrictedtag = nil
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("zskb_bead")
    inst.AnimState:SetBank("zskb_bead")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)

    inst:AddTag("zskb_bead")

    inst.entity:SetPristine()
    --------------------------------------------------------------------------
    if not TheWorld.ismastersim then
        return inst
    end
    --------------------------------------------------------------------------
    inst:AddComponent("inspectable")
    inst:AddComponent("trader")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/zskb_inventoryimages.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.MAGIC
    inst.components.fueled:InitializeFuelLevel(450)
    inst.components.fueled:SetDepletedFn(OnDepleted)
    inst.components.fueled.accepting = false

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(accepttest)
    inst.components.trader.onaccept = onacceptitem
    inst.components.trader.acceptnontradable = true

    MakeHauntableLaunch(inst)

    inst.ruinshat_proc = ruinshat_proc
    inst.ruinshat_unproc = ruinshat_unproc

    inst:ListenForEvent("percentusedchange", OnPercentUsedChange)

    return inst
end

return Prefab("zskb_bead", fn, assets)
