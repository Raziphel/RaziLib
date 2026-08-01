local Recipe = require("__razi_lib__/lib/recipe")
local Technology = require("__razi_lib__/lib/technology")
local Validation = require("__razi_lib__/lib/validation")

local recipe = Recipe.optional("example-recipe")
if recipe then
  recipe:upsert_ingredient({ type = "item", name = "iron-plate", amount = 2 })
    :set_energy(1.5)
end

local technology = Technology.optional("example-technology")
if technology then
  technology:add_prerequisite("automation")
    :unlock("example-recipe")
end

if recipe and technology then Validation.unlock("example-technology", "example-recipe") end
