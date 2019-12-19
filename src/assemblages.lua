-- Assemblages

local PATH = (...):gsub('%.[^%.]+$', '')

local Type = require(PATH..".type")

local Assemblages = {}

function Assemblages.register(name, assemblage)
    if (type(name) ~= "string") then
        error("bad argument #1 to 'Assemblages.register' (string expected, got "..type(name)..")", 3)
    end

    if (not Type.isAssemblage(assemblage)) then
        error("bad argument #2 to 'Assemblages.register' (assemblage expected, got "..type(world)..")", 3)
    end

    if (rawget(Assemblages, name)) then
        error("bad argument #2 to 'Assemblages.register' (Assemblage with name '"..name.."' is already registerd)", 3)
    end

    Assemblages[name] = assemblage
end

return setmetatable(Assemblages, {
    __index = function(_, name)
        error("Attempt to index assemblage '"..tostring(name).."' that does not exist / was not registered", 2)
    end
})