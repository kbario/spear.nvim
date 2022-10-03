local utils = require("spear.utils")
local pth = require("plenary.path")
local log = require("spear.dev")

local M = {}

-- start validation functions
local function is_valid(extn_input)
  if utils.is_table(extn_input) then
    local length = 0
    for _, v in ipairs(extn_input) do
      if not utils.is_string(v) then
        return false
      end
      if v == "" or v == " " then
        return false
      end
      length = length + 1
    end
    if length == 0 then return nil end
    return "table"
  elseif utils.is_string(extn_input) then
    return "string"
  end
  return false
end

local function is_writable_file(new_nome)
  return vim.fn.filewritable(new_nome) == 1
end

local function check_current_is_file_or_dir(buf_nome)
  local num = vim.fn.filewritable(buf_nome)
  if num == 1 then
    return "file"
  elseif num == 2 then
    return "dir"
  else
    return false
  end
end

-- end validation functions

-- start getters
--[[ local function get_rel_buf_name(id)
  if id == nil then
    return utils.normalize_path(vim.api.nvim_buf_get_name(0))
  elseif type(id) == "string" then
    return utils.normalize_path(id)
  end
end ]]

local function get_abs_buf_name(id)
  if id == nil then
    return vim.api.nvim_buf_get_name(0)
  elseif type(id) == "string" then
    return vim.api.nvim_buf_get_name(id)
  end
end

local function get_end(buf_nome)
  -- for getting the parent... duh
  -- require("plenary.path"):new(outfile):parent()
  if not utils.is_string(buf_nome)then
    return false
  end
  local filenome = vim.fn.fnamemodify(buf_nome, ":p:t")
  if not utils.is_string(filenome) then
    filenome = nil
  end
  local dirnome = vim.fn.fnamemodify(buf_nome, ":p:h:t")
  local new_file_name = vim.fn.fnamemodify(buf_nome, ":p:h:h")
  return filenome, dirnome, new_file_name
  --[[ local end_name = string.match(buf_nome:reverse(), "[^".. utils.get_slash() .."]+"):reverse()
  local new_file_name = string.gsub(buf_nome, utils.get_slash()..end_name, "")
  return end_name, new_file_name ]]
end

local function get_ext_as_string(dirnome, ext_inpt)
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
        sep = " or "
      else
        sep = ", "
      end
      ext_string = string.format("%s%s%s%s", ext_string, sep, dirnome, v)
    end
    return ext_string
  end
end

local function make_new_file(dir_nome, ext)
  return string.format("%s%s", dir_nome, ext)
end

local function make_new_path(path, dir_nome, file_nome)
  local slash = utils.get_slash()
  return pth:new(string.format("%s%s%s%s%s", path, slash, dir_nome, slash, file_nome))
end

local function get_path(settings, current_path, dirnome, ext, filenome)
  if utils.is_string(ext) then
    local new_file = make_new_file(dirnome, ext)
    local first_or_swap = 'first'
    if new_file == filenome then
      if settings["match_pref"] == "first" then
        return "stay", nil
      elseif settings["match"] == "swap" then
        first_or_swap = "swap"
      end
    else
      local new_path = make_new_path(current_path, dirnome, new_file)
      if is_writable_file(new_path.filename) then
        return first_or_swap, new_path.filename
      end
    end
  else
    return nil, nil
  end
end

local function get_writable_file(settings, current_path, dirnome, ext_inpt, filenome)
  if utils.is_table(ext_inpt) then
    for _, v in ipairs(ext_inpt) do
      local action, new_path = get_path(settings, current_path, dirnome, v, filenome)
      if not utils.is_nil(new_path) then
        return action, new_path
      end
    end
    return nil, nil
  else
    return get_path(settings, current_path, dirnome, ext_inpt, filenome)
  end
end

local function get_buf_to_go_to_id(new_nome)
  if vim.fn.bufexists(new_nome) ~= 0 then
    return vim.fn.bufnr(new_nome)
  else
    return vim.fn.bufadd(new_nome)
  end
end

-- end getters

-- start file nav functions
local function change_to(name)
  local id = get_buf_to_go_to_id(name)
  vim.api.nvim_set_current_buf(id)
  vim.api.nvim_buf_set_option(id, "buflisted", true)
end

-- end file nav functions

-- start print functions
local function speared_to(pathnome, spear_or_swap)
  if spear_or_swap == "swap" then
    print(string.format("spear: swapped to %s", utils.normalize_path(pathnome)))
  else
    print(string.format("speared to %s", utils.normalize_path(pathnome)))
  end
end

local function already_in(pathnome)
  print(string.format("spear: already in %s", utils.normalize_path(pathnome)))
end

-- end print functions

-- main function
function M.spear(ext_input, overrides)

  -- check inputs are valid
  if not is_valid(ext_input) then
    return print("spear: not a valid extension; check your config")
  end

  local prefs = utils.validate_options(overrides or {}, false)
  local cur_buf_name = get_abs_buf_name()

  -- check if were in a file or folder
  local is_file_or_dir = check_current_is_file_or_dir(cur_buf_name)
  if not is_file_or_dir then
    return print("spear can't do things here")
  end

  local file_name, dir_name, buf_name = get_end(cur_buf_name)

  local action, new_path = get_writable_file(prefs, buf_name, dir_name, ext_input, file_name)

  --[[ if is_file_or_dir == "file" then

    file_name, dir_name, buf_name = get_end(cur_buf_name)
    if not file_name then return print("spear: invalid buf name") end

    dir_name, buf_name = get_end(buf_name)
    if not dir_name then return print("spear: invalid buf name") end 

    new_path, first_or_swap = get_writable_file(prefs, buf_name, dir_name, ext_input, file_name)

  elseif is_file_or_dir == "dir" then

    file_name, dir_name, buf_name = get_end(cur_buf_name)
    dir_name, buf_name = get_end(cur_buf_name)
    if not dir_name then return print("spear: invalid buf name") end 

    new_path, first_or_swap = get_writable_file(prefs, buf_name, dir_name, ext_input, file_name)
  end ]]

  log.info(
    "\n",
    "\nFINAL",
    "\ncurrent buf name:", cur_buf_name,
    "\npreferences", prefs,
    "\ninputs", ext_input,
    "\nbuf name:", buf_name,
    "\nfile name:", file_name,
    "\ndir name:", dir_name,
    "\nnew path:", new_path,
    "\nfirst or swap:", action,
    "\n"
  )

  if action == "stay" then
    return already_in(file_name)
  end

  if utils.is_nil(new_path) then
    local ext_string = get_ext_as_string(dir_name, ext_input)
    return print(string.format("spear: no files named %s found", ext_string))
  end

  if prefs["save_on_spear"] then
    vim.api.nvim_command(":w")
  end

  change_to(new_path)
  speared_to(new_path, action)
end

-- end main function


return M
