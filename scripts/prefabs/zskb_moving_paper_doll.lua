local assets =
{
    Asset("ANIM", "anim/zskb_moving_paper_doll.zip"),
    Asset("SOUND", "sound/sfx.fsb"),
}

local prefabs =
{
    "campfirefire",
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

local brain = require("brains/stagehandbrain")

SetSharedLootTable('zskb_moving_paper_doll_creature',
    {
        { 'zskb_bell',              0.1 },
        { 'zskb_blessing',          0.1 },
        { 'zskb_bull_head_statue',  0.1 },
        { 'zskb_comb',              0.1 },
        { 'zskb_embroidered_shoes', 0.1 },
        { 'zskb_hydrangea',         0.1 },
        { 'zskb_ingot',             0.1 },
        { 'zskb_reel',              0.1 },
        { 'zskb_scissors',          0.1 },
    })

local function onworked(inst, worker)
    inst.components.workable:SetWorkLeft(TUNING.STAGEHAND_HITS_TO_GIVEUP)
end

local function getstatus(inst)
    return inst.sg:HasStateTag("hiding") and "HIDING" or "AWAKE"
end

local function CanStandUp(inst)
    --如果不在光线下或屏幕外（屏幕外是为了不让它永远卡在萤火虫/猪舍灯之类的东西上），它就可以站起来走动
    return (not inst:IsInLight()) or (TheWorld.state.isnight and (not TheWorld.state.isfullmoon) and not inst:IsNearPlayer(30))
end

local sounds =
{
    hit       = "dontstarve/creatures/together/stagehand/hit",
    awake_pre = "dontstarve/creatures/together/stagehand/awake_pre",
    footstep  = "dontstarve/creatures/together/stagehand/footstep",
}

local function ChangePhysics(inst, is_standing)
    if is_standing then
        if inst:HasTag("blocker") then
            inst:RemoveTag("blocker")
            inst.Physics:SetMass(100)
            inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
            inst.Physics:CollidesWith(COLLISION.WORLD)
        end
    elseif not inst:HasTag("blocker") then
        inst:AddTag("blocker")
        inst.Physics:SetMass(0)
        inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.ITEMS)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        inst.Physics:CollidesWith(COLLISION.GIANTS)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    inst.Physics:SetFriction(0)    --设置无摩擦运动。
    inst.Physics:SetDamping(5)     --设置高阻尼，快速减速。
    ChangePhysics(inst, false)     --调用自定义函数，设为障碍物模式。
    inst.Physics:SetCapsule(.5, 1) --设置碰撞体为胶囊体，半径0.5，高度1。

    inst.AnimState:SetBank("zskb_moving_paper_doll")
    inst.AnimState:SetBuild("zskb_moving_paper_doll")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("notraptrigger")            --不会触发陷阱
    inst:AddTag("antlion_sinkhole_blocker") --不受蚁狮地震波及

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeSmallPropagator(inst) --火焰传播
    MakeHauntableWork(inst)   --可以作祟
    MakeSnowCovered(inst)     --冬天被积雪覆盖(这次我保留了积雪图层)

    --原版舞台之手的燃烧逻辑,做保留吧,反正我也留了图层
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:SetBurnTime(10)
    inst.components.burnable:AddBurnFX("campfirefire", Vector3(0, 0, 0), "swap_fire")

    --可以被锤子锤击,我就留个彩蛋吧
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(TUNING.STAGEHAND_HITS_TO_GIVEUP)
    -- inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onworked)

    inst:AddComponent("locomotor")                              --locomotor 组件必须在 stategraph 设定之前添加
    inst.components.locomotor.walkspeed = 8
    inst.components.locomotor:SetTriggersCreep(false)           --猜测是不会惊扰领地,例如蜘蛛巢里的蜘蛛,鱼人房里的鱼人
    inst.components.locomotor.pathcaps = { ignorecreep = true } --忽略特殊地形减速(例如蛛网)
    inst.sounds = sounds

    inst.CanStandUp = CanStandUp
    inst.ChangePhysics = ChangePhysics

    inst:SetStateGraph("SGstagehand")
    inst:SetBrain(brain)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('stagehand_creature')

    return inst
end

return Prefab("zskb_moving_paper_doll", fn, assets, prefabs)
