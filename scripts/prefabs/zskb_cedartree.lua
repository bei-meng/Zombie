local assets = {
	Asset("ANIM", "anim/zskb_cedartree.zip"),
}

local MIN = TUNING.SHADE_CANOPY_RANGE_SMALL
local MAX = MIN + TUNING.WATERTREE_PILLAR_CANOPY_BUFFER

local DROP_ITEMS_DIST_MIN = 6
local DROP_ITEMS_DIST_VARIANCE = 10

local NUM_DROP_SMALL_ITEMS_MIN_LIGHTNING = 3
local NUM_DROP_SMALL_ITEMS_MAX_LIGHTNING = 5

local DROPPED_ITEMS_SPAWN_HEIGHT = 10

local lightningprods =
{
	"twigs",
	"cutgrass",
	"oceantree_leaf_fx_fall",
	"oceantree_leaf_fx_fall",
	"oceantree_leaf_fx_fall",
	"oceantree_leaf_fx_fall",
	"oceantree_leaf_fx_fall",
	"oceantree_leaf_fx_fall",
}

local CANOPY_SHADOW_DATA = require("prefabs/canopyshadows")

-----------------------------------------------------------------------------------
--[[ pickable ]]
-----------------------------------------------------------------------------------
local function onpickedfn(inst, picker)
	inst.AnimState:PlayAnimation("idle")
	if picker ~= nil and picker.components.zskb_zombie_threefire ~= nil then
		picker.components.zskb_zombie_threefire:DoDelta(-1)
	end
end

local function onregenfn(inst)
	inst.AnimState:PlayAnimation("coin")
end

local function makeemptyfn(inst)
end
-----------------------------------------------------------------------------------

local function GetStatus(inst)
	return (inst.components.pickable ~= nil and inst.components.pickable:CanBePicked()) and "COIN" or "NONE"
end
local function OnInit(inst)
	if inst.components.pickable ~= nil and inst.components.pickable:CanBePicked() then
		onregenfn(inst)
	else
		onpickedfn(inst)
	end
end

local function removecanopyshadow(inst)
	if inst.canopy_data ~= nil then
		for _, shadetile_key in ipairs(inst.canopy_data.shadetile_keys) do
			if TheWorld.shadetiles[shadetile_key] ~= nil then
				TheWorld.shadetiles[shadetile_key] = TheWorld.shadetiles[shadetile_key] - 1

				if TheWorld.shadetiles[shadetile_key] <= 0 then
					if TheWorld.shadetile_key_to_leaf_canopy_id[shadetile_key] ~= nil then
						DespawnLeafCanopy(TheWorld.shadetile_key_to_leaf_canopy_id[shadetile_key])
						TheWorld.shadetile_key_to_leaf_canopy_id[shadetile_key] = nil
					end
				end
			end
		end

		for _, ray in ipairs(inst.canopy_data.lightrays) do
			ray:Remove()
		end
	end
end
local function DropLightningItems(inst, items)
	local x, _, z = inst.Transform:GetWorldPosition()
	local num_items = #items

	for i, item_prefab in ipairs(items) do
		local dist = DROP_ITEMS_DIST_MIN + DROP_ITEMS_DIST_VARIANCE * math.random()
		local theta = 2 * PI * math.random()

		inst:DoTaskInTime(i * 5 * FRAMES, function(inst2)
			local item = SpawnPrefab(item_prefab)
			item.Transform:SetPosition(x + dist * math.cos(theta), 20, z + dist * math.sin(theta))

			if i == num_items then
				inst._lightning_drop_task:Cancel()
				inst._lightning_drop_task = nil
			end
		end)
	end
end

local function OnLightningStrike(inst)
	if inst._lightning_drop_task ~= nil then
		return
	end

	local num_small_items = math.random(NUM_DROP_SMALL_ITEMS_MIN_LIGHTNING, NUM_DROP_SMALL_ITEMS_MAX_LIGHTNING)
	local items_to_drop = {}

	for i = 1, num_small_items do
		table.insert(items_to_drop, lightningprods[math.random(1, #lightningprods)])
	end

	inst._lightning_drop_task = inst:DoTaskInTime(20 * FRAMES, DropLightningItems, items_to_drop)
end

local function OnFar(inst, player)
	if player.canopytrees then
		player.canopytrees = player.canopytrees - 1
		player:PushEvent("onchangecanopyzone", player.canopytrees > 0)
	end
	inst.players[player] = nil
end

local function OnNear(inst, player)
	inst.players[player] = true

	player.canopytrees = (player.canopytrees or 0) + 1

	player:PushEvent("onchangecanopyzone", player.canopytrees > 0)
end

local function OnRemoveEntity(inst)
	for player in pairs(inst.players) do
		if player:IsValid() then
			if player.canopytrees then
				OnFar(inst, player)
			end
		end
	end
	local point = inst:GetPosition()
	local oceanvines = TheSim:FindEntities(point.x, point.y, point.z, DROP_ITEMS_DIST_MIN + DROP_ITEMS_DIST_VARIANCE)
	if #oceanvines > 0 then
		for i, ent in ipairs(oceanvines) do
			if ent.prefab == "oceantree_leaf_fx_fall" then
				ent:Remove()
			end
		end
	end

	inst._hascanopy:set(false)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("zskb_cedartree")
	inst.AnimState:SetBuild("zskb_cedartree")
	inst.AnimState:PlayAnimation("idle")

	inst.Transform:SetScale(2.5, 2.5, 2.5)

	inst.MiniMapEntity:SetIcon("zskb_cedartree.tex")
	inst.MiniMapEntity:SetPriority(-1)

	inst:AddTag("noattack")
	inst:AddTag("notarget")
	inst:AddTag("tree")
	inst:AddTag("shadecanopysmall")
	inst:AddTag("antlion_sinkhole_blocker")

	if not TheNet:IsDedicated() then
		inst:AddComponent("distancefade")
		inst.components.distancefade:Setup(15, 25)
	end

	inst._hascanopy = net_bool(inst.GUID, "oceantree_pillar._hascanopy", "hascanopydirty")
	inst._hascanopy:set(true)
	inst:DoTaskInTime(0, function()
		inst.canopy_data = CANOPY_SHADOW_DATA.spawnshadow(inst, math.floor(TUNING.SHADE_CANOPY_RANGE_SMALL / 4), true)
	end)

	inst:ListenForEvent("hascanopydirty", function()
		if not inst._hascanopy:value() then
			removecanopyshadow(inst)
		end
	end)

	MakeObstaclePhysics(inst, 2.35)
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus

	inst:AddComponent("lootdropper")
	inst.components.lootdropper.loot = { "zskb_copper_coin", "zskb_copper_coin", "zskb_copper_coin", "zskb_copper_coin", "zskb_copper_coin" }

	inst:AddComponent("pickable")
	inst.components.pickable:SetUp("zskb_copper_coin", TUNING.TOTAL_DAY_TIME * 10)
	inst.components.pickable.use_lootdropper_for_product = true
	inst.components.pickable.onregenfn = onregenfn
	inst.components.pickable.onpickedfn = onpickedfn
	inst.components.pickable.makeemptyfn = makeemptyfn

	inst.players = {}
	inst:AddComponent("playerprox")
	inst.components.playerprox:SetTargetMode(inst.components.playerprox.TargetModes.AllPlayers)
	inst.components.playerprox:SetDist(MIN, MAX)
	inst.components.playerprox:SetOnPlayerFar(OnFar)
	inst.components.playerprox:SetOnPlayerNear(OnNear)

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(1000)
	inst.components.health:SetInvincible(true)

	inst:AddComponent("lightningblocker")
	inst.components.lightningblocker:SetBlockRange(TUNING.SHADE_CANOPY_RANGE_SMALL)
	inst.components.lightningblocker:SetOnLightningStrike(OnLightningStrike)

	inst:DoTaskInTime(FRAMES, OnInit)

	inst.OnRemoveEntity = OnRemoveEntity
	MakeSnowCovered(inst)
	MakeHauntable(inst)

	return inst
end

return Prefab("zskb_cedartree", fn, assets)
