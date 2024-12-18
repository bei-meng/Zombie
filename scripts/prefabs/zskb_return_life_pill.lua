local assets = {
    Asset("ANIM", "anim/zskb_return_life_pill.zip"),
}

local function oneaten(inst, eater)
    if eater.components.debuffable then
        if eater.components.debuffable:HasDebuff("zskb_buff_return_life_pill") then
            eater.components.debuffable:RemoveDebuff("zskb_buff_return_life_pill")
        end
        local buff = eater.components.debuffable:AddDebuff("zskb_buff_return_life_pill", "zskb_buff_return_life_pill")
        buff.components.timer:SetTimeLeft("buffover", TUNING.TOTAL_DAY_TIME)
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("zskb_return_life_pill")
    inst.AnimState:SetBank("zskb_return_life_pill")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)

    inst:AddTag("zskb_return_life_pill")

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
    inst.components.inventoryitem.imagename = "zskb_return_life_pill"

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.GOODIES
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 0
    inst.components.edible.sanityvalue = 0
    inst.components.edible.oneaten = oneaten

    inst:AddComponent("stackable")

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("zskb_return_life_pill", fn, assets)
