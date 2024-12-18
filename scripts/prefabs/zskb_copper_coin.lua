local assets = {
    Asset("ANIM", "anim/zskb_copper_coin.zip"),
}

local function ontimerdone(inst)
    -- if inst.components.stackable:StackSize() == 1 then
    --     local owner = inst.components.inventoryitem.owner
    --     if owner then
    --         inst:Remove()

    --         local black = SpawnPrefab("zskb_black_copper_coin")
    --         owner.components.container:GiveItem(black)
    --     end
    -- end
    local owner = inst.components.inventoryitem.owner
    if owner then
        owner:PushEvent("coin_convert_finished", { coin = inst }) -- zskb_coffin will listen this
    end
end

local function common(anim, name)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("zskb_copper_coin")
    inst.AnimState:SetBank("zskb_copper_coin")
    inst.AnimState:PlayAnimation(anim)

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)

    -- inst:AddTag("zskb_copper_coin")
    inst:AddTag(name)

    inst.entity:SetPristine()
    --------------------------------------------------------------------------
    if not TheWorld.ismastersim then
        return inst
    end
    --------------------------------------------------------------------------
    inst:AddComponent("inspectable")
    inst:AddComponent("stackable")
    inst:AddComponent("trader")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/zskb_inventoryimages.xml"
    inst.components.inventoryitem.imagename = name

    MakeHauntableLaunch(inst)

    return inst
end

local function fn()
    local inst = common("idle", "zskb_copper_coin")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)

    inst:AddComponent("tradable")
    inst.components.tradable.zskbtoy = 1

    return inst
end

local function black_fn()
    local inst = common("black", "zskb_black_copper_coin")

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("zskb_copper_coin", fn, assets),
    Prefab("zskb_black_copper_coin", black_fn, assets)
