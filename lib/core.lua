local Core = {}

function Core.assert_string(value, label)
  if type(value) ~= "string" or value == "" then
    error((label or "value") .. " must be a non-empty string", 2)
  end
  return value
end

function Core.assert_table(value, label)
  if type(value) ~= "table" then error((label or "value") .. " must be a table", 2) end
  return value
end

function Core.assert_number(value, label, minimum)
  if type(value) ~= "number" or (minimum and value < minimum) then
    error((label or "value") .. " must be a number" .. (minimum and " >= " .. minimum or ""), 2)
  end
  return value
end

function Core.deepcopy(value)
  if table and table.deepcopy then return table.deepcopy(value) end
  if type(value) ~= "table" then return value end
  local copy = {}
  for key, entry in pairs(value) do copy[Core.deepcopy(key)] = Core.deepcopy(entry) end
  return setmetatable(copy, getmetatable(value))
end

function Core.clamp(value, minimum, maximum)
  if value < minimum then return minimum end
  if value > maximum then return maximum end
  return value
end

function Core.merge(target, source, deep)
  target = target or {}
  for key, value in pairs(source or {}) do
    if deep and type(value) == "table" and type(target[key]) == "table" then
      Core.merge(target[key], value, true)
    else
      target[key] = Core.deepcopy(value)
    end
  end
  return target
end

function Core.sorted_keys(source)
  local keys = {}
  for key in pairs(source or {}) do keys[#keys + 1] = key end
  table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
  return keys
end

function Core.stage_has_data()
  return type(data) == "table" and type(data.raw) == "table"
end

return Core
