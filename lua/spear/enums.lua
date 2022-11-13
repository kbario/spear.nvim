local M = {
  ---@enum MatchPref
  MatchPref = {
    FIRST = "first",
    NEXT = "next"
  },
  ---@enum SaveOnSpear
  SaveOnSpear = {
    TRUE = true,
    FALSE = false
  },
  ---@enum Actions
  Actions = {
    STAY = "stay",
    SPEAR = "spear",
    SWAP = "swap",
  },
  ---@enum ValidationErrors
  ValidationErrors = {
    None = "None",
    InvalidInput = "InvalidInput",
    NotAFileOrDir = "NotAFileOrDir",
    InvalidCurrPath = "InvalidCurrPath",
    InvalidPaths = "InvalidPaths",
    NoMatchFound = "NoMatchFound",
  }
}

return M
