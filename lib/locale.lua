local Locale = {}

function Locale.key(section, name) return { section .. "." .. name } end
function Locale.name(prototype_type, name) return Locale.key(prototype_type .. "-name", name) end
function Locale.description(prototype_type, name) return Locale.key(prototype_type .. "-description", name) end

function Locale.concat(...)
  local result = { "" }
  for _, value in ipairs({ ... }) do result[#result + 1] = value end
  return result
end

function Locale.icon(kind, name) return ("[%s=%s]"):format(kind, name) end
function Locale.color(color, value) return { "", "[color=" .. color .. "]", value, "[/color]" } end

return Locale
