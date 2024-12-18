local function MakeBuff(name, data)
    local function OnAttached(inst, target, followsymbol, followoffset, _data)
        inst.entity:SetParent(target.entity)
        inst.Transform:SetPosition(0, 0, 0) -- in case of loading
        if data.ontick then
            inst.task = inst:DoPeriodicTask(_data.frequency, data.ontick, nil, target, _data)
        end
        inst:ListenForEvent("death", function()
            if not inst.zskb_dontremoveondeath then
                inst.components.debuff:Stop()
            end
        end, target)
        if data.onattachedfn then data.onattachedfn(inst, target, followsymbol, followoffset, _data) end
    end

    local function OnTimerDone(inst, d)
        if d.name == "buffover" then
            inst.components.debuff:Stop()
        end
    end

    local function OnExtended(inst, target, followsymbol, followoffset, _data)
        inst.components.timer:StopTimer("buffover")
        inst.components.timer:StartTimer("buffover", _data.duration or 1)
        if data.ontick then
            inst.task:Cancel()
            inst.task = inst:DoPeriodicTask(_data.frequency, data.ontick, nil, target, _data)
        end
        if data.onextendedfn ~= nil then
            data.onextendedfn(inst, target)
        end
    end

    local function OnDetached(inst, target)
        if data.ondetachedfn then data.ondetachedfn(inst, target) end
        inst:Remove()
    end

    local function fn()
        local inst = CreateEntity()

        if not TheWorld.ismastersim then
            -- Not meant for client!
            inst:DoTaskInTime(0, inst.Remove)

            return inst
        end
        inst.entity:AddTransform()

        --[[Non-networked entity]]
        -- inst.entity:SetCanSleep(false)
        inst.entity:Hide()
        inst.persists = false

        inst:AddTag("CLASSIFIED")

        inst:AddComponent("debuff")
        inst.components.debuff:SetAttachedFn(OnAttached)
        inst.components.debuff:SetDetachedFn(OnDetached)
        inst.components.debuff:SetExtendedFn(OnExtended)
        inst.components.debuff.keepondespawn = true

        inst:AddComponent("timer")
        -- 在添加buff处开启
        inst.components.timer:StartTimer("buffover", data.duration or 10)
        inst:ListenForEvent("timerdone", OnTimerDone)

        return inst
    end

    return Prefab(name, fn)
end

local prefs = {}
for k, v in pairs(require("zskb_buff_defs")) do
    table.insert(prefs, MakeBuff(k, v))
end

return unpack(prefs)
