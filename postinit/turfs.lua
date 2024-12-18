AddTile(
	"ZSKB_TURF01",
	"LAND",
	{ ground_name = "zskb_turf01" },
	{
		name = "grass",
		atlas = "grass.xml",
		noise_texture = "zskb_turf01_noise.tex",
		runsound = "dontstarve/movement/run_grass",
		walksound = "dontstarve/movement/walk_grass",
		snowsound = "dontstarve/movement/run_snow",
		mudsound = "dontstarve/movement/run_mud",
		flooring = true,
		hard = true,
	},
	{
		name = "grass",
		atlas = "grass.xml",
		noise_texture = "zskb_turf01_noise.tex",
	},
	{
		name = "zskb_turf01", -- Inventory item
		anim = "turf01", -- Ground item
		bank_build = "zskb_turfs",
		pickupsound = "cloth",
	}
)
ChangeTileRenderOrder(GLOBAL.WORLD_TILES.ZSKB_TURF01, GLOBAL.WORLD_TILES.GRASS)
ChangeMiniMapTileRenderOrder(GLOBAL.WORLD_TILES.ZSKB_TURF01, GLOBAL.WORLD_TILES.GRASS)

STRINGS.NAMES.TURF_ZSKB_TURF01 = "地皮01"
STRINGS.RECIPE_DESC.TURF_ZSKB_TURF01 = "这是地皮01"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TURF_ZSKB_TURF01 = "这是地皮01"

AddRecipe2(
	"turf_zskb_turf01",
	{ Ingredient("log", 1), Ingredient("rope", 2) },
	TECH.TURFCRAFTING_TWO,
	{
		atlas = "images/zskb_inventoryimages.xml",
		image = "zskb_turf01.tex",
		numtogive = 4,
	},
	{ "DECOR" }
)

AddPrefabPostInit("turf_zskb_turf01", function(inst)
	if not TheWorld.ismastersim then
		return inst
	end
	if inst.components.inventoryitem ~= nil then
		inst.components.inventoryitem.atlasname = "images/zskb_inventoryimages.xml"
		inst.components.inventoryitem.imagename = "zskb_turf01"
	end
end)
