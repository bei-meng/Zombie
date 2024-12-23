Gyde的备忘录:
1.红包随机生成在玩家附近的设定还未添加
2.红包诅咒解除的设定还未添加
3.红包诅咒期间，开启洞穴的情况下玩家鼠标悬浮在装备上不是显示检查
4.榕树用火药摧毁的机制暂未完成


动画制作:(Gyde把动画做好,方便直接取用,专心码代码)
一个可以在线预览饥荒动画包的网址: https://dont-starve-anim-tool.vercel.app/ 打开zip包
一个可以在线预览饥荒贴图集的网址: https://dont-starve-anim-tool.vercel.app/src/TexTool/index.html 请分别打开tex和xml
符箓篇：
    破煞符：
        动画包:zskb_break_talisman.zip
        build:zskb_break_talisman
        bank:zskb_break_talisman
        动画:
            闲置动画:idle
        贴图:
            源:zskb_inventoryimages.tex | zskb_inventoryimages.xml
            合集中的名称(请prefab名称与其保持一致):zskb_break_talisman
        (以下未标明贴图来源的,均来自该贴图集,prefab名必须与合集里的名字相同)

    镇煞符:
        动画包:zskb_seal_talisman.zip
        build:zskb_seal_talisman
        bank:zskb_seal_talisman
        动画:
            闲置动画:idle
        贴图:
            合集中的名称:zskb_seal_talisman

    鬼画符:
        动画包:zskb_ghost_talisman.zip
        build:zskb_ghost_talisman
        bank:zskb_ghost_talisman
        动画:
            闲置动画:idle
        贴图:
            合集中的名称:zskb_ghost_talisman
    
    五雷符:
        动画包:zskb_thunder_talisman.zip
        build:zskb_thunder_talisman
        bank:zskb_thunder_talisman
        动画:
            闲置动画:idle
        贴图:
            合集中的名称:zskb_thunder_talisman
    
    离火符:
        动画包:zskb_fire_talisman.zip
        build:zskb_fire_talisman
        bank:zskb_fire_talisman
        动画:
            闲置动画:idle
        贴图:
            合集中的名称:zskb_fire_talisman

    五鬼搬运符:(建议创建两个prefab,一个是符的prefab,一个是符打包后的prefab)
        画包:zskb_five_ghosts_talisman.zip
        build:zskb_five_ghosts_talisman
        bank:zskb_five_ghosts_talisman
        动画:
            闲置动画:idle
            打包动画:package
        贴图:
            合集中的名称:
                zskb_five_ghosts_talisman(五鬼搬运符贴图)
                zskb_ghost_package(打包后的贴图)