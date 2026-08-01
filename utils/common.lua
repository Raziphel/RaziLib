-- Compatibility facade for projects migrating from older utility libraries.
local Prototype = require("__razi_lib__/lib/prototype")
local Settings = require("__razi_lib__/lib/settings")

return {
  config = function(name) return Settings.value(name) end,
  cloneInto = function(prototype_type, from, into)
    return Prototype.clone(prototype_type, from, into)
  end,
}
