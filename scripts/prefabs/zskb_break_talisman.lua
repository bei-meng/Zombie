local assets =
{
    Asset("ANIM", "anim/zskb_break_talisman.zip"),
}
--[[
点燃后会使附近生物接下来收到的伤害提高50%
]]--
local RANGE = 20
local function OnBurnt(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    -- 所有能攻击，有血量，"locomotor"，不能移动的也当做生物
    -- 这里随便给个范围，半径5个地皮
    local ents = TheSim:FindEntities(x, 0, z, RANGE, {"_combat","_health",}, {"player","INLIMBO", "notarget", "noattack", "invisible", "playerghost"})
    for i, v in ipairs(ents) do
        if v and not v.components.health:IsDead() and not v.zskb_break_talisman_buff then
            -- 增伤1.5倍
            local old_fn = v.components.health.DoDelta
            v.components.health.DoDelta=function (self,amount,...)
                if amount<0 then
                    amount = amount*1.5
                end
                return old_fn(self,amount,...)
            end
            -- 不能重复施加效果
            v.zskb_break_talisman_buff = true
        end
    end
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("zskb_break_talisman")
    inst.AnimState:SetBuild("zskb_break_talisman")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "med", nil, 0.75)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("inventoryitem")

    --添加监听点燃完成的逻辑
    inst:ListenForEvent("onburnt", OnBurnt)

    return inst
end

return Prefab("zskb_break_talisman", fn, assets)
