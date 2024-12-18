local assets =
{
    Asset("ANIM", "anim/zskb_mountain_spirit_house.zip"),
}

local prefabs =
{
    "zskb_mountain_spirit_house_floor",
    "zskb_mountain_spirit_house_wallpaper",
    "zskb_mountain_spirit_house_pillar_top",
    "zskb_mountain_spirit_house_pillar_bottom",
    "zskb_mountain_spirit_house_bottle",
    "zskb_mountain_spirit_house_exit",
    "zskb_mountain_spirit_statue",
    "zskb_mountain_spirit_spawner",
}

local function onsave(inst, data)
    data.zskb_has_room = inst.zskb_has_room
end

local function onload(inst, data)
    if data then
        inst.zskb_has_room = data.zskb_has_room
    end
end

local function BuildRoomDecors(entrance, x, z)
    local function SetDecor(prefab, x, y, z, is_right)
        local item = SpawnPrefab(prefab)
        if item ~= nil then
            item.Transform:SetPosition(x, y, z)
            if item.components.zskb_saved_turned ~= nil then
                item.components.zskb_saved_turned:SetTurned(is_right)
            end
            return item
        end
    end
    -- floor
    SetDecor("zskb_mountain_spirit_house_floor", x, 0, z - 0.25)
    -- wallpaper
    SetDecor("zskb_mountain_spirit_house_wallpaper", x, 0, z - 0.25)
    -- pillar
    SetDecor("zskb_mountain_spirit_house_pillar_top", x - 5.5, 0, z - 8.75)
    SetDecor("zskb_mountain_spirit_house_pillar_top", x - 5.5, 0, z + 8.75, true)
    SetDecor("zskb_mountain_spirit_house_pillar_bottom", x + 7, 0, z - 10.75)
    SetDecor("zskb_mountain_spirit_house_pillar_bottom", x + 7, 0, z + 10.75, true)

    -- bottle
    -- for n = 1, 10 do
    --     local right = math.random() > 0.5
    --     local offset_z = (math.random()*3 + 5) * (right and 1 or -1) -- -5~-8 以及 5~8
    --     local offset_x = math.random()*11 + -5 -- -5 ~ 6
    --     SetDecor("zskb_mountain_spirit_house_bottle", x+offset_x, 0 ,z+offset_z )
    -- end

    -- exit
    local exit = SpawnPrefab("zskb_mountain_spirit_house_exit")
    if exit ~= nil then
        exit.Transform:SetPosition(x + 7, 0, z)
        if exit.components.teleporter then
            exit.components.teleporter:Target(entrance)
            entrance.components.teleporter:Target(exit)
        end
    end

    -- statue/BOSS spawner
    local boss_spawner = SpawnPrefab("zskb_mountain_spirit_spawner")
    if boss_spawner ~= nil then
        boss_spawner.Transform:SetPosition(x, 0, z)
    end
end


local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("zskb_mountain_spirit_house.tex")

    inst.entity:AddLight()
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.7)
    inst.Light:SetRadius(2)
    inst.Light:Enable(true)
    inst.Light:SetColour(180 / 255, 195 / 255, 50 / 255)

    MakeObstaclePhysics(inst, 1.25)

    inst.AnimState:SetBank("zskb_mountain_spirit_house")
    inst.AnimState:SetBuild("zskb_mountain_spirit_house")
    inst.AnimState:PlayAnimation("idle")
    inst.Transform:SetScale(1.5, 1.5, 1.5)

    inst:AddTag("zskb_mountain_spirit_house")
    inst:AddTag("zskb_enterable")
    inst:AddTag("structure")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("teleporter")
    inst.components.teleporter.offset = 0
    inst.components.teleporter.travelcameratime = 0.2
    inst.components.teleporter.travelarrivetime = 0.1

    inst:AddComponent("hauntable") -- for playerghost trigger the teleport
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        if haunter and haunter:HasTag("player") and inst.components.teleporter then
            inst.components.teleporter:Activate(haunter)
        end
    end)

    inst:DoTaskInTime(0, function(inst)
        if not inst.zskb_has_room and TheWorld.components.zskb_interiormanager then
            local x, z = TheWorld.components.zskb_interiormanager:AllocateRoom(inst)
            if x ~= nil and z ~= nil then
                BuildRoomDecors(inst, x, z)
                inst.zskb_has_room = true
            end
        end
    end)

    --inst.OnRemoveEntity = function(inst)
    inst:ListenForEvent("onremove", function(inst)
        if inst.zskb_has_room and TheWorld.components.zskb_interiormanager then
            TheWorld.components.zskb_interiormanager:DestoryRoom(inst)
            inst.zskb_has_room = false
        end
    end
    )

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("zskb_mountain_spirit_house", fn, assets)
