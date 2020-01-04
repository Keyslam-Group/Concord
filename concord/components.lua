--- Container for registered ComponentClasses
-- @module Components

local PATH = (...):gsub('%.[^%.]+$', '')

local Type = require(PATH..".type")

local Components = {}

--- Registers a ComponentClass.
-- @string name Name to register under
-- @tparam Component componentClass ComponentClass to register
function Components.register(name, componentClass)
    if (type(name) ~= "string") then
        error("bad argument #1 to 'Components.register' (string expected, got "..type(name)..")", 3)
    end

    if (not Type.isComponentClass(componentClass)) then
        error("bad argument #2 to 'Components.register' (ComponentClass expected, got "..type(componentClass)..")", 3)
    end

    if (rawget(Components, name)) then
        error("bad argument #2 to 'Components.register' (ComponentClass with name '"..name.."' was already registerd)", 3) -- luacheck: ignore
    end

    Components[name] = componentClass
    componentClass.__name = name
end

--- Returns true if the containter has the ComponentClass with the specified name
-- @string name Name of the ComponentClass to check
-- @treturn boolean
function Components.has(name)
    return Components[name] and true or false
end

--- Returns the ComponentClass with the specified name
-- @string name Name of the ComponentClass to get
-- @treturn Component
function Components.get(name)
    return Components[name]
end

return setmetatable(Components, {
    __index = function(_, name)
        error("Attempt to index ComponentClass '"..tostring(name).."' that does not exist / was not registered", 2)
    end
})
