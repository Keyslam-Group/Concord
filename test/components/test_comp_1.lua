local Component = require("src").component

return Component(function(e, x, y)
    e.x = x
    e.y = y
end)