-- 添加中式恐怖mod专属科技

-- 代码作者:梧桐山(棱镜mod作者)

local _G = GLOBAL

--------------------------------------------------------------------------
--[[ 修改默认的科技树生成方式 ]]
--------------------------------------------------------------------------
local TechTree = require("techtree")

table.insert(TechTree.AVAILABLE_TECH, "ZSKB_PAPER_TECH") --其实就是加个自己的科技树名称

local Create_old = TechTree.Create
TechTree.Create = function(t, ...)
    local newt = Create_old(t, ...)
    newt["ZSKB_PAPER_TECH"] = newt["ZSKB_PAPER_TECH"] or 0
    return newt
end

--------------------------------------------------------------------------
--[[ 新制作栏兼容 ]]
--------------------------------------------------------------------------
AddPrototyperDef("zskb_moving_paper_doll", { --第一个参数是指玩家靠近时会解锁科技的prefab名
    icon_atlas = "images/paper_tech_icon.xml",
    icon_image = "paper_tech_icon.tex",
    is_crafting_station = true,
    action_str = "ZSKB_PAPER",                           --台词已在语言文件中
    filter_text = STRINGS.UI.CRAFTING_FILTERS.ZSKB_PAPER --台词已在语言文件中
})

--纸扎栏
AddRecipeFilter({
    name = "ZSKB_PAPER",
    atlas = "images/paper_tech_icon.xml",
    image = "paper_tech_icon.tex",
    custom_pos = true --不新建常驻分类
})

--------------------------------------------------------------------------
--[[ 制作等级中加入自己的部分 ]]
--------------------------------------------------------------------------
_G.TECH.NONE.ZSKB_PAPER_TECH = 0
_G.TECH.ZSKB_PAPER_TECH_ONE = { ZSKB_PAPER_TECH = 1 }

--------------------------------------------------------------------------
--[[ 解锁等级中加入自己的部分 ]]
--------------------------------------------------------------------------
for k, v in pairs(TUNING.PROTOTYPER_TREES) do
    v.ZSKB_PAPER_TECH = 0
end

TUNING.PROTOTYPER_TREES.ZSKB_PAPER_TECH_ONE = TechTree.Create({
    ZSKB_PAPER_TECH = 1,
})

--------------------------------------------------------------------------
--[[ 修改全部制作配方，对缺失的值进行补充 ]]
--------------------------------------------------------------------------
for i, v in pairs(AllRecipes) do
    if v.level.ZSKB_PAPER_TECH == nil then
        v.level.ZSKB_PAPER_TECH = 0
    end
end
