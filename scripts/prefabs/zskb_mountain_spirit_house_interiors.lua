local assets =
{
    Asset("ANIM", "anim/zskb_mountain_spirit_house_interiors.zip"),
}

local function floor_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank("zskb_mountain_spirit_house_interiors")
    inst.AnimState:SetBuild("zskb_mountain_spirit_house_interiors")
    inst.AnimState:PlayAnimation("floor")
    inst.Transform:SetScale(3.3, 3, 1)
    --inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BELOW_GROUND)
    inst.AnimState:SetSortOrder(-1)

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst:AddTag("nonpackable")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("zskb_saved_turned")

    return inst
end

local function wallpaper_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank("zskb_mountain_spirit_house_interiors")
    inst.AnimState:SetBuild("zskb_mountain_spirit_house_interiors")
    inst.AnimState:PlayAnimation("wallpaper")
    inst.AnimState:Hide("wall_hole")
    inst.AnimState:Hide("wall_hole_broken")
    inst.Transform:SetScale(3.3, 3, 1)
    --inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BELOW_GROUND)
    inst.AnimState:SetSortOrder(0)

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst:AddTag("nonpackable")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("zskb_saved_turned")

    return inst
end


local function pillar_top_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank("zskb_mountain_spirit_house_interiors")
    inst.AnimState:SetBuild("zskb_mountain_spirit_house_interiors")
    inst.AnimState:PlayAnimation("pillar_top")
    inst.Transform:SetScale(3.8, 3.3, 3.3)
    MakeObstaclePhysics(inst, 0.25)

    inst:AddTag("NOCLICK")
    inst:AddTag("birdblocker")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("nonpackable")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("zskb_saved_turned")

    return inst
end


local function pillar_bottom_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank("zskb_mountain_spirit_house_interiors")
    inst.AnimState:SetBuild("zskb_mountain_spirit_house_interiors")
    inst.AnimState:PlayAnimation("pillar_bottom")
    inst.Transform:SetScale(2.4, 2.4, 2.4)
    MakeObstaclePhysics(inst, 0.75)

    inst:AddTag("NOCLICK")
    inst:AddTag("birdblocker")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("nonpackable")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("zskb_saved_turned")

    return inst
end

local function OnDeath(inst)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("pot")
    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function bottle_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank("zskb_mountain_spirit_house_interiors")
    inst.AnimState:SetBuild("zskb_mountain_spirit_house_interiors")
    inst.AnimState:PlayAnimation("bottle_" .. tostring(math.random(1, 3)))
    inst.Transform:SetScale(1.25, 1.25, 1.25)

    inst:AddTag("NOBLOCK")
    inst:AddTag("smashable")
    inst:AddTag("clay")

    -- inst.entity:AddMiniMapEntity()
    -- inst.MiniMapEntity:SetIcon("relic.png")

    MakeObstaclePhysics(inst, .25)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("zskb_saved_turned")

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:AddRandomLoot("twigs", 10)
    inst.components.lootdropper:AddRandomLoot("cutgrass", 10)
    inst.components.lootdropper:AddRandomLoot("meat_dried", 2)
    inst.components.lootdropper:AddRandomLoot("rabbit", 5)
    inst.components.lootdropper:AddRandomLoot("ghost", 5)
    inst.components.lootdropper.numrandomloot = 1

    inst:AddComponent("combat")
    inst.components.combat:SetKeepTargetFunction(function() return false end)

    inst:AddComponent("health")
    inst.components.health.nofadeout = true
    inst.components.health.canmurder = false
    inst.components.health.canheal = false
    inst.components.health:SetMaxHealth(1)

    inst:ListenForEvent("death", OnDeath)

    -- inst:AddComponent("workable")
    -- inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    -- inst.components.workable:SetWorkLeft(1)
    -- inst.components.workable:SetOnFinishCallback(OnDeath)

    MakeHauntableWork(inst)
    return inst
end

return Prefab("zskb_mountain_spirit_house_floor", floor_fn, assets),
    Prefab("zskb_mountain_spirit_house_wallpaper", wallpaper_fn, assets),
    Prefab("zskb_mountain_spirit_house_pillar_top", pillar_top_fn, assets),
    Prefab("zskb_mountain_spirit_house_pillar_bottom", pillar_bottom_fn, assets),
    Prefab("zskb_mountain_spirit_house_bottle", bottle_fn, assets)
