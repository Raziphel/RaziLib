local Remote = {}

function Remote.has(interface_name, function_name)
  local interface = remote and remote.interfaces and remote.interfaces[interface_name]
  return interface ~= nil and (function_name == nil or interface[function_name] ~= nil)
end

function Remote.call(interface_name, function_name, ...)
  if not Remote.has(interface_name, function_name) then return nil, false end
  return remote.call(interface_name, function_name, ...), true
end

function Remote.require(interface_name, function_name, ...)
  assert(Remote.has(interface_name, function_name),
    ("Missing remote interface function %s.%s"):format(interface_name, function_name))
  return remote.call(interface_name, function_name, ...)
end

function Remote.add_interface(name, functions)
  if Remote.has(name) then return false end
  remote.add_interface(name, functions)
  return true
end

return Remote
