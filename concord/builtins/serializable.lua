local PATH = (...):gsub('%.builtins%.[^%.]+$', '')

local Component = require(PATH..".component")

local Serializable = Component("serializable")

function Serializable:serialize ()
  -- Don't serialize this Component
  return nil
end

return Serializable