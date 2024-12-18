local Layouts = require("map/layouts").Layouts
local StaticLayout = require("map/static_layout")

-- local DefaultStart = require("map/static_layouts/default_start")
-- table.insert(DefaultStart.layers[2].objects, {
--     name = "",
--     type = "zskb_vegetable_spring_roll",
--     shape = "rectangle",
--     x = 192,
--     y = 150,
--     width = 0,
--     height = 0,
--     visible = true,
--     properties = {}
-- })

Layouts["zskb_grave_child"] = StaticLayout.Get("map/static_layouts/zskb_grave_child")
Layouts["zskb_grave_normal"] = StaticLayout.Get("map/static_layouts/zskb_grave_normal")
Layouts["zskb_grave_older"] = StaticLayout.Get("map/static_layouts/zskb_grave_older")

Layouts["zskb_mountain_spirit_house"] = StaticLayout.Get("map/static_layouts/zskb_mountain_spirit_house")

AddRoom("zskb_cedar_forest_grave_child", {
    colour = { r = 0.3, g = .5, b = .5, a = .3 },
    value = WORLD_TILES.FOREST,
    contents = {
        countprefabs = {
        },
        countstaticlayouts = {
            ["zskb_grave_child"] = 1,
        },
        distributepercent = .1,
        distributeprefabs = {
            --           lichen = 0.025, --苔藓
            sapling = 0.05,          --树枝
            grass = 0.05,            --草
            twigs = 0.05,            --采集的树枝
            berrybush_juicy = 0.025, --高浆果
            berrybush = 0.025,       -- 浆果
            gravestone = 0.05,       --墓
        },
    }
})
AddRoom("zskb_cedar_forest_grave_normal", {
    colour = { r = 0.3, g = .5, b = .5, a = .3 },
    value = WORLD_TILES.FOREST,
    contents = {
        countprefabs = {
        },
        countstaticlayouts = {
            ["zskb_grave_normal"] = 1,
        },
        distributepercent = .1,
        distributeprefabs = {
            --            lichen = 0.025, --苔藓
            sapling = 0.05,          --树枝
            grass = 0.05,            --草
            twigs = 0.05,            --采集的树枝
            berrybush_juicy = 0.025, --高浆果
            berrybush = 0.025,       -- 浆果
            gravestone = 0.05,       --墓
        },
    }
})
AddRoom("zskb_cedar_forest_grave_older", {
    colour = { r = 0.3, g = .5, b = .5, a = .3 },
    value = WORLD_TILES.FOREST,
    contents = {
        countprefabs = {
        },
        countstaticlayouts = {
            ["zskb_grave_older"] = 1,
        },
        distributepercent = .1,
        distributeprefabs = {
            --            lichen = 0.025, --苔藓
            sapling = 0.05,          --树枝
            grass = 0.05,            --草
            twigs = 0.05,            --采集的树枝
            berrybush_juicy = 0.025, --高浆果
            berrybush = 0.025,       -- 浆果
            gravestone = 0.05,       --墓
        },
    }
})
AddRoom("zskb_cedar_forest_mountain_spirit_house", {
    colour = { r = 0.3, g = .5, b = .5, a = .3 },
    value = WORLD_TILES.FOREST,
    contents = {
        countprefabs = {
        },
        countstaticlayouts = {
            ["zskb_mountain_spirit_house"] = 1,
        },
        distributepercent = .1,
        distributeprefabs = {
            --            lichen = 0.025, --苔藓
            sapling = 0.05,          --树枝
            grass = 0.05,            --草
            twigs = 0.05,            --采集的树枝
            berrybush_juicy = 0.025, --高浆果
            berrybush = 0.025,       -- 浆果
            gravestone = 0.05,       --墓
        },
    }
})
AddRoom("zskb_room_CedarForest", {
    colour = { r = 0.8, g = 1, b = .8, a = .50 },
    value = WORLD_TILES.FOREST,
    -- tags = {"Town"},
    contents = {
        countprefabs = {
            zskb_cedartree = function() return 1 + math.random(4) end,
        },
        countstaticlayouts = {
        },
        distributepercent = .3,
        distributeprefabs = {
            --            lichen = 0.025, --苔藓
            sapling = 0.05,          --树枝
            grass = 0.05,            --草
            twigs = 0.05,            --采集的树枝
            berrybush_juicy = 0.025, --高浆果
            berrybush = 0.025,       -- 浆果
            gravestone = 0.05,       --墓
            --            zskb_cedartree = 0.001 --杉树
        },
    }
})
AddTask("zskb_task_CedarForest", {
    locks = LOCKS.NONE,
    keys_given = {},
    room_choices = {
        ["zskb_room_CedarForest"] = 6,
        ["zskb_cedar_forest_grave_child"] = 1,
        ["zskb_cedar_forest_grave_normal"] = 1,
        ["zskb_cedar_forest_grave_older"] = 1,
        ["zskb_cedar_forest_mountain_spirit_house"] = 1,
    },
    room_bg = WORLD_TILES.FOREST,
    background_room = "zskb_room_CedarForest",
    colour = { r = 1, g = 1, b = 1, a = 1 }
})
AddTaskSetPreInitAny(function(taskset)
    if taskset.location == "forest" then
        if taskset.tasks ~= nil then
            table.insert(taskset.tasks, "zskb_task_CedarForest")
        end
    end
end)
