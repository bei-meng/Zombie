local assets =
{
    Asset("ANIM", "anim/zskb_talisman_bound_bugnet.zip"),
}

local function onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_bugnet", inst.GUID, "swap_bugnet")
    else
        owner.AnimState:OverrideSymbol("swap_object", "zskb_talisman_bound_bugnet", "swap_bugnet")
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("zskb_talisman_bound_bugnet")
    inst.AnimState:SetBuild("zskb_talisman_bound_bugnet")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("tool")
    inst:AddTag("weapon")

    local swap_data = { sym_build = "swap_bugnet" }
    MakeInventoryFloatable(inst, "med", 0.09, { 0.9, 0.4, 0.9 }, true, -14.5, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.BUGNET_DAMAGE)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.NET)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("zskb_talisman_bound_bugnet", fn, assets)
