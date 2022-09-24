local spear = require("spear")

M = {}

-- start angular implementations and presets
-- app specific
M.spear_mod = function() spear(".module.ts") end
M.spear_route = function() spear("-routing.module.ts") end

-- component specific
M.spear_ts = function() spear(".component.ts") end
M.spear_html = function() spear(".component.html") end
M.spear_spec = function() spear(".component.spec.ts") end
M.spear_css = function() spear({ ".component.css", ".component.scss" }) end

-- combos of unlikely pairs
M.spear_ts_pipe = function() spear({ ".component.ts", ".pipe.ts" }) end
-- end angular implementations and presets

return M
