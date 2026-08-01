local Events = {}

local function append(map, key, handler)
  map[key] = map[key] or {}
  map[key][#map[key] + 1] = handler
end

function Events.new()
  local registry = {
    events = {}, nth_tick = {}, init = {}, load = {}, configuration_changed = {},
    installed = false,
  }

  function registry:on_event(event_ids, handler)
    if type(event_ids) ~= "table" then event_ids = { event_ids } end
    for _, event_id in ipairs(event_ids) do append(self.events, event_id, handler) end
    return self
  end

  function registry:on_nth_tick(interval, handler)
    append(self.nth_tick, interval, handler)
    return self
  end

  function registry:on_init(handler) self.init[#self.init + 1] = handler; return self end
  function registry:on_load(handler) self.load[#self.load + 1] = handler; return self end
  function registry:on_configuration_changed(handler)
    self.configuration_changed[#self.configuration_changed + 1] = handler
    return self
  end

  function registry:include(module)
    if module.register_events then module.register_events(self) end
    if module.on_init then self:on_init(module.on_init) end
    if module.on_load then self:on_load(module.on_load) end
    if module.on_configuration_changed then
      self:on_configuration_changed(module.on_configuration_changed)
    end
    return self
  end

  function registry:install(script_api)
    assert(not self.installed, "RAZI event registry is already installed")
    script_api = script_api or script
    for event_id, handlers in pairs(self.events) do
      script_api.on_event(event_id, function(event)
        for _, handler in ipairs(handlers) do handler(event) end
      end)
    end
    for interval, handlers in pairs(self.nth_tick) do
      script_api.on_nth_tick(interval, function(event)
        for _, handler in ipairs(handlers) do handler(event) end
      end)
    end
    if #self.init > 0 then script_api.on_init(function()
      for _, handler in ipairs(self.init) do handler() end
    end) end
    if #self.load > 0 then script_api.on_load(function()
      for _, handler in ipairs(self.load) do handler() end
    end) end
    if #self.configuration_changed > 0 then script_api.on_configuration_changed(function(event)
      for _, handler in ipairs(self.configuration_changed) do handler(event) end
    end) end
    self.installed = true
    return self
  end

  return registry
end

return Events
