--- Container for registered SystemClasses
-- @module Systems

local PATH = (...):gsub('%.[^%.]+$', '')

local Type = require(PATH..".type")

local Systems = {}

--- Registers a SystemClass.
-- @tparam string name Name to register under
-- @tparam System systemClass SystemClass to register
function Systems.register(name, systemClass)
    if (type(name) ~= "string") then
        error("bad argument #1 to 'Systems.register' (string expected, got "..type(name)..")", 3)
    end

    if (not Type.isSystemClass(systemClass)) then
        error("bad argument #2 to 'Systems.register' (systemClass expected, got "..type(systemClass)..")", 3)
    end

    if (rawget(Systems, name)) then
        error("bad argument #2 to 'Systems.register' (System with name '"..name.."' is already registerd)", 3)
    end

    Systems[name] = systemClass
    systemClass.__name = name
end

--- Returns true if the containter has the SystemClass with the name
-- @tparam string name Name of the SystemClass to check
-- @treturn boolean
function Systems.has(name)
    return Systems[name] and true or false
end

--- Returns the SystemClass with the name
-- @tparam string name Name of the SystemClass to get
-- @return SystemClass with the name
function Systems.get(name)
    return Systems[name]
end

return setmetatable(Systems, {
    __index = function(_, name)
        error("Attempt to index system '"..tostring(name).."' that does not exist / was not registered", 2)
    end
})
