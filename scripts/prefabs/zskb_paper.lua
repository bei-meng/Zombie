local assets = {
    Asset("ANIM", "anim/zskb_paper.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("zskb_paper")
    inst.AnimState:SetBuild("zskb_paper")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("irreplaceable")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/zskb_inventoryimages.xml"

    MakeHauntable(inst)

    return inst
end

return Prefab("zskb_paper", fn, assets)
