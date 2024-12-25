--阴棺
AddRecipe2(
    "zskb_coffin",
    { Ingredient("livinglog", 15), Ingredient("dug_marsh_bush", 2), Ingredient("papyrus", 2) },
    TECH.SCIENCE_TWO,
    {
        placer = "zskb_coffin_placer",
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_coffin.tex",
        builder_tag = "zskb_zombie",
    },
    { "CHARACTER", "STRUCTURES", "RESTORATION", "WINTER" }
)
--符纸伞
AddRecipe2(
    "zskb_rune_paper_umbrella",
    { Ingredient("pigskin", 1), Ingredient("papyrus", 4), Ingredient("featherpencil", 1) },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_rune_paper_umbrella.tex",
        builder_tag = "zskb_zombie",
    },
    { "CHARACTER", "CLOTHING", "SUMMER", "RAIN" }
)
--铜钱伞
AddRecipe2(
    "zskb_copper_coin_umbrella",
    { Ingredient("zskb_black_copper_coin", 20, "images/zskb_inventoryimages.xml"), Ingredient("livinglog", 5), Ingredient("zskb_rune_paper_umbrella", 1, "images/zskb_inventoryimages.xml") },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_copper_coin_umbrella_close.tex",
        builder_tag = "zskb_zombie",
    },
    { "CHARACTER", "CLOTHING", "SUMMER", "RAIN" }
)
--还阳丹
AddRecipe2(
    "zskb_return_life_pill",
    { Ingredient("dragon_scales", 1), Ingredient("mosquitosack", 1), Ingredient("feather_robin", 1) },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_return_life_pill.tex",
        builder_tag = "zskb_zombie",
        numtogive = 3,
    },
    { "CHARACTER", "RESTORATION" }
)
--铜钱面罩
AddRecipe2(
    "zskb_copper_coin_mask",
    { Ingredient("zskb_copper_coin", 20, "images/zskb_inventoryimages.xml"), Ingredient("nightmarefuel", 5), Ingredient("cutgrass", 4) },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_copper_coin_mask.tex",
        builder_tag = "zskb_zombie",
    },
    { "CHARACTER", "ARMOUR" }
)
--黑铜钱面罩
AddRecipe2(
    "zskb_black_copper_coin_mask",
    { Ingredient("zskb_black_copper_coin", 20, "images/zskb_inventoryimages.xml"), Ingredient("nightmarefuel", 5), Ingredient("cutgrass", 4) },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_black_copper_coin_mask.tex",
        builder_tag = "zskb_zombie",
    },
    { "CHARACTER", "ARMOUR" }
)
--黑菩提
AddRecipe2(
    "zskb_bead",
    { Ingredient("zskb_black_copper_coin", 2, "images/zskb_inventoryimages.xml"), Ingredient("goldnugget", 2), Ingredient("livinglog", 4), Ingredient("rope", 1) },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_bead.tex",
        builder_tag = "zskb_zombie",
    },
    { "CHARACTER", "ARMOUR" }
)
--铜雀台
AddRecipe2(
    "zskb_copper_crane_platform",
    { Ingredient("goldnugget", 3), Ingredient("nightmarefuel", 2), Ingredient("thulecite_pieces", 3) },
    TECH.MAGIC_TWO,
    {
        placer = "zskb_copper_crane_platform_placer",
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_copper_crane_platform.tex",
    },
    { "PROTOTYPERS" }
)
--香烛
AddRecipe2(
    "zskb_candle",
    { Ingredient("petals", 2), Ingredient("log", 1), Ingredient("beardhair", 1) },
    TECH.ZSKB_COPPER_CRANE_PLATFORM_ONE,
    {
        nounlock = true,
        station_tag = "zskb_copper_crane_platform",
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_candle.tex",
        numtogive = 3,
    },
    { "CRAFTING_STATION" }
)
--铜钱
AddRecipe2(
    "zskb_copper_coin",
    { Ingredient("goldnugget", 1) },
    TECH.ZSKB_COPPER_CRANE_PLATFORM_ONE,
    {
        nounlock = true,
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_copper_coin.tex",
    },
    { "CRAFTING_STATION" }
)
--香肠
AddRecipe2(
    "zskb_sausage",
    { Ingredient("meat", 1), Ingredient("saltrock", 1) },
    TECH.ZSKB_COPPER_CRANE_PLATFORM_ONE,
    {
        nounlock = true,
        station_tag = "zskb_copper_crane_platform",
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_sausage.tex",
        numtogive = 3,
    },
    { "CRAFTING_STATION" }
)
--通明灯
AddRecipe2(
    "zskb_brightly_light",
    { Ingredient("livinglog", 2), Ingredient("papyrus", 3), Ingredient(CHARACTER_INGREDIENT.HEALTH, 40) },
    TECH.ZSKB_COPPER_CRANE_PLATFORM_ONE,
    {
        nounlock = true,
        station_tag = "zskb_copper_crane_platform",
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_brightly_light.tex",
    },
    { "CRAFTING_STATION" }
)
--防火符咒
AddRecipe2(
    "zskb_fireproof_runepaper",
    { Ingredient("papyrus", 1), Ingredient("boneshard", 1), Ingredient("butterfly", 1) },
    TECH.NONE,
    {
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_fireproof_runepaper.tex",
        builder_tag = "zskb_zombie",
    },
    { "CHARACTER" }
)
--阴符咒
AddRecipe2(
    "zskb_yin_runepaper",
    { Ingredient("papyrus", 1), Ingredient("zskb_black_copper_coin", 1, "images/zskb_inventoryimages.xml"), Ingredient("featherpencil", 1) },
    TECH.ZSKB_COPPER_CRANE_PLATFORM_TWO,
    {
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_yin_runepaper.tex",
        builder_tag = "zskb_zombie",
    },
    { "CHARACTER" }
)
--青龙雕像
AddRecipe2(
    "zskb_qinglong",
    { Ingredient("marble", 20), Ingredient("cutstone", 5), Ingredient("petals", 60) },
    TECH.ZSKB_COPPER_CRANE_PLATFORM_TWO,
    {
        placer = "zskb_qinglong_placer",
        station_tag = "zskb_copper_crane_platform",
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_qinglong.tex",
    },
    { "CRAFTING_STATION" }
)
--白虎雕像
AddRecipe2(
    "zskb_baihu",
    { Ingredient("marble", 20), Ingredient("cutstone", 5), Ingredient("lightninggoathorn", 6) },
    TECH.ZSKB_COPPER_CRANE_PLATFORM_TWO,
    {
        placer = "zskb_baihu_placer",
        station_tag = "zskb_copper_crane_platform",
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_baihu.tex",
    },
    { "CRAFTING_STATION" }
)
--朱雀雕像
AddRecipe2(
    "zskb_zhuque",
    { Ingredient("marble", 20), Ingredient("cutstone", 5), Ingredient("feather_robin", 20) },
    TECH.ZSKB_COPPER_CRANE_PLATFORM_TWO,
    {
        placer = "zskb_zhuque_placer",
        station_tag = "zskb_copper_crane_platform",
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_zhuque.tex",
    },
    { "CRAFTING_STATION" }
)
--玄武雕像
AddRecipe2(
    "zskb_xuanwu",
    { Ingredient("marble", 20), Ingredient("cutstone", 5), Ingredient("palmcone_scale", 80) },
    TECH.ZSKB_COPPER_CRANE_PLATFORM_TWO,
    {
        placer = "zskb_xuanwu_placer",
        station_tag = "zskb_copper_crane_platform",
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_xuanwu.tex",
    },
    { "CRAFTING_STATION" }
)
--山神面具
AddRecipe2(
    "zskb_mountain_spirit_mask",
    { Ingredient("zskb_mountain_spirit_skull", 1, "images/zskb_inventoryimages.xml"), Ingredient("footballhat", 1), Ingredient("thulecite_pieces", 5) },
    TECH.ZSKB_COPPER_CRANE_PLATFORM_TWO,
    {
        nounlock = true,
        station_tag = "zskb_copper_crane_platform",
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_mountain_spirit_mask.tex",
    },
    { "CRAFTING_STATION" }
)
--纸币
AddRecipe2(
    "zskb_paper_money",
    { Ingredient("cutreeds", 1) },
    TECH.ZSKB_PAPER_TECH_ONE,
    {
        nounlock = true,
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_paper_money.tex",
        numtogive = 5,
    }
)
--纸月亮
AddRecipe2(
    "zskb_paper_moon",
    { Ingredient("papyrus", 2), Ingredient("nightmarefuel", 4), Ingredient("horrorfuel", 1), Ingredient("zskb_ghostfire", 2) },
    TECH.ZSKB_PAPER_TECH_ONE,
    {
        nounlock = true,
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_paper_moon.tex",
    }
)
--火盆
AddRecipe2(
    "zskb_fire_basin",
    { Ingredient("goldnugget", 2), Ingredient("charcoal", 2) },
    TECH.ZSKB_PAPER_TECH_ONE,
    {
        nounlock = true,
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_fire_basin.tex",
    }
)

--破煞符
AddRecipe2(
    "zskb_break_talisman",
    { Ingredient("papyrus", 1), Ingredient("featherpencil", 1), },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_break_talisman.tex",
        builder_tag = "zskb_zombie",
    },
    { "CHARACTER", }
)

--震煞符
AddRecipe2(
    "zskb_seal_talisman",
    { Ingredient("papyrus", 1), Ingredient("featherpencil", 1), Ingredient("thulecite", 1), },
    TECH.SCIENCE_TWO,
    {
        atlas = "images/zskb_inventoryimages.xml",
        image = "zskb_seal_talisman.tex",
        builder_tag = "zskb_zombie",
    },
    { "CHARACTER", }
)

----CONSTRUCTION PLANS----
--no api yet
local ZSKB_CONSTRUCTION_PLANS = {
    ["zskb_mountain_spirit_statue"] =
    { Ingredient("zskb_candle", 21, "images/zskb_inventoryimages.xml"), Ingredient("meat", 5), Ingredient("berries", 5), Ingredient("reviver", 1) },
}

local CONSTRUCTION_PLANS = rawget(GLOBAL, "CONSTRUCTION_PLANS")
if type(CONSTRUCTION_PLANS) == "table" then
    for k, v in pairs(ZSKB_CONSTRUCTION_PLANS) do
        CONSTRUCTION_PLANS[k] = v
    end
end
