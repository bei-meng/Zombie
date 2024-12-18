local assets =
{
    Asset("ANIM", "anim/zskb_ghostfire.zip"),
}

local function Task(inst)
    if not TheWorld.state.isnight then
        inst.AnimState:PlayAnimation("post")
        inst:ListenForEvent("animover", function()
            if inst:IsValid() then
                inst:Remove()
            end
        end)
    else
        local x, y, z = inst.Transform:GetWorldPosition()
        local players = TheSim:FindEntities(x, y, z, 4, { "player" })
        for _, player in ipairs(players) do
            if player.components.zskb_zombie_threefire ~= nil and player.components.zskb_zombie_threefire.current > 2 then
                inst.AnimState:PlayAnimation("post")
                inst:ListenForEvent("animover", function()
                    if inst:IsValid() then
                        inst:Remove()
                    end
                end)
                return
            end
        end
    end
end

local function ondropped(inst)
    inst.components.workable:SetWorkLeft(1)
    inst.Light:Enable(true)
    if inst.task == nil then
        inst.task = inst:DoPeriodicTask(1, Task)
    end
end

local function onpickup(inst)
    inst.Light:Enable(false)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
    end
end

local function onworked(inst, worker)
    --检查工作工具是否是专属捕虫网
    if worker.components.inventory ~= nil and worker.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) ~= nil then
        local tool = worker.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if tool.prefab == "zskb_talisman_bound_bugnet" then
            worker.components.inventory:GiveItem(inst, nil, inst:GetPosition())
        else
            if worker.components.talker ~= nil then
                worker.components.talker:Say(STRINGS.ZSKB.CATCHING)
            end
            inst.components.workable:SetWorkLeft(1)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(0.5)
    inst.Light:SetRadius(1)
    inst.Light:SetColour(0 / 255, 197 / 255, 205 / 255)
    inst.Light:Enable(true)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.AnimState:SetBank("zskb_ghostfire")
    inst.AnimState:SetBuild("zskb_ghostfire")
    inst.AnimState:PlayAnimation("pre")
    inst.AnimState:PushAnimation("idle_loop", true)

    inst:AddTag("NOBLOCK") --无障碍
    inst:AddTag("zskb_ghostfire")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.NET)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onworked)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst.components.stackable.forcedropsingle = true --快捷丢弃只丢一个

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPickupFn(onpickup)
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true

    inst.task = inst:DoPeriodicTask(1, Task)

    return inst
end

return Prefab("zskb_ghostfire", fn, assets)
