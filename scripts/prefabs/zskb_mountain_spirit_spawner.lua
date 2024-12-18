local prefabs =
{
    "zskb_mountain_spirit",
    "zskb_mountain_spirit_statue",
    "zskb_mountain_spirit_throne",
}

local ZSKB_MOUNTAIN_SPIRIT_SPAWNTIMER = "regen_zskb_mountain_spirit"
local ZSKB_MOUNTAIN_SPIRIT_RESPAWNTIME = TUNING.ZSKB_MOUNTAIN_SPIRIT_RESPAWNTIME
-- for debug
-- local ZSKB_MOUNTAIN_SPIRIT_RESPAWNTIME = 5

local function SpawnNewStatue(inst)
    local statue = SpawnPrefab("zskb_mountain_spirit_statue")
    if statue ~= nil then
        statue.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst.components.entitytracker:TrackEntity("zskb_mountain_spirit_statue", statue)
        inst:ListenForEvent("zskb_statue_replaced", inst._on_statue_replaced, statue)
    end

    -- spawn throne
    if FindEntity(inst, 1, nil, { "zskb_mountain_spirit_throne" }) == nil then
        local throne = SpawnPrefab("zskb_mountain_spirit_throne")
        if throne then
            local x, y, z = inst.Transform:GetWorldPosition()
            throne.Transform:SetPosition(x, y, z)
        end
    end
end

local function OnTimerDone(inst, data)
    if data.name == ZSKB_MOUNTAIN_SPIRIT_SPAWNTIMER then
        inst:RemoveEventCallback("timerdone", OnTimerDone)
        SpawnNewStatue(inst)
    end
end

local function OnInit(inst)
    local statue = inst.components.entitytracker:GetEntity("zskb_mountain_spirit_statue")
    local statue_activated = inst.components.entitytracker:GetEntity("zskb_mountain_spirit_statue_activated")
    local boss = inst.components.entitytracker:GetEntity("zskb_mountain_spirit")

    if statue == nil and statue_activated == nil and boss == nil then
        if inst.components.timer:TimerExists(ZSKB_MOUNTAIN_SPIRIT_SPAWNTIMER) then
            -- inst.components.timer:StartTimer(ZSKB_MOUNTAIN_SPIRIT_SPAWNTIMER, ZSKB_MOUNTAIN_SPIRIT_RESPAWNTIME)
            inst:ListenForEvent("timerdone", OnTimerDone)
        else
            SpawnNewStatue(inst)
        end
    else
        if statue ~= nil then
            inst:ListenForEvent("zskb_statue_replaced", inst._on_statue_replaced, statue)
        end
        if statue_activated ~= nil then
            inst:ListenForEvent("zskb_boss_spawned", inst._on_boss_spawned, statue_activated)
        end
        if boss ~= nil then
            inst:ListenForEvent("death", inst._on_boss_death, boss)
        end
    end
end

local function OnSave()

end

local function OnLoad()

end

local function OnLoadPostPass(inst) --, ents, data)

end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    -- inst:AddTag("CLASSIFIED") --添加了CLASSIFIED标签后就无法被FindEntities找到并正确移除
    inst:AddTag("zskb_mountain_spirit_spawner")

    inst:AddComponent("timer")
    inst:AddComponent("entitytracker")

    inst:DoTaskInTime(0, OnInit)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    inst._on_statue_replaced = function(statue, data)
        local new_statue = data and data.new_statue
        local doer = data and data.doer
        if new_statue ~= nil and doer ~= nil then
            if inst.components.entitytracker:GetEntity("zskb_mountain_spirit_statue") == statue then
                inst.components.entitytracker:ForgetEntity("zskb_mountain_spirit_statue", statue)
            end
            inst.components.entitytracker:TrackEntity("zskb_mountain_spirit_statue_activated", new_statue)
            inst:ListenForEvent("zskb_boss_spawned", inst._on_boss_spawned, new_statue)

            if doer.components.debuffable == nil then
                doer:AddComponent("debuffable")
            end

            if not doer.components.debuffable:HasDebuff("zskb_buff_spirit_statue") then
                doer.components.debuffable:AddDebuff("zskb_buff_spirit_statue", "zskb_buff_spirit_statue")
                doer.components.talker:Say(STRINGS.ZSKB_SPIRIT_STATUE_BUFF_ATTACHED)
            end
        end
    end

    inst._on_boss_death = function(boss)
        if inst.components.entitytracker:GetEntity("zskb_mountain_spirit") == boss then
            inst.components.entitytracker:ForgetEntity("zskb_mountain_spirit")
        end

        -- clean all player's debuff
        for _, player in ipairs(AllPlayers) do
            if player.components.debuffable and player.components.debuffable:HasDebuff("zskb_buff_spirit_statue") then
                player:DoTaskInTime(2 + math.random(0, 3), function()
                    player.components.debuffable:RemoveDebuff("zskb_buff_spirit_statue")
                    player.components.talker:Say(STRINGS.ZSKB_SPIRIT_STATUE_BUFF_DETACHED)
                end)
            end
        end

        inst.components.timer:StopTimer(ZSKB_MOUNTAIN_SPIRIT_SPAWNTIMER)
        inst:ListenForEvent("timerdone", OnTimerDone)
        inst.components.timer:StartTimer(ZSKB_MOUNTAIN_SPIRIT_SPAWNTIMER, ZSKB_MOUNTAIN_SPIRIT_RESPAWNTIME)
    end

    inst._on_boss_spawned = function(statue, data)
        local boss = data and data.boss
        if boss ~= nil then
            if inst.components.entitytracker:GetEntity("zskb_mountain_spirit_statue") == statue then
                inst.components.entitytracker:ForgetEntity("zskb_mountain_spirit_statue")
            end
            inst.components.entitytracker:TrackEntity("zskb_mountain_spirit", boss)
            inst:ListenForEvent("death", inst._on_boss_death, boss)
        end
    end

    return inst
end
return Prefab("zskb_mountain_spirit_spawner", fn, nil, prefabs)
