local utils = require("spear.utils")

local M = {}

-- start validation functions
local function is_valid(extn_input)
  if utils.is_table(extn_input) then
    local length = 0
    for _, v in ipairs(extn_input) do
      if not utils.is_string(v) then
        return nil
      end
      if v == "" or v == " " then
        return nil
      end
      length = length + 1
    end
    if length == 0 then return nil end
    return "table"
  elseif utils.is_string(extn_input) then
    return "string"
  end
  return nil
end

local function check_is_writable_file(new_nome)
  return vim.fn.filewritable(new_nome) == 1
end

local function check_current_is_file_or_dir(buf_nome)
  local num = vim.fn.filewritable(buf_nome)
  if num == 1 then
    return "file"
  elseif num == 2 then
    return "dir"
  else
    return nil
  end
end

local function ext_input_matches_extension(current_ext, ext_inpt)
  if utils.is_table(ext_inpt) then
    for _, v in ipairs(ext_inpt) do
      if v == current_ext then
        return true
      end
    end
  elseif utils.is_string(ext_inpt) then
    if ext_inpt == current_ext then
      return true
    end
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
  if not utils.is_string(buf_nome)then
    return nil
  end
  local eman = string.match(buf_nome:reverse(), "[^".. utils.get_slash() .."%s]")
  local end_name = eman:reverse()
  local new_file_name = string.gsub(buf_nome, utils.get_slash()..end_name,'')
  return end_name, new_file_name
  -- return vim.fn.fnamemodify(buf_nome, ":t")
end

--[[ local function get_parent(buf_nome)
  return vim.fn.fnamemodify(buf_nome, ":h:t")
end ]]

local function get_extension(dir_nome, file_nome)
  return string.gsub(file_nome, dir_nome, "")
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

local function get_new_path_name(current_path, filenome, new_file_name)
  if filenome == nil then
    return string.format("%s%s", vim.fn.fnamemodify(current_path, ":p"), new_file_name)
  elseif utils.is_string(filenome) then
    return vim.fn.fnamemodify(current_path, string.format(":s?%s?%s?", filenome, new_file_name))
  end
end

local function get_writable_file(current_path, dirnome, filenome, ext_inpt)
  if utils.is_table(ext_inpt) then
    for _, v in ipairs(ext_inpt) do
      local new_file_name = string.format("%s%s", dirnome, v)
      local new_path = get_new_path_name(current_path, filenome, new_file_name)
      if check_is_writable_file(new_path) then
        return new_path
      end
    end
    return nil
  elseif utils.is_string(ext_inpt) then
    local new_file_name = string.format("%s%s", dirnome, ext_inpt)
    local new_path = get_new_path_name(current_path, filenome, new_file_name)
    if check_is_writable_file(new_path) then
      return new_path
    end
    return nil
  else
    return nil
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
local function change_file(id)
  vim.api.nvim_set_current_buf(id)
  vim.api.nvim_buf_set_option(id, "buflisted", true)
end

-- end file nav functions

-- start print functions
local function speared_to(pathnome)
  print(string.format("speared to %s", utils.normalize_path(pathnome)))
end

local function swapped_to(pathnome)
  print(string.format("spear: swapped to %s", utils.normalize_path(pathnome)))
end

-- end print functions

-- main function
function M.spear(ext_input, overrides)

  -- check inputs are valid
  local ext_input_is_valid = is_valid(ext_input)
  if ext_input_is_valid == nil then
    return print("spear: not a valid extension; check your config")
  end

  overrides = utils.validate_options(overrides, "local")

  -- initialise all variables
  local buf_name = get_abs_buf_name()
  local file_name
  local dir_name
  local new_path

  -- check if were in a file or folder
  local is_file_or_dir = check_current_is_file_or_dir(buf_name)
  if is_file_or_dir == nil then
    return print("spear can't do things here")
  end

  if is_file_or_dir == "file" then
    file_name, buf_name = get_end(buf_name)
    dir_name, buf_name = get_end(buf_name)
    local extension = get_extension(dir_name, file_name)
    if ext_input_matches_extension(extension, ext_input) then
      return print("spear: already in file")
    end
    new_path = get_writable_file(buf_name, dir_name, file_name, ext_input)
  elseif is_file_or_dir == "dir" then
    dir_name = get_end(buf_name)
    new_path = get_writable_file(buf_name, dir_name, nil, ext_input)
  end

  if new_path == nil then
    local ext_string = get_ext_as_string(dir_name, ext_input)
    return print(string.format("spear: no files named %s found", ext_string))
  end

  local id = get_buf_to_go_to_id(new_path)
  change_file(id)
  speared_to(new_path)
end

-- end main function


return M
