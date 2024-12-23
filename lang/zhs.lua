--------------------------------------------------------------------------
--[[ CHARACTER ]]
--------------------------------------------------------------------------
-- The character select screen lines  --人物选人界面的描述
STRINGS.CHARACTER_TITLES.zskb_zombie = "僵尸"
STRINGS.CHARACTER_NAMES.zskb_zombie = "僵尸"
STRINGS.CHARACTER_DESCRIPTIONS.zskb_zombie = "*惧怕阳光\n*可以在棺材里面睡觉\n*能在晚上看清东西"
STRINGS.CHARACTER_QUOTES.zskb_zombie = "\"讨厌阳光，喜欢尸气\""

-- Custom speech strings  ----人物语言文件  可以进去自定义
STRINGS.CHARACTERS.ZSKB_ZOMBIE = require "speech_zskb_zombie_zhs"

-- The character's name as appears in-game  --人物在游戏里面的名字
STRINGS.NAMES.ZSKB_ZOMBIE = "僵尸"
STRINGS.SKIN_NAMES.zskb_zombie_none = "僵尸" --检查界面显示的名字

--生存几率
STRINGS.CHARACTER_SURVIVABILITY.zskb_zombie = "生存？爷是来斩妖除魔的！"

--------------------------------------------------------------------------
--[[ TALK ]]
--------------------------------------------------------------------------
STRINGS.ZSKB = {}
STRINGS.ZSKB.CATCHING = "我需要用特殊的捕虫网来捕捉它"

--------------------------------------------------------------------------
--[[ TECH ]]
--------------------------------------------------------------------------
STRINGS.UI.CRAFTING.NEEDSZSKB_PAPER_TECH_ONE = "靠近移动的纸人制作"
STRINGS.ACTIONS.OPEN_CRAFTING.ZSKB_PAPER = "试探" --靠近解锁时的前置提示。名字与AddPrototyperDef里的action_str一致
STRINGS.UI.CRAFTING_FILTERS.ZSKB_PAPER = "纸扎栏"

--------------------------------------------------------------------------
--[[ RECIPES ]]
--------------------------------------------------------------------------
STRINGS.NAMES.ZSKB_COFFIN = "阴棺"
STRINGS.RECIPE_DESC.ZSKB_COFFIN = "尘归尘土归土"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_COFFIN = "看起来阴气十足"

STRINGS.NAMES.ZSKB_COPPER_COIN = "铜钱"
STRINGS.RECIPE_DESC.ZSKB_COPPER_COIN = "古铜币"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_COPPER_COIN = "外圆内方，天人合一"

STRINGS.NAMES.ZSKB_BLACK_COPPER_COIN = "黑色铜钱"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BLACK_COPPER_COIN = "它散发着不详的气息"

STRINGS.NAMES.ZSKB_COPPER_COIN_UMBRELLA = "铜钱伞"
STRINGS.RECIPE_DESC.ZSKB_COPPER_COIN_UMBRELLA = "现在能用它敲人了"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_COPPER_COIN_UMBRELLA = "闻起来有很冲的血腥味"

STRINGS.NAMES.ZSKB_RUNE_PAPER_UMBRELLA = "符纸伞"
STRINGS.RECIPE_DESC.ZSKB_RUNE_PAPER_UMBRELLA = "让你的僵尸在白天也能活动"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_RUNE_PAPER_UMBRELLA = "伞上贴满了符咒"

STRINGS.NAMES.ZSKB_RETURN_LIFE_PILL = "还阳丹"
STRINGS.RECIPE_DESC.ZSKB_RETURN_LIFE_PILL = "应该不是用来壮阳的"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_RETURN_LIFE_PILL = "摸起来暖暖的"

STRINGS.NAMES.ZSKB_COPPER_COIN_MASK = "铜钱面罩"
STRINGS.RECIPE_DESC.ZSKB_COPPER_COIN_MASK = "可以遮住伸出来的舌头"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_COPPER_COIN_MASK = "几吊钱"

STRINGS.NAMES.ZSKB_BLACK_COPPER_COIN_MASK = "黑铜钱面罩"
STRINGS.RECIPE_DESC.ZSKB_BLACK_COPPER_COIN_MASK = "煞气四溢"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BLACK_COPPER_COIN_MASK = "不要碰它，会引来血光之灾"

STRINGS.NAMES.ZSKB_BEAD = "黑菩提"
STRINGS.RECIPE_DESC.ZSKB_BEAD = "黑色的珠子"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BEAD = "摸起来有点像眼球？"

STRINGS.NAMES.ZSKB_COPPER_CRANE_PLATFORM = "铜鹤台"
STRINGS.RECIPE_DESC.ZSKB_COPPER_CRANE_PLATFORM = "仙翁醉卧南山头，吸月餐霞听鸟讴"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_COPPER_CRANE_PLATFORM = {
    LVL_ONE = "手艺蛮好",
    LVL_TWO = "样子变了",
}

STRINGS.NAMES.ZSKB_SAUSAGE = "肉肠"
STRINGS.RECIPE_DESC.ZSKB_SAUSAGE = "非常古老的食物生产和肉食保存技术"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_SAUSAGE = "这样保质期会长一点"

STRINGS.NAMES.ZSKB_SAUSAGE_DRIED = "腊肠"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_SAUSAGE_DRIED = "熟制后应该会更好吃"

STRINGS.NAMES.ZSKB_VEGETABLE_SPRING_ROLL = "素春卷"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_VEGETABLE_SPRING_ROLL = "外酥里鲜，外脆里嫩，口感极佳"

STRINGS.NAMES.ZSKB_CURED_MEAT_RICE = "腊味煲仔饭"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_CURED_MEAT_RICE = "独沽一味，好吃不贵"

STRINGS.NAMES.ZSKB_ROAST_DUCK = "烤鸭"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_ROAST_DUCK = "也算去了趟全聚德"

STRINGS.NAMES.ZSKB_PEACH_STEAM_BUN = "寿桃馒头"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_PEACH_STEAM_BUN = "宁吃仙桃一口，不吃烂杏一筐"

STRINGS.NAMES.ZSKB_RABBIT_STEAM_BUN = "兔子馒头"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_RABBIT_STEAM_BUN = "小孩子很喜欢"

STRINGS.NAMES.ZSKB_FIREPROOF_RUNEPAPER = "防火符咒"
STRINGS.RECIPE_DESC.ZSKB_FIREPROOF_RUNEPAPER = "让你的僵尸在白天工作"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_FIREPROOF_RUNEPAPER = "带上以后会很难受！"

STRINGS.NAMES.ZSKB_YIN_RUNEPAPER = "阴符咒"
STRINGS.RECIPE_DESC.ZSKB_YIN_RUNEPAPER = "可以暂时封印阴棺带来的功能"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_YIN_RUNEPAPER = "带上他就什么也不想干了"

STRINGS.NAMES.ZSKB_CANDLE = "香烛"
STRINGS.RECIPE_DESC.ZSKB_CANDLE = "馨香持一炷，不着去来今。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_CANDLE = "有着奇特的香味"

STRINGS.NAMES.ZSKB_BRIGHTLY_LIGHT = "通明灯"
STRINGS.RECIPE_DESC.ZSKB_BRIGHTLY_LIGHT = "引魂灯一盏，往生路难辨。"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BRIGHTLY_LIGHT = "盯久了会有点恍惚"

STRINGS.NAMES.ZSKB_QINGLONG = "青龙雕像"
STRINGS.RECIPE_DESC.ZSKB_QINGLONG = "天神之贵者，莫贵于青龙"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_QINGLONG = "青龙破云出，祥瑞绕乾坤"

STRINGS.NAMES.ZSKB_BAIHU = "白虎雕像"
STRINGS.RECIPE_DESC.ZSKB_BAIHU = "虎者，阳物，百兽之长也，能执搏挫"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BAIHU = "英英素质，肃肃清音，威摄禽兽，啸动山林"

STRINGS.NAMES.ZSKB_ZHUQUE = "朱雀雕像"
STRINGS.RECIPE_DESC.ZSKB_ZHUQUE = "鹑火，柳之次明也"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_ZHUQUE = "非梧桐不栖，非竹实不食，非醴泉不饮"

STRINGS.NAMES.ZSKB_XUANWU = "玄武雕像"
STRINGS.RECIPE_DESC.ZSKB_XUANWU = "属，言非一也。其色，天龟玄，所谓玄武是也"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_XUANWU = "北方七神之宿，实始于斗，镇北方，主风雨"

STRINGS.NAMES.ZSKB_GRAVE_NORMAL = "骷髅坟墓"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_GRAVE_NORMAL = "有些破败了"

STRINGS.NAMES.ZSKB_GRAVE_OLDER = "老人坟墓"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_GRAVE_OLDER = "希望是个好相处的老太太"

STRINGS.NAMES.ZSKB_GRAVE_CHILD = "婴灵坟墓"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_GRAVE_CHILD = "真是个有童心的墓主"

STRINGS.NAMES.ZSKB_PAPER = "纸条"

STRINGS.NAMES.ZSKB_CEDARTREE = "杉树"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_CEDARTREE = {
    NONE = "阳光都被遮住了",
    COIN = "用红线缠了些铜钱在上面",
}

STRINGS.NAMES.ZSKB_MOUNTAIN_SPIRIT = "山鬼"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOUNTAIN_SPIRIT = "这才是这东西的真面目吗？"

STRINGS.NAMES.ZSKB_MOUNTAIN_SPIRIT_SKULL = "山神头颅"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOUNTAIN_SPIRIT_SKULL = "他还在盯着我?!"

STRINGS.NAMES.ZSKB_MOUNTAIN_SPIRIT_STATUE = "山神像"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOUNTAIN_SPIRIT_STATUE = "神像需要贡品"
STRINGS.NAMES.ZSKB_MOUNTAIN_SPIRIT_STATUE_ACTIVATED = "激活的山神像"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOUNTAIN_SPIRIT_STATUE_ACTIVATED = "这神像刚刚是动过了吗?!"
STRINGS.ZSKB_SPIRIT_STATUE_BUFF_WARNING = "神像的惩罚要来了"
STRINGS.ZSKB_SPIRIT_STATUE_BUFF_ATTACHED = "我获得了力量！还是诅咒？"
STRINGS.ZSKB_SPIRIT_STATUE_BUFF_DETACHED = "恶鬼的怨念消散了"

STRINGS.NAMES.ZSKB_MOUNTAIN_SPIRIT_MASK = "山神面具"
STRINGS.RECIPE_DESC.ZSKB_MOUNTAIN_SPIRIT_MASK = "惊驱疫厉之鬼"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOUNTAIN_SPIRIT_MASK = "现在他看着好多了"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOUNTAIN_SPIRIT_MASK_BROKEN = "他饿的睁不开眼了"

STRINGS.NAMES.ZSKB_MOUNTAIN_SPIRIT_HOUSE = "山神庙"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOUNTAIN_SPIRIT_HOUSE = "宁睡荒坟，不住破庙，离远些吧"

STRINGS.NAMES.ZSKB_MOUNTAIN_SPIRIT_THRONE = "石笋王座"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOUNTAIN_SPIRIT_THRONE = "里面藏着什么宝藏吗"

STRINGS.NAMES.ZSKB_MOUNTAIN_SPIRIT_HOUSE_EXIT = "出口"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOUNTAIN_SPIRIT_HOUSE_EXIT = "是时候离开了"

STRINGS.NAMES.ZSKB_RED_PACKET1 = "红包"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_RED_PACKET1 = "被诅咒了的红包"

STRINGS.NAMES.ZSKB_RED_PACKET2 = "开启的红包"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_RED_PACKET2 = "被诅咒了的红包"

STRINGS.NAMES.ZSKB_BANYANTREENUT = "榕树树种"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BANYANTREENUT = "他会长得像他们一样高大吗？"

STRINGS.NAMES.ZSKB_BANYANTREE = "榕树"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BANYANTREE = {
    GENERIC = "看起来它是想一飞冲天",
    CHOPPED = "这上面的年轮充满了故事",
}

STRINGS.NAMES.ZSKB_BANYANTREE_PILLAR = "高大的榕树"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BANYANTREE_PILLAR = "遮天蔽日呀"

STRINGS.NAMES.ZSKB_BELL = "铃铛"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BELL = "上面有个猫猫头"

STRINGS.NAMES.ZSKB_BLESSING = "福"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BLESSING = "福祸相依"

STRINGS.NAMES.ZSKB_BULL_HEAD_STATUE = "牛头人雕像"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BULL_HEAD_STATUE = "牛头人神的怪物陶土人偶"

STRINGS.NAMES.ZSKB_COMB = "梳子"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_COMB = "有股淡淡的香味"

STRINGS.NAMES.ZSKB_EMBROIDERED_SHOES = "绣花鞋"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_EMBROIDERED_SHOES = "头七还魂"

STRINGS.NAMES.ZSKB_HYDRANGEA = "红绣球"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_HYDRANGEA = "新郎官！"

STRINGS.NAMES.ZSKB_INGOT = "元宝"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_INGOT = "可以用来花吗？"

STRINGS.NAMES.ZSKB_REEL = "卷轴"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_REEL = "读万卷书，行千里路"

STRINGS.NAMES.ZSKB_SCISSORS = "剪刀"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_SCISSORS = "破尽裁缝衣，忘收遗翰墨"

STRINGS.NAMES.ZSKB_BROKEN_PAGES1 = "残破书页·壹"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BROKEN_PAGES1 = "残破不堪，没办法阅读"

STRINGS.NAMES.ZSKB_BROKEN_PAGES2 = "残破书页·贰"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BROKEN_PAGES2 = "残破不堪，没办法阅读"

STRINGS.NAMES.ZSKB_BROKEN_PAGES3 = "残破书页·叁"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BROKEN_PAGES3 = "残破不堪，没办法阅读"

STRINGS.NAMES.ZSKB_GHOSTFIRE = "鬼火"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_GHOSTFIRE = "阴房鬼火青，坏道哀湍泻"

STRINGS.NAMES.ZSKB_TALISMAN_BOUND_BUGNET = "缠了黄符的捕虫网"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_TALISMAN_BOUND_BUGNET = "绑了黄符在上面"

STRINGS.NAMES.ZSKB_GOURD = "葫芦"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_GOURD = "内有乾坤"

STRINGS.NAMES.ZSKB_WATER_KIKI = "水猴子"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_WATER_KIKI = "好丑！"

STRINGS.NAMES.ZSKB_PAPER_DOLL1 = "内殿纸人·葫芦"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_PAPER_DOLL1 = {
    NORMAL = "看起来很普通",
    HAND = "手上拿着个葫芦",
    HAND_ANGRY = "我还是不要碰他比较好",
}
STRINGS.NAMES.ZSKB_PAPER_DOLL1_NORMAL = "内殿纸人·葫芦·未持有"
STRINGS.NAMES.ZSKB_PAPER_DOLL1_HAND = "内殿纸人·葫芦·持有"
STRINGS.NAMES.ZSKB_PAPER_DOLL1_HAND_ANGRY = "内殿纸人·葫芦·愤怒"

STRINGS.NAMES.ZSKB_PAPER_DOLL2 = "内殿纸人·香炉"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_PAPER_DOLL2 = {
    NORMAL = "看起来很普通",
    HAND = "手上拿着个香炉",
    HAND_ANGRY = "我还是不要碰她比较好",
}
STRINGS.NAMES.ZSKB_PAPER_DOLL2_NORMAL = "内殿纸人·香炉·未持有"
STRINGS.NAMES.ZSKB_PAPER_DOLL2_HAND = "内殿纸人·香炉·持有"
STRINGS.NAMES.ZSKB_PAPER_DOLL2_HAND_ANGRY = "内殿纸人·香炉·愤怒"

STRINGS.NAMES.ZSKB_PAPER_DOLL3 = "内殿纸人"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_PAPER_DOLL3 = {
    NORMAL = "看起来很普通",
}

STRINGS.NAMES.ZSKB_PAPER_DOLL4 = "内殿纸人"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_PAPER_DOLL4 = {
    NORMAL = "看起来很普通",
}

STRINGS.NAMES.ZSKB_INCENSE_BURNER = "香炉"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_INCENSE_BURNER = "飘着着让人心安的味道"

STRINGS.NAMES.ZSKB_COFFIN_NAIL = "棺材钉"
STRINGS.RECIPE_DESC.ZSKB_COFFIN_NAIL = "钉棺材用的"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_COFFIN_NAIL = "摸上去很凉"

STRINGS.NAMES.ZSKB_MOVING_PAPER_DOLL = "移动纸人"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOVING_PAPER_DOLL = "他是在动吗？"

--------------------------------------------------------------------------
--[[ ACTIONS ]]
--------------------------------------------------------------------------
ACTIONS_ZSKB_TOUCH_GENERIC_STR = "触摸"
ACTIONS_ZSKB_TOUCH_TAKE_STR = "拿取"
ACTIONS_ZSKB_ENCASE_GENERIC_STR = "装入"
ACTIONS_ZSKB_ENCASE_FAIL = "已经被灌满了"
ACTIONS_ZSKB_PLANT_GENERIC_STR = "种植树种"
ACTIONS_ZSKB_UMBRELLA_CLOSE_GENERIC_STR = "收伞"
ACTIONS_ZSKB_UMBRELLA_OPEN_GENERIC_STR = "开伞"
ACTIONS_ZSKB_ENTER_HOUSE_GENERIC_STR = "进入"