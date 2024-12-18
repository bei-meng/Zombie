local assets =
{
    Asset("ANIM", "anim/zskb_paper_doll.zip"),
    Asset("ANIM", "anim/zskb_paper_doll.zip"),
}

local function inspect_paper_doll(inst)
    if inst.status == "normal" then
        return "NORMAL"
    elseif inst.status == "hand" then
        return "HAND"
    elseif inst.status == "hand_angry" then
        return "HAND_ANGRY"
    else
        return "HAND"
    end
end

local function takefn(inst, doer)
    local prefabname = inst.prefab
    local product
    if prefabname == "zskb_paper_doll1" then
        product = "zskb_gourd"
    elseif prefabname == "zskb_paper_doll2" then
        product = "zskb_incense_burner"
    else
        return
    end
    if doer ~= nil then
        local inventory = doer.components.inventory or nil
        local pt = inst:GetPosition()
        local item = SpawnPrefab(product)
        if inventory and item.components.inventoryitem then
            inventory:GiveItem(item, nil, pt)
        else
            item.Transform:SetPosition(pt:Get())
        end
        inst.status = "normal"
        inst.animation = string.sub(prefabname, 6)
        inst.AnimState:PlayAnimation(inst.animation)
    end
end

local function onsave(inst, data)
    if inst.animation then
        data.animation = inst.animation
    end
    if inst.status then
        data.status = inst.status
    end
end

local function onload(inst, data)
    if data then
        if data.status then
            inst.status = data.status
            if data.status ~= "hand" and inst.components.zskb_touch ~= nil then
                inst:RemoveComponent("zskb_touch")
            end
        end
        if data.animation then
            inst.animation = data.animation
            inst.AnimState:PlayAnimation(inst.animation)
        end
    end
end

local make_paper_doll = function(prefabname, animation, name, status)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, 0.25)

        inst.AnimState:SetBank("zskb_paper_doll")
        inst.AnimState:SetBuild("zskb_paper_doll")
        inst:SetPrefabName(prefabname)

        inst.animation = animation
        inst.status = status

        inst:AddTag("structure")
        inst:AddTag("zskb_paper_doll")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.AnimState:PlayAnimation(inst.animation)

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_paper_doll

        if inst.status == "hand" then
            inst:AddComponent("zskb_touch")
            inst.components.zskb_touch.takefn = takefn
        end

        inst.OnSave = onsave
        inst.OnLoad = onload

        return inst
    end

    return Prefab(name, fn, assets)
end

return
    make_paper_doll("zskb_paper_doll1", "paper_doll1_hand", "zskb_paper_doll1", "hand"),
    make_paper_doll("zskb_paper_doll1", "paper_doll1", "zskb_paper_doll1_normal", "normal"),
    make_paper_doll("zskb_paper_doll1", "paper_doll1_hand", "zskb_paper_doll1_hand", "hand"),
    make_paper_doll("zskb_paper_doll1", "paper_doll1_hand_angry", "zskb_paper_doll1_hand_angry", "hand_angry"),

    make_paper_doll("zskb_paper_doll2", "paper_doll2_hand", "zskb_paper_doll2", "hand"),
    make_paper_doll("zskb_paper_doll2", "paper_doll2", "zskb_paper_doll2_normal", "normal"),
    make_paper_doll("zskb_paper_doll2", "paper_doll2_hand", "zskb_paper_doll2_hand", "hand"),
    make_paper_doll("zskb_paper_doll2", "paper_doll2_hand_angry", "zskb_paper_doll2_hand_angry", "hand_angry"),

    make_paper_doll("zskb_paper_doll3", "paper_doll3", "zskb_paper_doll3", "normal"),
    make_paper_doll("zskb_paper_doll4", "paper_doll4", "zskb_paper_doll4", "normal")
