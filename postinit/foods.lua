AddIngredientValues({ "zskb_sausage", "zskb_sausage_dried" }, { meat = 1 })

local foods = require("zskb_preparedfoods")
for k, recipe in pairs(foods) do
    AddCookerRecipe("cookpot", recipe)
    AddCookerRecipe("portablecookpot", recipe)
    AddCookerRecipe("archive_cookpot", recipe)

    if recipe.card_def then
        AddRecipeCard("cookpot", recipe)
    end
end

local spicedfoods = require("spicedfoods")
GenerateSpicedFoods(require("zskb_preparedfoods"))
for k, recipe in pairs(spicedfoods) do
    if recipe.mod and recipe.mod == "zskb" then
        recipe.official = false
        AddCookerRecipe("portablespicer", recipe)
    end
end
-- 兼容Craft Pot
if RegisterFoodAtlas ~= nil then
    RegisterFoodAtlas("zskb_sausage", "zskb_sausage.tex", GLOBAL.resolvefilepath("images/zskb_inventoryimages.xml"))
    RegisterFoodAtlas("zskb_sausage_dried", "zskb_sausage_dried.tex", GLOBAL.resolvefilepath("images/zskb_inventoryimages.xml"))
end
