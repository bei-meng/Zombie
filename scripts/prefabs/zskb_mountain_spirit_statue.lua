local assets = {
    Asset("ANIM", "anim/zskb_mountain_spirit_statue.zip"),
}

local prefabs = {
    "zskb_mountain_spirit",
    "construction_container",
}

local TRADABLE_ITEMS = {
    PREPAREDFOODS_TAGS = { --tag check
        edible_MEAT = 1 * TUNING.TOTAL_DAY_TIME,
        edible_VEGGIE = 2 / 3 * TUNING.TOTAL_DAY_TIME,
    },
    PREFABS = { --prefab name
        zskb_candle = 1 / 3 * TUNING.TOTAL_DAY_TIME,
    },
}

local function OnWorkFinished(inst, worker)
    local x, y, z = inst.Transform:GetWorldPosition()

    local boss = SpawnPrefab("zskb_mountain_spirit")
    if boss ~= nil then
        boss.Transform:SetPosition(x, y, z)
        boss.sg:GoToState("taunt")
        inst:PushEvent("zskb_boss_spawned", { boss = boss }) -- listened by mountain_spirit spawner
    end

    inst:Remove()
end

local function CheckTradableAndGetBuffDuration(item)
    local is_preparedfood = item:HasTag("preparedfood") or item:HasTag("pre-preparedfood")
    if is_preparedfood then
        local TAGS = TRADABLE_ITEMS and TRADABLE_ITEMS.PREPAREDFOODS_TAGS or {}
        for tag, buff_duration in pairs(TAGS) do
            if item:HasTag(tag) and type(buff_duration) == "number" then
                return true, buff_duration
            end
        end
    else
        local PREFABS = TRADABLE_ITEMS and TRADABLE_ITEMS.PREFABS or {}
        if type(PREFABS[item.prefab]) == "number" then
            return true, PREFABS[item.prefab]
        end
    end
end

local function TradaleTest(inst, item, giver)
    local tradable, _ = CheckTradableAndGetBuffDuration(item)
    return tradable
end

local function OnAccept(inst, giver, item)
    local _, rage_calming = CheckTradableAndGetBuffDuration(item)
    if rage_calming and rage_calming > 0 then
        local statue_buff = giver.components.debuffable and giver.components.debuffable:GetDebuff("zskb_buff_spirit_statue") or nil
        local timeleft = statue_buff and statue_buff.components.timer:GetTimeLeft("rage") or nil
        if statue_buff and type(timeleft) == "number" then
            timeleft = math.min(timeleft + rage_calming, TUNING.ZSKB_BUFF_SPIRIT_STATUE_RAGE_MAX_TIME) --
            statue_buff.components.timer:SetTimeLeft("rage", timeleft)
        end

        if giver.trade_protection ~= nil then
            giver.trade_protection:Cancel()
        end
        giver.trade_protection = giver:DoTaskInTime(3, function() giver.trade_protection = nil end)
    end
end

local function OnActivate(inst, doer)
    local new_statue = SpawnPrefab("zskb_mountain_spirit_statue_activated")
    if new_statue ~= nil then
        inst:PushEvent("zskb_statue_replaced", { new_statue = new_statue, doer = doer })
        new_statue.Transform:SetPosition(inst.Transform:GetWorldPosition())
        new_statue.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/place")

        inst:Remove()
    end
end

local function OnConstructed(inst, doer)
    if inst.components.constructionsite and inst.components.constructionsite:IsComplete() then
        OnActivate(inst, doer)
    end
end


local function MakeStatue(activated)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        inst:AddTag("zskb_mountain_spirit_statue" .. (activated and "_activated" or ""))

        if activated then
            inst.entity:AddLight()
            inst.Light:SetFalloff(1)
            inst.Light:SetIntensity(.5)
            inst.Light:SetRadius(1)
            inst.Light:Enable(true)
            inst.Light:SetColour(180 / 255, 195 / 255, 50 / 255)
        else
            --constructionsite (from constructionsite component) added to pristine state for optimization
            inst:AddTag("constructionsite")
        end

        MakeObstaclePhysics(inst, 1.5)

        inst.AnimState:SetBank("zskb_mountain_spirit_statue")
        inst.AnimState:SetBuild("zskb_mountain_spirit_statue")
        inst.AnimState:PlayAnimation("idle", true)
        inst.Transform:SetScale(2.5, 2.5, 2.5)

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        if activated then
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.MINE)
            inst.components.workable:SetWorkLeft(5)
            inst.components.workable:SetOnFinishCallback(OnWorkFinished)
            inst.components.workable:SetRequiresToughWork(true)
            inst.components.workable.savestate = true

            inst:AddComponent("trader")
            inst.components.trader:SetAbleToAcceptTest(TradaleTest)
            inst.components.trader.onaccept = OnAccept
            inst.components.trader.acceptnontradable = true
        else
            inst:AddComponent("constructionsite")
            inst.components.constructionsite:SetConstructionPrefab("construction_container")
            inst.components.constructionsite:SetOnConstructedFn(OnConstructed)
            -- constructionsite item list see "postinit/recipes"
        end

        -- make nearby throne unworkable
        inst:DoTaskInTime(1, function()
            local x, y, z = inst.Transform:GetWorldPosition()

            local ents = TheSim:FindEntities(x, y, z, 2, { "zskb_mountain_spirit_throne" })
            for k, v in pairs(ents) do
                if v.components.workable then
                    v.components.workable:SetWorkable(false)
                end
                v:AddTag("NOCLICK")
            end
        end)

        return inst
    end
    return Prefab("zskb_mountain_spirit_statue" .. (activated and "_activated" or ""), fn, assets, prefabs)
end


return MakeStatue(false), MakeStatue(true)
