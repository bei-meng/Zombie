local function SpawnFXAtInst(fx_name, inst)
    local fx = SpawnPrefab(fx_name)
    if fx then
        fx.Transform:SetPosition(inst:GetPosition():Get())
        fx:DoTaskInTime(5, fx.Remove) -- just in case
    end
end

--持续掉血掉精神值
local function OnTick(inst, target)
    if target.components.health ~= nil and not target.components.health:IsDead() and not target:HasTag("playerghost") then
        target.components.health:DoDelta(-2, nil, "zskb_water_kiki")
    end
    if target.components.sanity ~= nil and not target:HasTag("playerghost") then
        target.components.sanity:DoDelta(-10)
    end
    if target.components.health == nil and target.components.sanity == nil then
        inst.components.debuff:Stop()
    end
end

local buffs = {
    -- 工作效率
    zskb_buff_workmultiplier = {
        onattachedfn = function(inst, target, followsymbol, followoffset, data)
            if target:HasTag("player") and target.components.health and not target.components.health:IsDead() then
                target.components.workmultiplier:AddMultiplier(ACTIONS.CHOP, TUNING.BUFF_WORKEFFECTIVENESS_MODIFIER, target)
                target.components.workmultiplier:AddMultiplier(ACTIONS.MINE, TUNING.BUFF_WORKEFFECTIVENESS_MODIFIER, target)
                target.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, TUNING.BUFF_WORKEFFECTIVENESS_MODIFIER, target)

                target.components.efficientuser:AddMultiplier(ACTIONS.CHOP, TUNING.BUFF_WORKEFFECTIVENESS_MODIFIER, target)
                target.components.efficientuser:AddMultiplier(ACTIONS.MINE, TUNING.BUFF_WORKEFFECTIVENESS_MODIFIER, target)
                target.components.efficientuser:AddMultiplier(ACTIONS.HAMMER, TUNING.BUFF_WORKEFFECTIVENESS_MODIFIER, target)
                SpawnFXAtInst("wolfgang_mighty_fx", target)
            end
        end,
        ondetachedfn = function(inst, target)
            if target.components.health and not target.components.health:IsDead() then
                target.components.workmultiplier:RemoveMultiplier(ACTIONS.CHOP, target)
                target.components.workmultiplier:RemoveMultiplier(ACTIONS.MINE, target)
                target.components.workmultiplier:RemoveMultiplier(ACTIONS.HAMMER, target)

                target.components.efficientuser:RemoveMultiplier(ACTIONS.CHOP, target)
                target.components.efficientuser:RemoveMultiplier(ACTIONS.MINE, target)
                target.components.efficientuser:RemoveMultiplier(ACTIONS.HAMMER, target)
                target.components.talker:Say("力量，结束了？")
            end
        end,
    },
    -- 隐身
    zskb_buff_invisibility = {
        onattachedfn = function(inst, target, followsymbol, followoffset, data)
            if target:HasTag("player") and target.components.health and not target.components.health:IsDead() then
                target:AddTag("notarget")
                target:AddTag("invisible")
                target.AnimState:SetMultColour(1, 1, 1, 0.3)
                SpawnFXAtInst("sand_puff", target)
            end
        end,
        ondetachedfn = function(inst, target)
            target:RemoveTag("notarget")
            target:RemoveTag("invisible")
            target.AnimState:SetMultColour(1, 1, 1, 1)
            SpawnFXAtInst("sand_puff", target)
        end,
    },
    -- 防雨
    zskb_buff_waterproofness = {
        onattachedfn = function(inst, target, followsymbol, followoffset, data)
            if target.components.health and not target.components.health:IsDead() then
                target.components.moisture.waterproofnessmodifiers:SetModifier(inst, 1)
            end
        end,
        ondetachedfn = function(inst, target)
            if target.components.health and not target.components.health:IsDead() then
                target.components.moisture.waterproofnessmodifiers:RemoveModifier(inst)
            end
        end,
    },
    -- 还阳丹
    zskb_buff_return_life_pill = {
        onattachedfn = function(inst, target, followsymbol, followoffset, data)
            if target.components.health and not target.components.health:IsDead() then
                SpawnFXAtInst("fx_book_fire", target)
            end
        end,
        ondetachedfn = function(inst, target)
            if target.components.health and not target.components.health:IsDead() then

            end
        end,
    },
    -- 建造
    zskb_buff_craft = {
        onattachedfn = function(inst, target, followsymbol, followoffset, data)
            local zskb_zombie = target.components.zskb_zombie
            if zskb_zombie == nil then return end
            zskb_zombie:SetCraftModifierCount(zskb_zombie.craftbuff_count + 10)
            inst:DoTaskInTime(0, function() inst.components.timer:StopTimer("buffover") end) -- cancel buff manually instead timer
            inst:ListenForEvent("consumeingredients", function(owner, data)
                if zskb_zombie and zskb_zombie:HasCraftModifier() then
                    zskb_zombie:SetCraftModifierCount(zskb_zombie.craftbuff_count - 1)
                    -- print(zskb_zombie.craftbuff_count .. " craft buff times left")
                end
                if zskb_zombie == nil or not zskb_zombie:HasCraftModifier() then
                    inst:PushEvent("timerdone", { name = "buffover" })
                    -- print("over")
                end
            end, target)
            SpawnFXAtInst("fx_book_research_station", target)
        end,
        ondetachedfn = function(inst, target)
            if target.components.zskb_zombie and not target.components.zskb_zombie:HasCraftModifier() and
                target.components.talker then
                target.components.talker:Say("制作技巧用光了")
            end
        end,
    },
    -- 尸毒
    zskb_buff_ptomaine = {
        onattachedfn = function(inst, target, followsymbol, followoffset, data)
            if target.components.health and not target.components.health:IsDead() then
                inst.start_attached_time = GetTime()
                inst.last_update_time = inst.start_attached_time
                local fx = SpawnPrefab("zskb_poisonbubble")
                if fx then
                    fx.Transform:SetScale(target.Transform:GetScale())
                    --fx.AnimState:SetMultColour(1,1,1,1)
                    target:AddChild(fx)
                    fx.Transform:SetPosition(0, 0, 0)
                    target.zskb_poison_fx = fx
                    fx.persists = false
                end
            end
        end,
        ondetachedfn = function(inst, target)
            if target.components.health and not target.components.health:IsDead() then
                if target.zskb_poison_fx and target.zskb_poison_fx.StopBubbles then
                    target.zskb_poison_fx:StopBubbles()
                end
            end
        end,
        ontick = function(inst, target, data) --frequency, base_dmg, base_multipl, bonus_dmg_perlevel, bonus_multipl_perlevel, maxlevel
            local time = GetTime()
            if inst.last_update_time and inst.start_attached_time and time - inst.last_update_time > data.frequency then
                local level = math.floor((time - inst.start_attached_time) / data.levelup_time) + 1 -- 本身算一层
                level = math.max(0, math.min(data.maxlevel, level))
                if target.components.health and not target.components.health:IsDead() then
                    -- 扣血
                    target.components.health:DoDelta(level * data.dmg_perlevel, nil, "ptomaine", nil, nil, true)
                    -- 受击系数修改
                    local exterdmgtakenmultipliers = target.components.combat and target.components.combat.externaldamagetakenmultipliers or nil
                    if exterdmgtakenmultipliers ~= nil and exterdmgtakenmultipliers.SetModifier then
                        exterdmgtakenmultipliers:SetModifier(inst, 1 + level * data.multipl_perlevel)
                    end
                    -- fx 层数
                    local fx = target.zskb_poison_fx
                    if fx ~= nil and level ~= fx.level and fx.SetLevelAndBubbles ~= nil then
                        fx:SetLevelAndBubbles(level)
                    end
                end
                inst.last_update_time = time
            end
        end,
    },
    -- 造成伤害减少
    zskb_buff_damage_reduce = {
        onattachedfn = function(inst, target, followsymbol, followoffset, data)
            if target.components.health and not target.components.health:IsDead() then
                local extermultipliers = target.components.combat and target.components.combat.externaldamagemultipliers or nil
                if extermultipliers ~= nil and extermultipliers.SetModifier then
                    extermultipliers:SetModifier(inst, 0.85)

                    target:DoTaskInTime(math.random() * 0.25, function()
                        local x, y, z = target.Transform:GetWorldPosition()
                        local fx = SpawnPrefab("battlesong_instant_taunt_fx")
                        if fx then
                            fx.Transform:SetPosition(x, y, z)
                        end
                    end)
                end
            end
        end,
        ondetachedfn = function(inst, target)
            if target.components.health and not target.components.health:IsDead() then
                local extermultipliers = target.components.combat and target.components.combat.externaldamagemultipliers or nil
                if extermultipliers ~= nil then
                    extermultipliers:RemoveModifier(inst)
                end
            end
        end,
    },
    zskb_buff_spirit_statue = {
        onattachedfn = function(inst, target, followsymbol, followoffset, data)
            if target.components.health and not target.components.health:IsDead() then
                local extermultipliers = target.components.combat and target.components.combat.externaldamagemultipliers or nil
                if extermultipliers ~= nil and extermultipliers.SetModifier then
                    extermultipliers:SetModifier(inst, 1.15)
                end
                inst.zskb_maxragetime = TUNING.ZSKB_BUFF_SPIRIT_STATUE_RAGE_INIT_TIME
                inst.components.timer:StartTimer("rage", inst.zskb_maxragetime)
                inst.components.timer:StartTimer("cost", TUNING.ZSKB_BUFF_SPIRIT_STATUE_COST_TIME)
                inst.components.timer:StopTimer("buffover")
                inst.zskb_dontremoveondeath = treasurechest_clear_fn
                inst:DoTaskInTime(1, function() inst.components.debuff.keepondespawn = false end)
                inst:ListenForEvent("timerdone", function(inst, data)
                    if data == nil then return end
                    if data.name == "rage" then
                        target.components.talker:Say(STRINGS.ZSKB_SPIRIT_STATUE_BUFF_WARNING)
                        target:DoTaskInTime(2 + math.random(0, 1), function()
                            local health = target and target.components.health or nil
                            if health and not health:IsDead() and target.trade_protection == nil then --交易后有短暂时间的保护（补救）机制
                                health:DoDelta(-30)
                            end
                        end)
                        inst.zskb_maxragetime = math.max(inst.zskb_maxragetime * TUNING.ZSKB_BUFF_SPIRIT_STATUE_RAGE_FAILURE_SCALE, TUNING.ZSKB_BUFF_SPIRIT_STATUE_RAGE_MIN_TIME) --TUNING.TOTAL_DAY_TIME
                        inst.components.timer:StartTimer("rage", inst.zskb_maxragetime)
                    elseif data.name == "cost" then
                        if target.components.hunger ~= nil then
                            target.components.hunger:DoDelta(-10)
                        end
                        if target.components.sanity ~= nil then
                            target.components.sanity:DoDelta(-10)
                        end
                        inst.components.timer:StartTimer("cost", TUNING.ZSKB_BUFF_SPIRIT_STATUE_COST_TIME)
                    end
                end)
            end
        end,
        ondetachedfn = function(inst, target)
            if target.components.health and not target.components.health:IsDead() then
                local extermultipliers = target.components.combat and target.components.combat.externaldamagemultipliers or nil
                if extermultipliers ~= nil then
                    extermultipliers:RemoveModifier(inst)
                end
            end
        end,
    },
    zskb_buff_water_kiki = {
        duration = 10,                        --buff时长
        onattachedfn = function(inst, target) --buff触发的执行函数
            if target.components.locomotor ~= nil then
                target.components.locomotor:SetExternalSpeedMultiplier(inst, "zskb_water_kiki", 0.8)
            end
            inst.task = inst:DoPeriodicTask(1, OnTick, nil, target)
        end,
        onextendedfn = function(inst, target)
            inst.components.timer:StopTimer("buffover")
            inst.components.timer:StartTimer("buffover", 10)
            inst.task:Cancel()
            inst.task = inst:DoPeriodicTask(1, OnTick, nil, target)
        end,
        ondetachedfn = function(inst, target) --buff结束时的执行函数
            if target.components.locomotor ~= nil then
                target.components.locomotor:RemoveExternalSpeedMultiplier(inst, "zskb_water_kiki")
            end
        end,
    }
}

return buffs
