local assets =
{
    Asset("ANIM", "anim/zskb_mountain_spirit.zip"),
    Asset("SOUNDPACKAGE", "sound/zskb_mountain_spirit.fev"),
    Asset("SOUND", "sound/zskb_mountain_spirit.fsb"),
}

local prefabs =
{
    "zskb_mountain_spirit_egg",
    "warningshadow"
}

local BASE_LOOT =
{
    "zskb_mountain_spirit_skull",
}
for i = 1, 10 do
    table.insert(BASE_LOOT, "monstermeat")
end
local gems = { 'redgem', 'bluegem', 'purplegem', 'orangegem', 'yellowgem', 'greengem' }
for i = 1, 2 do
    for _, gem in ipairs(gems) do
        table.insert(BASE_LOOT, gem)
    end
end
-- prefab | weigh
local RANDOM_LOOT = {
    dragon_scales     = 10,
    minotaurhorn      = 10,
    deerclops_eyeball = 10,
    steelwool         = 10,
    shroom_skin       = 10,
    bearger_fur       = 10,
    gnarwail_horn     = 10,
    shadowheart       = 10,
    krampus_sack      = 1,
}


local spawn_positions =
{
    { x = 6, z = -6 },
    { x = 6, z = 6 },
    { x = 6, z = 0 },
}

local function ShrinkWarningShadow(inst, times, startsize, endsize)
    inst.AnimState:SetMultColour(1, 1, 1, 0.33)
    inst.Transform:SetScale(startsize, startsize, startsize)
    if inst.components.colourtweener == nil then
        inst:AddComponent("colourtweener")
    end
    if inst.components.sizetweener == nil then
        inst:AddComponent("sizetweener")
    end
    inst.components.colourtweener:StartTween({ 1, 1, 1, 1 }, times)
    inst.components.sizetweener:StartTween(.5, times, inst.Remove)
end


--- SKILLS FUNCTION
-- Launch EggBomb
local function SpawnEgg(inst, target)
    local x, y, z
    if target ~= nil then
        x, y, z = target:GetPosition():Get()
    else
        x, y, z = inst.Transform:GetWorldPosition()
        local random_offset = spawn_positions[math.random(1, #spawn_positions)]
        x = x + random_offset.x
        z = z + random_offset.z
    end

    x = x + math.random(-1.5, 1.5)
    y = 35
    z = z + math.random(-1.5, 1.5)

    local egg = SpawnPrefab("zskb_mountain_spirit_egg")
    egg.queen = inst
    egg.Physics:Teleport(x, y, z)

    -- egg.start_grounddetection(egg)

    egg.sg:GoToState("flying")

    local shadow = SpawnPrefab("warningshadow")
    shadow.Transform:SetPosition(x, 0.2, z)
    --shadow:shrink(1.5, 1.5, 0.25)
    ShrinkWarningShadow(shadow, 1.5, 1.5, 0.25)

    --inst.warrior_count = inst.warrior_count + 1
end

-- SANITY ATTACK
local SANITY_ATTACK_RANGE = TUNING.ZSKB_MOUNTAIN_SPIRIT_MUSIC_ATTACK_RANGE
local function DoMusicAttack(inst)
    local pt = inst:GetPosition()
    local players = TheSim:FindEntities(pt.x, pt.y, pt.z, SANITY_ATTACK_RANGE, { "player" }, { "playerghost" })
    for k, v in ipairs(players) do
        if v and v:IsValid() and v.entity:IsVisible() and not IsEntityDeadOrGhost(v) then
            local head = v.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
            if not (head and head.prefab == "earmuffshat") then
                v:PushEvent("zskb_sanity_stun", { duration = TUNING.ZSKB_MOUNTAIN_SPIRIT_MUSIC_ATTACK_DURATION })
            end
        end
    end
end

local function LaunchItem(inst, target, item)
    if item.Physics ~= nil and item.Physics:IsActive() then
        local x, y, z = item.Transform:GetWorldPosition()
        item.Physics:Teleport(x, .1, z)

        x, y, z = inst.Transform:GetWorldPosition()
        local x1, y1, z1 = target.Transform:GetWorldPosition()
        local angle = math.atan2(z1 - z, x1 - x) + (math.random() * 20 - 10) * DEGREES
        local speed = 5 + math.random() * 2
        item.Physics:SetVel(math.cos(angle) * speed, 10, math.sin(angle) * speed)
    end
end

-- Disarm target when GroundPound
local DISARM_RANGE = 20
local function OnGroundPound(inst)
    -- disarm nearby players
    local pt = inst:GetPosition()
    local players = TheSim:FindEntities(pt.x, pt.y, pt.z, DISARM_RANGE, { "player" }, { "playerghost" })
    for k, v in ipairs(players) do
        if v and v:IsValid() and v.entity:IsVisible() and not IsEntityDeadOrGhost(v) and
            v.components.inventory ~= nil and not v:HasTag("stronggrip") then
            local item = v.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if item ~= nil then
                v.components.inventory:DropItem(item)
                LaunchItem(inst, v, item)
            end
        end
    end
end

local MOUNTAIN_SPIRIT_DEAGRRO_DIST = 25
local MOUNTAIN_SPIRIT_AGGRO_DIST = 15
local function UpdatePlayerTargets(inst)
    local toadd = {}
    local toremove = {}
    --local pos = inst.components.knownlocations:GetLocation("spawnpoint")
    local pos = inst:GetPosition()

    for k, v in pairs(inst.components.grouptargeter:GetTargets()) do
        toremove[k] = true
    end
    for i, v in ipairs(FindPlayersInRange(pos.x, pos.y, pos.z, MOUNTAIN_SPIRIT_DEAGRRO_DIST, true)) do
        if toremove[v] then
            toremove[v] = nil
        else
            table.insert(toadd, v)
        end
    end

    for k, v in pairs(toremove) do
        inst.components.grouptargeter:RemoveTarget(k)
    end
    for i, v in ipairs(toadd) do
        inst.components.grouptargeter:AddTarget(v)
    end
end

local function GetClosestStunnedPlayerAndDistSq(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local closest = nil
    local mindistsq = math.huge
    for k, v in ipairs(AllPlayers) do
        local distsq = v:GetDistanceSqToPoint(x, y, z)
        if distsq < mindistsq and not IsEntityDeadOrGhost(v) and v.entity:IsVisible()
            and v.sg ~= nil and v.sg.currentstate.name == "mindcontrolled" then
            closest = v
            mindistsq = distsq
        end
    end
    return closest, mindistsq
end

local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "INLIMBO", "prey", "companion" }
local MOUNTAIN_SPIRIT_ATTACK_RANGE = 4 -- groundpounder hit range
local function RetargetFn(inst)
    local target, distsq = GetClosestStunnedPlayerAndDistSq(inst)
    if target ~= nil and distsq >= MOUNTAIN_SPIRIT_ATTACK_RANGE then return target, true end

    UpdatePlayerTargets(inst)

    local player = inst.components.combat.target
    if player ~= nil and player:HasTag("player") then
        local newplayer = inst.components.grouptargeter:TryGetNewTarget()
        if newplayer ~= nil and newplayer:IsNear(inst, MOUNTAIN_SPIRIT_ATTACK_RANGE) then
            return newplayer, true
        elseif player:IsNear(inst, MOUNTAIN_SPIRIT_ATTACK_RANGE) then
            return
        elseif newplayer ~= nil then
            player = newplayer
        end
    else
        player = nil
    end


    local x, y, z = inst.Transform:GetWorldPosition()
    local nearplayers = FindPlayersInRange(x, y, z, MOUNTAIN_SPIRIT_ATTACK_RANGE, true)
    if #nearplayers > 0 then
        return nearplayers[math.random(#nearplayers)], true
    end

    --Also needs to deal with other creatures in the world
    -- TODO a spawnpoint
    --local spawnpoint = inst.components.knownlocations:GetLocation("spawnpoint")
    local spawnpoint = inst:GetPosition()
    local deaggro_dist_sq = MOUNTAIN_SPIRIT_DEAGRRO_DIST * MOUNTAIN_SPIRIT_DEAGRRO_DIST
    local creature = FindEntity(
        inst,
        MOUNTAIN_SPIRIT_AGGRO_DIST,
        function(guy)
            return inst.components.combat:CanTarget(guy)
                and guy:GetDistanceSqToPoint(spawnpoint) < deaggro_dist_sq
        end,
        RETARGET_MUST_TAGS,     --see entityreplica.lua
        RETARGET_CANT_TAGS
    )

    if player ~= nil and
        (creature == nil or
            player:GetDistanceSqToPoint(x, y, z) <= creature:GetDistanceSqToPoint(x, y, z)
        ) then
        return player, true
    end

    if creature ~= nil then
        return creature, true
    end
end

local function KeepTargetFn(inst, target)
    return inst.components.combat:CanTarget(target)
        and target:GetDistanceSqToPoint(inst:GetPosition()) < MOUNTAIN_SPIRIT_DEAGRRO_DIST * MOUNTAIN_SPIRIT_DEAGRRO_DIST
end

-- attacker is myself, inst is the hitted guy
local function onhitotherfn(attacker, inst, damage, stimuli, weapon, damageresolved)
    if inst.components.zskb_zombie_threefire ~= nil then
        inst.components.zskb_zombie_threefire:DoDelta(-3)
        --print("三火清零")
    end
end



local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    trans:SetScale(0.9, 0.9, 0.9)

    MakeObstaclePhysics(inst, 2)

    anim:SetBank("zskb_mountain_spirit")
    anim:SetBuild("zskb_mountain_spirit")
    --anim:AddOverrideBuild("throne")

    inst:AddTag("zskb_mountain_spirit")
    inst:AddTag("epic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")

    inst:AddComponent("sleeper")

    inst:AddComponent("combat")
    inst.components.combat.canattack = false
    inst.components.combat:SetDefaultDamage(TUNING.BEARGER_DAMAGE)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat.playerdamagepercent = .5
    inst.components.combat.onhitotherfn = onhitotherfn

    inst:AddComponent("epicscare")
    inst.components.epicscare:SetRange(TUNING.TOADSTOOL_EPICSCARE_RANGE)

    inst:AddComponent("grouptargeter")

    inst:AddComponent("groundpounder") -- for sg
    inst.components.groundpounder:UseRingMode()
    inst.components.groundpounder.destroyer = true
    inst.components.groundpounder.damageRings = 3
    inst.components.groundpounder.destructionRings = 3
    inst.components.groundpounder.platformPushingRings = 3
    inst.components.groundpounder.numRings = 3
    inst.components.groundpounder.radiusStepDistance = 2
    inst.components.groundpounder.ringWidth = 1.5
    inst.components.groundpounder.groundpoundFn = OnGroundPound
    inst.SKILLS_COOLDOWN = {
        EGG_ATTACK = 12, -- 发射一次炮动画耗时1.6s, 三次 4.8 秒
        JUMP_ATTACK = 12,
        SANITY_ATTACK = 20,

    }

    --TODO: this is bull shit, should use healthtrigger component to make these better
    inst.components.combat:SetOnHit(function()
        local health_percent = inst.components.health:GetPercent()

        if health_percent <= 0.75 and health_percent > 0.5 then
            inst.summon_count = 4
            inst.min_combat_cooldown = 3
            inst.max_combat_cooldown = 5
            inst.SKILLS_COOLDOWN = {
                EGG_ATTACK = 12, -- 发射一次炮动画耗时1.6s, 三次 4.8 秒
                JUMP_ATTACK = 12,
                SANITY_ATTACK = 20,

            }
        elseif health_percent <= 0.5 and health_percent > 0.25 then
            inst.max_sanity_attack_count = 3
            inst.max_jump_attack_count = 3
            inst.min_combat_cooldown = 1
            inst.max_combat_cooldown = 3
            inst.SKILLS_COOLDOWN = {
                EGG_ATTACK = 10, -- 发射一次炮动画耗时1.6s, 三次 4.8 秒
                JUMP_ATTACK = 10,
                SANITY_ATTACK = 20,

            }
        elseif health_percent <= 0.25 then
            inst.min_combat_cooldown = 1
            inst.max_combat_cooldown = 1
            inst.SKILLS_COOLDOWN = {
                EGG_ATTACK = 6, -- 发射一次炮动画耗时1.6s, 三次 4.8 秒
                JUMP_ATTACK = 6,
                SANITY_ATTACK = 16,

            }
        end
    end)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.ZSKB_MOUNTAIN_SPIRIT_HEALTH)
    inst.components.health:StartRegen(1, 4)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(BASE_LOOT)

    for perfab, weigh in pairs(RANDOM_LOOT) do
        inst.components.lootdropper:AddRandomLoot(perfab, weigh)
    end
    inst.components.lootdropper.numrandomloot = 1

    inst:AddComponent("inspectable")

    -- Used in SG
    inst.jump_count = 1
    inst.jump_attack_count = 0
    inst.max_jump_attack_count = 3

    inst.sanity_attack_count = 0
    inst.max_sanity_attack_count = 2

    inst.summon_count = 3
    inst.current_summon_count = 0

    inst.min_combat_cooldown = 5
    inst.max_combat_cooldown = 7

    MakeLargeFreezableCharacter(inst, "crick_ab")

    inst:SetStateGraph("SGzskb_mountain_spirit")
    local brain = require "brains/zskb_mountain_spirit_brain"
    inst:SetBrain(brain)

    -- for sg and hack
    inst.SpawnEgg = SpawnEgg
    inst.DoMusicAttack = DoMusicAttack

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

    -- make nearby throne workable
    inst:ListenForEvent("onremove", function()
        local x, y, z = inst.Transform:GetWorldPosition()

        local ents = TheSim:FindEntities(x, y, z, 10, { "zskb_mountain_spirit_throne" })
        for k, v in pairs(ents) do
            if v.components.workable then
                v.components.workable:SetWorkable(true)
            end
            v:RemoveTag("NOCLICK")
        end
    end)

    return inst
end


return Prefab("zskb_mountain_spirit", fn, assets, prefabs)
