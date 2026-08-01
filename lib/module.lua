local Core = require("__razi_lib__/lib/core")
local Prototype = require("__razi_lib__/lib/prototype")

local Module = {}
local methods = {}

local function requested_name(self_or_name, maybe_name) return maybe_name or self_or_name end
function Module.get(self_or_name, maybe_name)
  return Prototype.get("module", requested_name(self_or_name, maybe_name), methods)
end
function Module.optional(self_or_name, maybe_name)
  return Prototype.optional("module", requested_name(self_or_name, maybe_name), methods)
end
function Module.clone(self_or_from, from_or_into, maybe_into)
  local from = maybe_into and from_or_into or self_or_from
  local into = maybe_into or from_or_into
  Prototype.clone("module", from, into)
  return Module.get(into)
end
Module.cloneInto = Module.clone

function methods:set_effect(effect) self._prototype.effect = Core.deepcopy(effect); return self end
function methods:set_category(category) self._prototype.category = category; return self end
function methods:set_tier(tier) self._prototype.tier = tier; return self end
methods.setEffect = methods.set_effect
methods.setIcon = function(self, path, size) return self:set_icon(path, size) end

return Module
