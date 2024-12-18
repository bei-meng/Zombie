require "behaviours/doaction"

local WAKE_UP_DIST = 5.5
local SLEEP_DIST = 40

local function IsPlayerInVicinity(inst)
    return GetClosestInstWithTag("player", inst, WAKE_UP_DIST) ~= nil
end

local function IsPlayerInVicinity2(inst)
    return GetClosestInstWithTag("player", inst, SLEEP_DIST) ~= nil
end

local function IsFirstEncounter(inst)
    return inst.components.combat.target == nil
end

local function GoToState(inst, state)
    if inst.sg.currentstate.name ~= state then
        inst.sg:GoToState(state)
    end
end

local function InAvailableState(inst)
    --return inst.sg.currentstate.name ~= "taunt" and inst.sg.currentstate.name ~= "wake" and
    --inst.sg.currentstate.name ~= "sleeping" and inst.sg.currentstate.name ~= "sleep"
    --and not table.contains(inst.sg.currentstate.tags, "busy")
    return not inst.sg:HasStateTag("busy")
end

local function CanAttack(inst)
    return inst.components.combat.canattack and InAvailableState(inst) and not inst.components.health:IsDead()
end

local function IsQuaking(inst)
    --return TheWorld.components.quaker_interior:IsQuaking() and not (inst.components.health:GetPercent() <= 0.3)
    return false
end

local function WakeUpFn(inst)
    GoToState(inst, "wake")
end

local function SleepFn(inst)
    inst.components.combat.target = nil
    GoToState(inst, "sleep")
end

local function SetCoolDown(inst, min, max)
    local fortime = math.random(min, max)
    inst.components.combat:BlankOutAttacks(fortime)
    inst:DoTaskInTime(fortime, function(inst)
        if math.random() < 0.3 and InAvailableState(inst) then
            GoToState(inst, "taunt")
        end
    end)
end

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- local SKILLS_COOLDOWN = {
--     EGG_ATTACK = 10, -- 发射一次炮动画耗时1.6s, 三次 4.8 秒
--     JUMP_ATTACK = 10,
--     SANITY_ATTACK = 16,

-- }
local GROUNDPOUND_RANGE = 4
local JMP_ATK_TEST_DISTSQ = (GROUNDPOUND_RANGE + 1) * (GROUNDPOUND_RANGE + 1)
-- local jump_attack_chance = { 0.9, 0.5, 0.25, }
--local function TryJumpAttack(inst)
--    if CanAttack(inst) and inst.jump_attack_count < inst.max_jump_attack_count and not IsQuaking(inst) then
--        if math.random () < (jump_attack_chance[inst.jump_attack_count + 1] or 0.9) then
--            return true
--        end
--    end
--    return false
--end

local function TryJumpAttack(inst)
    if CanAttack(inst) and inst.jump_attack_count < inst.max_jump_attack_count and not IsQuaking(inst) then
        local x, y, z = inst:GetPosition():Get()
        local target = inst.components.combat.target
        local distsq = target and target:GetDistanceSqToPoint(x, y, z)

        --local target, distsq = FindClosestPlayerInRange(x, y, z, GROUNDPOUND_RANGE, true)

        --local target, distsq = FindClosestEntity(inst, GROUNDPOUND_RANGE, true, { "_health", "_combat" }, { "INLIMBO", "playerghost", "shadowcreature", "spawnprotection" })
        if (inst.last_jump_attack_time == nil or GetTime() - inst.last_jump_attack_time >= inst.SKILLS_COOLDOWN.JUMP_ATTACK) and
            (target ~= nil and distsq < JMP_ATK_TEST_DISTSQ) then
            return true
        end
    end
    return false
end

local function JumpAttack(inst)
    inst.sanity_attack_count = 0
    --inst.last_attack_time = GetTime()
    inst.last_jump_attack_time = GetTime()
    inst.jump_attack_count = inst.jump_attack_count + 1
    GoToState(inst, "jump_attack")
    SetCoolDown(inst, inst.min_combat_cooldown, inst.max_combat_cooldown)
end

local function TrySummonEggs(inst)
    if InAvailableState(inst) and not inst.components.health:IsDead() then
        if inst.last_egg_attack_time == nil or GetTime() - inst.last_egg_attack_time >= inst.SKILLS_COOLDOWN.EGG_ATTACK then
            local target = inst.components.combat.target
            if target and target:IsValid() and inst.components.combat:CanTarget(target) then
                return true
            end
        end
    end

    return false
end

local function SummonEggs(inst)
    --inst.jump_attack_count = 0
    --inst.sanity_attack_count = 0
    --inst.last_attack_time = GetTime()
    inst.last_egg_attack_time = GetTime()
    GoToState(inst, "summon_eggs")
    SetCoolDown(inst, inst.min_combat_cooldown / 2, inst.max_combat_cooldown / 2)
end

local SANITY_ATTACK_RANGE = TUNING.ZSKB_MOUNTAIN_SPIRIT_MUSIC_ATTACK_RANGE
local function TrySanityAttack(inst)
    return (inst.last_sanity_attack_time == nil or GetTime() - inst.last_sanity_attack_time >= inst.SKILLS_COOLDOWN.SANITY_ATTACK) and
        inst.components.health:GetPercent() <= 0.75 and inst.sanity_attack_count < inst.max_sanity_attack_count and CanAttack(inst) and
        IsAnyOtherPlayerNearInst(inst, SANITY_ATTACK_RANGE * SANITY_ATTACK_RANGE, true)
end

local function SanityAttack(inst)
    inst.jump_attack_count = 0
    inst.sanity_attack_count = inst.sanity_attack_count + 1
    --inst.last_attack_time = GetTime()
    inst.last_sanity_attack_time = GetTime()
    GoToState(inst, "music_attack")
    SetCoolDown(inst, inst.min_combat_cooldown, inst.max_combat_cooldown)
end

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

local MountainSpiritBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function MountainSpiritBrain:OnStart()
    --print(self.inst, "PigBrain:OnStart")
    local root =
        PriorityNode(
            {
                ----TODO: check if we're already in combat in case the player put the queen to sleep
                --IfNode(function() return IsPlayerInVicinity(self.inst) and IsFirstEncounter(self.inst) and (self.inst.sg.currentstate.name == "sleeping" or self.inst.sg.currentstate.name == "sleep") end, "PlayerInVicinity",
                --    DoAction(self.inst, function()
                --        if self.inst.components.combat.target == nil then
                --            self.inst.components.combat:SetTarget(GetPlayer())
                --            WakeUpFn(self.inst)
                --        end
                --    end, "WakingUp")),
                --
                --IfNode(function() return not IsPlayerInVicinity2(self.inst) end, "PlayerInVicinity",
                --    DoAction(self.inst, function()
                --            SleepFn(self.inst)
                --    end, "Sleep")),

                IfNode(function() return TryJumpAttack(self.inst) end, "TryJumpAttack",
                    DoAction(self.inst, JumpAttack, "JumpAttack", false)),

                IfNode(function() return TrySanityAttack(self.inst) end, "TrySanityAttack",
                    DoAction(self.inst, SanityAttack, "SanityAttack", false)),

                IfNode(function() return TrySummonEggs(self.inst) end, "TrySummonEggs",
                    DoAction(self.inst, SummonEggs, "SummonEggs", false)),

            }, .25)

    self.bt = BT(self.inst, root)
end

return MountainSpiritBrain
