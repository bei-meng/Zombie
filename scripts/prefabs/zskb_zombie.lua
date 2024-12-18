local MakePlayerCharacter = require "prefabs/player_common"


local assets = {
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}
local prefabs = {}

-- 初始物品
local start_inv = {
	"zskb_rune_paper_umbrella",
	"zskb_return_life_pill",
	"zskb_return_life_pill",
}
-- 当人物复活的时候
local function onbecamehuman(inst)
	-- 设置人物的移速（1表示1倍于wilson）
	-- inst.components.locomotor:SetExternalSpeedMultiplier(inst, "zskb_zombie_speed_mod", 1)
end
--当人物死亡的时候
local function onbecameghost(inst)
	-- 变成鬼魂的时候移除速度修正
	--    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "zskb_zombie_speed_mod")
end

local function onsave(inst, data)
	data.max_health = inst.components.health.maxhealth
	data.max_sanity = inst.components.sanity.max
	data.max_hunger = inst.components.hunger.max
end

-- 重载游戏或者生成一个玩家的时候
local function onload(inst, data)
	if data == nil then
		return
	end
	if data.max_health then
		local percent = inst.components.health:GetPercent()
		inst.components.health.maxhealth = data.max_health
		inst.components.health:SetPercent(percent)

		local badgedelta = 0.01
		inst.components.health:DoDelta(badgedelta, false, nil, true)
	end

	if data.max_sanity then
		local percent = inst.components.sanity:GetPercent()
		inst.components.sanity.max = data.max_sanity
		inst.components.sanity:SetPercent(percent)
	end

	if data.max_hunger then
		local percent = inst.components.hunger:GetPercent()
		inst.components.hunger.max = data.max_hunger
		inst.components.hunger:SetPercent(percent)
	end
end

local function on_zombie_gas_delta(inst, data)
	local percent = data.percent
	if percent < 0.25 then
		inst.components.locomotor:SetExternalSpeedMultiplier(inst, "zombie_gas", 1.05)
	elseif percent >= 0.25 and percent < 0.75 then
		inst.components.locomotor:SetExternalSpeedMultiplier(inst, "zombie_gas", 1.15)
		inst.components.health.externalabsorbmodifiers:SetModifier(inst, 0.05)
	elseif percent >= 0.75 then
		inst.components.locomotor:SetExternalSpeedMultiplier(inst, "zombie_gas", 1.25)
		inst.components.health.externalabsorbmodifiers:SetModifier(inst, 0.10)
	end
end
local function oneat(inst, data)
	local food = data.food
	if inst.components.zskb_zombie_gas then
		local foodtype = food.components.edible.foodtype
		if foodtype == FOODTYPE.MEAT then
			inst.components.zskb_zombie_gas:DoDelta(10, nil, false, true)
		end
	end
end

local RADIUS = 10
local last_spawntime = nil
local function spawnghost(inst, num, max)
	if not inst.components.health:IsDead() then
		local x, y, z = inst:GetPosition():Get()
		local nearby_ghosts = TheSim:FindEntities(x, y, z, RADIUS, { "ghost" })
		if nearby_ghosts ~= nil and #nearby_ghosts < max then
			for i = 1, math.min(num, max - #nearby_ghosts) do
				local nearpos = FindNearbyLand(inst:GetPosition(), RADIUS)
				if nearpos ~= nil then
					local ghost = SpawnPrefab("ghost")
					ghost.Transform:SetPosition(nearpos:Get())
					ghost.components.combat:SuggestTarget(inst)
				end
			end
			local time = GetTime()
			if last_spawntime then
				-- print("Spawn Ghost", time - last_spawntime)
			end
			last_spawntime = time
		end
	end
end
local function timerdone(inst, data)
	if data == nil then return end
	local current = inst.components.zskb_zombie_threefire:GetCurrent()
	if data.name == "threefire2" then
		if current < 1 then
			spawnghost(inst, math.random(2, 3), 3)
		end
		inst.components.timer:StartTimer("threefire2", 120)
	elseif data.name == "threefire4" then
		if current < 2 and current >= 1 then
			spawnghost(inst, math.random(1, 2), 2)
		end
		inst.components.timer:StartTimer("threefire4", 240)
	elseif data.name == "threefire6" then
		if current < 3 and current >= 2 then
			spawnghost(inst, 1, 1)
		end
		inst.components.timer:StartTimer("threefire6", 360)
	end
end

local NIGHTVISIONMODULE_GRUEIMMUNITY_NAME = "zskb_zombie_nightvision"
local function SetForcedNightVision(inst, nightvision_on)
	inst._forced_nightvision:set(nightvision_on)
	if inst.components.playervision ~= nil then
		inst.components.playervision:ForceNightVision(nightvision_on)
	end

	-- The nightvision event might get consumed during save/loading,
	-- so push an extra custom immunity into the table.
	if nightvision_on then
		inst.components.grue:AddImmunity(NIGHTVISIONMODULE_GRUEIMMUNITY_NAME)
	else
		inst.components.grue:RemoveImmunity(NIGHTVISIONMODULE_GRUEIMMUNITY_NAME)
	end
end

local function OnForcedNightVisionDirty(inst)
	if inst.components.playervision ~= nil then
		inst.components.playervision:ForceNightVision(inst._forced_nightvision:value())
	end
end

local function nightvision_onworldstateupdate(inst)
	inst:SetForcedNightVision(TheWorld.state.isnight and not TheWorld.state.isfullmoon)
	inst.components.zskb_zombie:SetCanNightVision(TheWorld.state.isnight and not TheWorld.state.isfullmoon) -- show the UI
	--print("Night Vision" .. (TheWorld.state.isnight and not TheWorld.state.isfullmoon and "ON" or "OFF"))
end

local function custom_stats_mod_fn(inst, health_delta, hunger_delta, sanity_delta, food, feeder)
	if food.components.edible.foodtype == FOODTYPE.MEAT then
		return health_delta, hunger_delta, sanity_delta and math.max(0, sanity_delta) or sanity_delta
	elseif food.components.edible.foodtype == FOODTYPE.VEGGIE then
		return health_delta and health_delta > 0 and health_delta / 2 or health_delta, hunger_delta and hunger_delta > 0 and hunger_delta / 2 or hunger_delta, sanity_delta
	end
	return health_delta, hunger_delta, sanity_delta
end

local function IsPointInRoom(inst)
	local interiormanager = TheWorld ~= nil and TheWorld.components.zskb_interiormanager or nil
	if interiormanager ~= nil and interiormanager:IsPointInRoom(inst:GetPosition()) then
		return true
	end
end

local function ondeath(inst)
	if inst.components.zskb_zombie_gas then
		inst.components.zskb_zombie_gas:DoDelta(-inst.components.zskb_zombie_gas.current, nil, false, true)
	end
	-- inst.components.health.maxhealth = TUNING.ZSKB_ZOMBIE_HEALTH
	-- inst.components.hunger.max = TUNING.ZSKB_ZOMBIE_HUNGER
	-- inst.components.sanity.max = TUNING.ZSKB_ZOMBIE_SANITY

	inst.components.zskb_zombie:SetCanNightVision(false)
	inst.components.zskb_zombie:SetCanRainControl(false)
end

local function onresurrection(inst)
	nightvision_onworldstateupdate(inst)
	local health, sanity, hunger = inst.components.health, inst.components.sanity, inst.components.hunger
	if (health == nil or health.maxhealth >= 275) and (sanity == nil or sanity.max >= 250) and (hunger == nil or hunger.max >= 200) then
		inst.components.zskb_zombie:SetCanRainControl(true)
	end
end

local function onhitotherfn(attacker, inst, damage, stimuli, weapon, damageresolved)
	local percent = attacker.components.health:GetPercent()
	local equip_bead = attacker.components.inventory:EquipHasTag("zskb_bead")
	local equip_mask = attacker.components.inventory:EquipHasTag("zskb_black_copper_coin_mask")
	local equip_umbrella = attacker.components.inventory:EquipHasTag("zskb_copper_coin_umbrella_close")

	local has_suit = equip_bead and equip_mask and equip_umbrella

	local vampirism = 0
	if percent < 0.25 then
		vampirism = has_suit and damage * 0.16 or 2 + math.random()
	elseif percent >= 0.25 and percent < 0.5 then
		vampirism = has_suit and damage * 0.14 or 1 + math.random()
	elseif percent >= 0.5 and percent < 0.75 then
		vampirism = has_suit and damage * 0.12 or 1 + math.random()
	elseif percent >= 0.75 then
		vampirism = has_suit and damage * 0.1 or math.random()
	end
	attacker.components.health:DoDelta(vampirism, false, "zskb_zombie_gas")

	if attacker.components.zskb_zombie_gas:GetPercent() > 0 and
		inst and inst:IsValid() and not inst:HasTag("zskb_zombie") and inst.components.health and not inst.components.health:IsDead() then
		if not inst.components.debuffable then
			inst:AddComponent("debuffable")
		end
		--if inst.components.debuffable:HasDebuff("zskb_buff_ptomaine") then
		--	inst.components.debuffable:RemoveDebuff("zskb_buff_ptomaine")
		--end
		--inst.components.debuffable:AddDebuff("zskb_buff_ptomaine") -- add or extend
		--local _damage = -10
		-- if attacker.components.inventory:EquipHasTag("zskb_black_copper_coin_mask") then
		-- 	_damage = _damage - 5
		-- end

		local buff = inst.components.debuffable:GetDebuff("zskb_buff_ptomaine")
		if buff ~= nil then
			-- extend time
			buff.components.timer:SetTimeLeft("buffover", 10)
		else -- (dmg_persec 6 ~ 24,  dmgtaken_multip 1.1 ~ 1.6)
			local buff = inst.components.debuffable:AddDebuff("zskb_buff_ptomaine", "zskb_buff_ptomaine",
				{ frequency = 1, duration = 10, dmg_perlevel = -6, multipl_perlevel = .15, levelup_time = 5, maxlevel = 4 })
			buff.components.timer:SetTimeLeft("buffover", 10)
		end
	end
end

local function OnLightningStrike(inst)
	if inst.components.health ~= nil and not (inst.components.health:IsDead() or inst.components.health:IsInvincible()) then
		if inst.components.inventory:IsInsulated() then
			inst:PushEvent("lightningdamageavoided")
		else
			inst.components.health:DoDelta(-20, false, "lightning")
		end
	end
end

local function GetEquippableDapperness(owner, equippable)
	return 0.25
end

--这个函数将在服务器和客户端都会执行
--一般用于添加小地图标签等动画文件或者需要主客机都执行的组件（少数）
local common_postinit = function(inst)
	-- Minimap icon
	inst.MiniMapEntity:SetIcon("zskb_zombie.tex")
	inst:AddTag("zskb_zombie")
	inst:AddTag("monster")

	inst._forced_nightvision = net_bool(inst.GUID, "zskb_zombie.forced_nightvision", "forced_nightvision_dirty")

	if not TheNet:IsDedicated() then
		inst:ListenForEvent("forced_nightvision_dirty", OnForcedNightVisionDirty)
		OnForcedNightVisionDirty(inst)
	end
end

-- 这里的的函数只在主机执行  一般组件之类的都写在这里
local master_postinit = function(inst)
	-- 人物音效
	inst.soundsname = "wilson"

	--最喜欢的食物  名字 倍率（1.2）
	inst.components.foodaffinity:AddPrefabAffinity("eel_cooked", TUNING.AFFINITY_15_CALORIES_HUGE)
	-- 三维
	inst.components.health:SetMaxHealth(TUNING.ZSKB_ZOMBIE_HEALTH)
	inst.components.hunger:SetMax(TUNING.ZSKB_ZOMBIE_HUNGER)
	inst.components.sanity:SetMax(TUNING.ZSKB_ZOMBIE_SANITY)

	-- 伤害系数
	inst.components.combat.damagemultiplier = 1
	inst.components.combat.onhitotherfn = onhitotherfn

	-- 饥饿速度
	inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE
	if inst.components.eater ~= nil then
		inst.components.eater.custom_stats_mod_fn = custom_stats_mod_fn
		inst.components.eater:SetStrongStomach(true)
		inst.components.eater:SetCanEatRawMeat(true)
	end

	-- inst.components.sanity.custom_rate_fn = CustomSanityFn
	inst.components.sanity:SetNegativeAuraImmunity(true)
	inst.components.sanity:SetPlayerGhostImmunity(true)
	inst.components.sanity:SetLightDrainImmune(true)
	inst.components.sanity.get_equippable_dappernessfn = GetEquippableDapperness
	inst.components.sanity.only_magic_dapperness = true

	inst.components.playerlightningtarget:SetOnStrikeFn(OnLightningStrike)

	inst:AddComponent("zskb_zombie")
	inst:AddComponent("zskb_zombie_gas")
	inst:AddComponent("zskb_zombie_threefire")
	inst:AddComponent("staffsanity")
	inst.components.staffsanity:SetMultiplier(0.25)

	inst:AddComponent("efficientuser")
	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

	inst.OnSave = onsave
	inst.OnLoad = onload
	inst.OnNewSpawn = onload
	inst.SetForcedNightVision = SetForcedNightVision
	inst.IsPointInRoom = IsPointInRoom

	inst:ListenForEvent("zskb_zombie_gas_delta", on_zombie_gas_delta)
	inst:ListenForEvent("oneat", oneat)

	inst.components.timer:StartTimer("threefire2", 120)
	inst.components.timer:StartTimer("threefire4", 240)
	inst.components.timer:StartTimer("threefire6", 360)
	inst:ListenForEvent("timerdone", timerdone)

	inst:WatchWorldState("isnight", nightvision_onworldstateupdate)
	inst:WatchWorldState("isfullmoon", nightvision_onworldstateupdate)

	inst:ListenForEvent("death", ondeath)
	inst:ListenForEvent("ms_becameghost", ondeath)
	inst:ListenForEvent("ms_respawnedfromghost", onresurrection)

	inst:DoTaskInTime(0, nightvision_onworldstateupdate)
end

return MakePlayerCharacter("zskb_zombie", prefabs, assets, common_postinit, master_postinit, start_inv)
