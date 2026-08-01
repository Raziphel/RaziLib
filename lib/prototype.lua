local Core = require("__razi_lib__/lib/core")

local Prototype = {}
local methods = {}

local function raw_group(prototype_type)
  if not Core.stage_has_data() then error("RAZI prototype helpers require the data stage", 3) end
  return data.raw[prototype_type]
end

function Prototype.exists(prototype_type, name)
  local group = raw_group(prototype_type)
  return group ~= nil and group[name] ~= nil
end

function Prototype.raw(prototype_type, name)
  local group = raw_group(prototype_type)
  return group and group[name] or nil
end

function Prototype.wrap(prototype_type, name, prototype, extra_methods)
  local wrapper = { _type = prototype_type, _name = name, _prototype = prototype }
  return setmetatable(wrapper, {
    __foundry_methods = extra_methods,
    __index = function(_, key)
      return (extra_methods and extra_methods[key]) or methods[key] or prototype[key]
    end,
    __newindex = function(_, key, value) prototype[key] = value end,
    __pairs = function() return pairs(prototype) end,
  })
end

function Prototype.get(prototype_type, name, extra_methods)
  Core.assert_string(prototype_type, "prototype type")
  Core.assert_string(name, "prototype name")
  local prototype = Prototype.raw(prototype_type, name)
  assert(prototype, ("Prototype '%s.%s' not found"):format(prototype_type, name))
  return Prototype.wrap(prototype_type, name, prototype, extra_methods)
end

function Prototype.optional(prototype_type, name, extra_methods)
  local prototype = Prototype.raw(prototype_type, name)
  return prototype and Prototype.wrap(prototype_type, name, prototype, extra_methods) or nil
end

function Prototype.clone(prototype_type, from, into)
  Core.assert_string(into, "clone name")
  local source = Prototype.raw(prototype_type, from)
  assert(source, ("Cannot clone missing prototype '%s.%s'"):format(prototype_type, from))
  local clone = Core.deepcopy(source)
  clone.name = into
  data.raw[prototype_type] = data.raw[prototype_type] or {}
  data.raw[prototype_type][into] = clone
  return clone
end

function Prototype.each(prototype_type, callback)
  for _, name in ipairs(Core.sorted_keys(raw_group(prototype_type) or {})) do
    callback(Prototype.get(prototype_type, name), name)
  end
end

function methods:raw() return self._prototype end

function methods:clone(into)
  Prototype.clone(self._type, self._name, into)
  return Prototype.get(self._type, into, getmetatable(self).__foundry_methods)
end

function methods:set(values)
  Core.merge(self._prototype, values, true)
  return self
end

function methods:set_icon(path, size)
  self._prototype.icons = nil
  self._prototype.icon = path
  self._prototype.icon_size = size
  return self
end

function methods:set_icons(icons)
  self._prototype.icon = nil
  self._prototype.icon_size = nil
  self._prototype.icons = Core.deepcopy(icons)
  return self
end

function methods:hide()
  self._prototype.hidden = true
  if self._type == "recipe" then self._prototype.enabled = false end
  return self
end

function methods:remove()
  data.raw[self._type][self._name] = nil
  return nil
end

methods.setIcon = methods.set_icon
methods.setIcons = methods.set_icons

return Prototype
