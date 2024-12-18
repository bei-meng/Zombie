local ASSETS_CONTAINER =
{
    Asset("ANIM", "anim/zskb_gourd.zip"),
}

local function OnOpen(inst)
    inst.SoundEmitter:PlaySound("maxwell_rework/magician_chest/open")
end

local function OnClose(inst)
    inst.SoundEmitter:PlaySound("maxwell_rework/magician_chest/close")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("zskb_gourd")
    inst.AnimState:SetBuild("zskb_gourd")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("irreplaceable")

    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = function(inst)
            inst.replica.container:WidgetSetup("zskb_gourd") --客户端容器设置
        end
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("zskb_gourd")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose

    inst:AddComponent("inventoryitem")

    inst:AddComponent("zskb_encase")

    MakeHauntableLaunchAndDropFirstItem(inst)

    return inst
end

return Prefab("zskb_gourd", fn, ASSETS_CONTAINER)
