local function DropRunePaper(inst, data)
    local paper = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.RUNEPAPER)
    if paper and paper.prefab == "zskb_fireproof_runepaper" then
        inst.components.inventory:Unequip(EQUIPSLOTS.RUNEPAPER, true)
        inst.components.inventory:DropItem(paper)
        if paper.Physics ~= nil then
            local x, y, z = paper.Transform:GetWorldPosition()
            paper.Physics:Teleport(x, .3, z)
            local angle = (math.random() * 20 - 10) * DEGREES
            if data.target ~= nil and data.target:IsValid() then
                local x1, y1, z1 = inst.Transform:GetWorldPosition()
                x, y, z = data.target.Transform:GetWorldPosition()
                angle = angle + (x1 == x and z1 == z and math.random() * TWOPI or math.atan2(z1 - z, x1 - x))
            else
                angle = angle + math.random() * TWOPI
            end
            local speed = 3 + math.random() * 2
            paper.Physics:SetVel(math.cos(angle) * speed, 10, math.sin(angle) * speed)
        end
    end
end

local function MakeRunePaper(name)
    local assets =
    {
        Asset("ANIM", "anim/zskb_" .. name .. "_runepaper.zip"),
    }

    local function onequip(inst, owner)
        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
        end

        if name == "fireproof" then
            if owner.components.locomotor then
                owner.components.locomotor:SetExternalSpeedMultiplier(owner, "zskb_runepaper", 1 - 0.1)
            end
            if inst.drop_onattackother then
                inst:ListenForEvent("onattackother", DropRunePaper, owner)
            end
        elseif name == "yin" then
            --[[
                zskb_buff_return_life_pill
                zskb_buff_waterproofness
                zskb_buff_invisibility
                zskb_buff_workmultiplier
            ]]
            owner.components.debuffable:PauseDebuff("zskb_buff_return_life_pill")
            owner.components.debuffable:PauseDebuff("zskb_buff_waterproofness")
            owner.components.debuffable:PauseDebuff("zskb_buff_invisibility")
            owner.components.debuffable:PauseDebuff("zskb_buff_workmultiplier")

            owner.components.workmultiplier:AddMultiplier(ACTIONS.CHOP, 0.9, owner)
            owner.components.workmultiplier:AddMultiplier(ACTIONS.MINE, 0.9, owner)
            owner.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, 0.9, owner)

            owner.components.efficientuser:AddMultiplier(ACTIONS.CHOP, 0.9, owner)
            owner.components.efficientuser:AddMultiplier(ACTIONS.MINE, 0.9, owner)
            owner.components.efficientuser:AddMultiplier(ACTIONS.HAMMER, 0.9, owner)

            local exterdmgtakenmultipliers = owner.components.combat and owner.components.combat.externaldamagetakenmultipliers or nil
            if exterdmgtakenmultipliers ~= nil and exterdmgtakenmultipliers.SetModifier then
                exterdmgtakenmultipliers:SetModifier(inst, 1.1)
            end
        end
    end

    local function onunequip(inst, owner)
        if name == "fireproof" then
            if inst.drop_onattackother then
                inst:RemoveEventCallback("onattackother", DropRunePaper, owner)
            end
        elseif name == "yin" then
            if owner ~= nil then
                owner.components.debuffable:ResumeDebuff("zskb_buff_return_life_pill")
                owner.components.debuffable:ResumeDebuff("zskb_buff_waterproofness")
                owner.components.debuffable:ResumeDebuff("zskb_buff_invisibility")
                owner.components.debuffable:ResumeDebuff("zskb_buff_workmultiplier")

                owner.components.workmultiplier:RemoveMultiplier(ACTIONS.CHOP, owner)
                owner.components.workmultiplier:RemoveMultiplier(ACTIONS.MINE, owner)
                owner.components.workmultiplier:RemoveMultiplier(ACTIONS.HAMMER, owner)

                owner.components.efficientuser:RemoveMultiplier(ACTIONS.CHOP, owner)
                owner.components.efficientuser:RemoveMultiplier(ACTIONS.MINE, owner)
                owner.components.efficientuser:RemoveMultiplier(ACTIONS.HAMMER, owner)
            end

            local exterdmgtakenmultipliers = owner.components.combat and owner.components.combat.externaldamagetakenmultipliers or nil
            if exterdmgtakenmultipliers ~= nil and exterdmgtakenmultipliers.RemoveModifier then
                exterdmgtakenmultipliers:RemoveModifier(inst)
            end
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("zskb_" .. name .. "_runepaper")
        inst.AnimState:SetBuild("zskb_" .. name .. "_runepaper")
        inst.AnimState:PlayAnimation("idle")

        -- inst:AddTag("zskb_runepaper")
        inst:AddTag("zskb_" .. name .. "_runepaper")

        MakeInventoryFloatable(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.MAGIC
        inst.components.fueled:InitializeFuelLevel(TUNING.TOTAL_DAY_TIME * 3)
        inst.components.fueled:SetDepletedFn(inst.Remove)
        inst.components.fueled.accepting = false

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = "images/zskb_inventoryimages.xml"

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.RUNEPAPER
        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)
        inst.components.equippable.restrictedtag = "zskb_zombie"

        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab("zskb_" .. name .. "_runepaper", fn, assets)
end

return MakeRunePaper("fireproof"),
    MakeRunePaper("yin")
