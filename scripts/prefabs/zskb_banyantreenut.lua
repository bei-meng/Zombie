local assets =
{
    Asset("ANIM", "anim/zskb_banyantreenut.zip"),
}

local prefabs =
{
    "collapse_small",
    "twigs",
    "log",
}

SetSharedLootTable('zskb_banyantreenut',
    {
        { 'twigs', 1.00 },
        { 'twigs', 0.50 },
        { 'log',   1.00 },
    })

local PHYSICS_RADIUS = .75 --物理半径

local function OnWorkedFinished(inst, worker)
    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")

    inst:Remove()
end

local function OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
end

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "zskb_banyantreenut", "swap_body")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("zskb_banyantreenut")
    inst.AnimState:SetBuild("zskb_banyantreenut")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("heavy")

    MakeHeavyObstaclePhysics(inst, PHYSICS_RADIUS) --设置重物的物理半径及重量
    inst:SetPhysicsRadiusOverride(PHYSICS_RADIUS)  --设置覆盖的物理半径

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('zskb_banyantreenut')

    inst:AddComponent("heavyobstaclephysics")
    inst.components.heavyobstaclephysics:SetRadius(PHYSICS_RADIUS)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/zskb_inventoryimages.xml"
    inst.components.inventoryitem.cangoincontainer = false
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable.walkspeedmult = TUNING.HEAVY_SPEED_MULT

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(OnWorkedFinished)

    inst:AddComponent("submersible")
    inst:AddComponent("symbolswapdata")
    inst.components.symbolswapdata:SetData("zskb_banyantreenut", "swap_body")

    MakeHauntableWork(inst)

    return inst
end

return Prefab("zskb_banyantreenut", fn, assets, prefabs)
