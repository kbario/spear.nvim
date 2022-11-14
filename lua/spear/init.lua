local utils = require("spear.utils")
local M = {}

---@class settings
---@field match_pref MatchPref
---@field save_on_spear SaveOnSpear
---@field print_err SaveOnSpear
---@field print_info SaveOnSpear

---@param config_input settings
M.setup = function(config_input)

  if not config_input then
    config_input = {}
  end

  local output = utils.validate_options(config_input, true)

  utils.save_config("data", output)
end

return M
