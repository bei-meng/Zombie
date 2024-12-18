local _G = GLOBAL
local containers = require("containers")
local params = {}
--------------------------------------------------------------------------
--兼容模组"Show Me (中文)"的容器列表
--------------------------------------------------------------------------

local showmeneed = {
    "zskb_gourd",
}

--------------------------------------------------------------------------
--注册容器:葫芦
--------------------------------------------------------------------------
params.zskb_gourd =
{
    widget =
    {
        slotpos = {
            Vector3(-37.5, 32 + 4, 0),
            Vector3(37.5, 32 + 4, 0),
            Vector3(-37.5, -(32 + 4), 0),
            Vector3(37.5, -(32 + 4), 0),
        },
        animbank = "ui_chest_2x2",
        animbuild = "ui_chest_2x2",
        pos = Vector3(0, -250, 0), --容器默认坐标
        side_align_tip = 160,
    },
    type = "zskb_box", --容器类型,可以自定义,不同的容器类型可以同时打开
}

--------------------------------------------------------------------------
--[[ 修改容器注册函数 ]]
--------------------------------------------------------------------------
for k, v in pairs(params) do
    containers.params[k] = v

    --更新容器格子数量的最大值
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end
params = nil --释放内存

--------------------------------------------------------------------------
--mod兼容：Show Me (中文)
--------------------------------------------------------------------------
------以下代码参考自风铃草大佬的穹妹------
--showme优先级如果比本mod高，那么这部分代码会生效
for k, mod in pairs(ModManager.mods) do
    if mod and _G.rawget(mod, "SHOWME_STRINGS") then --showme特有的全局变量
        if
            mod.postinitfns and mod.postinitfns.PrefabPostInit and
            mod.postinitfns.PrefabPostInit.treasurechest
        then
            for _, v in ipairs(showmeneed) do
                mod.postinitfns.PrefabPostInit[v] = mod.postinitfns.PrefabPostInit.treasurechest
            end
        end
        break
    end
end

--showme优先级如果比本mod低，那么这部分代码会生效
TUNING.MONITOR_CHESTS = TUNING.MONITOR_CHESTS or {}
for _, v in ipairs(showmeneed) do
    TUNING.MONITOR_CHESTS[v] = true
end
