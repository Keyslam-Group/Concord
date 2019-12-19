-- Components

local PATH = (...):gsub('%.[^%.]+$', '')

local Type = require(PATH..".type")

local Components = {}

function Components.register(name, component)
    if (type(name) ~= "string") then
        error("bad argument #1 to 'Components.register' (string expected, got "..type(name)..")", 3)
    end

    if (not Type.isComponent(component)) then
        error("bad argument #2 to 'Components.register' (component expected, got "..type(component)..")", 3)
    end

    if (rawget(Components, name)) then
        error("bad argument #2 to 'Components.register' (Component with name '"..name.."' is already registerd)", 3)
    end

    Components[name] = component
end

return setmetatable(Components, {
    __index = function(_, name)
        error("Attempt to index component '"..tostring(name).."' that does not exist / was not registered", 2)
    end
})