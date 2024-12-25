local assets =
{
    Asset("ANIM", "anim/zskb_paper_moon.zip"),
}

local function OnBurnt(inst)
    if TheWorld and TheWorld.state then
        --强制设置为全天黑夜
        TheWorld:PushEvent("ms_setclocksegs", { day = 0, dusk = 0, night = 16 })

        --设置月相为新月
        TheWorld:PushEvent("ms_setmoonphase", { moonphase = "new", iswaxing = true })
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("zskb_paper_moon")
    inst.AnimState:SetBuild("zskb_paper_moon")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("zskb_burn")
    inst:AddTag("furnituredecor")

    MakeInventoryFloatable(inst, "med", nil, 0.75)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    inst:AddComponent("tradable")

    inst:AddComponent("furnituredecor")

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    --添加监听点燃完成的逻辑
    inst:ListenForEvent("onburnt", OnBurnt)

    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab("zskb_paper_moon", fn, assets)
