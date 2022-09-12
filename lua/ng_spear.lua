local spear = require("spear")

M = {}

M.spear_ts = function() spear("component.ts") end
M.spear_spec = function() spear("component.spec.ts") end
M.spear_css = function() spear({ "component.css", "component.scss" }) end
M.spear_html = function() spear("component.html") end

return M
