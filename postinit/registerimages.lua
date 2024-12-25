local r1_table =
{
    "zskb_broken_pages1",
    "zskb_broken_pages2",
    "zskb_broken_pages3",
    "zskb_bell",
    "zskb_blessing",
    "zskb_bull_head_statue",
    "zskb_comb",
    "zskb_embroidered_shoes",
    "zskb_hydrangea",
    "zskb_ingot",
    "zskb_reel",
    "zskb_scissors",
    "zskb_banyantree",
    "zskb_banyantree_normal",
    "zskb_banyantree_short",
    "zskb_banyantree_stump",
    "zskb_banyantree_pillar",
    "zskb_baihu",
    "zskb_banyantreenut",
    "zskb_bead",
    "zskb_black_copper_coin",
    "zskb_black_copper_coin_mask",
    "zskb_brightly_light",
    "zskb_brightly_light_off",
    "zskb_candle",
    "zskb_cedartree_none",
    "zskb_coffin",
    "zskb_copper_coin",
    "zskb_copper_coin_mask",
    "zskb_copper_coin_umbrella_close",
    "zskb_copper_coin_umbrella_open",
    "zskb_copper_crane_platform",
    "zskb_cured_meat_rice",
    "zskb_fireproof_runepaper",
    "zskb_grave_child",
    "zskb_grave_normal",
    "zskb_grave_older",
    "zskb_mountain_spirit_house",
    "zskb_mountain_spirit_mask",
    "zskb_mountain_spirit_skull",
    "zskb_paper",
    "zskb_peach_steam_bun",
    "zskb_qinglong",
    "zskb_rabbit_steam_bun",
    "zskb_red_packet1",
    "zskb_red_packet2",
    "zskb_return_life_pill",
    "zskb_roast_duck",
    "zskb_rune_paper_umbrella",
    "zskb_sausage",
    "zskb_sausage_dried",
    "zskb_turf01",
    "zskb_vegetable_spring_roll",
    "zskb_xuanwu",
    "zskb_yin_runepaper",
    "zskb_zhuque",
    "zskb_zombie",
    "zskb_mountain_spirit_house_exit",
    "zskb_copper_coin_umbrella",
    "zskb_ghostfire",
    "zskb_talisman_bound_bugnet",
    "zskb_gourd",
    "zskb_water_kiki",
    "zskb_paper_doll1",
    "zskb_paper_doll1_normal",
    "zskb_paper_doll1_hand",
    "zskb_paper_doll1_hand_angry",
    "zskb_paper_doll2",
    "zskb_paper_doll2_normal",
    "zskb_paper_doll2_hand",
    "zskb_paper_doll2_hand_angry",
    "zskb_paper_doll3",
    "zskb_paper_doll4",
    "zskb_incense_burner",
    "zskb_coffin_nail",
    "zskb_moving_paper_doll",
    "zskb_paper_money",
    "zskb_paper_moon",
    "zskb_fire_basin",
    "zskb_break_talisman",
    "zskb_seal_talisman",
}

for _, v in ipairs(r1_table) do
    RegisterInventoryItemAtlas(GLOBAL.resolvefilepath("images/zskb_inventoryimages.xml"), v .. ".tex")
end
