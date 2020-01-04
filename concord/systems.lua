--- Systems
-- Container for registered SystemClasses

local PATH = (...):gsub('%.[^%.]+$', '')

local Type = require(PATH..".type")

local Systems = {}

--- Registers a SystemClass.
-- @param name Name to register under
-- @param systemClass SystemClass to register
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
end

return setmetatable(Systems, {
    __index = function(_, name)
        error("Attempt to index system '"..tostring(name).."' that does not exist / was not registered", 2)
    end
})