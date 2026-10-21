-- Runs on top of the base config of GreenTech-Solutions/factorio-mod-tools (lua/luacheckrc.lua), which sets
-- std = "lua52", the Factorio globals and allow_defined_top: add to its tables here.

-- tests/run.lua runs outside the game and defines the Factorio globals it needs: table.deepcopy and settings
files["tests/run.lua"] = { ignore = { "121", "122" } }
