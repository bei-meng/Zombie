local zskb_copper_coin_umbrella_assets = {
    Asset("ANIM", "anim/zskb_copper_coin_umbrella.zip"),
    Asset("ANIM", "anim/swap_zskb_copper_coin_umbrella_close.zip"),
    Asset("ANIM", "anim/swap_zskb_copper_coin_umbrella_open.zip"),
}

local zskb_rune_paper_umbrella_assets = {
    Asset("ANIM", "anim/zskb_rune_paper_umbrella.zip"),
    Asset("ANIM", "anim/swap_zskb_rune_paper_umbrella.zip"),
}

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end

    if inst.add_zombie_gas_task ~= nil then
        inst.add_zombie_gas_task:Cancel()
        inst.add_zombie_gas_task = nil
    end
end

------------------------------------------------------------------------------

local WAVE_FX_LEN = 0.5
local function WaveFxOnUpdate(inst, dt)
    inst.t = inst.t + dt

    if inst.t < WAVE_FX_LEN then
        local k = 1 - inst.t / WAVE_FX_LEN
        k = k * k
        inst.AnimState:SetMultColour(1, 1, 1, k)
        k = (2 - 1.7 * k) * (inst.scalemult or 1)
        inst.AnimState:SetScale(k, k)
    else
        inst:Remove()
    end
end

local function CreateWaveFX()
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("umbrella_voidcloth")
    inst.AnimState:SetBuild("umbrella_voidcloth")
    inst.AnimState:PlayAnimation("barrier_rim")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(WaveFxOnUpdate)
    inst.t = 0
    inst.scalemult = .75
    WaveFxOnUpdate(inst, 0)

    return inst
end

local function CreateDomeFX()
    local inst = CreateEntity()

    inst:AddTag("FX")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBank("umbrella_voidcloth")
    inst.AnimState:SetBuild("umbrella_voidcloth")
    inst.AnimState:PlayAnimation("barrier_dome")
    inst.AnimState:SetFinalOffset(7)

    inst:AddComponent("updatelooper")
    inst.components.updatelooper:AddOnUpdateFn(WaveFxOnUpdate)
    inst.t = 0
    WaveFxOnUpdate(inst, 0)

    return inst
end

local function CLIENT_TriggerFX(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    CreateWaveFX().Transform:SetPosition(x, 0, z)
    local fx = CreateDomeFX()
    fx.Transform:SetPosition(x, 0, z)
    fx.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_activate")
end

local function SERVER_TriggerFX(inst)
    inst.triggerfx:push()
    if not TheNet:IsDedicated() then
        CLIENT_TriggerFX(inst)
    end
end

local function SetShadow(inst, enable)
    inst.DynamicShadow:Enable(enable)
end

local function onnear(inst, player)
    if player ~= nil and player:HasTag("zskb_zombie") then
        inst.players[player] = true
        player.components.zskb_zombie.under_copper_coin_umbrella = true
    end
end

local function onfar(inst, player)
    if player ~= nil and player:HasTag("zskb_zombie") then
        inst.players[player] = nil
        player.components.zskb_zombie.under_copper_coin_umbrella = false
    end
end

local function OnRemoveEntity(inst)
    if inst.players ~= nil then
        for player in pairs(inst.players) do
            if player:IsValid() then
                onfar(inst, player)
            end
        end
    end
end

local function turnon(inst)
    -- if not inst.components.fueled:IsEmpty() then
    -- inst.components.inventoryitem.canbepickedup = false
    -- inst.components.fueled.rate = TUNING.VOIDCLOTH_UMBRELLA_DOME_RATE
    -- inst.components.fueled:StartConsuming()
    inst.components.raindome:Enable()

    if inst.components.sanityaura == nil then
        inst:AddComponent("sanityaura")
        inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL
        inst.components.sanityaura.max_distsq = TUNING.VOIDCLOTH_UMBRELLA_DOME_RADIUS * TUNING.VOIDCLOTH_UMBRELLA_DOME_RADIUS
    end

    if inst.shadowtask ~= nil then
        inst.shadowtask:Cancel()
        inst.shadowtask = nil
    end

    if inst:IsAsleep() or POPULATING then
        inst.DynamicShadow:Enable(true)
        inst.AnimState:PlayAnimation("open")
    else
        inst.DynamicShadow:Enable(false)
        inst.shadowtask = inst:DoTaskInTime(7 * FRAMES, SetShadow, true)
        inst.AnimState:PlayAnimation("open")
        SERVER_TriggerFX(inst)
    end

    inst.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_lp", "loop")
    -- end

    -- local pt = inst:GetPosition()
    -- local ents = TheSim:FindEntities(x, y, z, radius, musttags, canttags, mustoneoftags)
    -- local players = TheSim:FindEntities(pt.x,pt.y,pt.z, TUNING.VOIDCLOTH_UMBRELLA_DOME_RADIUS, {"zskb_zombie"})
    -- if players then
    --     for i, v in pairs(players) do
    --         v.components.zskb_zombie.under_copper_coin_umbrella = true
    --     end
    -- end

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetTargetMode(inst.components.playerprox.TargetModes.AllPlayers)
    inst.components.playerprox:SetDist(TUNING.VOIDCLOTH_UMBRELLA_DOME_RADIUS, TUNING.VOIDCLOTH_UMBRELLA_DOME_RADIUS)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)
end

local function turnoff(inst)
    inst.components.inventoryitem.canbepickedup = true
    -- inst.components.fueled:StopConsuming()
    -- inst.components.fueled.rate = 1
    inst.components.raindome:Disable()

    if inst.components.sanityaura ~= nil then
        inst:RemoveComponent("sanityaura")
    end

    if inst.shadowtask ~= nil then
        inst.shadowtask:Cancel()
        inst.shadowtask = nil
    end

    local shouldsfx
    -- if inst.components.fueled:IsEmpty() then
    -- 	inst.DynamicShadow:Enable(false)
    -- 	inst.AnimState:PlayAnimation("broken")
    -- 	shouldsfx = true
    -- else
    if inst.components.inventoryitem:IsHeld() or inst:IsAsleep() then
        inst.DynamicShadow:Enable(false)
        inst.AnimState:PlayAnimation("close")
    else
        inst.DynamicShadow:Enable(true)
        inst.shadowtask = inst:DoTaskInTime(9 * FRAMES, SetShadow, false)
        inst.AnimState:PlayAnimation("close")
        shouldsfx = true
    end

    if inst.SoundEmitter:PlayingSound("loop") then
        inst.SoundEmitter:KillSound("loop")
        if shouldsfx then
            inst.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_close")
        end
    end

    -- local pt = inst:GetPosition()
    -- local players = TheSim:FindEntities(pt.x,pt.y,pt.z, TUNING.VOIDCLOTH_UMBRELLA_DOME_RADIUS, {"zskb_zombie"})
    -- if players then
    --     for i, v in pairs(players) do
    --         v.components.zskb_zombie.under_copper_coin_umbrella = false
    --     end
    -- end

    if inst.components.playerprox then
        inst:OnRemoveEntity()
        inst:RemoveComponent("playerprox")
    end
end
------------------------------------------------------------------------------

local function common(name)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBuild(name)
    inst.AnimState:SetBank(name)
    inst.AnimState:PlayAnimation("idle")
    inst.Transform:SetScale(1.25, 1.25, 1.25)

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)

    inst:AddTag("nopunch")
    inst:AddTag("umbrella")
    inst:AddTag("zskb_keep_zombie_gas")
    inst:AddTag("zskb_zombie_umbrella")
    inst:AddTag("waterproofer")
    inst:AddTag("acidrainimmune")
    inst:AddTag(name)

    inst.entity:SetPristine()
    --------------------------------------------------------------------------
    if not TheWorld.ismastersim then
        return inst
    end
    --------------------------------------------------------------------------
    inst:AddComponent("inspectable")
    --inst:AddComponent("trader") -- what's this for ?

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/zskb_inventoryimages.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_ABSOLUTE)

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
    inst.components.insulator:SetSummer()

    MakeHauntableLaunch(inst)

    return inst
end

local function copper_coin_onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    inst:change_copper_coin_inventoryimage(owner)

    if inst.add_zombie_gas_task ~= nil then
        inst.add_zombie_gas_task:Cancel()
        inst.add_zombie_gas_task = nil
    end
    inst.add_zombie_gas_task = inst:DoPeriodicTask(1, function(inst)
        if owner.components.zskb_zombie_gas then
            owner.components.zskb_zombie_gas:DoDelta(TUNING.ZSKB.ONE_DAY_DELTA * 2 / TUNING.TOTAL_DAY_TIME, nil, false)
        end
    end)
end

local function change_copper_coin_inventoryimage(inst, owner)
    if inst._status == "open" then
        if owner then
            owner.AnimState:OverrideSymbol("swap_object", "swap_zskb_copper_coin_umbrella_open", "swap_zskb_copper_coin_umbrella_open")
        end
        inst:RemoveTag("zskb_copper_coin_umbrella_close")
        inst:AddTag("zskb_copper_coin_umbrella_open")
        inst.components.inventoryitem:ChangeImageName("zskb_copper_coin_umbrella_open")

        if inst.components.weapon then
            inst:RemoveComponent("weapon")
        end
        if inst.components.planardamage then
            inst:RemoveComponent("planardamage")
        end
    elseif inst._status == "close" then
        if owner then
            owner.AnimState:OverrideSymbol("swap_object", "swap_zskb_copper_coin_umbrella_close", "swap_zskb_copper_coin_umbrella_close")
        end
        inst:RemoveTag("zskb_copper_coin_umbrella_open")
        inst:AddTag("zskb_copper_coin_umbrella_close")
        inst.components.inventoryitem:ChangeImageName("zskb_copper_coin_umbrella_close")

        if not inst.components.weapon then
            inst:AddComponent("weapon")
            inst.components.weapon:SetDamage(55)
        end
        if not inst.components.planardamage then
            local planardamage = inst:AddComponent("planardamage")
            planardamage:SetBaseDamage(15)
        end
    end
end

local function copper_coin_onsave(inst, data)
    data._status = inst._status or "open"
end
local function copper_coin_onload(inst, data)
    if data and data._status ~= nil then
        inst._status = data._status or "open"

        change_copper_coin_inventoryimage(inst)
    end
end
local function cropper_coin_onentitysleep(inst)
    if inst.components.machine and inst.components.machine:IsOn() then
        inst.components.machine:TurnOff()
    end
end

local function OnValidPosition(inst)
    local map = TheWorld and TheWorld.Map or nil
    local x, y, z = inst:GetPosition():Get()
    return map and (map:IsVisualGroundAtPoint(x, y, z) or map:GetPlatformAtPoint(x, z) ~= nil)
end

local function InvalidPos_QuickFix(inst)
    if not OnValidPosition(inst) and inst.components.machine and inst.components.machine.ison then
        inst.components.machine:TurnOff()
    end
end

local function cropper_coin_ondropped(inst)
    if inst._status == "open" and inst.components.machine and not inst.components.machine:IsOn() then
        inst.components.machine:TurnOn()
    end
end

local function cropper_coin_onputininventory(inst)
    if inst.components.machine and inst.components.machine:IsOn() then
        inst.components.machine:TurnOff()
    end
end

local function copper_coin()
    local inst = common("zskb_copper_coin_umbrella")
    inst.AnimState:PlayAnimation("close")
    inst.triggerfx = net_event(inst.GUID, "zskb_copper_coin_umbrella.triggerfx")

    --Must be added client-side, but configured server-side
    inst:AddComponent("raindome")

    if not TheWorld.ismastersim then
        --delayed because we don't want any old events
        inst:DoTaskInTime(0, inst.ListenForEvent, "zskb_copper_coin_umbrella.triggerfx", CLIENT_TriggerFX)
        return inst
    end

    inst.players = {}

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(55)

    local planardamage = inst:AddComponent("planardamage")
    planardamage:SetBaseDamage(15)

    --------------------------------------------------------
    inst:AddComponent("machine")
    -- inst.components.machine:SetGroundOnlyMachine(true)
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
    inst.components.machine.cooldowntime = 0.5
    inst.components.inventoryitem:SetOnDroppedFn(cropper_coin_ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(cropper_coin_onputininventory)
    inst:DoTaskInTime(0, function(inst)
        if not inst:IsInLimbo() then
            cropper_coin_ondropped(inst)
        end
    end)
    ---------------------------------------------------

    inst.components.equippable:SetOnEquip(copper_coin_onequip)
    inst.components.inventoryitem.imagename = "zskb_copper_coin_umbrella_close"

    inst._status = "open"

    inst.change_copper_coin_inventoryimage = change_copper_coin_inventoryimage
    inst.OnSave = copper_coin_onsave
    inst.OnLoad = copper_coin_onload
    inst.OnRemoveEntity = OnRemoveEntity
    --    inst.OnEntitySleep = cropper_coin_onentitysleep -- it no longer cost fuel now

    return inst
end

local function rune_paper_onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()

    owner.AnimState:OverrideSymbol("swap_object", "swap_zskb_rune_paper_umbrella", "swap_zskb_rune_paper_umbrella")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if inst.components.fueled ~= nil then
        inst.components.fueled:StartConsuming()
    end
end

local function rune_paper()
    local inst = common("zskb_rune_paper_umbrella")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.inventoryitem.imagename = "zskb_rune_paper_umbrella"

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:SetDepletedFn(inst.Remove)
    inst.components.fueled:InitializeFuelLevel(TUNING.UMBRELLA_PERISHTIME)

    inst.components.equippable:SetOnEquip(rune_paper_onequip)

    return inst
end

return Prefab("zskb_copper_coin_umbrella", copper_coin, zskb_copper_coin_umbrella_assets),
    Prefab("zskb_rune_paper_umbrella", rune_paper, zskb_rune_paper_umbrella_assets)
