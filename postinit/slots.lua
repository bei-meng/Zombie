EQUIPSLOTS["RUNEPAPER"] = "runepaper"

local W = 68
local SEP = 12
local YSEP = 8
local INTERSEP = 28
AddClassPostConstruct("widgets/inventorybar", function(self, owner)
    if not owner or not owner:HasTag("zskb_zombie") then
        return
    end

    if TheNet:GetServerGameMode() == "quagmire" then

    else
        self:AddEquipSlot(EQUIPSLOTS.RUNEPAPER, "images/zskb_runepaper.xml", "zskb_runepaper.tex", 3)
    end

    local old_Rebuild = self.Rebuild
    function self:Rebuild()
        if old_Rebuild ~= nil then
            old_Rebuild(self)
        end

        local inventory = self.owner.replica.inventory
        local do_self_inspect = not (self.controller_build or GetGameModeProperty("no_avatar_popup"))

        local num_slots = inventory:GetNumSlots()
        local num_equip = #self.equipslotinfo
        local num_buttons = do_self_inspect and 1 or 0
        local num_slotintersep = math.ceil(num_slots / 5)
        local num_equipintersep = num_buttons > 0 and 1 or 0
        local total_w = (num_slots + num_equip + num_buttons) * W + (num_slots + num_equip + num_buttons - num_slotintersep - num_equipintersep - 1) * SEP + (num_slotintersep + num_equipintersep) * INTERSEP + W + SEP

        local w, h = self.bg:GetSize()

        self.bg:SetScale(total_w / w, 1, 1)
        self.bgcover:SetScale(total_w / w, 1, 1)
    end
end)
