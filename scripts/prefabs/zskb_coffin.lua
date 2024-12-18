local containers = require("containers")
local params = containers.params

local BUFF_NAME_ITEMS = {
    zskb_buff_return_life_pill = { "redgem", "spidergland", "feather_crow" },
    zskb_buff_waterproofness   = { "bluegem", "papyrus", "goose_feather" },
    zskb_buff_invisibility     = { "purplegem", "nightmarefuel", "batwing" },
    zskb_buff_craft            = { "greengem", "nightmarefuel", "butterflywings" },
    zskb_buff_workmultiplier   = { "orangegem", "nightmarefuel", "horn" },
}

--  rgb of buff attach fx
local BUFF_NAME_RGB = {
    zskb_buff_return_life_pill = { 240 / 255, 20 / 255, 20 / 255 },
    zskb_buff_waterproofness   = { 20 / 255, 20 / 255, 240 / 255 },
    zskb_buff_invisibility     = { 148 / 255, 20 / 255, 211 / 255 },
    zskb_buff_craft            = { 20 / 255, 240 / 255, 20 / 255 },
    zskb_buff_workmultiplier   = { 255 / 255, 165 / 255, 20 / 255 },
}

local assets = {
    Asset("ANIM", "anim/zskb_coffin.zip"),
}

params.zskb_coffin =
{
    widget =
    {
        slotpos =
        {
            Vector3(-(64 + 12), 0, 0),
            Vector3(0, 0, 0),
            Vector3(64 + 12, 0, 0),
        },
        animbank = "ui_chest_3x1",
        animbuild = "ui_chest_3x1",
        pos = Vector3(200, 0, 0),
        side_align_tip = 100,
    },
    type = "chest",
    acceptsstacks = false,
}

function params.zskb_coffin.itemtestfn(container, item, slot)
    if item:HasTag("zskb_copper_coin") or item.prefab == "opalpreciousgem" then
        return true
    else
        for buff, item_comb in pairs(BUFF_NAME_ITEMS) do
            if table.contains(item_comb, item.prefab) then
                return true
            end
        end
    end
end

local function onitemlose(inst, data)
    local slot = data.slot
    local item = data.prev_item

    if item.prefab == "zskb_copper_coin" then
        item.components.timer:StopTimer("coin_convert")
        -- print("stop coin convert task")
    end
end

local function onitemget(inst, data)
    local slot = data.slot
    local item = data.item
    local src_pos = data.src_pos

    if item.prefab == "zskb_copper_coin" then
        item.components.timer:StartTimer("coin_convert", 180)
        -- print("start coin convert task")
    end
end

local COIN_TAG = { "zskb_copper_coin" }
local COIN_SCAN_RANG = 5
local function pick_random_theta_point(dist)
    local theta = math.random() * TWOPI
    return Vector3(math.cos(theta) * dist, 0, math.sin(theta) * dist)
end
local function DoCoinConvert(inst, data)
    local coin = data and data.coin
    if coin == nil then return end
    -- spawn black coin
    inst.components.container:RemoveItem(coin)
    local black_coin = SpawnPrefab("zskb_black_copper_coin")
    inst.components.container:GiveItem(black_coin)                                                  -- it will drop since it not allowed into coffin container
    inst.components.container:DropItemAt(black_coin, inst:GetPosition() + pick_random_theta_point(2)) -- just in case
    -- try to find nearby coin and put into container
    local nearby_coin = FindEntity(inst, COIN_SCAN_RANG, nil, COIN_TAG, "INLIMBO")
    if nearby_coin then
        SpawnPrefab('sand_puff').Transform:SetPosition(nearby_coin.Transform:GetWorldPosition())
        inst.components.container:GiveItem(nearby_coin)
    else
        -- print("not found coin")
    end
end

local function onsave(inst, data)

end

local function onload(inst, data)

end

local function onopen(inst)
    inst.AnimState:PlayAnimation("open")
end

local function onclose(inst)
    inst.AnimState:PlayAnimation("close")
end

local function onhammered(inst, worker)
    if inst.components.lootdropper then
        inst.components.lootdropper:DropLoot()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
    if inst.components.container then
        inst.components.container:DropEverything()
    end
end

local function PlaySleepLoopSoundTask(inst, stopfn)
    inst.SoundEmitter:PlaySound("dontstarve/common/tent_sleep")
end

local function stopsleepsound(inst)
    if inst.sleep_tasks ~= nil then
        for i, v in ipairs(inst.sleep_tasks) do
            v:Cancel()
        end
        inst.sleep_tasks = nil
    end
end

local function startsleepsound(inst, len)
    stopsleepsound(inst)
    inst.sleep_tasks =
    {
        inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 33 * FRAMES),
        inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 47 * FRAMES),
    }
end

local function IsMatchesItemComb(comb, prefab_list)
    if #comb ~= #prefab_list then return false end
    local comb_lookup = {}
    for k, v in ipairs(comb) do
        comb_lookup[v] = (comb_lookup[v] or 0) + 1
    end
    for k, v in ipairs(prefab_list) do
        comb_lookup[v] = (comb_lookup[v] or 0) - 1
        if comb_lookup[v] < 0 then
            return false
        end
    end
    return true
end

local function GetBuffName(inst)
    local item_slot1 = inst.components.container:GetItemInSlot(1)
    local item_slot2 = inst.components.container:GetItemInSlot(2)
    local item_slot3 = inst.components.container:GetItemInSlot(3)

    if item_slot1 and item_slot2 and item_slot3 then
        for buff_name, item_comb in pairs(BUFF_NAME_ITEMS) do
            if IsMatchesItemComb(item_comb, { item_slot1.prefab, item_slot2.prefab, item_slot3.prefab }) then
                return buff_name
            end
        end
    end
end

local function SpawnBuffFX(sleeper, buff_name)
    local rgb = BUFF_NAME_RGB[buff_name]
    if rgb then
        local fx = SpawnPrefab("chesterlight")
        fx.Transform:SetPosition(sleeper:GetPosition():Get())
        fx.Light:SetColour(rgb[1], rgb[2], rgb[3])
        fx.AnimState:SetMultColour(rgb[1], rgb[2], rgb[3], 1)
        if fx.TurnOn and fx.TurnOff then
            fx:TurnOn()
            fx:DoTaskInTime(2, function() fx:TurnOff() end)
        end
    end
end

local function AddBuffToSleeper(sleeper, buff_name, duration)
    if BUFF_NAME_ITEMS[buff_name] then
        if sleeper.components.debuffable then
            if sleeper.components.debuffable:HasDebuff(buff_name) then
                sleeper.components.debuffable:RemoveDebuff(buff_name)
            end
            local buff = sleeper.components.debuffable:AddDebuff(buff_name, buff_name)
            buff.components.timer:SetTimeLeft("buffover", duration)
            SpawnBuffFX(sleeper, buff_name)
        end
    end
end

local function onignite(inst)
    inst.components.sleepingbag:DoWakeUp()
end

local function DespawnFullMoonFX(inst)
    if inst._fxpulse ~= nil then
        inst._fxpulse:KillFX()
        inst._fxpulse = nil
    end
    if inst._fxfront ~= nil then
        inst._fxfront:KillFX()
        inst._fxfront = nil
    end
    if inst._fxback ~= nil then
        inst._fxback:KillFX()
        inst._fxback = nil
    end
end

local function SpawnFullMoonFX(inst)
    DespawnFullMoonFX(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst._fxpulse = SpawnPrefab("positronpulse")
    inst._fxpulse:SetLevel(3)
    inst._fxpulse.Transform:SetPosition(x, y, z)
    inst._fxfront = SpawnPrefab("positronbeam_front")
    inst._fxfront.Transform:SetPosition(x, y, z)
    inst._fxback = SpawnPrefab("positronbeam_back")
    inst._fxback.Transform:SetPosition(x, y, z)
end

local function onwake(inst, sleeper, nostatechange)
    inst.sleep_end_time = GetTime()
    sleeper:RemoveEventCallback("onignite", onignite, inst)

    if inst.sleep_anim ~= nil then
        inst.AnimState:PushAnimation("close")
        stopsleepsound(inst)
    end
    DespawnFullMoonFX(inst)

    -- inst.components.finiteuses:Use()

    -- if sleeper.zskb_sleep_task ~= nil then
    --     sleeper.zskb_sleep_task:Cancel()
    --     sleeper.zskb_sleep_task = nil
    -- end
    local sleep_duration = inst.sleep_end_time - (inst.sleep_start_time or GetTime())
    local buff_name = GetBuffName(inst)
    if buff_name then
        AddBuffToSleeper(sleeper, buff_name, math.max(10, sleep_duration * 3))
        inst.components.container:DestroyContents() -- remove all items in container
    end
end

local function onsleep(inst, sleeper)
    inst.sleep_start_time = GetTime()
    sleeper:ListenForEvent("onignite", onignite, inst)

    if inst.sleep_anim ~= nil then
        inst.AnimState:PlayAnimation(inst.sleep_anim, true)
        startsleepsound(inst, inst.AnimState:GetCurrentAnimationLength())
    end

    -- if sleeper.zskb_sleep_task ~= nil then
    --     sleeper.zskb_sleep_task:Cancel()
    --     sleeper.zskb_sleep_task = nil
    -- end

    if TheWorld.state.isfullmoon then
        SpawnFullMoonFX(inst)
    end
end

local function temperaturetick(inst, sleeper)
    if sleeper.components.temperature ~= nil then
        if inst.is_cooling then
            if sleeper.components.temperature:GetCurrent() > TUNING.SLEEP_TARGET_TEMP_TENT then
                sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() - TUNING.SLEEP_TEMP_PER_TICK)
            end
        elseif sleeper.components.temperature:GetCurrent() < TUNING.SLEEP_TARGET_TEMP_TENT then
            sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() + TUNING.SLEEP_TEMP_PER_TICK)
        end
    end

    if sleeper.components.zskb_zombie_gas then
        sleeper.components.zskb_zombie_gas:DoDelta(2, nil, false, true)
    end

    if TheWorld.state.isfullmoon then
        local health, sanity, hunger = sleeper.components.health, sleeper.components.sanity, sleeper.components.hunger
        if health then
            health.maxhealth = math.min(TUNING.ZSKB_ZOMBIE_HEALTH_MAX, health.maxhealth + 0.5)
            health.currenthealth = health.currenthealth + 0.5
        end
        if sanity then
            sanity.max = math.min(TUNING.ZSKB_ZOMBIE_SANITY_MAX, sanity.max + 0.5)
            sanity.current = sanity.current + 0.5
        end
        if hunger then
            hunger.max = math.min(TUNING.ZSKB_ZOMBIE_HUNGER_MAX, hunger.max + 0.5)
        end

        if (health == nil or health.maxhealth >= 275) and (sanity == nil or sanity.max >= 250) and (hunger == nil or hunger.max >= 200) then
            if not sleeper.components.zskb_zombie.can_rain_control then
                sleeper.components.zskb_zombie:SetCanRainControl(true)
                -- TODO: spawn fx ?
            end
        end
    end
end

local function onphase(inst, phase)
    if inst.components.sleepingbag == nil then
        return
    end
    -- 地面三个时段是 day, dusk, night
    -- 洞穴里三个时段都是 night
    if table.contains({ "dusk", "night" }, phase) then
        inst.components.sleepingbag:SetSleepPhase("night")
        inst:RemoveTag("siestahut")
    end
    if table.contains({ "day" }, phase) then
        inst.components.sleepingbag:SetSleepPhase("day")
        inst:AddTag("siestahut")
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()

    MakeSnowCoveredPristine(inst)
    MakeObstaclePhysics(inst, 1)

    inst.MiniMapEntity:SetIcon("zskb_coffin.tex")

    inst.AnimState:SetBuild("zskb_coffin")
    inst.AnimState:SetBank("zskb_coffin")
    inst.AnimState:PlayAnimation("close")

    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.3)
    inst.Light:SetColour(219 / 255, 89 / 255, 64 / 255)
    inst.Light:Enable(true)

    inst:AddTag("tent")
    inst:AddTag("zskb_coffin")

    inst.entity:SetPristine()
    --------------------------------------------------------------------------
    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = function(inst) inst.replica.container:WidgetSetup("zskb_coffin") end
        return inst
    end
    --------------------------------------------------------------------------
    inst:AddComponent("inspectable")
    inst:ListenForEvent("coin_convert_finished", DoCoinConvert) -- push from zsbk_copper_coin

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("zskb_coffin")
    -- inst.components.container.skipclosesnd = true
    -- inst.components.container.skipopensnd = true
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst.sleep_anim = "sleep_loop"
    inst:AddComponent("sleepingbag")
    inst.components.sleepingbag.onsleep = onsleep
    inst.components.sleepingbag.onwake = onwake
    inst.components.sleepingbag.health_tick = TUNING.SLEEP_HEALTH_PER_TICK * 2
    inst.components.sleepingbag.hunger_tick = TUNING.SLEEP_HUNGER_PER_TICK
    --convert wetness delta to drying rate
    inst.components.sleepingbag.dryingrate = math.max(0, -TUNING.SLEEP_WETNESS_PER_TICK / TUNING.SLEEP_TICK_PERIOD)
    inst.components.sleepingbag:SetTemperatureTickFn(temperaturetick)

    inst:ListenForEvent("itemlose", onitemlose)
    inst:ListenForEvent("itemget", onitemget)
    inst:WatchWorldState("phase", onphase)
    onphase(inst, TheWorld.state.phase)

    inst.OnSave = onsave
    inst.OnLoad = onload

    MakeSnowCovered(inst)
    MakeLargeBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("zskb_coffin", fn, assets),
    MakePlacer("zskb_coffin_placer", "zskb_coffin", "zskb_coffin", "open")
