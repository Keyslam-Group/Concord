-- Systems

local PATH = (...):gsub('%.[^%.]+$', '')

local Type = require(PATH..".type")

local Systems = {}

function Systems.register(name, system)
    if (type(name) ~= "string") then
        error("bad argument #1 to 'Systems.register' (string expected, got "..type(name)..")", 3)
    end

    if (not Type.isBaseSystem(system)) then
        error("bad argument #2 to 'Systems.register' (baseSystem expected, got "..type(system)..")", 3)
    end

    if (rawget(Systems, name)) then
        error("bad argument #2 to 'Systems.register' (System with name '"..name.."' is already registerd)", 3)
    end

    Systems[name] = system
end

return setmetatable(Systems, {
    __index = function(_, name)
        error("Attempt to index system '"..tostring(name).."' that does not exist / was not registered", 2)
    end
})