local InteriorManager = Class(function(self, inst)
    self.inst = inst

    self.rooms = {}
    self.start_x = 1500
    self.start_z = 1500
    self.max_width = 500
    self.max_height = 500
    self.room_size = 50
    -- (1500, 0, 1500) ~ (2000, 0, 2000)
    -- room size around 50 x 50 -- 25 x 20 左右, 算他 50x50
end)

--- COMMON FNS
function InteriorManager:SnapToRoomCenter(x, z)
    return self.start_x + math.floor((x - self.start_x) / self.room_size + 0.5) * self.room_size,
        self.start_z + math.floor((z - self.start_z) / self.room_size + 0.5) * self.room_size
end

function InteriorManager:RegisterRoom(center, top_width, bottom_width, top_halfheight, bottom_halfheight)
    if center == nil then return end
    local x, _, z = center.Transform:GetWorldPosition()
    x, z = self:SnapToRoomCenter(x, z)  -- just in case
    local room_info = { x = x, z = z, tw = top_width or 19, bw = bottom_width or 20.5, th = top_halfheight or 6.5, bh = bottom_halfheight or 7.5 }
    self.rooms[center] = room_info
end

function InteriorManager:UnregisterRoom(center)
    if center == nil then return end
    self.rooms[center] = nil
end

function InteriorManager:FindAvailableXZ()
    for cur_x = self.start_x, self.start_x + self.max_height, self.room_size do
        for cur_z = self.start_z, self.start_z + self.max_width, self.room_size do
            --if not self.rooms[getid(cur_x, cur_z)] or #TheSim:FindEntities(cur_x, 0, cur_z, 1.4*self.room_size/2) == 0 then
            if #TheSim:FindEntities(cur_x, 0, cur_z, 1.4 * self.room_size / 2) == 0 then
                return cur_x, cur_z
            end
        end
    end
end

function InteriorManager:IsPointInRoom(x, y, z)
    -- if input vector3
    if type(x) == "table" and x.IsVector3 and x:IsVector3() and x.Get ~= nil then
        x, y, z = x:Get()
    end
    -- if input x, z
    if z == nil then
        z = y
        y = 0
    end

    if x >= self.start_x - self.room_size and x <= self.start_x + self.max_height + self.room_size and
        z >= self.start_z - self.room_size and z <= self.start_z + self.max_width + self.room_size then
        for center, info in pairs(self.rooms) do
            -- x正方向向下，z正方向向右
            local p1 = { info.x - info.th, info.z + info.tw / 2 }
            local p2 = { info.x - info.th, info.z - info.tw / 2 }
            local p3 = { info.x + info.bh, info.z - info.bw / 2 }
            local p4 = { info.x + info.bh, info.z + info.bw / 2 }
            if TheSim:WorldPointInPoly(x, z, { p1, p2, p3, p4 }) then
                return info.x, info.z
            end
        end
    end
end

-- 客户端和服务端结果可能不一样，因为center 在客户端超加载范围会remove掉导致UnregisterRoom
function InteriorManager:PrintRooms()
    if self.rooms == nil or next(self.rooms) == nil then
        print("ROOMS EMPTY")
    else
        print("ROOMS HERE:")
        for center, info in pairs(self.rooms) do
            print(center, info.x, info.z)
        end
    end
end

if TheWorld and TheWorld.ismastersim then
    -- 房子中心x z, 上底，下底，上半高（中心到上底），下半高（中心到下底）
    function InteriorManager:BuildBoundary(x, z, top_width, bottom_width, top_halfheight, bottom_halfheight)
        local function addwall(x, z)
            local wall = SpawnPrefab("zskb_interior_wall_back")
            if wall ~= nil then
                wall.Physics:SetCollides(false)
                wall.Physics:Teleport(x, 0, z)
                wall.Physics:SetCollides(true)
            end
        end

        --上底
        for dz = -top_width / 2, top_width / 2 do
            addwall(x - top_halfheight, z + dz)
        end
        --下底
        for dz = -bottom_width / 2, bottom_width / 2 do
            addwall(x + bottom_halfheight, z + dz)
        end

        local tan = (top_halfheight + bottom_halfheight) / math.abs(bottom_width - top_width)
        local sita = math.atan(tan)
        local ddx, ddz = math.sin(sita), math.cos(sita)
        -- 添加斜边墙体
        local dz = 0
        for dx = -top_halfheight, bottom_halfheight, ddx do
            addwall(x + dx, z - top_width / 2 - dz)
            addwall(x + dx, z + top_width / 2 + dz)
            dz = dz + ddz
        end
    end

    -- 建好空气墙，和房间中心 （prefab 在 zskb_interior_items）
    function InteriorManager:AllocateRoom(entrance, top_width, bottom_width, top_halfheight, bottom_halfheight)
        local x, z = self:FindAvailableXZ()
        if entrance == nil or x == nil or z == nil then return end
        local room_info = { x = x, z = z, tw = top_width or 19, bw = bottom_width or 20.5, th = top_halfheight or 6.5, bh = bottom_halfheight or 7.5 }

        --self.rooms[entrance] = room_info
        self:BuildBoundary(x, z, room_info.tw, room_info.bw, room_info.th, room_info.bh)
        local center = SpawnPrefab("zskb_interior_center")
        if center then
            center.Transform:SetPosition(x, 0, z)
            --center.room_info = room_info -- TODO: add a replica to send room info to client
        end
        return x, z
    end

    local MULTIPLAYER_PORTAL_MUST_TAG = { "multiplayer_portal" }
    local INTERIOR_CENTER_MUST_TAG = { "zskb_interior_center" }
    function InteriorManager:DestoryRoom(entrance)
        if entrance == nil then return end
        local pt = entrance:GetPosition()
        if pt == nil then
            local portal = FindEntity(entrance, 9999, nil, MULTIPLAYER_PORTAL_MUST_TAG)
            pt = portal and portal:GetPosition() or Vector3(0, 0, 0)
        end

        local exit = entrance.components.teleporter and entrance.components.teleporter:GetTarget() or nil -- 房间内出口
        local interior_center = exit and FindEntity(exit, 20, nil, INTERIOR_CENTER_MUST_TAG) or nil
        local cent_pt = interior_center and interior_center:GetPosition() or nil

        if cent_pt ~= nil then
            local x, _, z = cent_pt:Get()
            local ents = TheSim:FindEntities(x, 0, z, 20, nil, { "INLIMBO" })

            for i, v in ipairs(ents) do
                if v:HasTag("player") or v:HasTag("playerghost") or v.components.inventoryitem ~= nil then
                    if v.Physic ~= nil then
                        v.Physic:Teleport(pt:Get()) -- urgent teleport
                    elseif v.Transform ~= nil then
                        v.Transform:SetPosition(pt:Get())
                    end
                else
                    v:Remove()
                end
            end
        end
    end

    --function InteriorManager:OnSave()
    --    local rooms = self.rooms
    --    local guid_rooms = {}
    --    if rooms ~= nil then
    --        for entrance, info in pairs(self.rooms) do
    --            guid_rooms[entrance.GUID] = info
    --        end
    --        return
    --        {
    --            guid_rooms = guid_rooms,
    --        }
    --
    --    end
    --end

    --function InteriorManager:OnLoad(data)
    --    if data ~= nil and data.rooms ~= nil then
    --		self.rooms = data.rooms
    --	end
    --end

    --function InteriorManager:LoadPostPass(newents, data)
    --    if data ~= nil and data.guid_rooms ~= nil then
    --        for guid, info in pairs(data.guid_rooms) do
    --            local entranceEnt = newents[guid]
    --            if entranceEnt ~= nil and entranceEnt.entity.components.teleporter ~= nil then
    --                self.rooms[entranceEnt.entity] = info
    --            end
    --
    --        end
    --    end
    --end
end

return InteriorManager
