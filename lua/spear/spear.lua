local utils = require("spear.utils")
local pth = require("plenary.path")


local MatchPref = require("spear.enums").MatchPref
local Actions = require("spear.enums").Actions
local ValidationErrors = require("spear.enums").ValidationErrors
local PrintErr = require("spear.enums").PrintErr
local PrintInfo = require("spear.enums").PrintInfo


local M = {}


--#region validation functions
local function is_valid(extn_input)
  if utils.is_valid_table_of_strings(extn_input)
      or utils.is_valid_string(extn_input) then
    return true
  end
  return false
end

local function is_valid_path(new_nome)
  return vim.fn.filewritable(new_nome) == 1
end

local function is_file_or_dir(buf_nome)
  local num = vim.fn.filewritable(buf_nome)
  if num == 1 or num == 2 then
    return true
  else
    return false
  end
end

--#endregion validation functions


--#region getters
local function get_path(id)
  if id == nil then
    return vim.api.nvim_buf_get_name(0)
  elseif utils.is_valid_string(id) then
    return vim.api.nvim_buf_get_name(id)
  end
end

local function get_buf_id(new_nome)
  if vim.fn.bufexists(new_nome) ~= 0 then
    return vim.fn.bufnr(new_nome)
  else
    return vim.fn.bufadd(new_nome)
  end
end

--#endregion getters


--#region print functions
local function get_ext_as_string(dirnome, ext_inpt, custom_sep)
  local ext_string = ""
  if utils.is_string(ext_inpt) then
    ext_string = string.format("%s%s", dirnome, ext_inpt)
    return ext_string
  elseif utils.is_table(ext_inpt) then
    local idx = 0
    local length = 0
    for _, _ in pairs(ext_inpt) do
      length = length + 1
    end
    if length == 0 then
      return nil
    end

    for _, v in pairs(ext_inpt) do
      local sep
      idx = idx + 1
      if idx == 1 then
        sep = ""
      elseif idx == length then
        sep = custom_sep or " or "
      else
        sep = ", "
      end
      ext_string = string.format("%s%s%s%s", ext_string, sep, dirnome, v)
    end
    return ext_string
  end
end

---@param err ValidationErrors
local function print_err(err, prefs, var1, var2)
  if prefs.print_err == PrintErr.FALSE then
    return
  elseif err == ValidationErrors.NotAFileOrDir then
    print("spear error: can't do things here")
  elseif err == ValidationErrors.InvalidInput then
    print("spear error: invalid input; check your config")
  elseif err == ValidationErrors.InvalidCurrPath then
    print("spear error: issue extracting path")
  elseif err == ValidationErrors.InvalidPaths then
    print("spear error: issue generating paths")
  elseif err == ValidationErrors.NoMatchFound then
    local ext_string = get_ext_as_string(var1, var2)
    print(string.format("spear error: no files named %s found", ext_string))
  end
end

local function speared_to(pathnome, spear_or_swap, prefs)
  if prefs.print_info == PrintInfo.FALSE then
    return
  elseif spear_or_swap == Actions.SWAP then
    print(string.format("spear: swapped to %s", utils.normalize_path(pathnome)))
  else
    print(string.format("speared to %s", utils.normalize_path(pathnome)))
  end
end

local function print_info(info, prefs, var1)
  if prefs.print_info == PrintInfo.FALSE then
    return
  elseif info == Actions.STAY then
    print(string.format("spear: already in %s", utils.normalize_path(var1)))
  end
end

--#endregion print functions


--#region find_spear_file functions
local function make_new_path(path, dir_nome, ext)
  local file_name = string.format("%s%s", dir_nome, ext)
  local slash = utils.get_slash()
  return pth:new(string.format("%s%s%s%s%s", path, slash, dir_nome, slash, file_name)).filename
end

local function get_valid_paths(init_path, dir_name, exts)
  local valid_paths = {}
  if utils.is_table(exts) then
    for _, ext in pairs(exts) do
      local new_path = make_new_path(init_path, dir_name, ext)
      if is_valid_path(new_path) then
        table.insert(valid_paths, new_path)
      end
    end
  else
    local new_path = make_new_path(init_path, dir_name, exts)
    if is_valid_path(new_path) then
      table.insert(valid_paths, new_path)
    end
  end
  return valid_paths
end

local function find_file_to_move_to(new_paths, curr_path, settings)
  -- init local vars
  local paths = {}
  local action = Actions.SPEAR
  -- check if a generated path matches the current
  -- if there is and prefs ars to match first then exit early
  -- else if pref is next, change action to do this and ignore file
  -- if generated file is not the same as current then add it to the
  -- list to be sorted through
  for _, new_path in pairs(new_paths) do
    if new_path == curr_path then
      if settings.match_pref == MatchPref.FIRST then
        return Actions.STAY, new_path
      elseif settings.match_pref == MatchPref.NEXT then
        action = Actions.SWAP
      end
    else
      table.insert(paths, new_path)
    end
  end
  if paths[1] ~= nil then
    return action, paths[1]
  else
    return Actions.STAY, nil
  end
end

--#endregion find_spear_file functions


--#region spear_to functions
local function change_to(name)
  local id = get_buf_id(name)
  vim.api.nvim_set_current_buf(id)
  vim.api.nvim_buf_set_option(id, "buflisted", true)
end

--#endregion spear_to functions


--#region main functions
local function validate(extensions, overrides)

  local prefs = utils.validate_options(overrides or {}, false)
  local curr_path = get_path()

  local error = ValidationErrors.None

  if not is_valid(extensions) then error = ValidationErrors.InvalidInput end
  if not is_file_or_dir(curr_path) then error = ValidationErrors.NotAFileOrDir end

  return curr_path, prefs, error
end

local function get_end(curr_path)
  local error = ValidationErrors.None
  if not utils.is_valid_string(curr_path) then error = ValidationErrors.InvalidCurrPath end
  -- remove the slash and get the dir_name
  local dir_name = vim.fn.fnamemodify(curr_path, ":p:h:t")
  if not utils.is_valid_string(dir_name) then error = ValidationErrors.InvalidCurrPath end
  -- then the path without the file or dir in it
  local init_path = vim.fn.fnamemodify(curr_path, ":p:h:h")
  if not utils.is_valid_string(init_path) then error = ValidationErrors.InvalidCurrPath end
  return init_path, dir_name, error
end

local function find_spear_file(curr_path, init_path, dir_name, exts, settings)
  local err = ValidationErrors.None
  local valid_paths = get_valid_paths(init_path, dir_name, exts)
  if not utils.is_valid_table_of_strings(valid_paths) then err = ValidationErrors.InvalidPaths end
  local action, path = find_file_to_move_to(valid_paths, curr_path, settings)
  return action, path, err
end

local function spear_to(new_path, action, prefs)
  if prefs.save_on_spear then vim.api.nvim_command(":w") end
  change_to(new_path)
  speared_to(new_path, action, prefs)
end

--#endregion main functions


--#region main function
function M.spear(exts, overrides)

  -- validate
  local curr_path, prefs, val_err = validate(exts, overrides)
  if val_err ~= ValidationErrors.None then return print_err(val_err, prefs) end

  -- get
  local init_path, dir_name, path_err = get_end(curr_path)
  if path_err ~= ValidationErrors.None then return print_err(path_err, prefs) end

  -- generate
  local action, new_path, err = find_spear_file(curr_path, init_path, dir_name, exts, prefs)
  if err ~= ValidationErrors.None then return print_err(err, prefs) end
  if utils.is_nil(new_path) then return print_err(ValidationErrors.NoMatchFound, prefs, dir_name, exts) end
  if action == Actions.STAY then return print_info(action, prefs, curr_path) end

  -- spear
  spear_to(new_path, action, prefs)
end

--#endregion main function


--#region binding function
local function bind(lhs, rhs, exts, prefs)
  local custom_sep
  local init
  if prefs.match_pref == MatchPref.FIRST then
    init = "spear to"
  end
  if prefs.match_pref == MatchPref.NEXT then
    init = "swap between"
    custom_sep = " and "
  end
  local ext_string = get_ext_as_string("", exts, custom_sep)
  local desc = string.format("spear: %s %s", init, ext_string)
  return vim.keymap.set("n", lhs, rhs, { noremap = true, desc = desc })
end

--#endregion binding function


function M.spear_bind(binding, exts, overrides)
  local prefs = utils.validate_options(overrides or {}, false)
  bind(binding, function() M.spear(exts, overrides) end, exts, prefs)
end

return M
