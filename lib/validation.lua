local Validation = {}

local function entry_name(entry) return entry and (entry.name or entry[1]) end

function Validation.prototype(prototype_type, name, message)
  local found = data.raw[prototype_type] and data.raw[prototype_type][name]
  if not found then error(message or ("Missing prototype %s.%s"):format(prototype_type, name)) end
  return found
end

function Validation.ingredient(recipe_name, ingredient_name, message)
  local recipe = Validation.prototype("recipe", recipe_name)
  for _, ingredient in pairs(recipe.ingredients or {}) do
    if entry_name(ingredient) == ingredient_name then return ingredient end
  end
  error(message or (recipe_name .. " must consume " .. ingredient_name))
end

function Validation.result(recipe_name, result_name, message)
  local recipe = Validation.prototype("recipe", recipe_name)
  for _, result in pairs(recipe.results or {}) do
    if entry_name(result) == result_name then return result end
  end
  error(message or (recipe_name .. " must produce " .. result_name))
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
    if seen[name] then error((label or "list") .. " contains duplicate " .. tostring(name)) end
    seen[name] = true
  end
  return true
end

return Validation
