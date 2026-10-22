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

## Testing

Run `lua tests/run.lua` for the pure-Lua suite. Consumer mods should additionally
run Factorio with `--dump-data` to validate actual prototypes and dependencies.

## Releases

Releases are made by CI from `main` ([.github/workflows/release.yml](.github/workflows/release.yml), through [factorio-mod-tools](https://github.com/GreenTech-Solutions/factorio-mod-tools)): a push to `main` with releasable commits since the last tag bumps `info.json`, writes the `changelog.txt` section, uploads the zip to the mod portal and makes a GitHub release. Every push and pull request runs the check (Lua 5.2 syntax, luacheck, emmylua against the Factorio API, the `changelog.txt` format); run it locally with `factorio-mod-check .`.

- Commit messages, and pull request titles when squash merging, are [conventional commits](https://www.conventionalcommits.org/); the subject becomes the changelog line as it is written. `feat:` is a minor release; `fix:`, `balance:`, `compat:`, `gui:`, `graphics:`, `sound:`, `locale:`, `perf:` and `control:` are patch releases; a breaking change is a major one. `ci:`, `docs:`, `chore:`, `test:` and `refactor:` release nothing.
- For normal automated releases, CI bumps the version and changelog from releasable Conventional Commits. Explicitly prepared maintenance versions must update `info.json` and `changelog.txt` together, then use a non-releasable release commit to avoid a second automatic bump.
- Every CI check inspects the actual `git archive` payload and rejects `.exe`, `.bat`, `.ps1`, `.sh` and `.py` files before release. Development examples, tests, source-art files, and CI metadata are excluded with `.gitattributes`.
- For manual Mod Portal uploads, build a mod ZIP from committed Factorio runtime files, not the GitHub **Code → Download ZIP** archive or the full working directory.
- The release zip is made with `git archive`; files that stay out of it are marked `export-ignore` in [.gitattributes](.gitattributes).
- The upload uses the `FACTORIO_TOKEN` repository secret, a mod portal API key with the upload permission.
