local assets =
{
    Asset("ANIM", "anim/zskb_red_packet.zip"),
}

local prefabs =
{
    "monkey_morphin_power_players_fx", --被诅咒附身的特效
}

local function OnUnwrapped(inst, pos, doer)
    SpawnPrefab("zskb_red_packet2").Transform:SetPosition(pos:Get())

    if doer ~= nil and doer.SoundEmitter ~= nil then
        doer.SoundEmitter:PlaySound("dontstarve/common/together/packaged")
    end
    inst:Remove()
end

local function fn1()
    local inst = CreateEntity() --创建实体

    inst.entity:AddTransform()  --添加坐标属性
    inst.entity:AddAnimState()  --添加动画属性
    inst.entity:AddNetwork()    --添加网络属性

    MakeInventoryPhysics(inst)  --预设物理属性
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)

    inst.AnimState:SetBank("zskb_red_packet")
    inst.AnimState:SetBuild("zskb_red_packet")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("nosteal") --不可偷窃

    MakeInventoryFloatable(inst, "med", 0.05, 0.68)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/zskb_inventoryimages.xml"
    inst.components.inventoryitem:ChangeImageName("zskb_red_packet1")

    inst:AddComponent("inspectable")

    inst:AddComponent("unwrappable")
    inst.components.unwrappable:SetOnUnwrappedFn(OnUnwrapped)

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

local function fn2()
    local inst = CreateEntity() --创建实体

    inst.entity:AddTransform()  --添加坐标属性
    inst.entity:AddAnimState()  --添加动画属性
    inst.entity:AddNetwork()    --添加网络属性

    MakeInventoryPhysics(inst)  --预设物理属性
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)

    inst.AnimState:SetBank("zskb_red_packet")
    inst.AnimState:SetBuild("zskb_red_packet")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("nosteal") --不可偷窃
    inst:AddTag("cursed")  --诅咒

    MakeInventoryFloatable(inst, "med", 0.05, 0.68)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/zskb_inventoryimages.xml"
    inst.components.inventoryitem.canonlygoinpocket = true --仅物品栏
    inst.components.inventoryitem.keepondrown = true       --死亡不掉落

    inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("curseditem")
    inst.components.curseditem.curse = "ZSKB"

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return
    Prefab("zskb_red_packet1", fn1, assets, prefabs),
    Prefab("zskb_red_packet2", fn2, assets, prefabs)
