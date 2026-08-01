local Core = require("__razi_lib__/lib/core")
local Storage = {}

function Storage.namespace(name, defaults)
  Core.assert_string(name, "storage namespace")
  local namespace = { name = name, defaults = defaults or {} }

  function namespace:ensure()
    assert(type(storage) == "table", "RAZI storage helpers require runtime storage")
    storage[self.name] = storage[self.name] or Core.deepcopy(self.defaults)
    return storage[self.name]
  end

  function namespace:get(key, fallback)
    local state = self:ensure()
    local value = state[key]
    return value == nil and fallback or value
  end

  function namespace:set(key, value)
    self:ensure()[key] = value
    return value
  end

  function namespace:update(key, updater, fallback)
    local state = self:ensure()
    state[key] = updater(state[key] == nil and fallback or state[key])
    return state[key]
  end

  function namespace:reset()
    storage[self.name] = Core.deepcopy(self.defaults)
    return storage[self.name]
  end

  return namespace
end

return Storage
