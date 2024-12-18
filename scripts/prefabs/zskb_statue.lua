local RADIUS = 16 * 1.414

local statues = {
    baihu = {
        postfn = function(inst)
            inst._players = {}
            inst:AddComponent("playerprox")
            inst.components.playerprox:SetTargetMode(inst.components.playerprox.TargetModes.AllPlayers)
            inst.components.playerprox:SetDist(RADIUS, RADIUS)
            inst.components.playerprox:SetOnPlayerFar(function(inst, player)
                if not player:HasTag("player") or player:HasTag("playerghost") then
                    return
                end
                inst._players[player] = nil
            end)
            inst.components.playerprox:SetOnPlayerNear(function(inst, player)
                if not player:HasTag("player") or player:HasTag("playerghost") then
                    return
                end
                inst._players[player] = true
            end)

            inst._task = inst:DoPeriodicTask(1, function(inst)
                local player_count = GetTableSize(inst._players)
                if player_count > 0 then
                    local x, y, z = inst:GetPosition():Get()
                    local ents = TheSim:FindEntities(x, y, z, RADIUS, nil, { "player", "playerghost", "INLIMBO" })
                    local newents = {}
                    for _, _ent in pairs(ents) do
                        if _ent:IsValid() and
                            _ent.components.health ~= nil and
                            not _ent.components.health:IsDead() and
                            _ent.components.combat ~= nil and
                            _ent.components.combat.target ~= nil and
                            inst._players[_ent.components.combat.target] then
                            table.insert(newents, _ent)
                        end
                    end
                    if #newents > 0 then
                        local _ent = newents[math.random(#newents)]
                        SpawnPrefab("lightning").Transform:SetPosition(_ent:GetPosition():Get())
                        _ent.components.health:DoDelta(-200, false, "lightning")
                    end
                end
            end)
        end
    },
    qinglong = {
        postfn = function(inst)
            inst._task = inst:DoPeriodicTask(1, function(inst)
                local ix, iy, iz = inst.Transform:GetWorldPosition()
                local nearby_tendable_plants = TheSim:FindEntities(ix, iy, iz, RADIUS, { "farm_plant" })
                for _, tendable_plant in pairs(nearby_tendable_plants) do
                    if tendable_plant:HasTag("tendable_farmplant") then
                        tendable_plant.components.farmplanttendable:TendTo()
                    end
                    -- 判断作物有没有青龙标签
                    if not tendable_plant:HasTag("zskb_farmplant_qinglong") then
                        tendable_plant:AddTag("zskb_farmplant_qinglong")
                    end
                end
                local lunarthrall_plants = TheSim:FindEntities(ix, iy, iz, RADIUS, { "lunarthrall_plant" })
                for _, lunarthrall_plant in pairs(lunarthrall_plants) do
                    if lunarthrall_plant:IsValid() and lunarthrall_plant.vines ~= nil then
                        lunarthrall_plant:killvines()
                    end
                end
            end)
        end
    },
    xuanwu = {
        postfn = function(inst)
            inst:AddComponent("zskb_touch")
        end
    },
    zhuque = {
        postfn = function(inst)
            inst:AddComponent("timer")

            inst._task = inst:DoPeriodicTask(1, function(inst)
                local ix, iy, iz = inst.Transform:GetWorldPosition()
                local nearby_ents = TheSim:FindEntities(ix, iy, iz, RADIUS)
                for _, ent in pairs(nearby_ents) do
                    if ent:IsValid() then
                        if ent:HasTag("playerghost") and not inst.components.timer:TimerExists("revive") then
                            ent:PushEvent("respawnfromghost", { source = inst })
                            inst.components.timer:StartTimer("revive", 600)
                        end
                        if not ent:HasTag("player") and
                            not ent:HasTag("campfire") and
                            ent.components.burnable ~= nil and
                            ent.components.burnable:IsBurning() then
                            ent.components.burnable:Extinguish(true)
                        end
                    end
                end
            end)
        end
    },
}

local function MakeStatue(name, data)
    local assets = {
        Asset("ANIM", "anim/zskb_statue.zip"),
    }

    local function onhammered(inst, worker)
        if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
            inst.components.burnable:Extinguish()
        end
        inst.components.lootdropper:DropLoot()
        if inst.components.container ~= nil then
            inst.components.container:DropEverything()
        end
        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("wood")
        inst:Remove()
    end

    local function onhit(inst, worker)

    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.entity:AddMiniMapEntity()

        MakeObstaclePhysics(inst, 1)

        inst.AnimState:SetBank("zskb_statue")
        inst.AnimState:SetBuild("zskb_statue")
        inst.AnimState:PlayAnimation(name)
        inst.AnimState:SetScale(1.25, 1.25, 1.25)

        inst.MiniMapEntity:SetIcon("zskb_" .. name .. ".tex")

        MakeSnowCoveredPristine(inst)

        inst:AddTag("structure")
        inst:AddTag("zskb_statue")
        inst:AddTag("zskb_" .. name)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("lootdropper")
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.MINE)
        inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit)

        MakeHauntable(inst)

        if data.postfn ~= nil then
            data.postfn(inst)
        end

        return inst
    end
    return Prefab("zskb_" .. name, fn, assets)
end

local prefs = {}
for name, data in pairs(statues) do
    table.insert(prefs, MakeStatue(name, data))
    table.insert(prefs, MakePlacer("zskb_" .. name .. "_placer", "zskb_statue", "zskb_statue", name))
end

return unpack(prefs)
