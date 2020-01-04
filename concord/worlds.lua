--- Worlds
-- Container for registered Worlds

local PATH = (...):gsub('%.[^%.]+$', '')

local Type = require(PATH..".type")

local Worlds = {}

--- Registers a World.
-- @tparam string name Name to register under
-- @param world World to register
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

    Worlds[name] = world
    world.__name = name
end

--- Returns true if the containter has the World with the name
-- @tparam string name Name of the World to check
-- @treturn boolean
function Worlds.has(name)
    return Worlds[name] and true or false
end

--- Returns the World with the name
-- @tparam string name Name of the World to get
-- @return World with the name
function Worlds.get(name)
    return Worlds[name]
end

return setmetatable(Worlds, {
    __index = function(_, name)
        error("Attempt to index world '"..tostring(name).."' that does not exist / was not registered", 2)
    end
})
