# RAZI Library

**RAZI** stands for **Reusable Architecture & Zero-friction Infrastructure**.

RAZI Library (`razi_lib`) is Raziphel's shared Factorio 2.1 foundation. It
provides opt-in helpers and makes no gameplay changes by itself.

## Design promises

- Passive by default: consumers require only the modules they use.
- Instance-safe wrappers: chained edits never share a hidden "current" target.
- Exact or optional lookup: use `get` when absence is a bug and `optional` for compatibility.
- Idempotent collection edits: prerequisites, unlocks, and upserts avoid duplicates.
- Native Factorio data: helpers return or mutate ordinary prototype tables.
- No Space Age dependency: Space Age science codes are available but only used on request.
- Snake-case API with compatibility aliases for straightforward migrations.

## Dependency

```json
"dependencies": ["razi_lib >= 1.2.0"]
```

## Quick start

```lua
local Recipe = require("__razi_lib__/lib/recipe")
local Technology = require("__razi_lib__/lib/technology")
local Icons = require("__razi_lib__/lib/icons")

Recipe.get("iron-gear-wheel")
  :upsert_ingredient({ type = "item", name = "steel-plate", amount = 1 })
  :set_energy(1)
  :set_modules("ESPQ")

Technology.get("automation")
  :add_prerequisite("steel-processing")
  :unlock("my-recipe")

local icons = Icons.compose("__base__/graphics/icons/iron-plate.png", 64, {
  Icons.badge("__base__/graphics/icons/copper-plate.png", 64, "bottom-right"),
})
```

See [API.md](API.md) for the complete module map and migration notes.

## Safe technology graph operations

```lua
local Graph = require("__razi_lib__/lib/technology_graph")
local techs = data.raw.technology
if not Graph.reaches(techs, "new-industry", "existing-industry") then
  Graph.add_prerequisite(techs, "new-industry", "existing-industry")
end
local existing_cycle = Graph.find_cycle(techs)
-- A source-specific compatibility module must decide whether to repair it.
```

The iterative traversal handles thousands of interdependent technologies
without recursion and never removes source-authored research automatically.

## Runtime orchestration

```lua
local Events = require("__razi_lib__/runtime/events")
local registry = Events.new()

registry
  :include(require("scripts.my-system"))
  :on_event(defines.events.on_player_created, function(event) end)
  :install()
```

RAZI does not install handlers globally. Each consumer owns its registry,
which prevents unrelated mods from sharing runtime state accidentally.


## Shared startup-settings hosting (1.3.0, opt-in)

Factorio displays settings by **owning mod** first. RAZI Library can host the
**startup** settings of specifically enrolled consumers under one native group.
It cannot force that group to the very top of Factorio's mod list.

The initial provider is Razi Protocol. It exports its normal setting prototypes
without defining them when RAZI Library requests them. RAZI Library registers
only `startup` prototypes; Razi Protocol continues owning its
`runtime-global` and `runtime-per-user` settings. All original setting IDs,
defaults, allowed values, orders and locale keys are preserved.

**Adding another opt-in consumer:** add its internal mod ID and export-module
path to `settings/registry.lua`. Its exported module should return an array of
ordinary setting prototypes when `__razi_lib_settings_export` is set, and
must have a normal local-registration fallback when no hosted marker exists.
RAZI Library sets `__razi_lib_settings_hosted[mod-id]` only after successfully
registering startup prototypes. Never move runtime settings whose values the
consumer must write. Registration is explicit, not an indiscriminate scan of
unrelated installed mods. An unavailable provider is skipped safely.

The host feature requires RAZI Library 1.3.0 or later, and should be validated
in Factorio's actual mod-settings screen before relying on GUI placement.

## Testing

Run `lua tests/run.lua` for the pure-Lua suite. Consumer mods should additionally
run Factorio with `--dump-data` to validate actual prototypes and dependencies.
