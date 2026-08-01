local Core = require("__razi_lib__/lib/core")
local Icons = {}

function Icons.layer(icon, icon_size, options)
  local layer = { icon = icon, icon_size = icon_size }
  return Core.merge(layer, options or {}, true)
end

function Icons.single(icon, icon_size, options)
  return { Icons.layer(icon, icon_size, options) }
end

function Icons.compose(base_icon, base_size, overlays)
  local icons = Icons.single(base_icon, base_size)
  for _, overlay in ipairs(overlays or {}) do icons[#icons + 1] = Core.deepcopy(overlay) end
  return icons
end

function Icons.badge(icon, icon_size, corner, scale, options)
  local shifts = {
    ["top-left"] = { -8, -8 }, ["top-right"] = { 8, -8 },
    ["bottom-left"] = { -8, 8 }, ["bottom-right"] = { 8, 8 },
  }
  local layer = {
    icon = icon,
    icon_size = icon_size,
    scale = scale or 0.35,
    shift = shifts[corner or "bottom-right"],
  }
  return Core.merge(layer, options or {}, true)
end

function Icons.from_prototype(prototype)
  if prototype.icons then return Core.deepcopy(prototype.icons) end
  if prototype.icon then return Icons.single(prototype.icon, prototype.icon_size) end
  return {}
end

function Icons.tint(icons, tint)
  local copy = Core.deepcopy(icons)
  for _, layer in ipairs(copy) do layer.tint = Core.deepcopy(tint) end
  return copy
end

return Icons
