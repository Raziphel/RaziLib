-- Shared startup-settings hosting for explicitly registered RAZI-compatible mods.
-- The settings stage has one shared Lua state, so the handshake is temporary.
-- Do not move runtime settings: Factorio restricts runtime writes to their owner.
local Registry = {}

-- Opt-in roster. Future consumers export an array from the listed module.
-- They must provide the normal fallback when RAZI Library cannot host them.
local providers = {
  { mod = "razi-protocol", source = "__razi-protocol__/settings",
    skip_if = "00-razi-protocol-settings" },
}

function Registry.register(installed, loader, emit)
  installed = installed or mods
  loader = loader or require
  emit = emit or function(entries) data:extend(entries) end
  local accepted = {}
  for _, provider in ipairs(providers) do
    if installed[provider.mod] and not (provider.skip_if and installed[provider.skip_if]) then
      -- Loading another mod's declared settings must not register them yet.
      local previous = rawget(_G, "__razi_lib_settings_export")
      rawset(_G, "__razi_lib_settings_export", true)
      local ok, definitions = pcall(loader, provider.source)
      rawset(_G, "__razi_lib_settings_export", previous)

      if ok and type(definitions) == "table" then
        local startup = {}
        local valid = true
        local seen = {}
        for _, setting in ipairs(definitions) do
          if type(setting) ~= "table" or type(setting.name) ~= "string"
              or type(setting.setting_type) ~= "string" then
            valid = false
            break
          end
          if setting.setting_type == "startup" then
            if seen[setting.name] then valid = false; break end
            seen[setting.name] = true
            startup[#startup + 1] = setting
          end
        end
        if valid and #startup > 0 then
          emit(startup)
          accepted[provider.mod] = true
        end
      end
      if not accepted[provider.mod] and log then
        log("[RAZI Library] Settings provider " .. provider.mod
          .. " not hosted; consumer fallback remains active."
          .. (not ok and (" Reason: " .. tostring(definitions)) or ""))
      end
    end
  end

  if next(accepted) then
    local hosted = rawget(_G, "__razi_lib_settings_hosted")
    if type(hosted) ~= "table" then
      hosted = {}
      rawset(_G, "__razi_lib_settings_hosted", hosted)
    end
    for mod_name in pairs(accepted) do hosted[mod_name] = true end
  end
  return accepted
end

return Registry
