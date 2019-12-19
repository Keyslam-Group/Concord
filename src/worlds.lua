-- Worlds

local PATH = (...):gsub('%.[^%.]+$', '')

local Type = require(PATH..".type")

local Worlds = {}

function Worlds.register(name, world)
    if (type(name) ~= "string") then
        error("bad argument #1 to 'Worlds.register' (string expected, got "..type(name)..")", 3)
    end

    if (not Type.isWorld(world)) then
        error("bad argument #2 to 'Worlds.register' (world expected, got "..type(world)..")", 3)
    end

    if (rawget(Worlds, name)) then
        error("bad argument #2 to 'Worlds.register' (World with name '"..name.."' is already registerd)", 3)
    end

    Worlds[name] = component
end

return setmetatable(Worlds, {
    __index = function(_, name)
        error("Attempt to index world '"..tostring(name).."' that does not exist / was not registered", 2)
    end
})