local assets =
{
    Asset("ANIM", "anim/zskb_mountain_spirit_throne.zip"),
}

SetSharedLootTable('zskb_mountain_spirit_throne',
    {
        { 'rocks',       1.0 },
        { 'rocks',       1.0 },
        { 'rocks',       1.0 },
        { 'rocks',       1.0 },
        { 'rocks',       1.0 },
        { 'rocks',       1.0 },
        { 'rocks',       1.0 },
        { 'rocks',       1.0 },

        { 'flint',       1.0 },
        { 'flint',       1.0 },
        { 'flint',       0.8 },
        { 'flint',       0.8 },
        { 'flint',       0.8 },
        { 'flint',       0.8 },

        { 'nitre',       0.8 },
        { 'nitre',       0.8 },
        { 'nitre',       0.8 },
        { 'nitre',       0.8 },

        --{'gold_dust', 0.6},
        --{'gold_dust', 0.6},

        { 'gold_nugget', 1.0 },
        { 'gold_nugget', 1.0 },
        { 'gold_nugget', 0.3 },
        { 'gold_nugget', 0.3 },

        { 'bluegem',     0.5 },
        { 'bluegem',     0.5 },
    })

local prefabs = { "zskb_throne_wall", "zskb_throne_wall_large" }

-- it's so sucks，just copy this from Hamlet
local SpawnThroneWallOffset = {}
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall_large", x_offset = 1, z_offset = 2.25 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = 2.2, z_offset = 2.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = 1.9, z_offset = 3 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = 1.6, z_offset = 3.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = 1.3, z_offset = 4 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = 1, z_offset = 4.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = 0.7, z_offset = 5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = 0.4, z_offset = 5.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = 0.1, z_offset = 6 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -0.4, z_offset = 6 })

table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -3.25, z_offset = 1.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -3, z_offset = 2 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -2.75, z_offset = 2.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -2.5, z_offset = 3 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -2.25, z_offset = 3.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -2, z_offset = 4 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -1.75, z_offset = 4.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -1.5, z_offset = 5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -1.25, z_offset = 5.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -1, z_offset = 6 })

table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -3.25, z_offset = 1 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -3.25, z_offset = 0.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -3.25, z_offset = -0 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -3.25, z_offset = -0.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -3.25, z_offset = -1 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -3.25, z_offset = -1.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -3, z_offset = -2 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -2.75, z_offset = -2.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -2.5, z_offset = -3 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -2.25, z_offset = -3.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -2, z_offset = -4 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -1.75, z_offset = -4.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -1.5, z_offset = -5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -1.25, z_offset = -5.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -1, z_offset = -6 })

table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall_large", x_offset = 1.5, z_offset = -2.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = 2, z_offset = -3 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = 1.75, z_offset = -3.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = 1.5, z_offset = -4 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = 1.25, z_offset = -4.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = 1, z_offset = -5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = 0.75, z_offset = -5.5 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = 0, z_offset = -6 })
table.insert(SpawnThroneWallOffset, { name = "zskb_throne_wall", x_offset = -0.5, z_offset = -6 })


local function OnWork(inst, worker, workleft)
    if workleft <= 0 then
        local pt = inst:GetPosition()
        SpawnPrefab("rock_break_fx").Transform:SetPosition(pt.x, pt.y, pt.z)
        inst.components.lootdropper:DropLoot(pt)

        if inst.showCloudFXwhenRemoved then
            local fx = SpawnPrefab("collapse_small")
            fx.Transform:SetPosition(pt.x, pt.y, pt.z)
        end

        if not inst.doNotRemoveOnWorkDone then
            inst:Remove()
        end
    else
        inst.AnimState:PlayAnimation(
            (workleft < 10 / 3 and "low_hit") or
            (workleft < 10 * 2 / 3 and "med_hit") or
            "full_hit"
        )
    end
end

local function fn(Sim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("zskb_mountain_spirit_throne")
    inst.AnimState:SetBuild("zskb_mountain_spirit_throne")
    inst.AnimState:PlayAnimation("full")

    inst.AnimState:SetSortOrder(-1)

    inst.Transform:SetScale(0.9, 0.9, 0.9)
    --MakeObstaclePhysics(inst, 3.5)

    inst:AddTag("zskb_mountain_spirit_throne")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('zskb_mountain_spirit_throne')

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(10)

    inst.components.workable:SetOnWorkCallback(OnWork)

    inst:DoTaskInTime(0, function()
        local x, y, z = inst.Transform:GetWorldPosition()
        for _, v in pairs(SpawnThroneWallOffset) do
            if v and v.name and v.x_offset and v.z_offset then
                local throne_wall = SpawnPrefab(v.name)
                throne_wall.Transform:SetPosition(x + v.x_offset, 0, z + v.z_offset)
            end
        end
    end)

    inst:ListenForEvent("onremove", function()
        local x, y, z = inst.Transform:GetWorldPosition()

        local ents = TheSim:FindEntities(x, y, z, 10, { "zskb_throne_wall" })
        for k, v in pairs(ents) do
            v:Remove()
        end
    end, inst)

    MakeSnowCovered(inst)

    MakeHauntableWork(inst)


    return inst
end

local wall_assets =
{
    Asset("ANIM", "anim/wall.zip"),
    Asset("ANIM", "anim/wall_stone.zip"),
}

local function make_throne_fn(size)
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddNetwork()
        -- for debug
        --inst.entity:AddAnimState()
        --inst.AnimState:SetBank("wall")
        --inst.AnimState:SetBuild("wall_stone")
        --inst.AnimState:PlayAnimation("half")
        --local scale = size / 0.5
        --inst.Transform:SetScale(scale,scale,scale)

        inst:AddTag("zskb_throne_wall")
        MakeObstaclePhysics(inst, size)

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        return inst
    end

    return fn
end

local function makethronewall(name, physics_size)
    return Prefab(name, make_throne_fn(physics_size), wall_assets)
end

return Prefab("zskb_mountain_spirit_throne", fn, assets, prefabs),
    makethronewall("zskb_throne_wall", 0.25),
    makethronewall("zskb_throne_wall_large", 0.5)
