GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local _G = GLOBAL

--※※ 标注的地方大概率在新增内容的时候需要添加对应的参数,请仔细核对 ※※ 标注的部分

--※※ 万物皆是prefab
PrefabFiles = {
    "zskb_zombie",                          --人物代码文件
    "zskb_zombie_none",                     --人物皮肤
    "zskb_coffin",                          --阴棺
    "zskb_copper_coin",                     --铜钱
    "zskb_umbrella",                        --铜钱伞/符纸伞
    "zskb_return_life_pill",                --还阳丹
    "zskb_buffs",                           --模组buff
    "zskb_copper_coin_mask",                --铜钱面罩
    "zskb_poisonbubble",                    --特效
    "zskb_bead",                            --黑菩提
    "zskb_copper_crane_platform",           --铜鹤台
    "zskb_sausage",                         --肉肠
    "zskb_preparedfoods",                   --烹饪锅料理
    "zskb_runepaper",                       --符咒:防火符咒/阴符咒
    "zskb_candle",                          --香烛
    "zskb_brightly_light",                  --通明灯
    "zskb_statue",                          --雕像:青龙雕像/白虎雕像/朱雀雕像/玄武雕像
    "zskb_cedartree",                       --杉树
    "zskb_graves",                          --坟墓:骷髅坟墓/老人坟墓/婴灵坟墓
    "zskb_paper",                           --纸条
    "zskb_mountain_spirit",                 --山鬼
    "zskb_mountain_spirit_spawner",         --山鬼生成点
    "zskb_mountain_spirit_statue",          --山神像
    "zskb_mountain_spirit_throne",          --石笋王座
    "zskb_mountain_spirit_egg",             --山神蛋
    "zskb_mountain_spirit_skull",           --山神头颅
    "zskb_mountain_spirit_mask",            --山神面具
    "zskb_mountain_spirit_house",           --山神庙
    "zskb_mountain_spirit_house_exit",      --山神庙出口
    "zskb_interior_items",                  --山神庙相关物品
    "zskb_mountain_spirit_house_interiors", --山神庙内饰
    "zskb_red_packet",                      --红包
    "zskb_banyantreenut",                   --榕树树种
    "zskb_banyantree",                      --榕树
    "zskb_banyantree_pillar",               --高大的榕树
    "zskb_toy",                             --玩具:铃铛/福/牛头人雕像/梳子/绣花鞋/红绣球/元宝/卷轴/剪刀/残破书页123
    "zskb_ghostfire",                       --鬼火
    "zskb_talisman_bound_bugnet",           --缠了黄符的捕虫网
    "zskb_gourd",                           --葫芦
    "zskb_water_kiki",                      --水猴子
    "zskb_paper_doll",                      --内殿纸人
    "zskb_incense_burner",                  --香炉
    "zskb_coffin_nail",                     --棺材钉
    "zskb_moving_paper_doll",               --移动纸人
    "zskb_paper_money",                     --纸币
    "zskb_paper_moon",                      --纸月亮
}

Assets = {
    Asset("IMAGE", "images/saveslot_portraits/zskb_zombie.tex"), --存档图片
    Asset("ATLAS", "images/saveslot_portraits/zskb_zombie.xml"),

    Asset("IMAGE", "images/selectscreen_portraits/zskb_zombie.tex"), --单机选人界面
    Asset("ATLAS", "images/selectscreen_portraits/zskb_zombie.xml"),

    Asset("IMAGE", "images/selectscreen_portraits/zskb_zombie_silho.tex"), --单机未解锁界面
    Asset("ATLAS", "images/selectscreen_portraits/zskb_zombie_silho.xml"),

    Asset("IMAGE", "bigportraits/zskb_zombie.tex"), --人物大图（方形的那个）
    Asset("ATLAS", "bigportraits/zskb_zombie.xml"),

    Asset("IMAGE", "images/avatars/avatar_zskb_zombie.tex"), --tab键人物列表显示的头像
    Asset("ATLAS", "images/avatars/avatar_zskb_zombie.xml"),

    Asset("IMAGE", "images/avatars/avatar_ghost_zskb_zombie.tex"), --tab键人物列表显示的头像（死亡）
    Asset("ATLAS", "images/avatars/avatar_ghost_zskb_zombie.xml"),

    Asset("IMAGE", "images/avatars/self_inspect_zskb_zombie.tex"), --人物检查按钮的图片
    Asset("ATLAS", "images/avatars/self_inspect_zskb_zombie.xml"),

    Asset("IMAGE", "images/names_zskb_zombie.tex"), --人物名字
    Asset("ATLAS", "images/names_zskb_zombie.xml"),

    Asset("IMAGE", "bigportraits/zskb_zombie.tex"), --人物大图（椭圆的那个）
    Asset("ATLAS", "bigportraits/zskb_zombie.xml"),

    Asset("IMAGE", "images/zskb_copper_crane_platform.tex"), --铜雀台制作栏图标
    Asset("ATLAS", "images/zskb_copper_crane_platform.xml"),

    Asset("IMAGE", "images/zskb_runepaper.tex"), --插槽
    Asset("ATLAS", "images/zskb_runepaper.xml"),

    Asset("ANIM", "anim/zskb_zombie_gas_badge.zip"),
    Asset("ANIM", "anim/zskb_zombie_threefire_badge.zip"),

    Asset("ATLAS", "images/zskb_inventoryimages.xml"),
    Asset("IMAGE", "images/zskb_inventoryimages.tex"),
    Asset("ATLAS_BUILD", "images/zskb_inventoryimages.xml", 256),

    Asset("ATLAS", "images/zskb_ui.xml"),
    Asset("IMAGE", "images/zskb_ui.tex"),

    Asset("ATLAS", "images/zskb_paper_ui.xml"),
    Asset("IMAGE", "images/zskb_paper_ui.tex"),

    Asset("ANIM", "anim/zskb_ghost_backpack.zip"), --背后灵

    Asset("ANIM", "anim/zskb_leaves_canopy.zip"),  --榕树树荫

    Asset("ATLAS", "images/paper_tech_icon.xml"),  --纸扎科技图标
    Asset("IMAGE", "images/paper_tech_icon.tex"),

    Asset("ANIM", "anim/zskb_minisign1.zip"), --小木牌资源,后面的数字代表 zskb_minisign_list.lua 中的序号
    Asset("ANIM", "anim/zskb_minisign2.zip"),
}

--判定别的mod是否开启，参考了风铃大佬的代码
_G.ZSKB_SETS = {
    ENABLEDMODS = {},
}
local modsenabled = KnownModIndex:GetModsToLoad(true)
local enabledmods = {}
for k, dir in pairs(modsenabled) do
    local info = KnownModIndex:GetModInfo(dir)
    local name = info and info.name or "unknown"
    enabledmods[dir] = name
end
local function IsModEnable(name)
    for k, v in pairs(enabledmods) do
        if v and (k:match(name) or v:match(name)) then
            return true
        end
    end
    return false
end
_G.ZSKB_SETS.ENABLEDMODS["legion"] = IsModEnable("Legion") or IsModEnable("棱镜") --棱镜

modimport("postinit/consts") --mod常量

local skin_modes = {
    {
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle",
        scale = 0.75,
        offset = { 0, -25 }
    },
}
--增加人物到mod人物列表 性别为女性（MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL）
AddModCharacter("zskb_zombie", "MALE", skin_modes)

--注册小地图图标
AddMinimapAtlas("images/zskb_inventoryimages.xml")

AddReplicableComponent("zskb_zombie")
AddReplicableComponent("zskb_zombie_gas")
AddReplicableComponent("zskb_zombie_threefire")

local lang = GetModConfigData("language") or "zhs"
modimport("lang/" .. lang .. ".lua") --※※ 中文&英文: zhs.lua en.lua

modimport("postinit/registerimages") --※※ 注册贴图
modimport("postinit/tech")           --科技
modimport("postinit/zskb_tech")      --科技(Gyde:重新写一页,旧的回头给删了)
modimport("postinit/recipes")        --※※ 制作配方
modimport("postinit/actions")        --mod动作
modimport("postinit/containers")     --容器
modimport("postinit/rpc")
modimport("postinit/slots")          --额外装备栏(插槽)
modimport("postinit/cmphook")        --组件hook函数
modimport("postinit/postinit")       --原版prefabs的hook函数(Gyde:我没有分的那么细,我会把相关的例如背后灵涉及到的hook函数放在一起)
modimport("postinit/foods")          --料理
modimport("postinit/stategraphs")

--※※ 兼容高清小木牌需前往 zskb_minisign_list.lua 填写 symbol(贴图名称) 和动画序号
--不会弄小木牌的话交给Gyde弄就行
