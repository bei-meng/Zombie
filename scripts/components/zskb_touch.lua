local Touch = Class(function(self, inst)
    self.inst = inst
    self.takefn = nil
end)

function Touch:Active(doer)
    if TheWorld.state.precipitation ~= "none" then
        TheWorld:PushEvent("ms_forceprecipitation", false)
    else
        TheWorld:PushEvent("ms_forceprecipitation", true)
    end
end

function Touch:Take(doer)
    if self.takefn ~= nil then
        self.takefn(self.inst, doer)
    end
end

return Touch
