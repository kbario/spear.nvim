local M = {}

M.settings = {
  ["match"] = {
    ["desc"] = "if a table is given to spear and one of the extensions is matched as the current file at run time, do you want to stay there or do you want to continue through the rest of the extensions",
    ["values"] = { "first", "swap" },
    ["default"] = "first",
  }
}

return M
