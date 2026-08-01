local Core = require("__razi_lib__/lib/core")
local Prototype = require("__razi_lib__/lib/prototype")
local Collections = require("__razi_lib__/lib/collections")

local Entity = {}
local methods = {}

function Entity.get(prototype_type, name) return Prototype.get(prototype_type, name, methods) end
function Entity.optional(prototype_type, name) return Prototype.optional(prototype_type, name, methods) end
function Entity.clone(prototype_type, from, into)
  Prototype.clone(prototype_type, from, into)
  return Entity.get(prototype_type, into)
end

function methods:set_energy_usage(value) self._prototype.energy_usage = value; return self end
function methods:set_energy_source(source) self._prototype.energy_source = Core.deepcopy(source); return self end
function methods:set_crafting_speed(speed) self._prototype.crafting_speed = speed; return self end
function methods:set_crafting_categories(categories)
  self._prototype.crafting_categories = Core.deepcopy(categories)
  return self
end
function methods:add_crafting_category(category)
  self._prototype.crafting_categories = Collections.append_unique(
    self._prototype.crafting_categories or {}, category
  )
  return self
end
function methods:set_module_slots(slots)
  self._prototype.module_slots = slots
  return self
end
function methods:set_effect_receiver(receiver)
  self._prototype.effect_receiver = Core.deepcopy(receiver)
  return self
end
function methods:set_surface_conditions(conditions)
  self._prototype.surface_conditions = Core.deepcopy(conditions)
  return self
end

return Entity
