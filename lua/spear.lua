local M = {}

local function get_slash(nome)
  --[[ if string.find(nome, "\\") ~= nil then
    return "\\"
  elseif string.find(nome, "/") ~= nil then
    return "/"
  end ]]
  return "/"
end

-- start checking functions
local function is_table(thing)
  return type(thing) == "table"
end

local function is_string(thing)
  return type(thing) == "string"
end

local function is_valid(extn_input)
  if is_table(extn_input) then
    local length = 0
    for _, v in ipairs(extn_input) do
      if not is_string(v) then
        print("Please provide only strings")
        return nil
      end
      length = length + 1
    end
    if length == 0 then return nil end
    return "table"
  elseif not is_string(extn_input) then
    print("Please provide only strings")
    return nil
  end
  return "string"
end

local function check_current_is_file_or_dir(thing)
  local num = vim.fn.filewritable(thing)
  if num == 1 then
    return "file"
  elseif num == 2 then
    return "dir"
  else
    return nil
  end
end

local function check_is_writable_file(new_nome)
  return vim.fn.filewritable(new_nome) == 1
end

local function ext_input_matches_extension(ext_inpt, current_ext)
  if is_table(ext_inpt) then
    for _, v in ipairs(ext_inpt) do
      if v == current_ext then
        return true
      end
    end
  elseif is_string(ext_inpt) then
    if ext_inpt == current_ext then
      return true
    end
  else
    return false
  end
end

-- end checking functions

-- start string manipulation functions
local function change_file(id)
  vim.api.nvim_set_current_buf(id)
  vim.api.nvim_buf_set_option(id, "buflisted", true)
end

local function remove_from(to_remove_from, to_remove)
  return string.gsub(to_remove_from, to_remove, "")
end

local function remove_file_from_dir(dir, slash, file)
  return remove_from(dir, slash .. file)
end

local function concatenare_sentiero(pathnome, slash, dirnome, extn)
  return string.format("%s%s%s%s", pathnome, slash, dirnome, extn)
end

-- end string manipulation functions

-- start getting detail functions
local function get_current_name()
  local buf_id = vim.api.nvim_get_current_buf()
  return vim.api.nvim_buf_get_name(buf_id)
end

local function get_last_sec_of_path(path, slash)
  local htap = path:reverse()
  return string.match(htap, "[^" .. slash .. "]*"):reverse()
end

local function get_buf_to_go_to_id(new_nome)
  if vim.fn.bufexists(new_nome) ~= 0 then
    return vim.fn.bufnr(new_nome)
  else
    return vim.fn.bufadd(new_nome)
  end
end

local function get_ext_as_string(dirnome, ext_inpt)
  local ext_string = ""
  if is_string(ext_inpt) then
    ext_string = string.format("%s%s", dirnome, ext_inpt)
    return ext_string
  elseif is_table(ext_inpt) then
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

local function get_writable_file(sentiero, slash, dirnome, ext_inpt)
  if is_table(ext_inpt) then
    for _, v in ipairs(ext_inpt) do
      local new_path = concatenare_sentiero(sentiero, slash, dirnome, v)
      if check_is_writable_file(new_path) then
        return new_path
      end
    end
    return false
  elseif is_string(ext_inpt) then
    local new_path = concatenare_sentiero(sentiero, slash, dirnome, ext_inpt)
    if check_is_writable_file(new_path) then
      return new_path
    end
    return false
  else
    return false
  end
end

local function print_speared_to(new_nome)
  print("spear speared to " .. new_nome)
end

-- end getting detail functions

-- main function
function M.spear(ext_input)

  local ext_input_is_valid = is_valid(ext_input)

  if ext_input_is_valid == nil then
    return print("spear: not a valid extension; check your config")
  end

  local current_name = get_current_name()
  local slash = get_slash(current_name)
  local is_file_or_dir = check_current_is_file_or_dir(current_name)

  if is_file_or_dir == nil then
    return print("spear can't do things here")
  end

  if is_file_or_dir == "file" then

    local filename = get_last_sec_of_path(current_name, slash)
    local directory = remove_file_from_dir(current_name, slash, filename)
    local dir_name = get_last_sec_of_path(directory, slash)
    local extension = remove_from(filename, dir_name)

    if ext_input_matches_extension(ext_input, extension) then
      return print("spear: already in file")
    end

    local new_path = get_writable_file(directory, slash, dir_name, ext_input)

    if new_path == false then
      local ext_string = get_ext_as_string(dir_name, ext_input)
      return print(string.format("spear can't find %s here", ext_string))
    end

    local id = get_buf_to_go_to_id(new_path)
    local new_name = get_last_sec_of_path(new_path, slash)
    change_file(id)
    print_speared_to(new_name)

  elseif is_file_or_dir == "dir" then

    local dirname = get_last_sec_of_path(current_name, slash)
    local new_path = get_writable_file(current_name, slash, dirname, ext_input)

    if new_path == false then
      local ext_string = get_ext_as_string(dirname, ext_input)
      return print(string.format("spear can't find %s here", ext_string))
    end

    local id = get_buf_to_go_to_id(new_path)

    local new_name = get_last_sec_of_path(new_path, slash)
    change_file(id)
    print_speared_to(new_name)
  end
end

-- end main function


return M
