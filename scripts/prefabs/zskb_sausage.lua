local assets = {
    Asset("ANIM", "anim/zskb_sausage.zip"),
    Asset("ANIM", "anim/zskb_meat_rack_food.zip"),
}

local function OnSpawnedFromHaunt(inst, data)
    Launch(inst, data.haunter, TUNING.LAUNCH_SPEED_SMALL)
end

local function common(bank, build, anim, tags, dryable, cookable)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(anim)
    inst.scrapbook_anim = anim

    --inst.pickupsound = "squidgy"

    inst:AddTag("meat")
    if tags ~= nil then
        for i, v in ipairs(tags) do
            inst:AddTag(v)
        end
    end

    if dryable ~= nil then
        --dryable (from dryable component) added to pristine state for optimization
        inst:AddTag("dryable")
        inst:AddTag("lureplant_bait")
    end

    if cookable ~= nil then
        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")
    end

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
    inst.components.edible.foodtype = FOODTYPE.MEAT

    inst:AddComponent("bait")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/zskb_inventoryimages.xml"

    inst:AddComponent("stackable")

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    if dryable ~= nil and dryable.product ~= nil then
        inst:AddComponent("dryable")
        inst.components.dryable:SetProduct(dryable.product)
        inst.components.dryable:SetDryTime(dryable.time)
        inst.components.dryable:SetBuildFile(dryable.build)
        inst.components.dryable:SetDriedBuildFile(dryable.dried_build)
    end

    if cookable ~= nil then
        inst:AddComponent("cookable")
        inst.components.cookable.product = cookable.product
    end

    MakeHauntableLaunchAndPerish(inst)
    inst:ListenForEvent("spawnedfromhaunt", OnSpawnedFromHaunt)

    return inst
end

local function driedmeat()
    local inst = common("zskb_meat_rack_food", "zskb_meat_rack_food", "idle_dried_sausage", nil, { isdried = true })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = 7
    inst.components.edible.hungervalue = 9
    inst.components.edible.sanityvalue = 6
    inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)

    inst.components.inventoryitem.imagename = "zskb_sausage_dried"

    return inst
end

local function raw()
    local inst = common("zskb_sausage", "zskb_sausage", "raw", { "catfood", "rawmeat" }, { product = "zskb_sausage_dried", build = "zskb_meat_rack_food", dried_build = "zskb_meat_rack_food", time = TUNING.DRY_MED + TUNING.DRY_FAST })

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.edible.healthvalue = 1
    inst.components.edible.hungervalue = 8
    inst.components.edible.sanityvalue = -3

    inst.components.perishable:SetPerishTime(TUNING.PERISH_FASTISH)

    inst.components.floater:SetVerticalOffset(0.05)

    inst.components.inventoryitem.imagename = "zskb_sausage"

    return inst
end

return Prefab("zskb_sausage", raw, assets),
    Prefab("zskb_sausage_dried", driedmeat, assets)
