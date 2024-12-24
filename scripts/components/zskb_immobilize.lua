-- 来自神话，做了部分修改
local function BitAND(a,b) local p,c=1,0 while a>0 and b>0 do local ra,rb=a%2,b%2 if ra+rb>1 then c=c+p end a,b,p=(a-ra)/2,(b-rb)/2,p*2 end return c end

local function CollidesWithPlayer(phy)
    local mask = phy:GetCollisionMask()
    if mask < COLLISION.CHARACTERS then 
        return false
    else
        return BitAND(mask, COLLISION.CHARACTERS) > 0
    end
end

local function IsObstacle(phy)
    return phy:GetCollisionGroup() == COLLISION.OBSTACLES
end

local zskb_immobilize = Class(function(self, inst)
    self.inst = inst
    self.time = 0
    self.dingshentime = 0
    self.holdding = false
    self.dstime = -10
    self._attacked = function()
        if self.holdding then
            self:Stop()
        end
    end
end)

function zskb_immobilize:Start(time,hold)
    if (GetTime() - self.dstime) < 10 then
        return 
    end
    self.dstime = GetTime()
    local inst = self.inst
    self.time = time
    self.dingshentime = 0
    self.holdding = hold
    inst:AddTag('zskb_immobilize')
    
    -- 暂停动画
    if inst.AnimState then
        inst.AnimState:Pause()
    end
    -- 记录物理相关信息，并停物理，之后再还原
    if inst.Physics then
        local mass = inst.Physics:GetMass()
        if IsObstacle(inst.Physics) then
        elseif not CollidesWithPlayer(inst.Physics) then
            inst.Physics:SetActive(false)
        elseif mass ~= 0 then
            -- 物理速度
            inst.vel = {inst.Physics:GetVelocity()}
            -- 
            inst.motor_vel = {inst.Physics:GetMotorVel()}
            -- 停止物理
            inst.phy_stop = true

            inst.Physics:Stop()
        elseif inst.Physics:GetMotorVel() ~= 0 then
            inst.Physics:SetActive(false)
        end
    end
    self.inst:ListenForEvent("attacked",self._attacked)
    self.inst:StartUpdatingComponent(self)
end

function zskb_immobilize:Stop()
    self.time = 0
    self.dingshentime = 0
    self.holdding = false
    local inst = self.inst
    inst:RemoveTag('zskb_immobilize')
    inst:RemoveEventCallback("attacked",self._attacked)
    inst:StopUpdatingComponent(self)

    if not inst:IsValid() then
        return
    end

    if inst.AnimState then
        inst.AnimState:Resume()
    end
    
    -- 这边还原物理参数
    if inst.Physics then
        if IsObstacle(inst.Physics) then         
        elseif not CollidesWithPlayer(inst.Physics) then
            inst.Physics:SetActive(true)
        elseif inst.phy_stop then
            inst.phy_stop = nil
            inst.vel = inst.vel and inst.Physics:SetVel(unpack(inst.vel))
            inst.motor_vel = inst.motor_vel and inst.Physics:SetMotorVel(unpack(inst.motor_vel))
        elseif inst.Physics:GetMass() ~= 0 or inst.Physics:GetMotorVel() ~= 0 then
            inst.Physics:SetActive(true)
        end
    end
end

function zskb_immobilize:OnUpdate(dt)
	self.dingshentime = self.dingshentime + dt
    local inst = self.inst
	if self.dingshentime >= self.time then
		self:Stop()
	end
    -- 这里遍历所有延时任务，不断往后延
    if inst.pendingtasks then
        for k in pairs(inst.pendingtasks or {})do
            k:AddTick()
        end
    end

    -- 这里一样延迟sg
    if inst.sg then
        inst.sg:AddZSKBTick(dt)
    end

    -- 停物理
    if inst.Physics and inst.phy_stop then
        inst.Physics:Stop()
    end

    -- 计时停止
    if inst.components.timer then
        for k,v in pairs(inst.components.timer.timers)do
            if not v.paused then
                v.end_time = v.end_time + dt
            end
        end
    end

    -- 被攻击时间往后延
    if inst.components.combat then 
        if inst.components.combat.lastdoattacktime then
            inst.components.combat.lastdoattacktime = inst.components.combat.lastdoattacktime + dt
        end
    end
end

return zskb_immobilize
