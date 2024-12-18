local L = locale ~= "zh" and locale ~= "zhr" --true-英文; false-中文
name = L and "Zombie" or "僵尸"
description = "中式恐怖人物主题模组"
author = "Backpfeifengesicht"
version = "1.1.5"

forumthread = ""

api_version = 10

dst_compatible = true

dont_starve_compatible = false
reign_of_giants_compatible = false

all_clients_require_mod = true

icon_atlas = "images/modicon.xml"
icon = "modicon.tex"

server_filter_tags = {
    "僵尸", "Zombie"
}

configuration_options = { {
    name = "language",
    label = L and "Language" or "语言",
    hover = "",
    options = { {
        description = "中文",
        data = "zhs",
        hover = ""
    }, {
        description = "English",
        data = "en",
        hover = ""
    } },
    default = "zhs"
} }
