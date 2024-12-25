local function AbleToAcceptDecor(inst, item, giver)
    if item:HasTag("zskb_burn") then
        return true
    else
        return false
    end
end

local function OnDecorGiven(inst, item, giver)
    if not item then return end

    -- inst.SoundEmitter:PlaySound("wintersfeast2019/winters_feast/table/food")

    if item.Physics then item.Physics:SetActive(false) end
    if item.Follower then item.Follower:FollowSymbol(inst.GUID, "swap_object") end
    if item.components.burnable then
        if item.components.propagator then
            item:RemoveComponent("propagator")
        end
        item.components.burnable:Ignite(true, inst, nil)
    end
end

local function OnDecorTaken(inst, item)
    -- Item might be nil if it's taken in a way that destroys it.
    if item then
        if item.Physics then item.Physics:SetActive(true) end
        if item.Follower then item.Follower:StopFollowing() end
    end
end

--拾起火盆
local function onpickup(inst, pickupguy)
    local item = inst.components.furnituredecortaker.decor_item
    if item ~= nil then
        if item.Physics then item.Physics:SetActive(true) end
        if item.Follower then item.Follower:StopFollowing() end
        pickupguy.components.inventory:GiveItem(item, nil, item:GetPosition())
    end
end

local function AddTable(results, prefab_name, data)
    local assets =
    {
        Asset("ANIM", "anim/" .. data.bank .. ".zip"),
        Asset("ANIM", "anim/" .. data.build .. ".zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(data.bank)
        inst.AnimState:SetBuild(data.build)
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("decortable")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        --
        local furnituredecortaker = inst:AddComponent("furnituredecortaker")
        furnituredecortaker.abletoaccepttest = AbleToAcceptDecor
        furnituredecortaker.ondecorgiven = OnDecorGiven
        furnituredecortaker.ondecortaken = OnDecorTaken

        --
        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem:SetOnPickupFn(onpickup)

        MakeHauntableWork(inst)

        return inst
    end

    table.insert(results, Prefab(prefab_name, fn, assets))
end

local result_tables = {}

AddTable(
    result_tables,
    "zskb_fire_basin",
    {
        bank = "zskb_fire_basin",
        build = "zskb_fire_basin",
    }
)

return unpack(result_tables)
