local Events = require("__razi_lib__/runtime/events")
local Storage = require("__razi_lib__/runtime/storage")

local state = Storage.namespace("example_mod", { joins = 0 })
local events = Events.new()

events:on_event(defines.events.on_player_joined_game, function()
  state:update("joins", function(value) return value + 1 end, 0)
end)

events:install()
