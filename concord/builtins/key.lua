local PATH = (...):gsub('%.builtins%.[^%.]+$', '')

local Component = require(PATH..".component")

local getKey = function (self, key)
  local entity = self.__entity

  if not entity:inWorld() then
    error("entity needs to belong to a world")
  end

  local world = entity:getWorld()

  return world:__assignKey(entity, key)
end

local Key = Component("key", function (self, key)
  self.value = getKey(self, key)
end)

function Key:deserialize (data)
  self.value = getKey(self, data)
end

function Key.__mt:__call()
  return self.value
end

function Key:removed (replaced)
  if not replaced then
    local entity = self.__entity

    if entity:inWorld() then
      local world = entity:getWorld()

      return world:__clearKey(entity)
    end
  end
end

return Key
