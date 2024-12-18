local upvaluehelper = require "zskb_upvaluehelper"
local _G = GLOBAL
----------------- INTERIOR WORLD POSTINIT --------------

-- for both client and server side
local function AddInteriorManager(world)
    if world.components.zskb_interiormanager == nil then
        world:AddComponent("zskb_interiormanager")
    end
    -- hook Map组件，让玩家可以在interior中建东西，丢东西不会落水
    local Map = getmetatable(world.Map).__index
    if Map ~= nil then
        local old_IsAboveGroundAtPoint = Map.IsAboveGroundAtPoint
        Map.IsAboveGroundAtPoint = function(self, x, y, z, ...)
            local interiormanager = world ~= nil and world.components.zskb_interiormanager
            return old_IsAboveGroundAtPoint(self, x, y, z, ...) or (interiormanager ~= nil and interiormanager:IsPointInRoom(x, y, z))
        end

        local old_IsVisualGroundAtPoint = Map.IsVisualGroundAtPoint
        Map.IsVisualGroundAtPoint = function(self, x, y, z, ...)
            local interiormanager = world ~= nil and world.components.zskb_interiormanager
            return old_IsVisualGroundAtPoint(self, x, y, z, ...) or (interiormanager ~= nil and interiormanager:IsPointInRoom(x, y, z))
        end

        local old_GetTileCenterPoint = Map.GetTileCenterPoint
        Map.GetTileCenterPoint = function(self, x, y, z, ...)
            -- with z means world point , without z means tile coord
            local interiormanager = world ~= nil and world.components.zskb_interiormanager
            if z ~= nil and interiormanager ~= nil and interiormanager:IsPointInRoom(x, y, z) then
                return math.floor(x / 4) * 4 + 2, 0, math.floor(z / 4) * 4 + 2
            else
                return old_GetTileCenterPoint(self, x, y, z, ...)
            end
        end
    end
end

-------------------- INTERIOR FOOTSTEP SOUND ----------------
local Old_PlayFootstep = rawget(GLOBAL, "PlayFootstep")
GLOBAL.PlayFootstep = function(inst, volume, ispredicted, ...)
    local interiormanager = TheWorld ~= nil and TheWorld.components.zskb_interiormanager
    if interiormanager ~= nil and interiormanager:IsPointInRoom(inst:GetPosition():Get()) then
        local sound = inst.SoundEmitter
        if sound ~= nil then
            sound:PlaySound(
                inst.sg ~= nil and inst.sg:HasStateTag("running") and "dontstarve/movement/run_woods" or "dontstarve/movement/walk_woods" .. ((inst:HasTag("smallcreature") and "_small") or (inst:HasTag("largecreature") and "_large" or "")),
                nil,
                volume or 1,
                ispredicted
            )
        end
    else
        return Old_PlayFootstep and Old_PlayFootstep(inst, volume, ispredicted, ...)
    end
end

------------------------ INTERIOR CAMERA  -------------------
AddPlayerPostInit(function(inst)
    if not TheNet:IsDedicated() then
        inst:DoPeriodicTask(0.2, function(inst)
            if ThePlayer and TheCamera and TheWorld then
                local interiormanager = TheWorld.components.zskb_interiormanager
                if interiormanager then
                    local x, z = interiormanager:IsPointInRoom(ThePlayer:GetPosition():Get())
                    if x ~= nil and z ~= nil then
                        TheCamera.zskb_interior_currentpos = Vector3(x, 1.5, z)
                    else
                        TheCamera.zskb_interior_currentpos = nil
                    end
                end
            end
        end)
    end
end)

local INTERIOR_CONSTANTS = {
    PITCH = 42.857142857143, -- hua's magic number
    HEADING = 0,
    DISTANCE = 30,
    FOV = 35,
}
-- see interiorcamera.lua in DLC0003
AddClassPostConstruct("cameras/followcamera", function(self)
    local Old_Apply = self.Apply
    function self:Apply()
        if self.zskb_interior_currentpos ~= nil then
            self.headingtarget = INTERIOR_CONSTANTS.HEADING
            local interior_pitch = INTERIOR_CONSTANTS.PITCH
            local interior_heading = INTERIOR_CONSTANTS.HEADING
            local interior_distance = INTERIOR_CONSTANTS.DISTANCE
            local interior_fov = INTERIOR_CONSTANTS.FOV
            local interior_currentpos = self.zskb_interior_currentpos

            --dir
            local dx = -math.cos(interior_pitch * DEGREES) * math.cos(interior_heading * DEGREES)
            local dy = -math.sin(interior_pitch * DEGREES)
            local dz = -math.cos(interior_pitch * DEGREES) * math.sin(interior_heading * DEGREES)

            --pos
            local px = dx * (-interior_distance) + interior_currentpos.x
            local py = dy * (-interior_distance) + interior_currentpos.y
            local pz = dz * (-interior_distance) + interior_currentpos.z

            --right
            local rx = math.cos((interior_heading + 90) * DEGREES)
            local ry = 0
            local rz = math.sin((interior_heading + 90) * DEGREES)

            --up
            local ux, uy, uz = dy * rz - dz * ry,
                dz * rx - dx * rz,
                dx * ry - dy * rx

            TheSim:SetCameraPos(px, py, pz)
            TheSim:SetCameraDir(dx, dy, dz)
            TheSim:SetCameraUp(ux, uy, uz)
            TheSim:SetCameraFOV(interior_fov)

            --listen dist
            local lx = 0.5 * dx * (-interior_distance * .1) + interior_currentpos.x
            local ly = 0.5 * dy * (-interior_distance * .1) + interior_currentpos.y
            local lz = 0.5 * dz * (-interior_distance * .1) + interior_currentpos.z

            -- if self.followPlayer then
            --     local target = Vector3(ThePlayer.Transform:GetWorldPosition())
            --     local source = Vector3(px,py,pz)
            --     local dir = target - source	
            --     dir:Normalize()
            --     local pos = target - dir * self.distance * 0.1
            --     lx,ly,lz = pos.x,pos.y,pos.z
            -- end
            TheSim:SetListener(lx, ly, lz, dx, dy, dz, ux, uy, uz)
        else
            Old_Apply(self)
        end
    end
end)

-- can't open map in interior
AddClassPostConstruct("widgets/controls",
    function(self)
        local old_ShowMap = self.ShowMap
        function self:ShowMap(world_position)
            local interiormanager = TheWorld ~= nil and TheWorld.components.zskb_interiormanager or nil
            if interiormanager ~= nil and interiormanager:IsPointInRoom(world_position) then
                return
            end
            return old_ShowMap and old_ShowMap(self, world_position)
        end

        local old_ToggleMap = self.ToggleMap
        function self:ToggleMap()
            local interiormanager = TheWorld ~= nil and TheWorld.components.zskb_interiormanager or nil
            if self.owner ~= nil and self.owner.HUD ~= nil and not self.owner.HUD:IsMapScreenOpen()
                and interiormanager ~= nil and interiormanager:IsPointInRoom(self.owner:GetPosition()) then
                return
            end
            return old_ToggleMap and old_ToggleMap(self)
        end
    end)

------------------- INTERIOR BIRDSPAWNER -----------------------------
-- dont spawn birds in interior rooms
AddComponentPostInit("birdspawner", function(self)
    local old_GetSpawnPoint = self.GetSpawnPoint
    self.GetSpawnPoint = function(self, pt, ...) -- it's a Vector3 input
        local interiormanager = TheWorld ~= nil and TheWorld.components.zskb_interiormanager
        return not (interiormanager ~= nil and interiormanager:IsPointInRoom(pt)) and old_GetSpawnPoint(self, pt, ...) or nil
    end
end)

--------------------------------------------------------------------


AddPrefabPostInit("world", function(world)
    AddInteriorManager(world)

    if not TheWorld.ismastersim then
        return world
    end
    world:DoTaskInTime(0, function(world)
        if GLOBAL.Prefabs.lunarthrall_plant and GLOBAL.Prefabs.lunarthrall_plant.fn then
            local OnRestTask = upvaluehelper.Get(GLOBAL.Prefabs.lunarthrall_plant.fn, "OnRestTask")
            if OnRestTask ~= nil then
                local function newOnRestTask(inst)
                    local x, y, z = inst:GetPosition():Get()
                    local RADIUS = 16 * 1.414
                    local nearby_statue = TheSim:FindEntities(x, y, z, RADIUS, { "zskb_statue" })
                    local has_ql = false
                    for _, state in pairs(nearby_statue) do
                        if state.prefab == "zskb_qinglong" then
                            if inst.resttask ~= nil then
                                inst.resttask:Cancel()
                            end
                            inst.resttask = inst:DoTaskInTime(TUNING.LUNARTHRALL_PLANT_REST_TIME + (math.random() * 1), newOnRestTask)

                            has_ql = true
                            break
                        end
                    end
                    if not has_ql then
                        OnRestTask(inst)
                    end
                end
                upvaluehelper.Set(GLOBAL.Prefabs.lunarthrall_plant.fn, "OnRestTask", newOnRestTask)
            end
        end
    end)
end)

AddPrefabPostInit("voidcloth_umbrella", function(inst)
    inst:AddTag("zskb_zombie_umbrella")
end)

AddPrefabPostInit("multiplayer_portal", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    local oldOnSave = inst.OnSave
    local oldOnLoad = inst.OnLoad
    inst.OnSave = function(inst, data)
        if oldOnSave ~= nil then oldOnSave(inst, data) end
        data.zskb_spawn_spring_roll = inst.zskb_spawn_spring_roll or false
    end
    inst.OnLoad = function(inst, data)
        if oldOnLoad ~= nil then oldOnLoad(inst, data) end
        if data ~= nil then
            inst.zskb_spawn_spring_roll = data.zskb_spawn_spring_roll or false
        end

        if not inst.zskb_spawn_spring_roll then
            local pt = inst:GetPosition()
            local theta = math.random() * 2 * PI
            local radius = math.floor(math.random(4, 8))
            pt.x = pt.x + math.cos(theta) * radius
            pt.z = pt.z + math.sin(theta) * radius
            SpawnPrefab("zskb_vegetable_spring_roll").Transform:SetPosition(pt.x, pt.y, pt.z)

            inst.zskb_spawn_spring_roll = true
        end
    end
end)


local function networkpostinit(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    local oldOnSave = inst.OnSave
    local oldOnLoad = inst.OnLoad
    inst.OnSave = function(inst, data)
        if oldOnSave ~= nil then oldOnSave(inst, data) end
        data.zskb_paper_exist = inst.zskb_paper_exist or false
    end
    inst.OnLoad = function(inst, data)
        if oldOnLoad ~= nil then oldOnLoad(inst, data) end
        inst.zskb_paper_exist = data.zskb_paper_exist or false
    end
end
AddPrefabPostInit("forest_network", networkpostinit)
AddPrefabPostInit("cave_network", networkpostinit)

----------------------------
--[[背后灵相关的hook代码]] --
----------------------------
--给可装备组件添加一个 restrictedtag_inverse 参数，玩家身上有一个 tag=restrictedtag_inverse 则不可以穿戴该装备
local function EquippablePostInit(self)
    self.restrictedtag_inverse = nil

    local _OldIsRestricted = self.IsRestricted

    function self:IsRestricted(target)
        if self.restrictedtag_inverse ~= nil then
            if target:HasTag(self.restrictedtag_inverse) then
                return true
            end
        end
        return _OldIsRestricted(self, target)
    end
end
AddComponentPostInit("equippable", EquippablePostInit)

--给身体栏装备添加 equippable.restrictedtag_inverse = "cannot_equip_body"
local function AddRestrictionToBodyEquippables(inst)
    if inst.components.equippable ~= nil and (inst.components.equippable.equipslot == EQUIPSLOTS.BODY or inst.components.equippable.equipslot == EQUIPSLOTS.BACK or inst.components.equippable.equipslot == EQUIPSLOTS.NECK) then
        inst.components.equippable.restrictedtag_inverse = "cannot_equip_body"
    end
end
AddPrefabPostInitAny(AddRestrictionToBodyEquippables)

--诅咒组件，添加背后灵诅咒的触发事件
local function CursablePostInit(self)
    local _OldApplyCurse = self.ApplyCurse

    function self:ApplyCurse(item, curse)
        _OldApplyCurse(self, item, curse)
        curse = item.components.curseditem.curse
        if curse == "ZSKB" then
            SpawnPrefab("monkey_morphin_power_players_fx").entity:SetParent(self.inst.entity)
            self.inst:AddComponent("zskb_blockbodyequip")
            self.inst:AddTag("cannot_equip_body")
        end
    end
end
AddComponentPostInit("cursable", CursablePostInit)

------------------------------------------------------------------------
--[[给所有玩家添加 _underzskbleafcanopy(在榕树下)变量,检测是否在榕树下]] --
------------------------------------------------------------------------
local function ZskbOnChangeCanopyZone(inst, underleaves)
    inst._underzskbleafcanopy:set(underleaves)
end
--------------------
--[[死鱼正口事件]] --
--------------------
local function OnFishingCollect(inst, data)
    --获取玩家组件
    if inst.components.zskb_zombie_threefire ~= nil and inst.components.zskb_zombie_threefire:GetCurrent() < 3 then
        --玩家三火值小于3时有概率触发死鱼正口事件
        local chance = 0.8 --80%的概率触发事件
        if math.random() < chance then
            if not inst._triggered_dead_fish_event then
                -- 第一次触发，生成2-3条死鱼
                local num_fish = math.random(2, 3)
                for i = 1, num_fish do
                    local pos = inst:GetPosition()
                    local offset = Vector3(math.random(-3, 3), 0, math.random(-3, 3))
                    local fx = SpawnPrefab("sand_puff") --生成特效
                    local fish = SpawnPrefab("fish")    --生成死鱼
                    fx.Transform:SetPosition((pos + offset):Get())
                    fish.Transform:SetPosition((pos + offset):Get())
                end
                --标记已触发死鱼事件
                inst._triggered_dead_fish_event = true
            else
                --再次触发，生成1-2只水猴子
                local num_monkeys = math.random(1, 2)
                for i = 1, num_monkeys do
                    local pos = inst:GetPosition()
                    local offset = Vector3(math.random(-3, 3), 0, math.random(-3, 3))
                    local fx = SpawnPrefab("sand_puff")               --生成特效
                    local water_kiki = SpawnPrefab("zskb_water_kiki") --生成水猴子
                    fx.Transform:SetPosition((pos + offset):Get())
                    water_kiki.Transform:SetPosition((pos + offset):Get())
                end
                inst._triggered_dead_fish_event = false
            end
        end
    end
end
local function PlayerHook(inst)
    --给玩家添加 _underzskbleafcanopy 变量
    inst._underzskbleafcanopy = net_bool(inst.GUID, "localplayer._underzskbleafcanopy", "underzskbleafcanopydirty")
    if not TheWorld.ismastersim then
        return inst
    end
    inst:ListenForEvent("zskbonchangecanopyzone", ZskbOnChangeCanopyZone)

    --监听玩家的 fishingcollect 事件
    inst:ListenForEvent("fishingcollect", OnFishingCollect)

    --这里顺便给全部玩家添加三火值组件
    if inst.components.zskb_zombie_threefire == nil then
        inst:AddComponent("zskb_zombie_threefire")
    end
end
AddPlayerPostInit(PlayerHook)

------------------------------
--[[猪王交易相关的hook代码]] --
------------------------------
local Toy_table =
{
    "zskb_broken_pages1",
    "zskb_broken_pages2",
    "zskb_broken_pages3",
    "zskb_bell",
    "zskb_blessing",
    "zskb_bull_head_statue",
    "zskb_comb",
    "zskb_embroidered_shoes",
    "zskb_hydrangea",
    "zskb_ingot",
    "zskb_reel",
    "zskb_scissors",
}
--照搬猪王代码里的公式函数
local function launchitem(item, angle)
    local speed = math.random() * 4 + 2
    angle = (angle + math.random() * 60 - 30) * DEGREES
    item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle))
end
--给予中式恐怖专属玩具得到铜钱，给予铜钱得到任意中式恐怖专属玩具
local function ontrade(inst, item, giver)
    local x, y, z = inst.Transform:GetWorldPosition()
    y = 4.5

    local angle
    if giver ~= nil and giver:IsValid() then
        angle = 180 - giver:GetAngleToPoint(x, 0, z)
    else
        local down = TheCamera:GetDownVec()
        angle = math.atan2(down.z, down.x) / DEGREES
        giver = nil
    end

    if item.components.tradable.coppercoin ~= nil then
        for k = 1, item.components.tradable.coppercoin do
            local nug = SpawnPrefab("zskb_copper_coin")
            nug.Transform:SetPosition(x, y, z)
            launchitem(nug, angle)
        end
    elseif item.components.tradable.zskbtoy ~= nil then
        local num = math.random(12)
        local toy = SpawnPrefab(Toy_table[num])
        toy.Transform:SetPosition(x, y, z)
        launchitem(toy, angle)
    end
end
local function HookPigking(inst)
    local old_test = inst.components.trader.test
    local old_OnGetItemFromPlayer = inst.components.trader.onaccept
    local function AcceptTest(inst, item, giver)
        if item.prefab == "zskb_copper_coin" or item:HasTag("zskb_toy") then
            return true
        end
        return old_test(inst, item, giver)
    end
    local function OnGetItemFromPlayer(inst, giver, item)
        old_OnGetItemFromPlayer(inst, giver, item)
        if item.prefab == "zskb_copper_coin" or item:HasTag("zskb_toy") then
            inst.sg:GoToState("cointoss")
            inst:DoTaskInTime(2 / 3, ontrade, item, giver)
        end
    end
    inst.components.trader:SetAcceptTest(AcceptTest)
    inst.components.trader.onaccept = OnGetItemFromPlayer
end
AddPrefabPostInit("pigking", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    HookPigking(inst)
end)

-----------------------------------
--[[挖坟额外获得一个模组专属玩具]] --
-----------------------------------
local function HookMound(inst)
    local old_onfinish = inst.components.workable.onfinish
    local function onfinishcallback(inst, worker)
        old_onfinish(inst, worker)
        inst.components.lootdropper:SpawnLootPrefab(Toy_table[math.random(12)])
        if worker ~= nil and worker.components.zskb_zombie_threefire ~= nil and math.random() < 0.2 then
            worker.components.zskb_zombie_threefire:DoDelta(-1)
        end
    end
    inst.components.workable:SetOnFinishCallback(onfinishcallback)
end
AddPrefabPostInit("mound", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    HookMound(inst)
end)

----------------------------------------------------------------------
--[[ 重写小木牌(插在地上的)的绘图机制，让小木牌可以画上本mod里的物品 ]] --
----------------------------------------------------------------------
local invPrefabList = require("zskb_minisign_list") --mod中有物品栏图片的prefabs的表
local invBuildMaps = { "zskb_minisign1", "zskb_minisign2" }
local function OnDrawn_minisign(inst, image, src, atlas, bgimage, bgatlas, ...) --这里image是所用图片的名字，而非prefab的名字
    if inst.drawable_ondrawnfn_zskb ~= nil then
        inst.drawable_ondrawnfn_zskb(inst, image, src, atlas, bgimage, bgatlas, ...)
    end
    --src在重载后就没了，所以没法让信息存在src里
    if image ~= nil and invPrefabList[image] ~= nil then
        inst.AnimState:OverrideSymbol("SWAP_SIGN", invBuildMaps[invPrefabList[image]] or invBuildMaps[1], image)
    end
    if bgimage ~= nil and invPrefabList[bgimage] ~= nil then
        inst.AnimState:OverrideSymbol("SWAP_SIGN_BG", invBuildMaps[invPrefabList[bgimage]] or invBuildMaps[1], bgimage)
    end
end
local function MiniSign_init(inst)
    if inst.drawable_ondrawnfn_zskb == nil and inst.components.drawable ~= nil then
        inst.drawable_ondrawnfn_zskb = inst.components.drawable.ondrawnfn
        inst.components.drawable:SetOnDrawnFn(OnDrawn_minisign)
    end
end
AddPrefabPostInit("minisign", MiniSign_init)
AddPrefabPostInit("minisign_drawn", MiniSign_init)
AddPrefabPostInit("decor_pictureframe", MiniSign_init)

--------------------------------------------
--[[ 高清256*256贴图兼容棱镜的白木展示柜 ]] --
--------------------------------------------
local function Zskb_SetShowSlot(inst, slot)
    local item = inst.components.container.slots[slot]
    if item ~= nil then
        local bgimage
        local image = FunctionOrValue(item.drawimageoverride, item, inst) or (#(item.components.inventoryitem.imagename or "") > 0 and item.components.inventoryitem.imagename) or item.prefab or nil
        if image ~= nil then
            if item.inv_image_bg ~= nil and item.inv_image_bg.image ~= nil and item.inv_image_bg.image:len() > 4 and item.inv_image_bg.image:sub(-4):lower() == ".tex" then
                bgimage = item.inv_image_bg.image:sub(1, -5)
            end
            if invPrefabList[image] ~= nil then
                inst.AnimState:ClearOverrideSymbol("slot" .. tostring(slot))
                inst.AnimState:OverrideSymbol("slot" .. tostring(slot), invBuildMaps[invPrefabList[image]] or invBuildMaps[1], image)
            end
            if bgimage ~= nil then
                if invPrefabList[bgimage] ~= nil then
                    inst.AnimState:ClearOverrideSymbol("slotbg" .. tostring(slot))
                    inst.AnimState:OverrideSymbol("slotbg" .. tostring(slot), invBuildMaps[invPrefabList[bgimage]] or invBuildMaps[1], bgimage)
                end
            end
        end
    end
end
local function Zskb_ItemGet_chest(inst, data)
    if data and data.slot and data.slot <= inst.shownum_l then
        Zskb_SetShowSlot(inst, data.slot)
    end
end
local function HookWhitewood(inst)
    if not TheWorld.ismastersim then
        return
    end
    local old_onclosefn = inst.components.container.onclosefn
    local function OnClose_chest(inst)
        old_onclosefn(inst)
        if not inst:HasTag("burnt") then
            for i = 1, inst.shownum_l, 1 do
                Zskb_SetShowSlot(inst, i)
            end
        end
    end
    inst.components.container.onclosefn = OnClose_chest
    inst:ListenForEvent("itemget", Zskb_ItemGet_chest)
end
if _G.ZSKB_SETS.ENABLEDMODS["legion"] then
    AddPrefabPostInit("chest_whitewood", HookWhitewood)
    AddPrefabPostInit("chest_whitewood_inf", HookWhitewood)
    AddPrefabPostInit("chest_whitewood_big", HookWhitewood)
    AddPrefabPostInit("chest_whitewood_big_inf", HookWhitewood)
end

----------------------------------
--[[ 耕地土堆可以种植榕树树种 ]] --
----------------------------------
local function OnUseHeavy(inst, doer, heavy_item)
    if heavy_item == nil then
        return
    end

    doer.components.inventory:RemoveItem(heavy_item)
    local x, y, z = inst.Transform:GetWorldPosition()
    local tree = SpawnPrefab("zskb_banyantree_short")
    tree.Transform:SetPosition(x, y, z)
    inst:Remove()

    return true
end
--关于客户端鼠标上动作可否交互的相关代码。Gyde：这逻辑写起来真的有够费劲的，真就全是硬骨头，牙都要啃没了
local function IsLowPriorityAction(act)
    return act == nil or act.action ~= ACTIONS.ZSKB_PLANT
end
local function HookFarmSoil(inst)
    if not inst:HasTag("can_use_heavy") then
        inst:AddTag("can_use_heavy")
    end
    local old_CanMouseThrough = inst.CanMouseThrough
    inst.CanMouseThrough = function(inst, ...)
        if ThePlayer ~= nil and ThePlayer.components.playeractionpicker ~= nil then
            local heavy_item = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
            if heavy_item ~= nil and heavy_item.prefab == "zskb_banyantreenut" then
                local lmb, rmb = ThePlayer.components.playeractionpicker:DoGetMouseActions(inst:GetPosition(), inst)
                return IsLowPriorityAction(rmb) and IsLowPriorityAction(lmb), true
            end
        end
        return old_CanMouseThrough(inst, ...)
    end
    if not TheWorld.ismastersim then
        return
    end
    inst:AddComponent("zskb_plant")
    inst.components.zskb_plant.on_use_fn = OnUseHeavy
end
AddPrefabPostInit("farm_soil", HookFarmSoil)

-----------------------------------------
--[[ 夜晚玩家靠近坟墓会在身边生成鬼火 ]] --
-----------------------------------------
local CHANCE_TO_SPAWN = 0.2 --概率，20%
local GHOSTFIRE_PREFAB = "zskb_ghostfire" --鬼火预制体名称
local MOUND_TAG = "grave" --坟墓的 Tag
local CHECK_RADIUS = 5 --检测半径

--判断玩家是否在坟墓范围内并生成鬼火
local function CheckForGhostFireSpawn(inst)
    if TheWorld.state.isnight then                                               --仅夜晚触发
        local x, y, z = inst.Transform:GetWorldPosition()
        local mounds = TheSim:FindEntities(x, y, z, CHECK_RADIUS, { MOUND_TAG }) --查找范围内的坟墓

        if #mounds > 0 and math.random() < CHANCE_TO_SPAWN then
            --在玩家附近生成鬼火
            local angle = math.random() * 2 * math.pi --随机角度
            local spawn_x = x + math.cos(angle) * 2
            local spawn_z = z + math.sin(angle) * 2

            local ghostfire = SpawnPrefab(GHOSTFIRE_PREFAB)
            if ghostfire then
                ghostfire.Transform:SetPosition(spawn_x, 0, spawn_z)
            end
        end
    end
end

--夜晚开始时启用检测，白天停止
local function StartGhostFireCheck(inst)
    if inst._checkghosttask == nil then
        inst._checkghosttask = inst:DoPeriodicTask(1, CheckForGhostFireSpawn) --每1秒检测一次
    end
end

local function StopGhostFireCheck(inst)
    if inst._checkghosttask ~= nil then
        inst._checkghosttask:Cancel()
        inst._checkghosttask = nil
    end
end

--Hook 玩家，监听昼夜变化
local function AddGhostFireMechanismToPlayer(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:WatchWorldState("isnight", function() StartGhostFireCheck(inst) end)
    inst:WatchWorldState("isday", function() StopGhostFireCheck(inst) end)

    if TheWorld.state.isnight then
        StartGhostFireCheck(inst)
    end
end

AddPlayerPostInit(AddGhostFireMechanismToPlayer)

-----------------------------------
--[[ 犬牙吹箭识别mod的装填射弹 ]] --
-----------------------------------
local function AmmoLoaded(inst)
    if not TheWorld.ismastersim then
        return
    end
    local old_OnAmmoLoaded = inst.OnAmmoLoaded
    inst.OnAmmoLoaded = function(inst, data)
        old_OnAmmoLoaded(inst, data)
        if data ~= nil and data.item.prefab == "zskb_coffin_nail" then
            inst.components.weapon:SetProjectile(nil)
            inst.components.weapon:SetProjectile("zskb_coffin_nail_proj")
        end
    end
    inst:ListenForEvent("itemget", inst.OnAmmoLoaded)
end
AddPrefabPostInit("houndstooth_blowpipe", AmmoLoaded)

---------------------------------------------------------
--[[ 玩家携带鬼火会得到-10/min的降san光环(写的不一定完美) ]] --
---------------------------------------------------------
local function HasGhostfireInInventoryFor_Checker(item)
    return item:HasTag("zskb_ghostfire")
end

--该函数参考了"玩家身上是否携带肉"的代码
local function HasGhostfireInInventoryFor(inst)
    local inventory = inst.components.inventory
    if inventory == nil then
        return false
    end
    return inventory:FindItem(HasGhostfireInInventoryFor_Checker) ~= nil
end

local function AddSanityDrainAura(inst)
    if inst.components.sanity == nil then
        return
    end

    local function CheckGhostFire(inst, data)
        --判断得到失去的物品是否是鬼火，若不是就跳过(减少性能损耗。。也许吧)
        local prefab_name = nil
        if data.item ~= nil then
            prefab_name = data.item.prefab
        elseif data.prev_item ~= nil then
            prefab_name = data.prev_item.prefab
        end
        if prefab_name ~= "zskb_ghostfire" then
            return
        end

        --判断身上是否还有鬼火
        local has_ghostfire = false
        has_ghostfire = HasGhostfireInInventoryFor(inst)

        if has_ghostfire then
            inst.components.sanity.externalmodifiers:SetModifier("sanity_drain_zskb", -1 / 6, "zskb_ghostfire")
        else
            inst.components.sanity.externalmodifiers:RemoveModifier("sanity_drain_zskb", "zskb_ghostfire")
        end
    end

    --监听物品栏得到，失去物品
    inst:ListenForEvent("itemget", CheckGhostFire)
    inst:ListenForEvent("itemlose", CheckGhostFire)
end

AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return
    end
    AddSanityDrainAura(inst)
end)
