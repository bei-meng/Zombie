local CANDLE_BURN_TIME = 420
local ANIM_CANDLE_COUNT = { "one", "two", "three" }
local trinkets = { "taffy", "jellybean" }
for k = 1, NUM_TRINKETS do
    table.insert(trinkets, "trinket_" .. tostring(k))
end

local sketchs = {
    "chesspiece_pawn_sketch",
    "chesspiece_rook_sketch",
    "chesspiece_knight_sketch",
    "chesspiece_bishop_sketch",
    "chesspiece_muse_sketch",
    "chesspiece_formal_sketch",
    "chesspiece_deerclops_sketch",
    "chesspiece_bearger_sketch",
    "chesspiece_moosegoose_sketch",
    "chesspiece_dragonfly_sketch",
    "chesspiece_clayhound_sketch",
    "chesspiece_claywarg_sketch",
    "chesspiece_butterfly_sketch",
    "chesspiece_anchor_sketch",
    "chesspiece_moon_sketch",
    "chesspiece_carrat_sketch",
    "chesspiece_malbatross_sketch",
    "chesspiece_crabking_sketch",
    "chesspiece_toadstool_sketch",
    "chesspiece_stalker_sketch",
    "chesspiece_klaus_sketch",
    "chesspiece_beequeen_sketch",
    "chesspiece_antlion_sketch",
    "chesspiece_minotaur_sketch",
    "chesspiece_beefalo_sketch",
    "chesspiece_guardianphase3_sketch",
    "chesspiece_eyeofterror_sketch",
    "chesspiece_twinsofterror_sketch",
    "chesspiece_kitcoon_sketch",
    "chesspiece_catcoon_sketch",
    "chesspiece_manrabbit_sketch",
    "chesspiece_daywalker_sketch",
    "chesspiece_deerclops_mutated_sketch",
    "chesspiece_warg_mutated_sketch",
    "chesspiece_bearger_mutated_sketch",
    "chesspiece_yotd_sketch",
}

local function GenerateLoot(loots)
    local _loots = {}
    for _, v in pairs(loots) do
        if math.random() < v[2] then
            table.insert(_loots, v[1])
        end
    end
    return _loots
end

local function launchitem(item, angle)
    local speed = math.random() * 4 + 2
    angle = (angle + math.random() * 60 - 30) * DEGREES
    item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
end

local GRAVES = {
    normal = {
        color = { 133 / 255, 164 / 255, 255 / 255 },
        tradeitemtags = { "preparedfood" },
        onacceptitem = function(inst, giver, item)
            local loots = {
                { "sketch",            0.05 },
                { "beeswax",           0.05 },
                { "bluegem",           0.05 },
                { "redgem",            0.05 },
                { "purplegem",         0.05 },
                { "orangegem",         0.05 },
                { "yellowgem",         0.05 },
                { "greengem",          0.05 },
                { "lightninggoathorn", 0.05 },
                { "steelwool",         0.05 },
                { "walrus_tusk",       0.05 },
                { "tentaclespots",     0.05 },

                { "goldnugget",        0.14 },
                { "livinglog",         0.14 },
                { "beefalowool",       0.14 },
                { "manrabbit_tail",    0.14 },
                { "rocks",             0.14 },
                { "cookingrecipecard", 0.14 },
                { "amulet",            0.14 },
                { "gunpowder",         0.14 },

                { "flint",             0.29 },
                { "nitre",             0.29 },
                { "cutgrass",          0.29 },
                { "twigs",             0.29 },
                { "log",               0.29 },

                -- 保底
                { "flint",             1.0 },
                { "nitre",             1.0 },
                { "cutgrass",          1.0 },
                { "twigs",             1.0 },
                { "log",               1.0 },
            }
            local _loots = GenerateLoot(loots)
            if _loots ~= nil and #_loots > 0 then
                local x, y, z = inst.Transform:GetWorldPosition()
                y = 4.5
                local angle
                if giver ~= nil and giver:IsValid() then
                    angle = 180 - giver:GetAngleToPoint(x, 0, z)
                else
                    local down = TheCamera:GetDownVec()
                    angle = math.atan2(down.z, down.x) / DEGREES
                    giver = nil
                end
                local select_item = _loots[1]
                if select_item == "sketch" then
                    select_item = sketchs[math.random(#sketchs)]
                end
                local reward_item = SpawnPrefab(select_item)
                reward_item.Transform:SetPosition(x, y, z)
                launchitem(reward_item, angle)
            end
        end
    },
    older = {
        color = { 69 / 255, 219 / 255, 233 / 255 },
        tradeitemtags = { "zskb_copper_coin" },
        onacceptitem = function(inst, giver, item)
            local loots = {
                { "nightstick",      0.05 },
                { "dreadstonehat",   0.05 },
                { "armordreadstone", 0.05 },
                { "armor_sanity",    0.05 },

                { "nightmarefuel",   0.14 },
                { "purpleamulet",    0.14 },
                { "armorwood",       0.14 },
                { "firestaff",       0.14 },
                { "telestaff",       0.14 },
                { "batbat",          0.14 },
                { "footballhat",     0.14 },
                { "icestaff",        0.14 },

                { "armorgrass",      0.29 },
                { "stinger",         0.29 },

                -- 保底
                { "armorgrass",      1.0 },
                { "stinger",         1.0 },
            }
            local _loots = GenerateLoot(loots)
            if _loots ~= nil and #_loots > 0 then
                local x, y, z = inst.Transform:GetWorldPosition()
                y = 4.5
                local angle
                if giver ~= nil and giver:IsValid() then
                    angle = 180 - giver:GetAngleToPoint(x, 0, z)
                else
                    local down = TheCamera:GetDownVec()
                    angle = math.atan2(down.z, down.x) / DEGREES
                    giver = nil
                end
                local reward_item = SpawnPrefab(_loots[1])
                reward_item.Transform:SetPosition(x, y, z)
                launchitem(reward_item, angle)
            end
        end,
    },
    child = {
        color = { 239 / 255, 254 / 255, 183 / 255 },
        tradeitemnames = trinkets,
        onacceptitem = function(inst, giver, item)
            local loots = {
                { "giftwrap",             0.14 },
                { "panflute",             0.14 },
                { "glommerfuel",          0.14 },
                { "armorsnurtleshell",    0.14 },
                { "featherfan",           0.14 },
                { "treegrowthsolution",   0.14 },

                { "feather_canary",       0.29 },
                { "feather_crow",         0.29 },
                { "feather_robin",        0.29 },
                { "feather_robin_winter", 0.29 },
                { "bundlewrap",           0.29 },
                { "cutless",              0.29 },

                -- 保底
                { "feather_canary",       0.29 },
                { "feather_crow",         0.29 },
                { "feather_robin",        0.29 },
                { "feather_robin_winter", 0.29 },
                { "bundlewrap",           0.29 },
                { "cutless",              0.29 },
            }
            local _loots = GenerateLoot(loots)
            if _loots ~= nil and #_loots > 0 then
                local x, y, z = inst.Transform:GetWorldPosition()
                y = 4.5
                local angle
                if giver ~= nil and giver:IsValid() then
                    angle = 180 - giver:GetAngleToPoint(x, 0, z)
                else
                    local down = TheCamera:GetDownVec()
                    angle = math.atan2(down.z, down.x) / DEGREES
                    giver = nil
                end
                local reward_item = SpawnPrefab(_loots[1])
                reward_item.Transform:SetPosition(x, y, z)
                launchitem(reward_item, angle)
            end
        end,
    },
}

local function MakeGrave(name, data)
    local assets = {
        Asset("ANIM", "anim/zskb_graves.zip"),
    }

    local function onphase(inst, phase)
        -- 地面三个时段是 day, dusk, night
        -- 洞穴里三个时段都是 night
        if phase == "night" and inst.candle_count == 3 then
            inst.AnimState:PlayAnimation(name .. "_soul")
            inst.AnimState:PushAnimation(name .. "_soul_idle", true)
            inst.Light:Enable(true)
        else
            inst.AnimState:PlayAnimation(inst.candle_count == 0 and name or name .. "_" .. ANIM_CANDLE_COUNT[inst.candle_count])
            inst.Light:Enable(false)
        end
    end

    local function accepttest(inst, item, giver)
        return (inst.candle_count < 3 and item.prefab == "zskb_candle") or
            (inst.candle_count == 3 and
                TheWorld.state.phase == "night" and
                giver.components.zskb_zombie_threefire ~= nil and
                giver.components.zskb_zombie_threefire:GetCurrent() == 0 and
                ((data.tradeitemtags ~= nil and item:HasOneOfTags(data.tradeitemtags)) or
                    (data.tradeitemnames ~= nil and table.contains(data.tradeitemnames, item.prefab))))
    end

    local function onacceptitem(inst, giver, item)
        if item.prefab == "zskb_candle" then
            inst.candle_count = math.clamp(inst.candle_count + 1, 0, 3)
            inst.AnimState:PlayAnimation(inst.candle_count == 0 and name or name .. "_" .. ANIM_CANDLE_COUNT[inst.candle_count])
            inst.components.fueled:DoDelta(CANDLE_BURN_TIME, giver)
            inst.components.fueled:StartConsuming()

            if inst.candle_count == 3 then
                onphase(inst, TheWorld.state.phase)
            end
        else
            data.onacceptitem(inst, giver, item)
        end
    end

    local function OnSave(inst, data)
        data.candle_count = inst.candle_count or 0
    end

    local function OnLoad(inst, data)
        if data ~= nil then
            inst.candle_count = data.candle_count or 0
        end
        onphase(inst, TheWorld.state.phase)
    end

    local function nofuel(inst)
        inst.candle_count = 0
        inst.AnimState:PlayAnimation(name)
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddLight()

        inst.MiniMapEntity:SetIcon("zskb_grave_" .. name .. ".tex")
        inst:AddTag("grave")

        inst.AnimState:SetBank("zskb_graves")
        inst.AnimState:SetBuild("zskb_graves")
        inst.AnimState:PlayAnimation(name)

        inst.Light:SetFalloff(0.5)
        inst.Light:SetIntensity(0.8)
        inst.Light:SetRadius(1.5)
        inst.Light:SetColour(data.color[1], data.color[2], data.color[3])
        inst.Light:Enable(false)
        inst.Light:EnableClientModulation(true)

        MakeSnowCoveredPristine(inst)
        MakeObstaclePhysics(inst, 1)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.candle_count = 0
        inst.cantrade = false
        inst:AddComponent("inspectable")

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.MAGIC
        inst.components.fueled:InitializeFuelLevel(CANDLE_BURN_TIME)
        inst.components.fueled:SetDepletedFn(nofuel)
        inst.components.fueled.acceptingcepting = false

        inst:AddComponent("trader")
        inst.components.trader:SetAbleToAcceptTest(accepttest)
        inst.components.trader.onaccept = onacceptitem
        inst.components.trader.acceptnontradable = true

        MakeSnowCovered(inst)
        MakeHauntableLaunch(inst)

        inst:WatchWorldState("phase", onphase)
        onphase(inst, TheWorld.state.phase)

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad

        return inst
    end
    return Prefab("zskb_grave_" .. name, fn, assets)
end

local prefs = {}
for name, data in pairs(GRAVES) do
    table.insert(prefs, MakeGrave(name, data))
end

return unpack(prefs)
