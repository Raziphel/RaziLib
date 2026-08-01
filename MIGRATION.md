# Migrating from haul_lib

1. Replace the dependency with `razi_lib >= 1.0.0`.
2. Move imports from `__haul_lib__/utils/*` to the matching `__razi_lib__/lib/*` module.
3. Replace `Common.cloneInto(type, from, into)` with `Prototype.clone(type, from, into)`.
4. Prefer snake-case methods such as `set_ingredients`, `set_cost`, and `set_prerequisites`.
5. Run pure-Lua tests and a real Factorio `--dump-data` pass without `haul_lib` installed.

Compatibility modules and camelCase aliases cover the original small API, but are intended as a migration bridge rather than the long-term interface.
