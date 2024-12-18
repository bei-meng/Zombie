--[[
	cooktime: 在普通锅里1为20s，2为40s，依此类推。厨师锅做饭是普通锅耗时的0.8倍，如果用厨师锅，1为18s，2为36s，依此类推。
]]

local foods =
{
	-- 素春卷
	zskb_vegetable_spring_roll =
	{
		test = function(cooker, names, tags) return tags.egg and tags.egg >= 1 and tags.veggie and tags.veggie >= 1 and not tags.meat end,
		priority = 8,
		weight = 1,
		foodtype = FOODTYPE.VEGGIE,
		health = 40,
		hunger = 20,
		sanity = 30,
		perishtime = TUNING.PERISH_PRESERVED,
		cooktime = 1,
		floater = { "small", 0.05, 0.7 },
		card_def = { ingredients = { { "bird_egg", 1 }, { "carrot", 3 } } },
		oneatenfn = function(inst, eater)
			if eater:HasTag("player") then
				if not TheWorld.net.zskb_paper_exist then
					TheWorld.net.zskb_paper_exist = true
					LaunchAt(SpawnPrefab("zskb_paper"), eater, nil, 1, 1)
				end
			end
		end
	},
	-- 腊味煲仔饭
	zskb_cured_meat_rice =
	{
		test = function(cooker, names, tags) return names.zskb_sausage_dried and names.zskb_sausage_dried >= 2 and tags.veggie and tags.veggie >= 1 and not tags.inedible end,
		priority = 30,
		weight = 1,
		foodtype = FOODTYPE.MEAT,
		health = 60,
		hunger = 100,
		sanity = 60,
		perishtime = TUNING.PERISH_MED,
		cooktime = 2,
		floater = { "small", 0.05, 0.7 },
		card_def = { ingredients = { { "zskb_sausage_dried", 2 }, { "carrot", 2 } } },
	},
	-- 烤鸭
	zskb_roast_duck =
	{
		test = function(cooker, names, tags)
			return
				((names.drumstick and names.drumstick >= 3) or
					(names.drumstick_cooked and names.drumstick_cooked >= 3) or
					((names.drumstick and names.drumstick_cooked and names.drumstick + names.drumstick_cooked >= 3))) and
				((tags.fruit and tags.fruit >= 1) or (tags.veggie and tags.veggie >= 1))
		end,
		priority = 10,
		weight = 1,
		foodtype = FOODTYPE.MEAT,
		health = 20,
		hunger = 100,
		sanity = 40,
		perishtime = TUNING.PERISH_SLOW,
		cooktime = 2,
		floater = { "small", 0.05, 0.7 },
		card_def = { ingredients = { { "drumstick", 3 }, { "carrot", 1 } } },
	},
	-- 寿桃馒头
	zskb_peach_steam_bun =
	{
		test = function(cooker, names, tags) return tags.sweetener and tags.sweetener >= 1 and ((tags.fruit and tags.fruit > 1) or (tags.veggie and tags.veggie > 1)) and not tags.inedible end,
		priority = 10,
		weight = 1,
		foodtype = FOODTYPE.GOODIES,
		health = 10,
		hunger = 30,
		sanity = 0,
		perishtime = TUNING.PERISH_PRESERVED,
		cooktime = 2,
		floater = { "small", 0.05, 0.7 },
		card_def = { ingredients = { { "honey", 1 }, { "carrot", 3 } } },
		oneatenfn = function(inst, eater)
			if eater.components.zskb_zombie_threefire ~= nil then
				eater.components.zskb_zombie_threefire:DoDelta(1)
			end
		end
	},
	-- 兔子馒头
	zskb_rabbit_steam_bun =
	{
		test = function(cooker, names, tags) return ((names.pumpkin and names.pumpkin >= 1) or (names.pumpkin_cooked and names.pumpkin_cooked >= 1)) and tags.sweetener and tags.sweetener > 1 and not tags.inedible end,
		priority = 10,
		weight = 1,
		foodtype = FOODTYPE.GOODIES,
		health = 10,
		hunger = 30,
		sanity = 30,
		perishtime = TUNING.PERISH_SLOW,
		cooktime = 2,
		floater = { "small", 0.05, 0.7 },
		card_def = { ingredients = { { "pumpkin", 1 }, { "honey", 3 } } },
	},
}

for k, v in pairs(foods) do
	v.name = k
	v.basename = k
	v.weight = v.weight or 1
	v.priority = v.priority or 0

	v.cookbook_category = "cookpot"
	v.overridebuild = "zskb_cook_pot_food"

	v.mod = "zskb"

	--烹饪指南里的料理贴图
	if v.cookbook_atlas == nil then
		v.cookbook_atlas = "images/cookbook_images/" .. k .. ".xml"
	end
	if v.cookbook_tex == nil then
		v.cookbook_tex = "" .. k .. ".tex" --一定不要填写完整路径，因为xml文件已经指定好了
	end
end

return foods
