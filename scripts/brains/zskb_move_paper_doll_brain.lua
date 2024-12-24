require "behaviours/follow"
require "behaviours/faceentity"
require "behaviours/standstill"
local BrainCommon = require("brains/braincommon")

local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 12
local TARGET_FOLLOW_DIST = 6


local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end


local MovePaperDollBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)


function MovePaperDollBrain:OnStart()
    local root =
        PriorityNode({
            BrainCommon.PanicTrigger(self.inst),
            Follow(self.inst, function() return self.inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
            StandStill(self.inst),
        }, .25)
    self.bt = BT(self.inst, root)
end

return MovePaperDollBrain
