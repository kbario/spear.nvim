local pth = require("plenary.path")
local settings = require("spear.settings").settings

local M = {}

M.is_dar = vim.loop.os_uname().sysname == "Darwin"
M.is_lin = vim.fn.has "linux" == 1
M.is_mac = vim.fn.has "macunix" == 1
M.is_win = vim.fn.has "win32" == 1 or vim.fn.has "win64" == 1
M.is_uni = vim.fn.has "unix" == 1
M.s_name = vim.loop.os_uname().sysname

M.get_slash = function()
  if M.is_win then
    return "\\"
  else
    return "/"
  end
end

M.is_table = function(thing)
  return type(thing) == "table"
end

M.is_string = function(thing)
  if type(thing) == "string" then
    if thing ~= "" or thing ~= " " then
      return true
    end
  end
  return false
end

M.project_key = function()
  return vim.loop.cwd()
end

M.normalize_path = function(item)
  return pth:new(item):make_relative(M.project_key())
end

M.is_nil = function(input)
 return input == nil
end

local function get_config_path(type)
  local path = vim.fn.stdpath(type)
  return string.format("%s%sspear.json", path, M.get_slash())
end

local function read_config(path)
  return vim.fn.json_decode(pth:new(path):read())
end

local function write_config(path, data)
  return pth:new(path):write(vim.fn.json_encode(data), "w")
end

M.load_config = function(type)
  local path = get_config_path(type)
  local ok, config = pcall(read_config, path)
  if ok then
    return config
  else
    return {}
  end
end

M.save_config = function(type, data)
  local path = get_config_path(type)
  return write_config(path, data)
end

local function valid_option(input, valid_inputs)
  if M.is_nil(input) then
    return false
  end
  if M.is_string(valid_inputs) then
    return input == valid_inputs
  elseif M.is_table(valid_inputs) then
    for _, v in pairs(valid_inputs) do
      if input == v then
        return true
      end
    end
    return false
  end
end

--[[ function returning an object with validated user spear settings ]]
M.validate_options = function (config_input, global)
  local output = {}
  local saved_config = M.load_config("data")

  for k, v in pairs(settings) do
    if valid_option(config_input[k], v['values']) then
      output[k] = config_input[k]
    elseif not M.is_nil(saved_config[k]) and global == false then
      output[k] = saved_config[k]
    else
      output[k] = v['default']
    end
  end

  return output
end

return M

