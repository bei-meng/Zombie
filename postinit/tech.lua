local TechTree = require("techtree")

---------------------------------------------------------------------------------------
-- 这块代码必须先加载，且要比AddRecipe2()早加载，否则会出现一些莫名其妙的问题
for k, v in pairs(TUNING.PROTOTYPER_TREES) do
	v.ZSKB_CCP_ONE = 0
	v.ZSKB_CCP_TWO = 0
end

for i, v in pairs(AllRecipes) do
	v.level.ZSKB_CCP_ONE = v.level.ZSKB_CCP_ONE or 0
	v.level.ZSKB_CCP_TWO = v.level.ZSKB_CCP_TWO or 0
end
---------------------------------------------------------------------------------------

table.insert(TechTree.AVAILABLE_TECH, "ZSKB_CCP_ONE")
table.insert(TechTree.AVAILABLE_TECH, "ZSKB_CCP_TWO")

TECH.NONE.ZSKB_CCP_ONE = 0
TECH.NONE.ZSKB_CCP_TWO = 0
TECH.ZSKB_COPPER_CRANE_PLATFORM_ONE = { ZSKB_CCP_ONE = 1 }
TECH.ZSKB_COPPER_CRANE_PLATFORM_TWO = { ZSKB_CCP_TWO = 1 }

TUNING.PROTOTYPER_TREES.COPPER_CRANE_PLATFORM_ONE = TechTree.Create({ ZSKB_CCP_ONE = 1 })
TUNING.PROTOTYPER_TREES.COPPER_CRANE_PLATFORM_TWO = TechTree.Create({ ZSKB_CCP_TWO = 1 })

STRINGS.UI.CRAFTING_STATION_FILTERS.ZSKB_COPPER_CRANE_PLATFORM = "铜雀台"
STRINGS.ACTIONS.OPEN_CRAFTING.ZSKB_COPPER_CRANE_PLATFORM = "打开"
STRINGS.UI.CRAFTING_FILTERS.ZSKB_COPPER_CRANE_PLATFORM = "铜雀台"
-- STRINGS.UI.CRAFTING.NEEDALCHEMYENGINE = "使用铜雀台制造一个原型！"

AddPrototyperDef("zskb_copper_crane_platform", {
	icon_atlas = "images/zskb_copper_crane_platform.xml",
	icon_image = "zskb_copper_crane_platform.tex",
	is_crafting_station = true,
	action_str = "ZSKB_COPPER_CRANE_PLATFORM",
	filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.ZSKB_COPPER_CRANE_PLATFORM
})
