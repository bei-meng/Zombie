--------------------------------------------------------------------------
--[[ CHARACTER ]]
--------------------------------------------------------------------------
-- The character select screen lines  --人物选人界面的描述
STRINGS.CHARACTER_TITLES.zskb_zombie = "Zombie"
STRINGS.CHARACTER_NAMES.zskb_zombie = "Zombie"
STRINGS.CHARACTER_DESCRIPTIONS.zskb_zombie = "*Fear of sunlight\n*You can sleep inside the coffin\n*Being able to see things clearly at night"
STRINGS.CHARACTER_QUOTES.zskb_zombie = "\"Hate sunlight, like zombie gas\""

-- Custom speech strings  ----人物语言文件  可以进去自定义
STRINGS.CHARACTERS.ZSKB_ZOMBIE = require "speech_zskb_zombie"

-- The character's name as appears in-game  --人物在游戏里面的名字
STRINGS.NAMES.ZSKB_ZOMBIE = "Zombie"
STRINGS.SKIN_NAMES.zskb_zombie_none = "Zombie" --检查界面显示的名字

--生存几率
STRINGS.CHARACTER_SURVIVABILITY.zskb_zombie = "Survival? I'm here to slay demons and eliminate them!"

--------------------------------------------------------------------------
--[[ TALK ]]
--------------------------------------------------------------------------
STRINGS.ZSKB = {}
STRINGS.ZSKB.CATCHING = "I need to use a special bug net to catch it"

--------------------------------------------------------------------------
--[[ TECH ]]
--------------------------------------------------------------------------
STRINGS.UI.CRAFTING.NEEDSZSKB_PAPER_TECH_ONE = "Craft near a moving paper doll"
STRINGS.ACTIONS.OPEN_CRAFTING.ZSKB_PAPER = "Probe"
STRINGS.UI.CRAFTING_FILTERS.ZSKB_PAPER = "Paper Crafting"

--------------------------------------------------------------------------
--[[ RECIPES ]]
--------------------------------------------------------------------------
STRINGS.NAMES.ZSKB_COFFIN = "Coffin"
STRINGS.RECIPE_DESC.ZSKB_COFFIN = "Dust returns to dust, dust returns to earth"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_COFFIN = "Looks full of Yin Qi"

STRINGS.NAMES.ZSKB_COPPER_COIN = "Copper Coin"
STRINGS.RECIPE_DESC.ZSKB_COPPER_COIN = "Ancient copper coins"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_COPPER_COIN = "Outer circle and inner side, unity of heaven and man"

STRINGS.NAMES.ZSKB_BLACK_COPPER_COIN = "Black Copper Coin"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BLACK_COPPER_COIN = "It emits an ominous aura"

STRINGS.NAMES.ZSKB_COPPER_COIN_UMBRELLA = "Copper Coin Umbrella"
STRINGS.RECIPE_DESC.ZSKB_COPPER_COIN_UMBRELLA = "Now you can use it to knock people"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_COPPER_COIN_UMBRELLA = "It smells strong and bloody"

STRINGS.NAMES.ZSKB_RUNE_PAPER_UMBRELLA = "Rune Paper Umbrella"
STRINGS.RECIPE_DESC.ZSKB_RUNE_PAPER_UMBRELLA = "Make your zombies active during the day"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_RUNE_PAPER_UMBRELLA = "The umbrella is covered with spells"

STRINGS.NAMES.ZSKB_RETURN_LIFE_PILL = "Return Life Pill"
STRINGS.RECIPE_DESC.ZSKB_RETURN_LIFE_PILL = "It shouldn't be used for aphrodisiac purposes"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_RETURN_LIFE_PILL = "It feels warm to the touch"

STRINGS.NAMES.ZSKB_COPPER_COIN_MASK = "Copper Coin Mask"
STRINGS.RECIPE_DESC.ZSKB_COPPER_COIN_MASK = "Can cover the protruding tongue"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_COPPER_COIN_MASK = "A few hanging coins"

STRINGS.NAMES.ZSKB_BLACK_COPPER_COIN_MASK = "Black Copper Coin Mask"
STRINGS.RECIPE_DESC.ZSKB_BLACK_COPPER_COIN_MASK = "Overflow of evil energy"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BLACK_COPPER_COIN_MASK = "Don't touch it, it will cause a bloody disaster"

STRINGS.NAMES.ZSKB_BEAD = "Black Bodhi"
STRINGS.RECIPE_DESC.ZSKB_BEAD = "Black beads"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BEAD = "Does it feel a bit like an eyeball?"

STRINGS.NAMES.ZSKB_COPPER_CRANE_PLATFORM = "Copper Crane Platform"
STRINGS.RECIPE_DESC.ZSKB_COPPER_CRANE_PLATFORM = "The immortal lies drunk on the southern mountain, sucking in the moonlit meal and listening to the birds singing in the sunset"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_COPPER_CRANE_PLATFORM = {
    LVL_ONE = "The craftsmanship is quite good",
    LVL_TWO = "The appearance has changed",
}

STRINGS.NAMES.ZSKB_SAUSAGE = "Sausage"
STRINGS.RECIPE_DESC.ZSKB_SAUSAGE = "Very ancient food production and meat preservation techniques"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_SAUSAGE = "This way, the shelf life will be longer"

STRINGS.NAMES.ZSKB_SAUSAGE_DRIED = "Dried Sausage"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_SAUSAGE_DRIED = "After cooking, it should taste better"

STRINGS.NAMES.ZSKB_VEGETABLE_SPRING_ROLL = "Vegetable Spring Roll"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_VEGETABLE_SPRING_ROLL = "Crispy on the outside and fresh on the inside, crispy on the outside and tender on the inside, with an excellent taste"

STRINGS.NAMES.ZSKB_CURED_MEAT_RICE = "Cured Meat Rice"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_CURED_MEAT_RICE = "Unique taste, delicious and not expensive"

STRINGS.NAMES.ZSKB_ROAST_DUCK = "Roast Duck"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_ROAST_DUCK = "Also counted as a trip to Quanjude"

STRINGS.NAMES.ZSKB_PEACH_STEAM_BUN = "Peach Steam Bun"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_PEACH_STEAM_BUN = "I would rather eat a bite of peach than a basket of rotten apricots"

STRINGS.NAMES.ZSKB_RABBIT_STEAM_BUN = "Rabbit Steam Bun"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_RABBIT_STEAM_BUN = "Children love it very much"

STRINGS.NAMES.ZSKB_FIREPROOF_RUNEPAPER = "Fireproof RunePaper"
STRINGS.RECIPE_DESC.ZSKB_FIREPROOF_RUNEPAPER = "Let your zombies work during the day"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_FIREPROOF_RUNEPAPER = "It will be very uncomfortable after wearing it!"

STRINGS.NAMES.ZSKB_YIN_RUNEPAPER = "Yin RunePaper"
STRINGS.RECIPE_DESC.ZSKB_YIN_RUNEPAPER = "Can temporarily seal the function brought by the Yin coffin"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_YIN_RUNEPAPER = "Take him with you and you don't want to do anything anymore"

STRINGS.NAMES.ZSKB_CANDLE = "Candle"
STRINGS.RECIPE_DESC.ZSKB_CANDLE = "Holding a stick of fragrant incense, I will not come here."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_CANDLE = "Has a unique fragrance"

STRINGS.NAMES.ZSKB_BRIGHTLY_LIGHT = "Brightly Light"
STRINGS.RECIPE_DESC.ZSKB_BRIGHTLY_LIGHT = "A soul guiding lamp makes it difficult to discern the path of rebirth."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BRIGHTLY_LIGHT = "Staring at it for a long time can make you feel a bit dazed"

STRINGS.NAMES.ZSKB_QINGLONG = "Qinglong Statue"
STRINGS.RECIPE_DESC.ZSKB_QINGLONG = "Those who are precious to the gods should not be more precious than Qinglong"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_QINGLONG = "The green dragon breaks through the clouds, and auspicious signs surround the heavens and earth"

STRINGS.NAMES.ZSKB_BAIHU = "White Tiger Statue"
STRINGS.RECIPE_DESC.ZSKB_BAIHU = "The tiger is a yang object, the longest of all beasts, capable of handling battles and setbacks"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BAIHU = "English quality, solemn and clear voice, intimidating beasts, howling in the mountains and forests"

STRINGS.NAMES.ZSKB_ZHUQUE = "Vermilion Bird Statue"
STRINGS.RECIPE_DESC.ZSKB_ZHUQUE = "The quail fire, the willow is second to the bright"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_ZHUQUE = "Do not live without wutong trees, do not eat without bamboos, and do not drink without Liquan"

STRINGS.NAMES.ZSKB_XUANWU = "Xuanwu Statue"
STRINGS.RECIPE_DESC.ZSKB_XUANWU = "Belonging, speaking is not the same. Its color is mysterious, and the so-called Xuanwu is also"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_XUANWU = "The Seven Gods of the North's Residence actually begins with fighting, controlling the north and controlling the wind and rain"

STRINGS.NAMES.ZSKB_GRAVE_NORMAL = "Skull Tomb"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_GRAVE_NORMAL = "It's a bit dilapidated"

STRINGS.NAMES.ZSKB_GRAVE_OLDER = "Older Tomb"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_GRAVE_OLDER = "I hope she is a easy-going old lady"

STRINGS.NAMES.ZSKB_GRAVE_CHILD = "Child Tomb"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_GRAVE_CHILD = "What a childlike tomb owner"

STRINGS.NAMES.ZSKB_PAPER = "Paper"

STRINGS.NAMES.ZSKB_CEDARTREE = "Cedar Tree"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_CEDARTREE = {
    NONE = "The sunlight has been blocked out",
    COIN = "Wrapped some copper coins around it with red thread",
}

STRINGS.NAMES.ZSKB_MOUNTAIN_SPIRIT = "Mountain Spirit"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOUNTAIN_SPIRIT = "Is this what this thing really looks like, huh? No more hiding?"

STRINGS.NAMES.ZSKB_MOUNTAIN_SPIRIT_SKULL = "Mountain Spirit's Skull"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOUNTAIN_SPIRIT_SKULL = "He's still giving me the evil eye? Seriously?"

STRINGS.NAMES.ZSKB_MOUNTAIN_SPIRIT_STATUE = "Mountain Spirit Statue"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOUNTAIN_SPIRIT_STATUE = "It needs tributes"
STRINGS.NAMES.ZSKB_MOUNTAIN_SPIRIT_STATUE_ACTIVATED = "Activated Mountain Spirit Statue"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOUNTAIN_SPIRIT_STATUE_ACTIVATED = "Did that statue just move?"
STRINGS.ZSKB_SPIRIT_STATUE_BUFF_WARNING = "Anger of the spirit statue is on the way"
STRINGS.ZSKB_SPIRIT_STATUE_BUFF_ATTACHED = "Power or curse, what have I obtained?"
STRINGS.ZSKB_SPIRIT_STATUE_BUFF_DETACHED = "Wrath of the devil has dissipated"

STRINGS.NAMES.ZSKB_MOUNTAIN_SPIRIT_MASK = "Mountain Spirit Mask"
STRINGS.RECIPE_DESC.ZSKB_MOUNTAIN_SPIRIT_MASK = "The terrifying ghost of evil finally vanquished"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOUNTAIN_SPIRIT_MASK = "Now he's much more pleasing to the eye"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOUNTAIN_SPIRIT_MASK_BROKEN = "I guess he needs a big meal"

STRINGS.NAMES.ZSKB_MOUNTAIN_SPIRIT_HOUSE = "Mountain Spirit Temple"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOUNTAIN_SPIRIT_HOUSE = "I'd rather crash in a graveyard than chill in this dump."

STRINGS.NAMES.ZSKB_MOUNTAIN_SPIRIT_THRONE = "Stalacmite Throne"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOUNTAIN_SPIRIT_THRONE = "Might be something interesting in there"

STRINGS.NAMES.ZSKB_MOUNTAIN_SPIRIT_HOUSE_EXIT = "Exit"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOUNTAIN_SPIRIT_HOUSE_EXIT = "Time to move"

STRINGS.NAMES.ZSKB_RED_PACKET1 = "Red Packet"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_RED_PACKET1 = "A cursed red packet"

STRINGS.NAMES.ZSKB_RED_PACKET2 = "Opened Red Packet"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_RED_PACKET2 = "A cursed red packet"

STRINGS.NAMES.ZSKB_BANYANTREENUT = "Banyan Tree Seed"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BANYANTREENUT = "Will it grow as tall as they do?"

STRINGS.NAMES.ZSKB_BANYANTREE = "Banyan Tree"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BANYANTREE = {
    GENERIC = "Looks like it wants to soar to the sky",
    CHOPPED = "The rings in its wood are full of stories",
}

STRINGS.NAMES.ZSKB_BANYANTREE_PILLAR = "Towering Banyan Tree"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BANYANTREE_PILLAR = "It blocks out the sky and sun"

STRINGS.NAMES.ZSKB_BELL = "Bell"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BELL = "There's a little cat head on it"

STRINGS.NAMES.ZSKB_BLESSING = "Blessing"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BLESSING = "Fortune and misfortune go hand in hand"

STRINGS.NAMES.ZSKB_BULL_HEAD_STATUE = "Bull-headed Statue"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BULL_HEAD_STATUE = "A clay figurine of the bull-headed god"

STRINGS.NAMES.ZSKB_COMB = "Comb"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_COMB = "It has a faint fragrance"

STRINGS.NAMES.ZSKB_EMBROIDERED_SHOES = "Embroidered Shoes"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_EMBROIDERED_SHOES = "The spirit returns on the seventh day"

STRINGS.NAMES.ZSKB_HYDRANGEA = "Red Hydrangea"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_HYDRANGEA = "Bridegroom!"

STRINGS.NAMES.ZSKB_INGOT = "Ingot"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_INGOT = "Can it be spent?"

STRINGS.NAMES.ZSKB_REEL = "Scroll"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_REEL = "Read thousands of books, travel thousands of miles"

STRINGS.NAMES.ZSKB_SCISSORS = "Scissors"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_SCISSORS = "Cuts through a tailor's clothes but forgets to gather the leftover words"

STRINGS.NAMES.ZSKB_BROKEN_PAGES1 = "Torn Book Page · One"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BROKEN_PAGES1 = "Too torn to be read"

STRINGS.NAMES.ZSKB_BROKEN_PAGES2 = "Torn Book Page · Two"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BROKEN_PAGES2 = "Too torn to be read"

STRINGS.NAMES.ZSKB_BROKEN_PAGES3 = "Torn Book Page · Three"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_BROKEN_PAGES3 = "Too torn to be read"

STRINGS.NAMES.ZSKB_GHOSTFIRE = "Ghost Fire"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_GHOSTFIRE = "The ghost fire in the dark room is blue, and the bad road is sad"

STRINGS.NAMES.ZSKB_TALISMAN_BOUND_BUGNET = "Talisman-bound Bug Net"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_TALISMAN_BOUND_BUGNET = "A yellow talisman is tied to it"

STRINGS.NAMES.ZSKB_GOURD = "Gourd"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_GOURD = "There's a world inside"

STRINGS.NAMES.ZSKB_WATER_KIKI = "Water Kiki"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_WATER_KIKI = "So ugly!"

STRINGS.NAMES.ZSKB_PAPER_DOLL1 = "Inner Hall Paper Doll · Gourd"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_PAPER_DOLL1 = {
    NORMAL = "Looks quite ordinary",
    HAND = "Holding a gourd in its hand",
    HAND_ANGRY = "I better not touch it",
}
STRINGS.NAMES.ZSKB_PAPER_DOLL1_NORMAL = "Inner Hall Paper Doll · Gourd · Unarmed"
STRINGS.NAMES.ZSKB_PAPER_DOLL1_HAND = "Inner Hall Paper Doll · Gourd · Armed"
STRINGS.NAMES.ZSKB_PAPER_DOLL1_HAND_ANGRY = "Inner Hall Paper Doll · Gourd · Angry"

STRINGS.NAMES.ZSKB_PAPER_DOLL2 = "Inner Hall Paper Doll · Censer"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_PAPER_DOLL2 = {
    NORMAL = "Looks quite ordinary",
    HAND = "Holding a censer in her hand",
    HAND_ANGRY = "I better not touch her",
}
STRINGS.NAMES.ZSKB_PAPER_DOLL2_NORMAL = "Inner Hall Paper Doll · Censer · Unarmed"
STRINGS.NAMES.ZSKB_PAPER_DOLL2_HAND = "Inner Hall Paper Doll · Censer · Armed"
STRINGS.NAMES.ZSKB_PAPER_DOLL2_HAND_ANGRY = "Inner Hall Paper Doll · Censer · Angry"

STRINGS.NAMES.ZSKB_PAPER_DOLL3 = "Inner Hall Paper Doll"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_PAPER_DOLL3 = {
    NORMAL = "Looks quite ordinary",
}

STRINGS.NAMES.ZSKB_PAPER_DOLL4 = "Inner Hall Paper Doll"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_PAPER_DOLL4 = {
    NORMAL = "Looks quite ordinary",
}

STRINGS.NAMES.ZSKB_INCENSE_BURNER = "Incense Burner"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_INCENSE_BURNER = "The incense is burning"

STRINGS.NAMES.ZSKB_COFFIN_NAIL = "Coffin Nail"
STRINGS.RECIPE_DESC.ZSKB_COFFIN_NAIL = "Used for nailing coffins"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_COFFIN_NAIL = "Feels cold to the touch"

STRINGS.NAMES.ZSKB_MOVING_PAPER_DOLL = "Moving Paper Doll"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ZSKB_MOVING_PAPER_DOLL = "Is it moving?"

--------------------------------------------------------------------------
--[[ ACTIONS ]]
--------------------------------------------------------------------------
ACTIONS_ZSKB_TOUCH_GENERIC_STR = "Touch"
ACTIONS_ZSKB_TOUCH_TAKE_STR = "Take"
ACTIONS_ZSKB_ENCASE_GENERIC_STR = "Encase"
ACTIONS_ZSKB_ENCASE_FAIL = "It's already full"
ACTIONS_ZSKB_PLANT_GENERIC_STR = "Plant"
ACTIONS_ZSKB_UMBRELLA_CLOSE_GENERIC_STR = "Close Umbrella"
ACTIONS_ZSKB_UMBRELLA_OPEN_GENERIC_STR = "Open Umbrella"
ACTIONS_ZSKB_ENTER_HOUSE_GENERIC_STR = "Enter"