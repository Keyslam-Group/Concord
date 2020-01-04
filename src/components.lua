-- Components
-- Container for registered ComponentClasss

local PATH = (...):gsub('%.[^%.]+$', '')

local Type = require(PATH..".type")

local Components = {}

--- Registers a ComponentClass.
-- @param name Name to register under
-- @param componentClass ComponentClass to register
function Components.register(name, componentClass)
    if (type(name) ~= "string") then
        error("bad argument #1 to 'Components.register' (string expected, got "..type(name)..")", 3)
    end

    if (not Type.isComponentClass(componentClass)) then
        error("bad argument #2 to 'Components.register' (ComponentClass expected, got "..type(componentClass)..")", 3)
    end

    if (rawget(Components, name)) then
        error("bad argument #2 to 'Components.register' (ComponentClass with name '"..name.."' was already registerd)", 3)
    end

    Components[name] = componentClass
end

return setmetatable(Components, {
    __index = function(_, name)
        error("Attempt to index ComponentClass '"..tostring(name).."' that does not exist / was not registered", 2)
    end
})