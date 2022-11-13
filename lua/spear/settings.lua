local Enums = require("spear.enums")

local function get_values_as_table(enum)
  local t = {}
  for _, v in pairs(enum) do
    table.insert(t, v)
  end
  return t
end

---@class Settings
local M = {
  ---@class match_pref
  ---@field desc string A description of the setting
  ---@field values table<MatchPref> The values this setting can have
  ---@field default MatchPref The default value for this setting
  match_pref = {
    desc = "if a table is given to spear and one of the extensions is matched as the current file at run time, do you want to stay there or do you want to continue through the rest of the extensions",
    values = get_values_as_table(Enums.MatchPref),
    default = Enums.MatchPref.FIRST,
  },
  ---@class save_on_spear
  ---@field desc string A description of the setting
  ---@field values table<SaveOnSpear> The values this setting can have
  ---@field default SaveOnSpear The default value for this setting
  save_on_spear = {
    desc = "save the file you spear from when spearing to new file",
    values = get_values_as_table(Enums.SaveOnSpear),
    default = Enums.SaveOnSpear.FALSE,
  },
  print_err = {
    desc = "whether or not to print any error messages spear generates",
    values = get_values_as_table(Enums.PrintErr),
    default = Enums.PrintErr.TRUE,
  },
  print_info = {
    desc = "whether or not to print any info messages spear generates",
    values = get_values_as_table(Enums.PrintInfo),
    default = Enums.PrintInfo.TRUE,
  }
}

return M
