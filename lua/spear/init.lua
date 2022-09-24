local utils = require("spear.utils")
local M = {}

M.setup = function(config_input)

  -- if no input, give it a value
  if not config_input then
    config_input = {}
  end

  -- make sure only predefined settings are in saved_config
  local output = utils.validate_options(config_input, "global")

  utils.save_config("data", output)
end

return M
