local assets =
{
    Asset("ANIM", "anim/zskb_coffin_nail.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("zskb_coffin_nail")
    inst.AnimState:SetBuild("zskb_coffin_nail")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("blowpipeammo")    --可以装填进犬牙吹箭:嚎弹炮
    inst:AddTag("reloaditem_ammo") --动作字符串,直接翻译:重新加载物品弹药

    inst.pickupsound = "rock"

    MakeInventoryFloatable(inst)

    --堆叠相关的，也不知道具体什么作用，就留着吧
    inst:AddTag("selfstacker")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    --不知道是什么，留着！
    inst:AddComponent("reloaditem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("selfstacker")

    MakeHauntableLaunchAndSmash(inst)

    return inst
end

local function OnHit(inst, attacker, target)
    if target and target.components.health and not target:HasTag("playerghost") then
        --添加 zskb_noheal 组件并设置持续时间
        if not target.components.zskb_noheal then
            target:AddComponent("zskb_noheal")
        end
        target.components.zskb_noheal:SetDuration(60) --持续 60 秒
        target.components.zskb_noheal:AttachToTarget(target)
    end
    inst:Remove()
end

local function onthrown(inst, data)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
end

local function ProjectileFn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeProjectilePhysics(inst)

    inst.AnimState:SetBank("zskb_coffin_nail")
    inst.AnimState:SetBuild("zskb_coffin_nail")
    inst.AnimState:PlayAnimation("dart")

    inst:AddTag("weapon")

    --射弹（来自射弹组件）添加到原始状态以进行优化。
    inst:AddTag("projectile")

    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(34)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(25)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetHitDist(1.5)
    inst.components.projectile:SetLaunchOffset(Vector3(2.5, 0.75, 2.5))
    inst.components.projectile:SetOnMissFn(inst.Remove)
    inst.components.projectile.range = 30
    inst.components.projectile.has_damage_set = true
    inst:ListenForEvent("onthrown", onthrown) --监听事件:动画射出的方向

    return inst
end

return Prefab("zskb_coffin_nail", fn, assets),
    Prefab("zskb_coffin_nail_proj", ProjectileFn, assets)
