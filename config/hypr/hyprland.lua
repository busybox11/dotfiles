-- Hyprland 0.55+ Lua config.
-- Temporary standalone config: hardcoded from conf/*.conf (nix module disabled).

local modules = {
  "lua/env",
  "lua/monitors",
  "lua/appearance",
  "lua/input",
  "lua/layouts",
  "lua/rules",
  "lua/autostart",
  "lua/keybinds",
}

for _, module in ipairs(modules) do
  local ok, err = pcall(require, module)
  if not ok then
    print("failed to load " .. module .. ": " .. tostring(err))
  end
end
