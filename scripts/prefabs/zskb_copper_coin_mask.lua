local assets = {
    Asset("ANIM", "anim/zskb_copper_coin_mask.zip"),
}
local black_assets = {
    Asset("ANIM", "anim/zskb_black_copper_coin_mask.zip"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_hat", inst.prefab, "swap_hat")
    owner.AnimState:Show("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

    owner.AnimState:Show("HEAD")
    owner.AnimState:Hide("HEAD_HAT")
    owner.AnimState:Hide("HEAD_HAT_NOHELM")
    owner.AnimState:Hide("HEAD_HAT_HELM")

    if inst.components.fueled ~= nil then
        inst.components.fueled:StartConsuming()
    end

    -- owner.components.health.externalabsorbmodifiers:SetModifier(inst, 0.25)

    if inst.prefab == "zskb_black_copper_coin_mask" then
        if owner.components.zskb_zombie_gas then
            owner.components.zskb_zombie_gas:DoDelta(50, nil, false, true)
        end
    end
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

    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end

    -- owner.components.health.externalabsorbmodifiers:RemoveModifier(inst)

    if inst.prefab == "zskb_black_copper_coin_mask" then
        if owner.components.zskb_zombie_gas then
            owner.components.zskb_zombie_gas:DoDelta(-50, nil, false, true)
        end
    end
end

local function common(name)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild(name)
    inst.AnimState:SetBank(name)
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)

    inst:AddTag("zskb_keep_zombie_gas")
    inst:AddTag(name)
    inst:AddTag("hat")

    inst.entity:SetPristine()
    --------------------------------------------------------------------------
    if not TheWorld.ismastersim then
        return inst
    end
    --------------------------------------------------------------------------
    inst:AddComponent("inspectable")
    inst:AddComponent("trader")
    inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/zskb_inventoryimages.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

local function copperdepletedfn(inst)
    local owner = inst.components.inventoryitem.owner
    if owner ~= nil then
        if owner.components.inventory ~= nil then
            owner.components.inventory:GiveItem(SpawnPrefab("zskb_black_copper_coin_mask"))
        else
            SpawnPrefab("zskb_black_copper_coin_mask").Transform:SetPosition(inst:GetPosition():Get())
        end
    end
    inst:Remove()
end

local function copper()
    local inst = common("zskb_copper_coin_mask")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:SetDepletedFn(copperdepletedfn)
    inst.components.fueled:InitializeFuelLevel(TUNING.UMBRELLA_PERISHTIME)

    return inst
end

local function black_copper()
    local inst = common("zskb_black_copper_coin_mask")

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("zskb_copper_coin_mask", copper, assets),
    Prefab("zskb_black_copper_coin_mask", black_copper, black_assets)
