-- 定身相关
-- 来自神话定身术

-- 将DoStaticTaskInTime和DoPeriodicTask任务不断往后延迟
-- 可以查阅cheduler文件
AddGlobalClassPostConstruct("scheduler", "Periodic", function(self)
    -- pendingtasks中的任务调用AddTick，因为DoStaticTaskInTime和DoPeriodicTask都会往pendingtasks中塞任务
    function self:AddTick()
        -- Periodic任务没有下一个执行任务的tick时间点，scheduler为全局变量，scheduler没有下一个时刻的任务，就返回
        if not self.nexttick or not scheduler.attime[self.nexttick] then
            return
        end
        -- self.nexttick是本任务要执行的时间点，找到对应的任务列表
        local thislist = scheduler.attime[self.nexttick]
        -- 把本任务的执行时间点+1
        self.nexttick = self.nexttick + 1
        -- 如果scheduler没有下一个时刻的任务列表，给一个空任务列表
        if not scheduler.attime[self.nexttick] then
            scheduler.attime[self.nexttick] = {}
        end
        local nextlist = scheduler.attime[self.nexttick]
        -- 然后把本任务塞到下一个时刻的任务列表里面去
        thislist[self] = nil--这里是清除原本所在的任务列表中的自己
        nextlist[self] = true--这里是把自己塞到下一个时刻的任务列表里面
        self.list = nextlist--更新所处的任务列表
    end
end)


-- 状态,和上面类似的，把要执行的任务不断往后延
AddGlobalClassPostConstruct("stategraph", "StateGraphInstance", function(self)

    local old_gotostate = self.GoToState
    function self:GoToState(newstate, p, ...)
        local state = self.sg.states[newstate]
        -- 没有目标state，返回原函数
        if not state then
            return old_gotostate(self, newstate, p, ...)
        end
        -- 如果要切换state了，就结束定身
		if self.inst:HasTag("zskb_immobilize") and self.inst.components.zskb_hold_anim then
			self.inst.components.zskb_hold_anim:Stop()
		end
		return old_gotostate(self, newstate, p, ...)
    end

    local old_update = self.Update
    function self:Update(...)
        local sleep_time = old_update(self, ...)
        -- 没有睡眠时间
        if not sleep_time then
            self.zskb_next_update_tick = nil
        else
            local sleep_ticks = sleep_time/GetTickTime()
            sleep_ticks = sleep_ticks == 0 and 1 or sleep_ticks
            -- 保持sleep延时
            self.zskb_next_update_tick = math.floor(sleep_ticks + GetTick())+1
        end

        return sleep_time
    end

    function self:AddZSKBTick(dt)
        dt = dt or GetTickTime()
        self.statestarttime = self.statestarttime + dt
        if self.zskb_next_update_tick then
            local thislist = SGManager.tickwaiters[self.zskb_next_update_tick]
            if not thislist then return end
            self.zskb_next_update_tick = self.zskb_next_update_tick + 1
            if not SGManager.tickwaiters[self.zskb_next_update_tick]then
                SGManager.tickwaiters[self.zskb_next_update_tick] = {}
            end
            -- 这里一样，把本任务塞到下一个时刻的任务列表里面去
            local nextlist = SGManager.tickwaiters[self.zskb_next_update_tick]
            thislist[self] = nil
            nextlist[self] = true
        end
    end
end)


-- AI，脑子的更新,
AddGlobalClassPostConstruct("behaviourtree", "BT", function(self)
    local old_update = self.Update
    function self:Update(...)
        if self.inst:HasTag("zskb_immobilize") then
            return
		end
		return old_update(self, ...)
    end
end)