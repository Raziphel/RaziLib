local Core = require("__razi_lib__/lib/core")
local Settings = {}

local function setting_table(setting_type)
  if setting_type == "startup" then return settings and settings.startup end
  if setting_type == "runtime-global" then return settings and settings.global end
  if setting_type == "runtime-per-user" then return settings and settings.get_player_settings end
end

function Settings.value(name, fallback, setting_type, player)
  setting_type = setting_type or "startup"
  local source = setting_table(setting_type)
  if setting_type == "runtime-per-user" then
    source = source and source(player)
  end
  local setting = source and source[name]
  if setting ~= nil and setting.value ~= nil then return setting.value end
  return fallback
end

function Settings.enabled(name, fallback, setting_type, player)
  return Settings.value(name, fallback == nil and false or fallback, setting_type, player) == true
end

function Settings.bool(name, setting_type, default_value, order, extra)
  return Core.merge({
    type = "bool-setting", name = name, setting_type = setting_type,
    default_value = default_value, order = order,
  }, extra or {}, true)
end

function Settings.string(name, setting_type, default_value, allowed_values, order, extra)
  return Core.merge({
    type = "string-setting", name = name, setting_type = setting_type,
    default_value = default_value, allowed_values = allowed_values, order = order,
  }, extra or {}, true)
end

function Settings.int(name, setting_type, default_value, minimum, maximum, order, extra)
  return Core.merge({
    type = "int-setting", name = name, setting_type = setting_type,
    default_value = default_value, minimum_value = minimum, maximum_value = maximum, order = order,
  }, extra or {}, true)
end

function Settings.double(name, setting_type, default_value, minimum, maximum, order, extra)
  return Core.merge({
    type = "double-setting", name = name, setting_type = setting_type,
    default_value = default_value, minimum_value = minimum, maximum_value = maximum, order = order,
  }, extra or {}, true)
end

return Settings
