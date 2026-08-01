local Prototype = require("__razi_lib__/lib/prototype")

local Item = {}
local methods = {}
local item_types = {
  "item", "ammo", "armor", "capsule", "gun", "module", "tool", "repair-tool",
  "item-with-entity-data", "item-with-inventory", "item-with-label", "item-with-tags",
  "rail-planner", "spidertron-remote", "selection-tool", "blueprint", "blueprint-book",
  "copy-paste-tool", "deconstruction-item", "upgrade-item",
}

function Item.find(name)
  for _, prototype_type in ipairs(item_types) do
    if data.raw[prototype_type] and data.raw[prototype_type][name] then
      return Prototype.get(prototype_type, name, methods)
    end
  end
end

function Item.get(name, prototype_type)
  if prototype_type then return Prototype.get(prototype_type, name, methods) end
  return assert(Item.find(name), "Item '" .. name .. "' not found")
end

function Item.optional(name, prototype_type)
  return prototype_type and Prototype.optional(prototype_type, name, methods) or Item.find(name)
end

function methods:set_stack_size(size) self._prototype.stack_size = size; return self end
function methods:set_weight(weight) self._prototype.weight = weight; return self end
function methods:set_subgroup(subgroup, order)
  self._prototype.subgroup = subgroup
  if order then self._prototype.order = order end
  return self
end
function methods:set_place_result(entity_name) self._prototype.place_result = entity_name; return self end
function methods:set_spoil_quality(minimum, maximum, change)
  self._prototype.spoil_quality_min = minimum
  self._prototype.spoil_quality_max = maximum
  self._prototype.spoil_quality_change = change
  return self
end

return Item
