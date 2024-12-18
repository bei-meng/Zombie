----------------------------------------------------------------
--[[ STATEGRAPH EVENT ]]
----------------------------------------------------------------

-- Happens when the Mountain Spirit uses his music attack
AddStategraphEvent("wilson",
    EventHandler("zskb_sanity_stun",
        function(inst, data)
            inst.zskb_sanity_stunned = true
            inst.sg:GoToState("zskb_mindcontrolled", data)

            if inst.components.sanity ~= nil then
                inst.components.sanity:DoDelta(-TUNING.SANITY_LARGE)
            end
            if inst.components.hunger ~= nil then
                inst.components.hunger:DoDelta(-TUNING.SANITY_LARGE / 2) -- should tuning ?
            end
        end))


----------------------------------------------------------------
--[[ STATEGRAPH ]]
----------------------------------------------------------------
local function ToggleOffPhysics(inst)
    inst.sg.statemem.isphysicstoggle = true
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
end

local function ToggleOnPhysics(inst)
    inst.sg.statemem.isphysicstoggle = nil
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
end
local function ClearStatusAilments(inst)
    if inst.components.freezable ~= nil and inst.components.freezable:IsFrozen() then
        inst.components.freezable:Unfreeze()
    end
    if inst.components.pinnable ~= nil and inst.components.pinnable:IsStuck() then
        inst.components.pinnable:Unstick()
    end
end

local function ForceStopHeavyLifting(inst)
    if inst.components.inventory:IsHeavyLifting() then
        inst.components.inventory:DropItem(
            inst.components.inventory:Unequip(EQUIPSLOTS.BODY),
            true,
            true
        )
    end
end

AddStategraphState("wilson",
    State {
        name = "zskb_mindcontrolled",
        tags = { "busy", "pausepredict", "nomorph", "nodangle" },

        onenter = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:RemotePausePrediction()
            end
            inst.components.inventory:Hide()
            inst:PushEvent("ms_closepopups")

            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst:ClearBufferedAction()

            if inst.components.rider:IsRiding() then
                inst.sg:AddStateTag("dismounting")
                inst.AnimState:PlayAnimation("fall_off")
                inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
            else
                inst.AnimState:PlayAnimation("mindcontrol_pre")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg:HasStateTag("dismounting") then
                        inst.sg:RemoveStateTag("dismounting")
                        inst.components.rider:ActualDismount()
                        inst.AnimState:PlayAnimation("mindcontrol_pre")
                    else
                        inst.sg.statemem.mindcontrolled = true
                        inst.sg:GoToState("zskb_mindcontrolled_loop")
                    end
                end
            end),
        },

        onexit = function(inst)
            if inst.sg:HasStateTag("dismounting") then
                --interrupted
                inst.components.rider:ActualDismount()
            end
            if not inst.sg.statemem.mindcontrolled then
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
                inst.components.inventory:Show()
            end
        end,
    })

AddStategraphState("wilson",
    State {
        name = "zskb_mindcontrolled_loop",
        tags = { "busy", "pausepredict", "nomorph", "nodangle" },

        onenter = function(inst)
            if not inst.AnimState:IsCurrentAnimation("mindcontrol_loop") then
                inst.AnimState:PlayAnimation("mindcontrol_loop", true)
            end
            inst.sg:SetTimeout(3.5)
        end,

        -- events =
        -- {
        --     EventHandler("zskb_mindcontrolled", function(inst)
        --         inst.sg.statemem.mindcontrolled = true
        --         inst.sg:GoToState("zskb_mindcontrolled_loop")
        --     end),
        -- },

        ontimeout = function(inst)
            inst.sg:GoToState("mindcontrolled_pst")
        end,

        onexit = function(inst)
            if not inst.sg.statemem.mindcontrolled then
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
                inst.components.inventory:Show()
            end
        end,
    })
AddStategraphState("wilson",
    State {
        name = "zskb_mindcontrolled_pst",
        tags = { "busy", "pausepredict", "nomorph", "nodangle" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("mindcontrol_pst")

            --Should be coming from "mindcontrolled" state
            --[[
        local stun_frames = 6
        if inst.components.playercontroller ~= nil then
            --Specify min frames of pause since "busy" tag may be
            --removed too fast for our network update interval.
            inst.components.playercontroller:RemotePausePrediction(stun_frames)
        end]]
            inst.sg:SetTimeout(6 * FRAMES)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle", true)
        end,
    })

-- AddStategraphState("wilson",
--     State {
--         name = "zskb_sanity_stun",
--         tags = { "busy", "pausepredict"},

--         onenter = function(inst, data)
--             --inst.components.playercontroller:Enable(false)
--             inst.components.locomotor:Stop()

--             inst.AnimState:PlayAnimation("idle_sanity_pre", false) -- FIXME: woodie tranform has no this anim
--             inst.AnimState:PushAnimation("idle_sanity_loop", true)

--             inst.zskb_sanity_stunned = true

--             inst.sg:SetTimeout(data and data.duration or 3.5)
--         end,

--         ontimeout = function(inst)
--             inst.sg:GoToState("idle")
--         end,

--         events =
--         {
--             EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
--         },

--         onexit = function(inst)
--             --inst.components.playercontroller:Enable(true)
--             inst.zskb_sanity_stunned = false -- this should be used for continue the stun when be hit
--             --inst:PushEvent("sanity_stun_over")
--         end
--     })


AddStategraphState("wilson",
    State {
        name = "zskb_enterhouse_pre",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
            inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.bufferedaction ~= nil then
                        inst:PerformBufferedAction()
                    else
                        inst.sg:GoToState("idle")
                    end
                end
            end),
        },
    })

AddStategraphState("wilson",
    State {
        name = "zskb_enterhouse",
        tags = { "doing", "busy", "canrotate", "nopredict", "nomorph" },

        onenter = function(inst, data)
            ToggleOffPhysics(inst)
            inst.components.locomotor:Stop()

            inst.sg.statemem.target = data.target
            inst.sg.statemem.heavy = inst.components.inventory:IsHeavyLifting()

            if data.target ~= nil and data.target.components.teleporter ~= nil then
                data.target.components.teleporter:RegisterTeleportee(inst)
            end
            inst.AnimState:PlayAnimation("give_pst", false)
            local pos = data ~= nil and data.target and data.target:GetPosition() or nil
            if pos ~= nil then
                inst:ForceFacePoint(pos:Get())
            else
                inst.sg.statemem.speed = 0
            end
            inst.sg.statemem.teleportarrivestate = "idle"
        end,

        timeline =
        {
            TimeEvent(10 * FRAMES, function(inst)
                if not inst.sg.statemem.heavy then
                    inst.Physics:Stop()
                end
                if inst.sg.statemem.target ~= nil then
                    if inst.sg.statemem.target:IsValid() then
                        inst.sg.statemem.target:PushEvent("starttravelsound", inst)
                    else
                        inst.sg.statemem.target = nil
                    end
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    if inst.sg.statemem.target ~= nil and inst.sg.statemem.target:IsValid() and inst.sg.statemem.target.components.teleporter ~= nil then
                        inst.sg.statemem.target.components.teleporter:UnregisterTeleportee(inst)
                        if inst.sg.statemem.target.components.teleporter:Activate(inst) then
                            inst.sg.statemem.isteleporting = true
                            inst.components.health:SetInvincible(true)
                            if inst.components.playercontroller ~= nil then
                                inst.components.playercontroller:Enable(false)
                            end
                            inst:Hide()
                            inst.DynamicShadow:Enable(false)
                            return
                        end
                    end
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            --if inst.sg.statemem.target ~= nil and
            --	inst.sg.statemem.target:IsValid() then
            --		inst.sg.statemem.target.AnimState:SetDeltaTimeMultiplier(0.5)
            --end
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
            inst.Physics:Stop()
            if inst.sg.statemem.isteleporting then
                inst.components.health:SetInvincible(false)
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
                inst:Show()
                inst.DynamicShadow:Enable(true)
            elseif inst.sg.statemem.target ~= nil
                and inst.sg.statemem.target:IsValid()
                and inst.sg.statemem.target.components.teleporter ~= nil then
                inst.sg.statemem.target.components.teleporter:UnregisterTeleportee(inst)
            end
        end,
    }
)

AddStategraphState('wilson_client',
    State {
        name = "zskb_enterhouse_pre",
        tags = { "doing", "busy", "canrotate" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give")
            inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(1)
        end,

        onupdate = function(inst)
            if inst:HasTag("doing") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    }
)
