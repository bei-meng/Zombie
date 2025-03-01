--选人界面人物三维显示
TUNING.ZSKB_ZOMBIE_HEALTH = 175
TUNING.ZSKB_ZOMBIE_HUNGER = 100
TUNING.ZSKB_ZOMBIE_SANITY = 150

TUNING.ZSKB_ZOMBIE_HEALTH_MAX = 275
TUNING.ZSKB_ZOMBIE_HUNGER_MAX = 200
TUNING.ZSKB_ZOMBIE_SANITY_MAX = 250

--选人界面初始物品显示
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.ZSKB_ZOMBIE = { "zskb_rune_paper_umbrella", "zskb_return_life_pill", "zskb_return_life_pill" }
TUNING.STARTING_ITEM_IMAGE_OVERRIDE["zskb_rune_paper_umbrella"] = {
	atlas = "images/zskb_inventoryimages.xml",
	image = "zskb_rune_paper_umbrella.tex",
}
TUNING.STARTING_ITEM_IMAGE_OVERRIDE["zskb_return_life_pill"] = {
	atlas = "images/zskb_inventoryimages.xml",
	image = "zskb_return_life_pill.tex",
}

-- boss
TUNING.ZSKB_MOUNTAIN_SPIRIT_HEALTH = 20000
TUNING.ZSKB_MOUNTAIN_SPIRIT_DAMAGE = 175
TUNING.ZSKB_MOUNTAIN_SPIRIT_EGG_FALLING_DMG = 20
TUNING.ZSKB_MOUNTAIN_SPIRIT_EGG_FALLING_RAD = 1.5
TUNING.ZSKB_MOUNTAIN_SPIRIT_EGG_EXPLODE_DMG = 80
TUNING.ZSKB_MOUNTAIN_SPIRIT_EGG_EXPLODE_RAD = 2.5
TUNING.ZSKB_MOUNTAIN_SPIRIT_MUSIC_ATTACK_RANGE = 15
TUNING.ZSKB_MOUNTAIN_SPIRIT_MUSIC_ATTACK_DURATION = 3.5

-- respawn time
TUNING.ZSKB_MOUNTAIN_SPIRIT_RESPAWNTIME = TUNING.TOTAL_DAY_TIME * 20
-- mask
TUNING.ARMOR_ZSKB_MOUNTAIN_SPIRIT_MASK = TUNING.WILSON_HEALTH * 8 * TUNING.MULTIPLAYER_ARMOR_DURABILITY_MODIFIER --TUNING.ARMOR_RUINSHAT
TUNING.ARMOR_ZSKB_MOUNTAIN_SPIRIT_MASK_ABSOPTION = .6 * TUNING.MULTIPLAYER_ARMOR_ABSORPTION_MODIFIER         -- 60%
TUNING.ARMOR_ZSKB_MOUNTAIN_SPIRIT_MASK_PLANAR_ABSOPTION = .2 * TUNING.MULTIPLAYER_ARMOR_ABSORPTION_MODIFIER  -- 20%

-- buff
TUNING.ZSKB_BUFF_SPIRIT_STATUE_RAGE_INIT_TIME = 4.2 * TUNING.TOTAL_DAY_TIME
TUNING.ZSKB_BUFF_SPIRIT_STATUE_RAGE_MAX_TIME = 6 * TUNING.TOTAL_DAY_TIME
TUNING.ZSKB_BUFF_SPIRIT_STATUE_RAGE_MIN_TIME = 1 * TUNING.TOTAL_DAY_TIME
TUNING.ZSKB_BUFF_SPIRIT_STATUE_RAGE_FAILURE_SCALE = 0.8
TUNING.ZSKB_BUFF_SPIRIT_STATUE_COST_TIME = 60
---------------------------------------------------------------------------------------------------------
TUNING.ZSKB = {
	ENABLE = true,
	ONE_DAY_DELTA = 75
}
