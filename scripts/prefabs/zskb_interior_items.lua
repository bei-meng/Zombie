local assets =
{
    Asset("ANIM", "anim/wall.zip"),
    Asset("ANIM", "anim/wall_stone.zip"),
}

local function wall_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    -- for debug
    --inst.entity:AddAnimState()
    --inst.AnimState:SetBank("wall")
    --inst.AnimState:SetBuild("wall_stone")
    --inst.AnimState:PlayAnimation("half")

    -- also you can use Physics:SetTriangleMesh
    local phy = inst.entity:AddPhysics()
    phy:SetMass(0)
    phy:SetCollisionGroup(COLLISION.WORLD)
    phy:ClearCollisionMask()
    for k, v in pairs(COLLISION) do
        if k ~= "SANITY" then
            phy:CollidesWith(v)
        end
    end
    phy:SetCapsule(0.5, 8)
    phy:SetDontRemoveOnSleep(true)

    inst:AddTag("blocker")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")
    return inst
end

local function light_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()
    inst.entity:AddLight()

    inst.Light:SetFalloff(.7)
    inst.Light:SetIntensity(.8)
    inst.Light:SetRadius(10)
    inst.Light:SetColour(255 / 255, 180 / 255, 180 / 255)
    inst.Light:Enable(true)

    return inst
end

local function center_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("zskb_interior_center")
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")



    inst:DoTaskInTime(0, function()
        local interiormanager = TheWorld and TheWorld.components.zskb_interiormanager
        if interiormanager then
            interiormanager:RegisterRoom(inst)
        end
    end)

    inst:ListenForEvent("onremove", function()
        local interiormanager = TheWorld and TheWorld.components.zskb_interiormanager
        if interiormanager then
            interiormanager:UnregisterRoom(inst)
        end
    end)


    return inst
end

return Prefab("zskb_interior_wall_back", wall_fn), --,  assets),
    Prefab("zskb_interior_light", light_fn),
    Prefab("zskb_interior_center", center_fn)
