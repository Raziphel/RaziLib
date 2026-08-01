# RAZI Library API

All imports use the stable `__razi_lib__/...` path.

## Data-stage modules

### `lib/core`

Assertions, deep copy, clamp, recursive merge, sorted keys, and stage detection.

### `lib/collections`

`contains`, `append_unique`, `remove`, `index_by`, `map`, and `copy`.

### `lib/prototype`

- `exists(type, name)`, `raw(type, name)`
- `get(type, name)`, `optional(type, name)`
- `clone(type, from, into)`, `each(type, callback)`
- Wrapper methods: `raw`, `clone`, `set`, `set_icon`, `set_icons`, `hide`, `remove`

Wrappers proxy ordinary prototype fields, so `Recipe.get("x").ingredients` works.

### `lib/recipe`

- `get`, `optional`, `clone`
- `set_ingredients`, `set_results`, `add_ingredient`, `upsert_ingredient`
- `remove_ingredient`, `replace_ingredient`, `add_result`, `remove_result`
- `set_energy`, `set_category`, `set_subgroup`, `set_modules`
- `enable`, `disable`, `set_conditions`, `set_recycling`, `set_main_product`
- `unlock_with`, `remove_unlocks`, `each_variant`

Ingredient setters apply to normal and expensive variants when they exist.

### `lib/technology`

- `get`, `optional`, `clone`, `register_science`
- `set_cost`, `set_cost_formula`, `set_time`, `set_packs`, `set_colors`, `add_pack`
- `set_effects`, `add_effect`, `unlock`, `remove_unlock`
- `set_prerequisites`, `add_prerequisite`, `remove_prerequisite`, `set_infinite`

Built-in science codes: `R G B M P Y W V F A C S`.

### `lib/item`, `lib/entity`, `lib/module`

Typed convenience wrappers for common stack, placement, crafting, energy, module,
surface-condition, effect, category, and tier changes.

### `lib/icons`

Build deterministic layered icons with `layer`, `single`, `compose`, `badge`,
`from_prototype`, and `tint`.

### `lib/settings`

Read settings safely with `value` and `enabled`. Build prototypes with `bool`,
`string`, `int`, and `double`.

### `lib/locale`

Construct localized keys, concatenations, rich-text icons, and colored values.

### `lib/validation`

Assertions for prototypes, recipe ingredients/results, technology unlocks and
prerequisites, plus duplicate-name detection. Intended for `data-final-fixes`.

## Runtime modules

### `runtime/events`

Creates a consumer-owned registry supporting multiple handlers for events,
nth-tick callbacks, init, load, configuration changes, and module inclusion.

### `runtime/storage`

Namespaced persistent state with defaults: `ensure`, `get`, `set`, `update`,
and `reset`.

### `runtime/remote`

Safe `has`, optional `call`, strict `require`, and idempotent `add_interface`.

## Migration from `haul_lib`

| Old | RAZI Library |
|---|---|
| `__haul_lib__/utils/common` | `__razi_lib__/lib/prototype` or compatibility `utils/common` |
| `__haul_lib__/utils/recipe` | `__razi_lib__/lib/recipe` |
| `__haul_lib__/utils/tech` | `__razi_lib__/lib/technology` |
| `__haul_lib__/utils/module` | `__razi_lib__/lib/module` |

CamelCase aliases remain for the small legacy surface, but new projects should
use snake_case names.
