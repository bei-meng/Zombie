local assets =
{
    Asset("ANIM", "anim/zskb_banyantree.zip"), --build
    Asset("SOUND", "sound/forest.fsb"),
}

--其他预制体
local prefabs =
{
    "log",                --木头
    "twigs",              --树枝
    "zskb_banyantreenut", --榕树树种
    "small_puff",         --在玩家加载范围内树根消失的特效
}

--所有树的数据
local builds =
{
    --榕树
    zskb_banyantree = {
        file = "zskb_banyantree",                    --动画文件名
        file_bank = "zskb_banyantree",               --动画bank名
        prefab_name = "zskb_banyantree",             --预制体名
        regrowth_tuning = TUNING.EVERGREEN_REGROWTH, --再生参数表,用的官方的,表中有个参数涉及树根消失,所有保留,所有宝石树都没有自然再生机制
        grow_times = TUNING.EVERGREEN_GROW_TIME,     --生长时间表,用的官方的
        --中等大小树的掉落
        normal_loot =
        {
            "log", "log", "log",
            "twigs", "twigs", "twigs", "twigs", "twigs"
        },
        --树砍到后摇晃屏幕的延迟
        chop_camshake_delay = 0.4,
    },
}

----------------------------------------------------------------------------------------
--各个阶段树的动画名
local function makeanims(stage)
    return {
        idle = stage,
        chop = "chop_" .. stage,
        fallleft = "fallleft_" .. stage,
        fallright = "fallright_" .. stage,
        stump = "stump_" .. stage,
    }
end

local short_anims = makeanims("short")
local normal_anims = makeanims("normal")
----------------------------------------------------------------------------------------

--树根挖铲后掉落战利品并消失
local function dig_up_stump(inst, chopper)
    inst.components.lootdropper:SpawnLootPrefab("log")
    inst.components.lootdropper:SpawnLootPrefab("log")
    inst:Remove()
end

--树根挖铲后掉落战利品并消失
local function dig_up_short(inst, chopper)
    inst.components.lootdropper:SpawnLootPrefab("zskb_banyantreenut")
    inst:Remove()
end

--获取某个颜色宝石树的数据表
local function GetBuild(inst)
    return builds[inst.build] or builds["zskb_banyantree"]
end

--某个动画结束之后循环播放摇晃动画:两个摇晃动画50%随机播放一个
local function PushSway(inst)
    inst.AnimState:PushAnimation(inst.anims.idle)
end

--循环播放摇晃动画:两个摇晃动画50%随机播放一个
local function Sway(inst)
    inst.AnimState:PlayAnimation(inst.anims.idle)
end

--树砍到后生成树根的执行函数
local function make_stump(inst)
    inst:RemoveComponent("workable")  --移除可以被工作组件
    inst:RemoveTag("shelter")         --移除树荫标签
    inst:RemoveComponent("hauntable") --移除可作祟组件
    MakeHauntableIgnite(inst)         --添加新的作祟组件

    RemovePhysicsColliders(inst)      --移除碰撞体积

    inst:AddTag("stump")              --添加树根标签
    --停止生长
    if inst.components.growable ~= nil then
        inst.components.growable:StopGrowing()
    end

    inst.MiniMapEntity:SetIcon("zskb_banyantree_stump.tex") --设置小地图图标

    --添加新的可以被工作组件:可以被铲子挖铲1次,挖铲后掉落战利品并消失
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up_stump)
    inst.components.workable:SetWorkLeft(1)

    --给树根添加一个消失的定时器
    if inst.components.timer and not inst.components.timer:TimerExists("decay") then
        inst.components.timer:StartTimer("decay", GetRandomWithVariance(GetBuild(inst).regrowth_tuning.DEAD_DECAY_TIME, GetBuild(inst).regrowth_tuning.DEAD_DECAY_TIME * 0.5))
    end
end

--砍伐榕树的回调函数
local function chop_tree(inst, chopper, chopsleft, numchops)
    --播放砍伐音效
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound(
            chopper ~= nil and chopper:HasTag("beaver") and
            "dontstarve/characters/woodie/beaver_chop_tree" or
            "dontstarve/wilson/use_axe_tree"
        )
    end

    --播放砍伐动画
    inst.AnimState:PlayAnimation(inst.anims.chop)
    inst.AnimState:PushAnimation(inst.anims.idle)
end

--树砍倒后摇晃屏幕的力度:阶段不同屏幕摇晃的参数不同
local function chop_down_tree_shake(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .25, .03,
        inst.components.growable ~= nil and
        inst.components.growable.stage > 2 and .5 or .25,
        inst, 6)
end

--树被砍倒后执行的函数
local function chop_down_tree(inst, chopper)
    inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")
    local pt = inst:GetPosition() --获取树的位置坐标

    ---------------------
    --根据砍伐者的位置判断树倒向哪边播放对应的动画
    local he_right = true

    if chopper then
        local hispos = chopper:GetPosition()
        he_right = (hispos - pt):Dot(TheCamera:GetRightVec()) > 0
    else
        if math.random() > 0.5 then
            he_right = false
        end
    end

    if he_right then
        inst.AnimState:PlayAnimation(inst.anims.fallleft)
        inst.components.lootdropper:DropLoot(pt - TheCamera:GetRightVec())
    else
        inst.AnimState:PlayAnimation(inst.anims.fallright)
        inst.components.lootdropper:DropLoot(pt + TheCamera:GetRightVec())
    end
    ---------------------

    --延迟摇晃屏幕
    inst:DoTaskInTime(GetBuild(inst).chop_camshake_delay, chop_down_tree_shake)

    --生成树根
    make_stump(inst)
    inst.AnimState:PushAnimation(inst.anims.stump, false)

    --停止生长成高大榕树
    if inst.components.timer and inst.components.timer:TimerExists("banyantree_cooldown") then
        inst.components.timer:StopTimer("banyantree_cooldown")
    end
end

--生成小树所执行的函数
local function SetShort(inst)
    inst.anims = short_anims --小树相关的动画名

    --添加树荫标签,玩家在树下可以提供些许防水效果,夏季避免过热效果
    inst:AddTag("shelter")

    --函数调用,循环播放摇晃动画
    Sway(inst)
end

--生成中等大小的树所执行的函数:函数内代码注释参考生成小树所执行的函数
local function SetNormal(inst)
    inst.anims = normal_anims

    if inst.components.workable then
        inst:RemoveComponent("workable")
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.CHOP)
        inst.components.workable:SetWorkLeft(TUNING.EVERGREEN_CHOPS_NORMAL)
        inst.components.workable:SetOnWorkCallback(chop_tree)
        inst.components.workable:SetOnFinishCallback(chop_down_tree)
    end

    inst.components.lootdropper:SetLoot(GetBuild(inst).normal_loot)

    inst:AddTag("shelter")

    Sway(inst)

    inst.components.growable:StopGrowing() --停止生长

    if inst.components.timer ~= nil and not inst.components.timer:TimerExists("banyantree_cooldown") then
        inst.components.timer:StartTimer("banyantree_cooldown", TUNING.OCEANTREE_ENRICHED_COOLDOWN_MIN + math.random() * TUNING.OCEANTREE_ENRICHED_COOLDOWN_VARIANCE)
    end
end

--小树长成中等大小的树所执行的函数
local function GrowNormal(inst)
    inst.AnimState:PlayAnimation("grow_short_to_normal")      --播放小树长成中等大小树的动画
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow") --播放树木生长的声音
    PushSway(inst)                                            --函数调用,上个动画结束之后循环播放摇晃动画
end

local function inspect_tree(inst)
    return (inst:HasTag("stump") and "CHOPPED")
        or nil
end

--生长阶段
local growth_stages = {}
for build, data in pairs(builds) do
    growth_stages[build] =
    {
        {
            name = "short",
            time = function(inst) return GetRandomWithVariance(data.grow_times[1].base, data.grow_times[1].random) end,
            fn = SetShort,
        },
        {
            name = "normal",
            fn = SetNormal,
            growfn = GrowNormal,
        },
    }
end

--返回生长阶段:赋予inst.components.growable.stages
local function GetGrowthStages(inst)
    return growth_stages[inst.build] or growth_stages["zskb_banyantree"]
end

--长成大榕树
local function SpawnBanyanTreePillar(inst)
    local x, _, z = inst.Transform:GetWorldPosition()

    local pillar = SpawnPrefab("zskb_banyantree_pillar")
    pillar.Transform:SetPosition(x, 0, z)

    if pillar.sproutfn ~= nil then
        pillar:sproutfn()
    end

    inst:Remove()

    return pillar -- Mods.
end

--保存世界执行的函数:存储部分数据到data
local function onsave(inst, data)
    if inst:HasTag("stump") then
        data.stump = true
    end

    if inst.build ~= "zskb_banyantree" then
        data.build = inst.build
    end

    if inst.components.growable ~= nil then
        data.growth_stage = inst.components.growable.stage
    end
end

--加载世界执行的函数:根据data恢复部分数据
local function onload(inst, data)
    if data ~= nil then
        inst.build = data.build ~= nil and builds[data.build] ~= nil and data.build or "zskb_banyantree"

        if data.stump then
            make_stump(inst)
            inst.AnimState:PlayAnimation(inst.anims.stump)
        end

        if data.growth_stage == 1 and inst.components.growable ~= nil then
            inst:RemoveComponent("workable")
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.DIG)
            inst.components.workable:SetWorkLeft(1)
            inst.components.workable:SetOnFinishCallback(dig_up_short)
        end

        if not inst:IsValid() then
            return
        end
    end
end

--脱离玩家加载范围后移除inspectable可检查组件
local function OnEntitySleep(inst)
    inst:RemoveComponent("inspectable")
end

--进入玩家加载范围后添加inspectable可检查组件
local function OnEntityWake(inst)
    if inst.components.inspectable == nil then
        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_tree
    end
end

--定时器函数
local function OnTimerDone(inst, data)
    --树根消失
    if data.name == "decay" then
        local x, y, z = inst.Transform:GetWorldPosition()
        if not inst:IsAsleep() then
            SpawnPrefab("small_puff").Transform:SetPosition(x, y, z)
        end
        inst:Remove()
    end
    --长成高大的榕树
    if data.name == "banyantree_cooldown" then
        inst:RemoveComponent("workable")

        if inst:IsAsleep() then
            SpawnBanyanTreePillar(inst)
        else
            inst.SoundEmitter:PlaySound("waterlogged2/common/watertree_pillar/grow")

            inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + FRAMES, SpawnBanyanTreePillar)
        end
    end
end

--被作祟时执行的函数
local function onhauntevergreen(inst, haunter)
    --有一定的概率对树进行1次砍伐
    if inst.components.workable ~= nil and math.random() <= TUNING.HAUNT_CHANCE_OFTEN then
        inst.components.workable:WorkedBy(haunter, 1)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
        return true
    end
    return false
end

--综合函数
local function tree(name, build, stage, data)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, .25)

        inst:SetDeploySmartRadius(DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT] / 2) --seed/planted_tree deployspacing/2

        inst.MiniMapEntity:SetIcon("zskb_banyantree.tex")

        inst:AddTag("shelter")

        inst.MiniMapEntity:SetPriority(-1)

        inst:AddTag("plant")
        inst:AddTag("tree")

        inst.build = build
        inst.AnimState:SetBuild(GetBuild(inst).file)

        inst.AnimState:SetBank(GetBuild(inst).file_bank)

        --注意:这条代码是指定该预制体的主prefab名称
        --而下面定义的三种name,算是子prefab名称
        --游戏里用控制台调用不同name,都是生成该prefab,区别查看下方※标识的注释
        inst:SetPrefabName(GetBuild(inst).prefab_name)

        MakeSnowCoveredPristine(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        local color = .5 + math.random() * .5
        inst.AnimState:SetMultColour(color, color, color, 1)

        -------------------
        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_tree

        -------------------
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.CHOP)
        inst.components.workable:SetOnWorkCallback(chop_tree)
        inst.components.workable:SetOnFinishCallback(chop_down_tree)

        -------------------
        inst:AddComponent("lootdropper")

        ---------------------
        inst:AddComponent("growable")
        inst.components.growable.stages = GetGrowthStages(inst)
        --※
        --对应上方注释,这里是根据stage参数生成不同阶段的树,stage=1是生成小树,stage=2是生成中等大小树,stage=0是随机生成中小树中的一种
        inst.components.growable:SetStage(stage == 0 and math.random(1, 2) or stage)
        inst.components.growable.springgrowth = true  --春季加快生长
        inst.components.growable.magicgrowable = true --可以被奶奶的应用造林学,旧版的应用园艺学催生,只能催生1个阶段
        if inst.components.growable.stage == 1 then
            inst.components.growable:StartGrowing()
            inst:RemoveComponent("workable")
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.DIG)
            inst.components.workable:SetWorkLeft(1)
            inst.components.workable:SetOnFinishCallback(dig_up_short)
        end

        ---------------------
        inst:AddComponent("timer")
        inst:ListenForEvent("timerdone", OnTimerDone)
        if inst.components.growable.stage == 2 and not inst.components.timer:TimerExists("banyantree_cooldown") then
            inst.components.timer:StartTimer("banyantree_cooldown", TUNING.OCEANTREE_ENRICHED_COOLDOWN_MIN + math.random() * TUNING.OCEANTREE_ENRICHED_COOLDOWN_VARIANCE)
        end

        ---------------------
        --作祟组件
        inst:AddComponent("hauntable")
        inst.components.hauntable:SetOnHauntFn(onhauntevergreen)

        ---------------------
        inst.OnSave = onsave
        inst.OnLoad = onload

        MakeSnowCovered(inst)

        ---------------------
        if data == "stump" then
            RemovePhysicsColliders(inst)
            inst:AddTag("stump")
            inst:RemoveTag("shelter")

            inst:RemoveComponent("workable")
            inst:RemoveComponent("growable")
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.DIG)
            inst.components.workable:SetOnFinishCallback(dig_up_stump)
            inst.components.workable:SetWorkLeft(1)
            inst.AnimState:PlayAnimation(inst.anims.stump)
            inst.MiniMapEntity:SetIcon("zskb_banyantree_stump.tex")
        else
            inst.AnimState:PlayAnimation(inst.anims.idle)
        end

        inst.OnEntitySleep = OnEntitySleep
        inst.OnEntityWake = OnEntityWake

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

--tree函数里的第一个参数仅是子prefab名称,也可以在控制台中调用得到,方便用控制台调出不同阶段的宝石树
return
    tree("zskb_banyantree", "zskb_banyantree", 0),
    tree("zskb_banyantree_short", "zskb_banyantree", 1),
    tree("zskb_banyantree_normal", "zskb_banyantree", 2),
    tree("zskb_banyantree_stump", "zskb_banyantree", 0, "stump")
