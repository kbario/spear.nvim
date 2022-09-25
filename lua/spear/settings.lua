local M = {}

M.settings = {
  ["match_pref"] = {
    ["desc"] = "if a table is given to spear and one of the extensions is matched as the current file at run time, do you want to stay there or do you want to continue through the rest of the extensions",
    ["values"] = { "first", "swap" },
    ["default"] = "first",
  },
  ["save_on_spear"] = {
    ["desc"] = "save the file you spear from when spearing to new file",
    ["values"] = { true, false },
    ["default"] = false,
  }
}

return M
