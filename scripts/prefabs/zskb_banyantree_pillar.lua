local assets =
{
    Asset("ANIM", "anim/zskb_banyantree_pillar.zip"), --build
    Asset("SCRIPT", "scripts/prefabs/canopyshadows.lua"),
}

local prefabs = {}

local MIN = TUNING.SHADE_CANOPY_RANGE_SMALL             --22
local MAX = MIN + TUNING.WATERTREE_PILLAR_CANOPY_BUFFER --22+1

local function OnFar(inst, player)
    if player.zskb_canopytrees then
        player.zskb_canopytrees = player.zskb_canopytrees - 1
        player:PushEvent("zskbonchangecanopyzone", player.zskb_canopytrees > 0)
    end
    inst.players[player] = nil
end

local function OnNear(inst, player)
    inst.players[player] = true

    player.zskb_canopytrees = (player.zskb_canopytrees or 0) + 1

    player:PushEvent("zskbonchangecanopyzone", player.zskb_canopytrees > 0)
end

local function make_heavy_object_falling(inst, heavy_obj)
    heavy_obj.components.heavyobstaclephysics:AddFallingStates()
    heavy_obj:PushEvent("startfalling")

    heavy_obj.Physics:SetVel(0, 0, 0)

    heavy_obj.falltask = heavy_obj:DoPeriodicTask(FRAMES, function()
        local x, y, z = heavy_obj.Transform:GetWorldPosition()
        if y <= 0.2 then
            if TheWorld.Map:IsOceanAtPoint(x, 0, z) then
                -- By this point the dropped object has submerged, so this position is local to the underwater container object
                heavy_obj.Transform:SetPosition(0, 0, 0)
            end

            heavy_obj:PushEvent("stopfalling")

            if heavy_obj.falltask then
                heavy_obj.falltask:Cancel()
                heavy_obj.falltask = nil
            end
        end
    end)
end

local function DropNut(inst)
    local x, _, z = inst.Transform:GetWorldPosition()

    local item = SpawnPrefab("zskb_banyantreenut")

    local dist = 8 + 12 * math.random()
    local theta = math.random() * TWOPI

    local spawn_x, spawn_z
    spawn_x, spawn_z = x + math.cos(theta) * dist, z + math.sin(theta) * dist
    make_heavy_object_falling(inst, item)

    item.Transform:SetPosition(spawn_x, 10, spawn_z)
end

local function chop_tree(inst, chopper, chopsleft, numchops)
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound(
            chopper ~= nil and chopper:HasTag("beaver") and
            "dontstarve/characters/woodie/beaver_chop_tree" or
            chopper ~= nil and chopper:HasTag("boat") and
            "dontstarve/characters/woodie/beaver_chop_tree" or
            "dontstarve/wilson/use_axe_tree"
        )
    end

    ShakeAllCameras(CAMERASHAKE.FULL, 0.25, 0.03, 0.2, inst, 6)

    if inst.components.workable.workleft / inst.components.workable.maxwork == 0.2 then
        inst.SoundEmitter:PlaySound("waterlogged2/common/watertree_pillar/cracking")
    elseif inst.components.workable.workleft / inst.components.workable.maxwork == 0.12 then
        inst.SoundEmitter:PlaySound("waterlogged2/common/watertree_pillar/cracking")
    end

    if math.random() < 0.02 then
        DropNut(inst)
    end
end

local function chop_down_tree(inst, chopper)
    if inst.components.timer ~= nil and not inst.components.timer:TimerExists("FellingCountdown") then
        inst.components.timer:StartTimer("FellingCountdown", TUNING.OCEANTREE_ENRICHED_COOLDOWN_MIN + math.random() * TUNING.OCEANTREE_ENRICHED_COOLDOWN_VARIANCE)
    end
end

local function OnRemoveEntity(inst)
    for player in pairs(inst.players) do
        if player:IsValid() then
            if player.zskb_canopytrees then
                OnFar(inst, player)
            end
        end
    end

    inst._hascanopy:set(false)
end

local function OnSprout(inst)
    inst.AnimState:PlayAnimation("grow_normal_to_tall")
    inst.AnimState:PushAnimation("tall", true)
end

--定时器函数
local function OnTimerDone(inst, data)
    --刷新可砍伐
    if data.name == "FellingCountdown" then
        inst.components.workable:SetWorkLeft(TUNING.OCEANTREE_PILLAR_CHOPS)
        inst.components.timer:StopTimer("FellingCountdown")
    end
end

local function OnSave(inst, data)
end


local function OnLoad(inst, data)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1.5, 2)

    --部署额外间距
    inst:SetDeployExtraSpacing(1.5)

    --官方开发留言:这实际上应该在 c 端检查动画的最大尺寸或动画的当前尺寸而不是第 0 帧
    inst.entity:SetAABB(60, 20)

    inst:AddTag("shadecanopysmall")        --小型遮阳棚
    inst:AddTag("event_trigger")           --事件触发器
    inst:AddTag("ignorewalkableplatforms") --忽略可行走平台

    inst.MiniMapEntity:SetIcon("zskb_banyantree_pillar.tex")

    inst.AnimState:SetBank("zskb_banyantree_pillar")
    inst.AnimState:SetBuild("zskb_banyantree_pillar")
    inst.AnimState:PlayAnimation("tall", true)
    -- inst.AnimState:SetScale(0.8, 0.8, 0.8)


    --判断是否是专用服务器,此处表示如果不是专用服务器,自己是主机或者是客户端,执行if内代码
    if not TheNet:IsDedicated() then
        --距离淡出,实体距离玩家变化,实时渲染变化
        inst:AddComponent("distancefade")
        inst.components.distancefade:Setup(15, 25) --15格距离开始淡化,25格距离完全淡化

        --玩家在树的范围内,头顶显示树叶华盖的组件
        inst:AddComponent("canopyshadows")
        inst.components.canopyshadows.range = math.floor(TUNING.SHADE_CANOPY_RANGE_SMALL / 4)

        inst:ListenForEvent("hascanopydirty", function()
            if not inst._hascanopy:value() then
                inst:RemoveComponent("canopyshadows")
            end
        end)
    end

    inst._hascanopy = net_bool(inst.GUID, "oceantree_pillar._hascanopy", "hascanopydirty")
    inst._hascanopy:set(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.sproutfn = OnSprout

    -------------------
    inst.players = {}

    inst:AddComponent("playerprox")                                                             --玩家检测组件
    inst.components.playerprox:SetTargetMode(inst.components.playerprox.TargetModes.AllPlayers) --所有玩家均检测
    inst.components.playerprox:SetDist(MIN, MAX)                                                --靠近的距离MIN,远离的范围MAX
    inst.components.playerprox:SetOnPlayerFar(OnFar)                                            --远离的回调函数
    inst.components.playerprox:SetOnPlayerNear(OnNear)                                          --靠近的回调函数

    -------------------

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.CHOP)
    inst.components.workable:SetMaxWork(TUNING.OCEANTREE_PILLAR_CHOPS) --25
    inst.components.workable:SetWorkLeft(TUNING.OCEANTREE_PILLAR_CHOPS)
    inst.components.workable:SetOnWorkCallback(chop_tree)
    inst.components.workable:SetOnFinishCallback(chop_down_tree)

    --------------------
    inst:AddComponent("inspectable")

    --------------------
    inst:AddComponent("lightningblocker") --避雷
    inst.components.lightningblocker:SetBlockRange(TUNING.SHADE_CANOPY_RANGE_SMALL)

    --------------------
    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", OnTimerDone)

    --------------------
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnRemoveEntity = OnRemoveEntity

    return inst
end

return Prefab("zskb_banyantree_pillar", fn, assets, prefabs)
