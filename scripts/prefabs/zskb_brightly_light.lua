local assets = {
    Asset("ANIM", "anim/zskb_brightly_light.zip"),
    Asset("ANIM", "anim/swap_zskb_brightly_light.zip"),
    Asset("ANIM", "anim/swap_zskb_brightly_light_off.zip"),
}

local function onremovelight(light)
    light._lantern._light = nil
end

local function fuelupdate(inst)
    if inst._light ~= nil then
        local fuelpercent = inst.components.fueled:GetPercent()
        inst._light.Light:SetIntensity(Lerp(.4, .6, fuelpercent))
        inst._light.Light:SetRadius(Lerp(3, 5, fuelpercent))
        inst._light.Light:SetFalloff(.9)
    end
end

local function stoptrackingowner(inst)
    if inst._owner ~= nil then
        inst:RemoveEventCallback("equip", inst._onownerequip, inst._owner)
        inst._owner = nil
    end
end

local function starttrackingowner(inst, owner)
    if owner ~= inst._owner then
        stoptrackingowner(inst)
        if owner ~= nil and owner.components.inventory ~= nil then
            inst._owner = owner
            inst:ListenForEvent("equip", inst._onownerequip, owner)
        end
    end
end

local function turnon(inst)
    if not inst.components.fueled:IsEmpty() then
        inst.components.fueled:StartConsuming()

        local owner = inst.components.inventoryitem.owner

        if inst._light == nil then
            inst._light = SpawnPrefab("zskb_brightly_light_light")
            inst._light._lantern = inst
            inst:ListenForEvent("onremove", onremovelight, inst._light)
            fuelupdate(inst)
        end

        inst.AnimState:PlayAnimation("on")
        inst.components.machine.ison = true
        inst._light.entity:SetParent((owner or inst).entity)
        inst.components.inventoryitem:ChangeImageName("zskb_brightly_light")

        inst._lightstatus:set(true)

        if owner ~= nil then
            owner:AddTag("ghostlyfriend")
        end
    end
end

local function turnoff(inst)
    stoptrackingowner(inst)
    local owner = inst.components.inventoryitem.owner

    inst.components.fueled:StopConsuming()

    if inst._light ~= nil then
        inst._light:Remove()
    end

    inst.AnimState:PlayAnimation("off")

    inst.components.machine.ison = false
    inst.components.inventoryitem:ChangeImageName("zskb_brightly_light_off")

    inst._lightstatus:set(false)

    if owner ~= nil then
        owner:RemoveTag("ghostlyfriend")
    end
end

local function OnRemove(inst)
    if inst._light ~= nil then
        inst._light:Remove()
    end
end

local function ondropped(inst)
    turnoff(inst)
    turnon(inst)
end

local function onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_zskb_brightly_light", inst.GUID, "swap_zskb_brightly_light")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_zskb_brightly_light", "swap_zskb_brightly_light")
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if not inst.components.fueled:IsEmpty() then
        turnon(inst)
    end
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    if inst.components.machine.ison then
        starttrackingowner(inst, owner)
    end
end

local function onequiptomodel(inst, owner, from_ground)
    if inst.components.machine.ison then
        starttrackingowner(inst, owner)
    end

    turnoff(inst)
end

local function nofuel(inst)
    if inst.components.equippable:IsEquipped() and inst.components.inventoryitem.owner ~= nil then
        local data =
        {
            prefab = inst.prefab,
            equipslot = inst.components.equippable.equipslot,
        }
        inst.components.inventoryitem.owner:PushEvent("torchranout", data)
    end
    turnoff(inst)
end

local function accepttest(inst, item, giver)
    return table.contains({ "cutgrass", "twigs" }, item.prefab) or item:HasTag("preparedfood")
end

local function onacceptitem(inst, giver, item)
    if inst.components.fueled ~= nil then
        local owner = inst.components.inventoryitem.owner
        inst.components.fueled:DoDelta(TUNING.LANTERN_LIGHTTIME, owner)
        if inst.components.equippable:IsEquipped() then
            turnon(inst)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("zskb_brightly_light")
    inst.AnimState:SetBuild("zskb_brightly_light")
    inst.AnimState:PlayAnimation("off")

    MakeInventoryFloatable(inst)

    inst:AddTag("zskb_brightly_light")

    inst.entity:SetPristine()

    inst._lightstatus = net_bool(inst.GUID, "zskb.brightly_light")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/zskb_inventoryimages.xml"
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(turnoff)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
    inst.components.machine.cooldowntime = 0

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.MAGIC
    inst.components.fueled:InitializeFuelLevel(TUNING.LANTERN_LIGHTTIME)
    inst.components.fueled:SetDepletedFn(nofuel)
    inst.components.fueled:SetUpdateFn(fuelupdate)
    inst.components.fueled.accepting = false

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(accepttest)
    inst.components.trader.onaccept = onacceptitem
    inst.components.trader.acceptnontradable = true

    inst._light = nil

    MakeHauntableLaunch(inst)

    inst.OnRemoveEntity = OnRemove
    inst._onownerequip = function(owner, data)
        if data.item ~= inst and
            (data.eslot == EQUIPSLOTS.HANDS or
                (data.eslot == EQUIPSLOTS.BODY and data.item:HasTag("heavy"))
            ) then
            turnoff(inst)
        end
    end

    return inst
end

local function lightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetColour(227 / 255, 68 / 255, 12 / 255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("zskb_brightly_light", fn, assets),
    Prefab("zskb_brightly_light_light", lightfn)
