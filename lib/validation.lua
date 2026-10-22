local Validation = {}

local function entry_name(entry) return entry and (entry.name or entry[1]) end
local function variants(recipe)
  local found = { recipe }
  if recipe.normal then found[#found+1] = recipe.normal end
  if recipe.expensive then found[#found+1] = recipe.expensive end
  return found
end


function Validation.prototype(prototype_type, name, message)
  local found = data.raw[prototype_type] and data.raw[prototype_type][name]
  if not found then error(message or ("Missing prototype %s.%s"):format(prototype_type, name)) end
  return found
end

function Validation.ingredient(recipe_name, ingredient_name, message)
  local recipe = Validation.prototype("recipe",recipe_name)
  for _, variant in ipairs(variants(recipe)) do
    for _, ingredient in ipairs(variant.ingredients or {}) do
      if entry_name(ingredient) == ingredient_name then return ingredient end
    end
  end
  error(message or (recipe_name.." must consume "..ingredient_name))
end

function Validation.result(recipe_name, result_name, message)
  local recipe = Validation.prototype("recipe",recipe_name)
  for _, variant in ipairs(variants(recipe)) do
    if variant.result == result_name then
      return {type="item",name=result_name,amount=variant.result_count or 1}
    end
    for _, product in ipairs(variant.results or {}) do
      if entry_name(product) == result_name then return product end
    end
  end
  error(message or (recipe_name.." must produce "..result_name))
end

function Validation.unlock(technology_name, recipe_name, message)
  local technology = Validation.prototype("technology", technology_name)
  for _, effect in pairs(technology.effects or {}) do
    if effect.type == "unlock-recipe" and effect.recipe == recipe_name then return effect end
  end
  error(message or (technology_name .. " must unlock " .. recipe_name))
end

function Validation.prerequisite(technology_name, prerequisite_name, message)
  local technology = Validation.prototype("technology", technology_name)
  for _, name in pairs(technology.prerequisites or {}) do
    if name == prerequisite_name then return name end
  end
  error(message or (technology_name .. " must require " .. prerequisite_name))
end

function Validation.no_duplicate_names(list, label)
  local seen = {}
  for _, entry in pairs(list or {}) do
    local name = entry_name(entry)
    if name == nil then error((label or "list") .. " contains an entry without a name") end
    if seen[name] then error((label or "list") .. " contains duplicate " .. tostring(name)) end
    seen[name] = true
  end
  return true
end

return Validation
