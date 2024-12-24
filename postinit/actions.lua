----------------------------------------------------------------
--[[ ACTIONS DEFINE ]]
----------------------------------------------------------------
local f_brain = require("brains/zskb_move_paper_doll_brain")
local actions = {
    ZSKB_TOUCH = {
        id = "ZSKB_TOUCH",
        strfn = function(act)
            if act.target:HasTag("zskb_paper_doll") then
                return "ZSKB_TAKE"
            else
                return "GENERIC"
            end
        end,
        fn = function(act)
            if act.target ~= nil then
                if act.target:HasTag("zskb_paper_doll") then
                    act.target.components.zskb_touch:Take(act.doer)
                    act.target:RemoveComponent("zskb_touch")
                else
                    act.target.components.zskb_touch:Active(act.doer)
                end
            end
            return true
        end
    },
    ZSKB_ENCASE = {
        id = "ZSKB_ENCASE",
        priority = 1,
        invalid_hold_action = true,
        strfn = function(act)
            if act.target:HasTag("zskb_moving_paper_doll") then
                return "ZSKB_BIND"
            else
                return "GENERIC"
            end
        end,
        fn = function(act)
            local useitem = act.invobject
            local target = act.target
            if useitem ~= nil and target ~= nil then
                if useitem.components.container ~= nil and target.prefab == "zskb_ghostfire" then
                    local give = act.invobject.components.container:GiveItem(act.target)
                    if give then
                        return true
                    else
                        return false, "ZSKB_ENCASE_FAIL"
                    end
                elseif useitem.prefab == "zskb_incense_burner" and target.prefab == "zskb_moving_paper_doll" then
                    if target.components.follower.leader == nil then
                        target.components.follower:SetLeader(useitem)
                        target:SetBrain(f_brain)
                        return true
                    else
                        return false
                    end
                end
            end
        end
    },
    ZSKB_PLANT = {
        id = "ZSKB_PLANT",
        priority = 1,
        rmb = true,
        encumbered_valid = true,
        strfn = function(act)
            return "GENERIC"
        end,
        fn = function(act)
            local heavy_item = act.doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.BODY)

            if heavy_item == nil or not act.target:HasTag("can_use_heavy") then
                return false
            end

            if heavy_item ~= nil and act.target ~= nil and act.target.components.zskb_plant ~= nil then
                return act.target.components.zskb_plant:UseHeavyObstacle(act.doer, heavy_item)
            end
        end
    },
    ZSKB_ENTER_HOUSE = {
        id = "ZSKB_ENTER_HOUSE",
        priority = 1,
        mount_valid = true,      -- can trigger in riding
        -- ghost_valid = true, -- can trigger when playerghost(we has set the onhaunt and use haunt action onhaunter to do the teleport)
        encumbered_valid = true, -- can trigger when heavy lifting
        str = ACTIONS_ZSKB_ENTER_HOUSE_GENERIC_STR,
        --strfn = function(act)
        --    return "GENERIC"
        --end,
        fn = function(act)
            if act.doer ~= nil and act.doer.sg ~= nil and act.doer.sg.currentstate.name == "zskb_enterhouse_pre" then
                if act.target ~= nil and act.target.components.teleporter ~= nil and act.target.components.teleporter:IsActive(act.doer) then
                    act.doer.sg:GoToState("zskb_enterhouse", { target = act.target })
                    return true
                end
            end
            act.doer.sg:GoToState("idle")
            return false
        end,
    }
}

for _, action in pairs(actions) do
    local _action = Action()
    for k, v in pairs(action) do
        _action[k] = v
    end
    AddAction(_action)
end

STRINGS.ACTIONS.ZSKB_TOUCH = {
    GENERIC = ACTIONS_ZSKB_TOUCH_GENERIC_STR,
    ZSKB_TAKE = ACTIONS_ZSKB_TOUCH_TAKE_STR,
}

STRINGS.ACTIONS.ZSKB_ENCASE = {
    GENERIC = ACTIONS_ZSKB_ENCASE_GENERIC_STR,
    ZSKB_BIND = ACTIONS_ZSKB_ENCASE_BIND_STR,
}
STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.ZSKB_ENCASE = {
    ZSKB_ENCASE_FAIL = ACTIONS_ZSKB_ENCASE_FAIL,
}

STRINGS.ACTIONS.ZSKB_PLANT = {
    GENERIC = ACTIONS_ZSKB_PLANT_GENERIC_STR,
}

STRINGS.ACTIONS.ZSKB_ENTER_HOUSE = {
    GENERIC = ACTIONS_ZSKB_ENTER_HOUSE_GENERIC_STR,
}

STRINGS.ACTIONS.UNEQUIP["ZSKB_UMBRELLA_CLOSE"] = ACTIONS_ZSKB_UMBRELLA_CLOSE_GENERIC_STR
STRINGS.ACTIONS.UNEQUIP["ZSKB_UMBRELLA_OPEN"] = ACTIONS_ZSKB_UMBRELLA_OPEN_GENERIC_STR

----------------------------------------------------------------
--[[ ACTION HANDLER ]]
----------------------------------------------------------------
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.ZSKB_TOUCH, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.ZSKB_TOUCH, "doshortaction"))

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.ZSKB_ENCASE, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.ZSKB_ENCASE, "dolongaction"))

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.ZSKB_PLANT, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.ZSKB_PLANT, "dolongaction"))

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.ZSKB_ENTER_HOUSE, "zskb_enterhouse_pre"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.ZSKB_ENTER_HOUSE, "zskb_enterhouse_pre"))

----------------------------------------------------------------
--[[ ADD COMPONENT ACTION ]]
-- SCENE		using an object in the world                                        --args: inst, doer, actions, right
-- USEITEM		using an inventory item on an object in the world                   --args: inst, doer, target, actions, right
-- POINT		using an inventory item on a point in the world                     --args: inst, doer, pos, actions, right, target
-- EQUIPPED		using an equiped item on yourself or a target object in the world   --args: inst, doer, target, actions, right
-- INVENTORY	using an inventory item                                             --args: inst, doer, actions, right
----------------------------------------------------------------
AddComponentAction("SCENE", "zskb_touch", function(inst, doer, actions, right)
    if right then
        table.insert(actions, ACTIONS.ZSKB_TOUCH)
    end
end)
AddComponentAction("SCENE", "zskb_plant", function(inst, doer, actions, right)
    local item = doer.replica.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if right and item ~= nil and item:HasTag("heavy") and item.prefab == "zskb_banyantreenut" and inst:HasTag("can_use_heavy") then
        table.insert(actions, ACTIONS.ZSKB_PLANT)
    end
end)
AddComponentAction("SCENE", "teleporter", function(inst, doer, actions, right)
    if inst:HasTag("zskb_enterable") then
        table.insert(actions, ACTIONS.ZSKB_ENTER_HOUSE)
    end
end)
AddComponentAction("USEITEM", "zskb_encase", function(inst, doer, target, actions)
    if target:HasTag("zskb_ghostfire") and inst.prefab == "zskb_gourd" then
        table.insert(actions, ACTIONS.ZSKB_ENCASE)
    elseif target:HasTag("zskb_moving_paper_doll") and inst.prefab == "zskb_incense_burner" then
        table.insert(actions, ACTIONS.ZSKB_ENCASE)
    end
end)

----------------------------------------------------------------
--[[ ACTIONS HOOK ]]
----------------------------------------------------------------
local unequipstrfn = ACTIONS.UNEQUIP.strfn
ACTIONS.UNEQUIP.strfn = function(act)
    if act.invobject:HasTag("zskb_copper_coin_umbrella") then
        return act.invobject:HasTag("zskb_copper_coin_umbrella_open") and "ZSKB_UMBRELLA_CLOSE" or "ZSKB_UMBRELLA_OPEN"
    else
        return unequipstrfn(act)
    end
end
local unequipfn = ACTIONS.UNEQUIP.fn
ACTIONS.UNEQUIP.fn = function(act)
    if act.invobject:HasTag("zskb_copper_coin_umbrella") then
        if act.invobject._status and act.doer then
            act.invobject._status = act.invobject._status == "open" and "close" or "open"
            act.invobject:change_copper_coin_inventoryimage(act.doer)
        end
        return true
    else
        return unequipfn(act)
    end
end

local old_lookatfn = ACTIONS.LOOKAT.fn
ACTIONS.LOOKAT.fn = function(act)
    local targ = act.target or act.invobject
    if targ ~= nil and targ.prefab == "zskb_paper" then
        SendModRPCToClient(GetClientModRPC("zskb_zombie", "paper_open"), act.doer.userid)
        return true
    else
        return old_lookatfn(act)
    end
end
