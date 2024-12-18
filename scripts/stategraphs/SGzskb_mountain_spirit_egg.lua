local falling_dmg = TUNING.ZSKB_MOUNTAIN_SPIRIT_EGG_FALLING_DMG
local falling_rad = TUNING.ZSKB_MOUNTAIN_SPIRIT_EGG_FALLING_RAD

local explode_dmg = TUNING.ZSKB_MOUNTAIN_SPIRIT_EGG_EXPLODE_DMG
local explode_rad = TUNING.ZSKB_MOUNTAIN_SPIRIT_EGG_EXPLODE_RAD

local explode_must_tags = { "_health", "_combat" }
local explode_no_tags = { "INLIMBO", "playerghost", "shadowcreature", "spawnprotection" }

local function DoAoeDamage(inst, rad, dmg)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, 0, z, rad, explode_must_tags, explode_no_tags)
    for k, v in ipairs(ents) do
        if v:IsValid() and v.entity:IsVisible() and not v:IsInLimbo() and
            v.components.combat ~= nil and (inst.queen == nil or v ~= inst.queen) then
            v.components.combat:GetAttacked(inst.queen or inst, dmg)
        end
    end
end

local events = {}

local states = {
    State {
        name = "idle",
        tags = { "idle" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State {
        name = "flying",
        tags = { "busy" },

        onenter = function(inst)
            -- inst.Physics:Stop()
            inst.AnimState:PlayAnimation("flying", true)
            inst.sg:SetTimeout(5) --to detect if we stuck in the sky , just remove
        end,

        onupdate = function(inst)
            local pos = inst:GetPosition()
            if pos.y <= 0.2 then
                inst.sg:GoToState("land")
            end
        end,

        ontimeout = function(inst)
            inst:Remove()
        end
    },

    State {
        name = "land",
        tags = { "busy" },

        onenter = function(inst)
            ChangeToObstaclePhysics(inst)
            inst.Physics:SetCapsule(.2, 2)

            inst.AnimState:PlayAnimation("land")

            DoAoeDamage(inst, falling_rad, falling_dmg)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("explode")
                end
            end),
        },
    },

    State {
        name = "explode",
        tags = { "busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PushAnimation("hatch")
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("zskb_mountain_spirit/mountain_spirit/explode") end),
            TimeEvent(10 * FRAMES, function(inst) DoAoeDamage(inst, explode_rad, explode_dmg) end),
            TimeEvent(15 * FRAMES, function(inst) inst:Remove() end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:Remove()
                end
            end),
        },
    }

}

return StateGraph("zskb_mountain_spirit_egg", states, events, "idle")
