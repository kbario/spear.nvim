local M = {}

local function is_table(thing)
  return type(thing) == "table"
end

local function is_string(thing)
  return type(thing) == "string"
end

local function is_valid(thing)
  if is_table(thing) then
    for _, v in ipairs(thing) do
      if not is_string(v) then
        print("Please provide only strings")
        return nil
      end
    end
    return "table"
  elseif not is_string(thing) then
    print("Please provide only strings")
    return nil
  end
  return "string"
end

local function get_name()
  local buf_this = vim.api.nvim_get_current_buf()
  return vim.api.nvim_buf_get_name(buf_this)
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

local function get_buf_id(no_end, ext, table_or_string)
  if table_or_string == "table" then
    for index, value in ipairs(ext) do
      local name = string.format("%s%s", no_end, value)
      if vim.fn.filewritable(name) == 1 then
        if vim.fn.bufexists(name) ~= 0 then
          return vim.fn.bufnr(name)
        else
          return vim.fn.bufadd(name)
        end
      end
    end
  elseif table_or_string == "string" then
    local name = string.format("%s%s", no_end, ext)
    if vim.fn.filewritable(name) == 1 then
      if vim.fn.bufexists(name) ~= 0 then
        return vim.fn.bufnr(name)
      else
        return vim.fn.bufadd(name)
      end
    end
  end
end

local function get_name_no_end(name, is)
  if is == "file" then
    local component_start_at, _ = string.find(name, "component.", 1, true)
    if component_start_at == nil then return print("no components found here") end
    return string.sub(name, 1, component_start_at - 1)
  elseif is == "dir" then
    local eman = name:reverse()
    local folder = string.match(eman, "[^/]*"):reverse()
    --local folder = :reverse()
    return string.format("%s/%s.", name, folder)
  end
end

local function change_file(id)
  vim.api.nvim_set_current_buf(id)
  vim.api.nvim_buf_set_option(id, "buflisted", true)
end

function M.spear(extension)
  -- check if things are valid inputs
  local what_is = is_valid(extension)
  -- gaurd against bad inputs
  if what_is == nil then return print("not a valid extension; check your config") end
  -- get current file/dir name
  local file_or_dir_name = get_name()
  -- check if current is a file or a dir
  local is_file_or_dir = check_current_is_file_or_dir(file_or_dir_name)
  -- gaurd against doing things when not in a file or dir
  if is_file_or_dir == nil then return print("cannot do things here") end
  -- get the path ready to append dif file suffix
  local name_no_end = get_name_no_end(file_or_dir_name, is_file_or_dir)
  -- get id of the buffer you wish to open
  local buf_id = get_buf_id(name_no_end, extension, what_is)
  -- do the changing
  change_file(buf_id)
end

return M
