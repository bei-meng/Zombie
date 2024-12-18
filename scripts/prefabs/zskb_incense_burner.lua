local ASSETS_CONTAINER =
{
    Asset("ANIM", "anim/zskb_incense_burner.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("zskb_incense_burner")
    inst.AnimState:SetBuild("zskb_incense_burner")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("irreplaceable")

    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("heater")
    inst.components.heater.heat = 50        --热量
    inst.components.heater.carriedheat = 50 --持有热量

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_TINY

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunchAndDropFirstItem(inst)

    return inst
end

return Prefab("zskb_incense_burner", fn, ASSETS_CONTAINER)
