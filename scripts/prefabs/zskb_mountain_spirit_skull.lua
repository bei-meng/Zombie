local assets =
{
    Asset("ANIM", "anim/zskb_mountain_spirit_skull.zip"),
}

local function fn(Sim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)

    inst.AnimState:SetBank("zskb_mountain_spirit_skull")
    inst.AnimState:SetBuild("zskb_mountain_spirit_skull")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("zskb_mountain_spirit_skull")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/zskb_inventoryimages.xml"

    return inst
end

return Prefab("zskb_mountain_spirit_skull", fn, assets)
