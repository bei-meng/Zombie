require "prefabutil"

local TechTree = require("techtree")

local IDLE_ANIMS = { "lvl_one", "lvl_two" }
local FIRE_ANIMS = { "fire_one", "fire_two" }

local function Default_PlayAnimation(inst, anim, loop)
    inst.AnimState:PlayAnimation(anim, loop)
end

local function Default_PushAnimation(inst, anim, loop)
    inst.AnimState:PushAnimation(anim, loop)
end

local function isgifting(inst)
    if inst.components.prototyper == nil then return false end
    for k, v in pairs(inst.components.prototyper.doers) do
        if k.components.giftreceiver ~= nil and
            k.components.giftreceiver:HasGift() and
            k.components.giftreceiver.giftmachine == inst then
            return true
        end
    end
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst)
end

local function doonact(inst, soundprefix)
    if inst._activecount > 1 then
        inst._activecount = inst._activecount - 1
    else
        inst._activecount = 0
        inst.SoundEmitter:KillSound("sound")
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_" .. soundprefix .. "_ding")
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
    data.lvl = inst.lvl
end

local function onload(inst, data)
    if data ~= nil then
        if data.burnt then
            inst.components.burnable.onburnt(inst)
        end
        if data.lvl then
            inst.lvl = data.lvl
        end
    end
    inst.AnimState:PlayAnimation(IDLE_ANIMS[inst.lvl or 1], true)
end

local function createmachine(name, soundprefix, techtree, giftsound)
    local assets =
    {
        Asset("ANIM", "anim/" .. name .. ".zip"),
    }

    local prefabs =
    {
        "collapse_small",
    }

    -- should play some anim and sound here
    local function onturnon(inst)

    end

    local function onturnoff(inst)

    end

    local function onremovelight(light)
        light._lantern._light = nil
    end

    local function lighton(inst)
        if inst._light == nil then
            inst._light = SpawnPrefab("lanternlight")
            inst._light._lantern = inst
            inst:ListenForEvent("onremove", onremovelight, inst._light)
        end
        inst._light.Light:SetIntensity(Lerp(.4, .6, 1))
        inst._light.Light:SetRadius(Lerp(3, 5, 1))
        inst._light.Light:SetFalloff(.9)
        inst._light.entity:SetParent(inst.entity)
    end
    local function lightoff(inst)
        if inst._light ~= nil then
            inst._light:Remove()
        end
    end

    local function refreshonstate(inst)
        --V2C: if "burnt" tag, prototyper cmp should've been removed *see standardcomponents*
        if not inst:HasTag("burnt") and inst.components.prototyper and inst.components.prototyper.on then
            onturnon(inst)
        end
    end

    local function doneact(inst)
        inst._activetask = nil
        if not inst:HasTag("burnt") then
            if inst.components.prototyper and inst.components.prototyper.on then
                onturnon(inst)
            else
                onturnoff(inst)
            end
        end
    end

    local function ongiftopened(inst)
        if not inst:HasTag("burnt") then
            inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_" .. giftsound .. "_gift_recieve")
            if inst._activetask ~= nil then
                inst._activetask:Cancel()
            end
            inst._activetask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, doneact)
        end
    end

    local function onbuilt(inst, data)
        inst:_PlayAnimation("lvl_one", true)
        inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_" .. soundprefix .. "_place")
    end

    local function changeResearchMachine(inst)
        if inst.components.prototyper == nil then
            inst:AddComponent("prototyper")
        end
        inst:RemoveTag("lvl_1")
        inst:RemoveTag("lvl_2")
        inst:AddTag("lvl_" .. tostring(inst.lvl or 1))
        inst.components.prototyper.trees = inst.lvl == 1 and TUNING.PROTOTYPER_TREES.COPPER_CRANE_PLATFORM_ONE or TUNING.PROTOTYPER_TREES.COPPER_CRANE_PLATFORM_TWO
    end

    local function accepttest(inst, item, giver)
        return table.contains({ "cutgrass", "twigs", "goldnugget" }, item.prefab)
    end

    local function onacceptitem(inst, giver, item)
        local lvl = inst.lvl or 1
        if item.prefab == "cutgrass" or item.prefab == "twigs" then
            changeResearchMachine(inst)

            lighton(inst)

            inst.components.trader:Disable()
            inst.AnimState:PlayAnimation(FIRE_ANIMS[lvl], true)

            inst:DoTaskInTime(120, function(inst)
                inst:RemoveComponent("prototyper")

                lightoff(inst)

                inst.components.trader:Enable()
                inst.AnimState:PlayAnimation(IDLE_ANIMS[lvl], true)
            end)
        end
        if item.prefab == "goldnugget" then
            inst.lvl = lvl == 1 and 2 or 1
            inst.AnimState:PlayAnimation(IDLE_ANIMS[inst.lvl], true)
            inst.SoundEmitter:PlaySound("dontstarve/maxwell/disappear_adventure")
            SpawnPrefab("maxwell_smoke").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end
    end

    -- String/Inspectable functions
    local function GetStatus(inst)
        return inst.lvl and inst.lvl == 1 and "LVL_ONE" or "LVL_TWO"
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, .4)

        inst.MiniMapEntity:SetPriority(5)
        inst.MiniMapEntity:SetIcon(name .. ".tex")

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("lvl_one")

        inst:AddTag("giftmachine")
        inst:AddTag("zskb_copper_crane_platform")
        inst:AddTag("structure")

        --prototyper (from prototyper component) added to pristine state for optimization
        inst:AddTag("prototyper")

        inst.scrapbook_specialinfo = "ZSKB_COPPER_CRANE_PLATFORM"

        MakeSnowCoveredPristine(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.lvl = 1
        inst._activecount = 0
        inst._activetask = nil

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = GetStatus

        inst:AddComponent("lootdropper")
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(4)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit)

        inst:AddComponent("trader")
        inst.components.trader:SetAbleToAcceptTest(accepttest)
        inst.components.trader.onaccept = onacceptitem
        inst.components.trader.acceptnontradable = true

        MakeSnowCovered(inst)

        -- MakeLargeBurnable(inst, nil, nil, true)
        -- MakeLargePropagator(inst)

        inst.OnSave = onsave
        inst.OnLoad = onload

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        inst:ListenForEvent("onbuilt", onbuilt)
        inst:ListenForEvent("ms_addgiftreceiver", refreshonstate)
        inst:ListenForEvent("ms_removegiftreceiver", refreshonstate)
        inst:ListenForEvent("ms_giftopened", ongiftopened)

        inst._PlayAnimation = Default_PlayAnimation
        inst._PushAnimation = Default_PushAnimation

        return inst
    end
    return Prefab(name, fn, assets, prefabs)
end
--------------------------------------------------------------------------

--Using old prefab names
return createmachine("zskb_copper_crane_platform", "lvl1", TechTree.Create(), "science"),
    MakePlacer("zskb_copper_crane_platform_placer", "zskb_copper_crane_platform", "zskb_copper_crane_platform", "lvl_one")
