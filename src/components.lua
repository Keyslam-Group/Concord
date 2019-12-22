-- Components

local PATH = (...):gsub('%.[^%.]+$', '')

local Type = require(PATH..".type")

local Components = {}

function Components.register(name, baseComponent)
    if (type(name) ~= "string") then
        error("bad argument #1 to 'Components.register' (string expected, got "..type(name)..")", 3)
    end

    if (not Type.isBaseComponent(baseComponent)) then
        error("bad argument #2 to 'Components.register' (BaseComponent expected, got "..type(baseComponent)..")", 3)
    end

    if (rawget(Components, name)) then
        error("bad argument #2 to 'Components.register' (BaseComponent with name '"..name.."' is already registerd)", 3)
    end

    Components[name] = baseComponent
end

return setmetatable(Components, {
    __index = function(_, name)
        error("Attempt to index BaseComponent '"..tostring(name).."' that does not exist / was not registered", 2)
    end
})