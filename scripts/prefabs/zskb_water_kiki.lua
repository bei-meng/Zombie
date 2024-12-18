local assets =
{
    Asset("ANIM", "anim/zskb_water_kiki.zip"),
    Asset("SOUND", "sound/monkey.fsb"),
}

local prefabs =
{
    "poop",
    "monkeyprojectile",
    "spoiled_food",
    "zskb_ghostfire",
}

local brain = require "brains/monkeybrain"
local nightmarebrain = require "brains/nightmaremonkeybrain"

local LOOT = {
    "spoiled_food",
    "spoiled_food",
    "spoiled_food",
    "zskb_ghostfire",
}

local function SetHarassPlayer(inst, player)
    --当骚扰的玩家不是当前玩家时
    if inst.harassplayer ~= player then
        --如果骚扰任务不为空，则取消任务
        if inst._harassovertask ~= nil then
            inst._harassovertask:Cancel()
            inst._harassovertask = nil
        end
        --如果骚扰的玩家不为空，则移除骚扰玩家的移除事件
        if inst.harassplayer ~= nil then
            inst:RemoveEventCallback("onremove", inst._onharassplayerremoved, inst.harassplayer)
            inst.harassplayer = nil
        end
        --如果新的骚扰玩家不为空，则添加骚扰玩家的移除事件，并设置骚扰玩家
        if player ~= nil then
            inst:ListenForEvent("onremove", inst._onharassplayerremoved, player)
            inst.harassplayer = player
            --定时120秒重复本函数
            inst._harassovertask = inst:DoTaskInTime(120, SetHarassPlayer, nil)
        end
    end
end

--判断是不是大便
local function IsPoop(item)
    return item.prefab == "poop"
end

local function oneat(inst)
    --猴子吃了一些食物。给他一些便便！
    if inst.components.inventory ~= nil then
        local maxpoop = 3
        local poopstack = inst.components.inventory:FindItem(IsPoop)
        if not poopstack or poopstack.components.stackable.stacksize < maxpoop then
            inst.components.inventory:GiveItem(SpawnPrefab("poop"))
        end
    end
end

--如果格子中有大便，就把大便丢出去
local function onthrow(weapon, inst)
    if inst.components.inventory ~= nil then
        inst.components.inventory:ConsumeByName("poop")
    end
end

--是否有弹药
local function hasammo(inst)
    return inst.components.inventory ~= nil and inst.components.inventory:FindItem(IsPoop) ~= nil
end

--被攻击的目标有30%的概率获得debuff
local function OnHitOther(inst, other)
    if other ~= nil and math.random() < 0.3 then
        if other.components.debuffable ~= nil and not other.components.debuffable:HasDebuff("zskb_buff_water_kiki") then
            other.components.debuffable:AddDebuff("zskb_buff_water_kiki", "zskb_buff_water_kiki")
        end
    end
end

--创建并装备猴子专属装备
local function EquipWeapons(inst)
    if inst.components.inventory ~= nil and not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
        local thrower = CreateEntity()
        thrower.name = "Thrower"
        thrower.entity:AddTransform()
        thrower:AddComponent("weapon")
        thrower.components.weapon:SetDamage(TUNING.MONKEY_RANGED_DAMAGE)
        thrower.components.weapon:SetRange(TUNING.MONKEY_RANGED_RANGE)
        thrower.components.weapon:SetProjectile("monkeyprojectile")
        thrower.components.weapon:SetOnProjectileLaunch(onthrow)
        thrower:AddComponent("inventoryitem")
        thrower.persists = false
        thrower.components.inventoryitem:SetOnDroppedFn(thrower.Remove)
        thrower:AddComponent("equippable")
        thrower:AddTag("nosteal")
        inst.components.inventory:GiveItem(thrower)
        inst.weaponitems.thrower = thrower

        local hitter = CreateEntity()
        hitter.name = "Hitter"
        hitter.entity:AddTransform()
        hitter:AddComponent("weapon")
        hitter.components.weapon:SetDamage(TUNING.MONKEY_MELEE_DAMAGE)
        hitter.components.weapon:SetRange(0)
        hitter:AddComponent("inventoryitem")
        hitter.persists = false
        hitter.components.inventoryitem:SetOnDroppedFn(hitter.Remove)
        hitter:AddComponent("equippable")
        hitter:AddTag("nosteal")
        inst.components.inventory:GiveItem(hitter)
        inst.weaponitems.hitter = hitter
    end
end

--攻击目标置空
local function _ForgetTarget(inst)
    inst.components.combat:SetTarget(nil)
end

local MONKEY_TAGS = { "monkey" }
local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    SetHarassPlayer(inst, nil)
    if inst.task ~= nil then
        inst.task:Cancel()
    end
    inst.task = inst:DoTaskInTime(math.random(55, 65), _ForgetTarget) --约一分钟之后忘记攻击目标

    --猴子群体仇恨
    local x, y, z = inst.Transform:GetWorldPosition()
    local monkeys = TheSim:FindEntities(x, y, z, 30, MONKEY_TAGS)
    for _, monkey in ipairs(monkeys) do
        if monkey ~= inst and monkey.components.combat then
            monkey.components.combat:SuggestTarget(data.attacker)
            SetHarassPlayer(monkey, nil)
            if monkey.task ~= nil then
                monkey.task:Cancel()
            end
            monkey.task = monkey:DoTaskInTime(math.random(55, 65), _ForgetTarget) --Forget about target after a minute
        end
    end
end

--判断是不是香蕉
local function IsBanana(item)
    return item.prefab == "cave_banana" or item.prefab == "cave_banana_cooked"
end

local function FindTargetOfInterest(inst)
    if not inst.curious then
        return
    end

    if inst.harassplayer == nil and inst.components.combat.target == nil then
        local x, y, z = inst.Transform:GetWorldPosition()
        --获取范围内所有玩家
        local targets = FindPlayersInRange(x, y, z, 25)
        --遍历所有玩家，直到找到感兴趣的玩家并跟随该玩家。
        for _ = 1, #targets do
            local randomtarget = math.random(#targets)
            local target = targets[randomtarget]
            table.remove(targets, randomtarget)
            --若玩家身上携带有香蕉，则有60%的概率跟随该玩家
            if target.components.inventory ~= nil and
                math.random() < (target.components.inventory:FindItem(IsBanana) ~= nil and .6 or .15) then
                SetHarassPlayer(inst, target)
                return
            end
        end
    end
end

--重新选择攻击目标
local RETARGET_MUST_TAGS = { "_combat" }
local RETARGET_CANT_TAGS = { "playerghost" }
local RETARGET_ONEOF_TAGS = { "character", "monster" }
local function retargetfn(inst)
    return FindEntity(
        inst,
        20,
        function(guy)
            return inst.components.combat:CanTarget(guy)
        end,
        RETARGET_MUST_TAGS,
        RETARGET_CANT_TAGS,
        RETARGET_ONEOF_TAGS
    )
end

--返回一个true值，表示保持攻击目标
local function shouldKeepTarget(inst)
    return true
end

--拾取物品的监听函数，如果是头部装备，则延迟一帧后装备
local function onpickup_delayed(inst, item)
    if item:IsValid() and
        item.components.inventoryitem ~= nil and
        item.components.inventoryitem.owner == inst then
        inst.components.inventory:Equip(item)
    end
end
local function OnPickup(inst, data)
    local item = data.item
    if item ~= nil and
        item.components.equippable ~= nil and
        item.components.equippable.equipslot == EQUIPSLOTS.HEAD and
        not inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) then
        --Ugly special case for how the PICKUP action works.
        --Need to wait until PICKUP has called "GiveItem" before equipping item.
        inst:DoTaskInTime(0, onpickup_delayed, item)
    end
end

--作祟时执行的函数，拉屎
local function OnCustomHaunt(inst)
    inst.components.periodicspawner:TrySpawn()
    return true
end

--mod玩具表格，击杀掉落2个随机玩具，可以重复
local Toy_table =
{
    "zskb_broken_pages1",
    "zskb_broken_pages2",
    "zskb_broken_pages3",
    "zskb_bell",
    "zskb_blessing",
    "zskb_bull_head_statue",
    "zskb_comb",
    "zskb_embroidered_shoes",
    "zskb_hydrangea",
    "zskb_ingot",
    "zskb_reel",
    "zskb_scissors",
}
local function OnKilled(inst)
    if inst.components.lootdropper ~= nil then
        for i = 1, 2 do
            local toy = Toy_table[math.random(#Toy_table)]
            inst.components.lootdropper:SpawnLootPrefab(toy)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow() --动态阴影
    inst.entity:AddNetwork()

    inst.DynamicShadow:SetSize(2, 1.25)  --动态阴影大小

    inst.Transform:SetSixFaced()         --设置六面体

    MakeCharacterPhysics(inst, 10, 0.25) --给生物添加物理属性，第二个参数是质量，第三个参数是碰撞半径

    inst.AnimState:SetBank("zskb_water_kiki")
    inst.AnimState:SetBuild("zskb_water_kiki")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst:AddTag("monkey")
    inst:AddTag("animal")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.soundtype = ""

    MakeMediumBurnableCharacter(inst)                   --添加燃烧属性
    MakeMediumFreezableCharacter(inst)                  --添加冰冻属性

    inst:AddComponent("bloomer")                        --视觉特效组件

    inst:AddComponent("inventory")                      --物品栏

    inst:AddComponent("inspectable")                    --可检查组件

    inst:AddComponent("thief")                          --小偷组件

    local locomotor = inst:AddComponent("locomotor")    --运动组件
    locomotor:SetSlowMultiplier(1)                      --设置减速倍数，1表示不减速
    locomotor:SetTriggersCreep(false)                   --控制实体是否触发地形上的特殊效果，比如蜘蛛网，使得蜘蛛出没，false表示不触发
    locomotor.pathcaps = { ignorecreep = false }        --寻路偏好设置
    locomotor.walkspeed = TUNING.MONKEY_MOVE_SPEED      --设置移动速度

    local combat = inst:AddComponent("combat")          --战斗组件
    combat:SetAttackPeriod(TUNING.MONKEY_ATTACK_PERIOD) --设置攻击间隔
    combat:SetRange(TUNING.MONKEY_MELEE_RANGE)          --设置攻击范围
    combat:SetRetargetFunction(1, retargetfn)           --设置失去攻击目标后重新寻找目标的函数，可忽略，此函数为暗影猴子所写
    combat:SetKeepTargetFunction(shouldKeepTarget)      --设置是否保持攻击目标的函数
    combat:SetDefaultDamage(0)                          --This doesn't matter, monkey uses weapon damage
    combat.onhitotherfn = OnHitOther

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(400)

    --随地大小便
    local periodicspawner = inst:AddComponent("periodicspawner") --周期性生成实体组件
    periodicspawner:SetPrefab("poop")                            --设置生成的实体
    periodicspawner:SetRandomTimes(200, 400)                     --设置生成间隔时间:每隔 200 ~ 600 秒随机生成一次实体
    periodicspawner:SetDensityInRange(20, 2)                     --在 20 半径范围内最多允许存在 2 个相同实体
    periodicspawner:SetMinimumSpacing(15)                        --设置生成实体的最小间距
    periodicspawner:Start()                                      --开始生成实体

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(LOOT)

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.VEGGIE }, { FOODTYPE.VEGGIE })
    inst.components.eater:SetOnEatFn(oneat)

    inst:AddComponent("sleeper")
    --函数总结:远离家的猴子，在确保没有战斗等干扰条件下，会在地面的白天期间睡觉(洞穴和地面均相同)
    inst.components.sleeper.sleeptestfn = NocturnalSleepTest
    --函数总结:睡眠中的猴子，会在周围有干扰条件的情况下被唤醒，地面的非白天时间也会被唤醒(洞穴和地面均相同)
    inst.components.sleeper.waketestfn = NocturnalWakeTest

    --区域检测组件
    inst:AddComponent("areaaware")

    inst:AddComponent("acidinfusible")                                             --酸雨影响组件
    inst.components.acidinfusible:SetFXLevel(1)                                    --强度
    inst.components.acidinfusible:SetMultipliers(TUNING.ACID_INFUSION_MULT.WEAKER) --攻击、行走、防御三个数值倍数改变，移步TUNING表

    inst:SetBrain(nightmarebrain)
    inst:SetStateGraph("SGmonkey")

    inst.FindTargetOfInterestTask = inst:DoPeriodicTask(10, FindTargetOfInterest) --寻找感兴趣的事情

    inst.HasAmmo = hasammo                                                        --是否有弹药(大便)
    inst.curious = true                                                           --是否好奇
    inst.harassplayer = nil                                                       --骚扰者
    inst._onharassplayerremoved = function() SetHarassPlayer(inst, nil) end       --设置骚扰者(玩家)函数

    inst:AddComponent("knownlocations")                                           --已知位置组件
    inst:AddComponent("timer")                                                    --计时器组件

    inst:ListenForEvent("onpickupitem", OnPickup)                                 --拾取物品时判断 该物品是否是头部装备
    inst:ListenForEvent("attacked", OnAttacked)                                   --被攻击时
    inst:ListenForEvent("death", OnKilled)                                        --死亡时

    --作祟
    MakeHauntablePanic(inst)
    AddHauntableCustomReaction(inst, OnCustomHaunt, true, false, true)

    --猴子专属武器
    inst.weaponitems = {}
    EquipWeapons(inst)

    return inst
end

return Prefab("zskb_water_kiki", fn, assets, prefabs)
