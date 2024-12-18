local assets =
{
	Asset("ANIM", "anim/zskb_zombie.zip"),
	Asset("ANIM", "anim/ghost_zskb_zombie_build.zip"),
}

local skins =
{
	normal_skin = "zskb_zombie",
	ghost_skin = "ghost_zskb_zombie_build",
}

local base_prefab = "zskb_zombie"

local tags = { "base", "zskb_zombie", "character" }

return CreatePrefabSkin("zskb_zombie_none",
	{
		base_prefab = base_prefab,
		skins = skins,
		assets = assets,
		skin_tags = tags,

		build_name_override = "zskb_zombie",
		rarity = "Character",
	})
