local SavedTurned = Class(function(self, inst)
    self.inst = inst
    self.horizontal_turned = false
    self.vertical_turned = false
end)

function SavedTurned:OnSave()
    return {
        horizontal_turned = self.horizontal_turned,
        vertical_turned = self.vertical_turned
    }
end

function SavedTurned:OnLoad(data)
    self.horizontal_turned = data and data.horizontal_turned
    self.vertical_turned = data and data.vertical_turned
    local animstate = self.inst.AnimState
    if animstate then
        animstate:SetScale(self.horizontal_turned and -1 or 1, self.vertical_turned and -1 or 1, 1)
    end
end

function SavedTurned:SetTurned(horizontal_turned, vertical_turned)
    self.horizontal_turned = horizontal_turned
    self.vertical_turned = vertical_turned
    local animstate = self.inst.AnimState
    if animstate then
        animstate:SetScale(self.horizontal_turned and -1 or 1, self.vertical_turned and -1 or 1, 1)
    end
end

-- function SavedTurned:LoadPostPass(newents, data)
--     self.horizontal_turned = data and data.horizontal_turned
--     self.vertical_turned = data and data.vertical_turned
--     local animstate = self.inst.AnimState
--     if animstate then
--         animstate:SetScale(self.horizontal_turned and -1 or 1, self.vertical_turned and -1 or 1, 1)
--     end
-- end


return SavedTurned
