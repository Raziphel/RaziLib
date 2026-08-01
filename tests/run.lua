local native_require = require

function require(name)
  return native_require((name:gsub("^__razi_lib__/", "")))
end

table.deepcopy = function(value)
  if type(value) ~= "table" then return value end
  local copy = {}
  for key, entry in pairs(value) do copy[table.deepcopy(key)] = table.deepcopy(entry) end
  return copy
end

data = {
  raw = {
    recipe = {
      alpha = { type = "recipe", name = "alpha", ingredients = { { "iron-plate", 1 } }, result = "gear" },
      beta = { type = "recipe", name = "beta", ingredients = {}, results = {} },
    },
    technology = {
      automation = { type = "technology", name = "automation", unit = { count = 10, ingredients = {}, time = 30 } },
      logistics = { type = "technology", name = "logistics", unit = { count = 20, ingredients = {}, time = 30 } },
    },
    item = {
      gear = { type = "item", name = "gear", stack_size = 100 },
      plate = { type = "item", name = "plate", stack_size = 100 },
    },
  },
}

local passed = 0
local function test(name, callback)
  local ok, message = pcall(callback)
  if not ok then error(("FAIL %s: %s"):format(name, message), 0) end
  passed = passed + 1
end

local Recipe = require("__razi_lib__/lib/recipe")
local Technology = require("__razi_lib__/lib/technology")
local Prototype = require("__razi_lib__/lib/prototype")

test("wrappers retain independent targets", function()
  local alpha = Recipe.get("alpha")
  local beta = Recipe.get("beta")
  alpha:set_energy(2)
  beta:set_energy(7)
  assert(data.raw.recipe.alpha.energy_required == 2)
  assert(data.raw.recipe.beta.energy_required == 7)
end)

test("recipe edits normalize legacy results", function()
  Recipe.get("alpha")
    :upsert_ingredient({ name = "copper-plate", amount = 2 })
    :add_result("plate", 3)
  assert(data.raw.recipe.alpha.result == nil)
  assert(data.raw.recipe.alpha.results[1].name == "gear")
  assert(data.raw.recipe.alpha.results[2].name == "plate")
end)

test("technology edits are idempotent", function()
  Technology.get("automation")
    :add_prerequisite("logistics")
    :add_prerequisite("logistics")
    :unlock("alpha")
    :unlock("alpha")
    :set_colors("RGB")
  assert(#data.raw.technology.automation.prerequisites == 1)
  assert(#data.raw.technology.automation.effects == 1)
  assert(#data.raw.technology.automation.unit.ingredients == 3)
end)

test("generic clones and wrappers remain typed", function()
  local clone = Recipe.get("beta"):clone("gamma"):set_energy(4)
  assert(clone.name == "gamma")
  assert(data.raw.recipe.gamma.energy_required == 4)
  Prototype.get("item", "gear"):clone("gear-copy"):set({ stack_size = 20 })
  assert(data.raw.item["gear-copy"].stack_size == 20)
end)

test("settings helpers preserve false and zero", function()
  settings = { startup = { enabled = { value = false }, count = { value = 0 } } }
  local Settings = require("__razi_lib__/lib/settings")
  assert(Settings.value("enabled", true) == false)
  assert(Settings.value("count", 9) == 0)
end)

test("event registry composes multiple consumers", function()
  local calls = {}
  local script_api = {}
  function script_api.on_event(id, handler) calls.event_id, calls.event = id, handler end
  function script_api.on_nth_tick(id, handler) calls.nth_id, calls.nth = id, handler end
  function script_api.on_init(handler) calls.init = handler end
  function script_api.on_load(handler) calls.load = handler end
  function script_api.on_configuration_changed(handler) calls.changed = handler end
  local Events = require("__razi_lib__/runtime/events")
  local registry = Events.new()
  local total = 0
  registry:on_event(5, function() total = total + 1 end)
  registry:on_event(5, function() total = total + 2 end)
  registry:on_init(function() total = total + 4 end):install(script_api)
  calls.event({})
  calls.init()
  assert(total == 7)
end)

test("storage namespaces isolate defaults", function()
  storage = {}
  local Storage = require("__razi_lib__/runtime/storage")
  local state = Storage.namespace("example", { count = 1 })
  assert(state:update("count", function(value) return value + 2 end) == 3)
  assert(storage.example.count == 3)
end)

io.write(("RAZI Library: %d tests passed\n"):format(passed))
