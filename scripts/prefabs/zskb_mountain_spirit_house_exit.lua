local assets =
{
    Asset("ANIM", "anim/zskb_mountain_spirit_house_exit.zip"),
}


local function exit_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.AnimState:SetBank("zskb_mountain_spirit_house_exit")
    inst.AnimState:SetBuild("zskb_mountain_spirit_house_exit")
    inst.AnimState:PlayAnimation("idle")
    inst.Transform:SetScale(1.75, 1.75, 1.75)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)

    inst:AddTag("zskb_mountain_spirit_house_exit")
    inst:AddTag("nonpackable")
    inst:AddTag("zskb_enterable")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("teleporter")
    inst.components.teleporter.offset = 0
    inst.components.teleporter.travelcameratime = 0.2
    inst.components.teleporter.travelarrivetime = 0.1

    inst:AddComponent("hauntable") -- for playerghost trigger the teleport
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        if haunter and haunter:HasTag("player") and inst.components.teleporter then
            inst.components.teleporter:Activate(haunter)
        end
    end)
    return inst
end

return Prefab("zskb_mountain_spirit_house_exit", exit_fn, assets)
