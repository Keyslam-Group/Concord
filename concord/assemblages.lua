--- A container for registered @{Assemblage}s
-- @module Assemblages

local PATH = (...):gsub('%.[^%.]+$', '')

local Type = require(PATH..".type")

local Assemblages = {}

--- Registers an Assemblage.
-- @string name Name to register under
-- @tparam Assemblage assemblage Assemblage to register
function Assemblages.register(name, assemblage)
    if (type(name) ~= "string") then
        error("bad argument #1 to 'Assemblages.register' (string expected, got "..type(name)..")", 3)
    end

    if (not Type.isAssemblage(assemblage)) then
        error("bad argument #2 to 'Assemblages.register' (assemblage expected, got "..type(assemblage)..")", 3)
    end

    if (rawget(Assemblages, name)) then
        error("bad argument #2 to 'Assemblages.register' (Assemblage with name '"..name.."' was already registerd)", 3)
    end

    Assemblages[name] = assemblage
    assemblage.__name = name
end

--- Returns true if the containter has an Assemblage with the specified name
-- @string name Name of the Assemblage to check
-- @treturn boolean
function Assemblages.has(name)
    return Assemblages[name] and true or false
end

--- Returns the Assemblage with the specified name
-- @string name Name of the Assemblage to get
-- @treturn Assemblage
function Assemblages.get(name)
    return Assemblages[name]
end


return setmetatable(Assemblages, {
    __index = function(_, name)
        error("Attempt to index assemblage '"..tostring(name).."' that does not exist / was not registered", 2)
    end
})
