local M = {}

-- start checking functions
local function is_table(thing)
  return type(thing) == "table"
end

local function is_string(thing)
  return type(thing) == "string"
end

local function is_valid(extn_input)
  if is_table(extn_input) then
    for _, v in ipairs(extn_input) do
      if not is_string(v) then
        print("Please provide only strings")
        return nil
      end
    end
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

local function remove_from(to_remove, to_remove_from)
  return string.gsub(to_remove_from, to_remove, "")
end

local function remove_file_from_dir(dir, file)
  return remove_from("/" .. file, dir)
end

local function add_ext_input_to_file(dirn, extn)
  return string.format("%s%s", dirn, extn)
end

-- end string manipulation functions

-- start getting detail functions
local function get_current_name()
  local buf_id = vim.api.nvim_get_current_buf()
  return vim.api.nvim_buf_get_name(buf_id)
end

local function get_last_sec_of_path(path)
  local htap = path:reverse()
  return string.match(htap, "[^/]*"):reverse()
end

local function get_buf_to_go_to_id(new_nome)
  if vim.fn.bufexists(new_nome) ~= 0 then
    return vim.fn.bufnr(new_nome)
  else
    return vim.fn.bufadd(new_nome)
  end
end

local function get_new_buf_id_if_any(dirnome, ext_inpt)
  if is_table(ext_inpt) then
    for _, v in pairs(ext_inpt) do
      local new_name = add_ext_input_to_file(dirnome, v)
      if check_is_writable_file(new_name) then
        return get_buf_to_go_to_id(new_name)
      end
    end
  elseif is_string(ext_inpt) then
    local new_name = add_ext_input_to_file(dirnome, ext_inpt)
    if check_is_writable_file(new_name) then
      return get_buf_to_go_to_id(new_name)
    end
  else
    return false
  end

end

-- end getting detail functions

-- main function
function M.spear(ext_input)

  local ext_input_is_valid = is_valid(ext_input)
  if ext_input_is_valid == nil then return print("not a valid extension; check your config") end

  local current_name = get_current_name()
  local is_file_or_dir = check_current_is_file_or_dir(current_name)
  if is_file_or_dir == nil then return print("cannot do things here") end

  if is_file_or_dir == "file" then

    local filename = get_last_sec_of_path(current_name)
    local path_without_filename = remove_file_from_dir(current_name, filename)
    local dirname = get_last_sec_of_path(path_without_filename)
    local extension = remove_from(dirname, filename)
    if ext_input_matches_extension(ext_input, extension) then return print("spear: already in file") end

    local file_to_go_to_id = get_new_buf_id_if_any(dirname, ext_input)
    if file_to_go_to_id == false then return print("spear: file with that name doesn't exist") end

    change_file(file_to_go_to_id)

  elseif is_file_or_dir == "dir" then

    local dirname = get_last_sec_of_path(current_name)
    local file_to_go_to_id = get_new_buf_id_if_any(dirname, ext_input)
    if file_to_go_to_id == false then return print("spear: file with that name doesn't exist") end

    change_file(file_to_go_to_id)

  end
end

-- end main function

-- start angular implementations and presets
-- app specific
M.spear_mod = function() M.spear(".module.ts") end
M.spear_route = function() M.spear("-routing.module.ts") end

-- component specific
M.spear_ts = function() M.spear(".component.ts") end
M.spear_html = function() M.spear(".component.html") end
M.spear_spec = function() M.spear(".component.spec.ts") end
M.spear_css = function() M.spear({ ".component.css", ".component.scss" }) end

-- combos of unlikely pairs
M.spear_ts_pipe = function() M.spear({ ".component.ts", ".pipe.ts" }) end
-- end angular implementations and presets

return M
