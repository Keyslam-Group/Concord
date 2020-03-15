--- An object that exists in a world. An entity
-- contains components which are processed by systems.
-- @classmod Entity

local PATH = (...):gsub('%.[^%.]+$', '')

local Components = require(PATH..".components")
local Type       = require(PATH..".type")

local Entity = {}
Entity.__mt = {
   __index = Entity,
}

--- Creates a new Entity. Optionally adds it to a World.
-- @tparam[opt] World world World to add the entity to
-- @treturn Entity A new Entity
function Entity.new(world)
   if (world ~= nil and not Type.isWorld(world)) then
      error("bad argument #1 to 'Entity.new' (world/nil expected, got "..type(world)..")", 2)
   end

   local e = setmetatable({
      __world      = nil,
      __components = {},

      __isEntity = true,
   }, Entity.__mt)

   if (world) then
      world:addEntity(e)
   end

   return e
end

local function give(e, name, componentClass, ...)
   local component = componentClass:__initialize(...)

   e[name] = component
   e.__components[name] = component

   e:__dirty()
end

local function remove(e, name, componentClass)
   e[name] = nil
   e.__components[name] = nil

   e:__dirty()
end

--- Gives an Entity a Component.
-- If the Component already exists, it's overridden by this new Component
-- @tparam Component componentClass ComponentClass to add an instance of
-- @param ... additional arguments to pass to the Component's populate function
-- @treturn Entity self
function Entity:give(name, ...)
   local ok, componentClass = Components.try(name)

   if not ok then
      error("bad argument #1 to 'Entity:get' ("..componentClass..")", 2)
   end

   give(self, name, componentClass, ...)

   return self
end

--- Ensures an Entity to have a Component.
-- If the Component already exists, no action is taken
-- @tparam Component componentClass ComponentClass to add an instance of
-- @param ... additional arguments to pass to the Component's populate function
-- @treturn Entity self
function Entity:ensure(name, ...)
   local ok, componentClass = Components.try(name)

   if not ok then
      error("bad argument #1 to 'Entity:get' ("..componentClass..")", 2)
   end

   if self[name] then
      return self
   end

   give(self, name, componentClass, ...)

   return self
end

--- Removes a Component from an Entity.
-- @tparam Component componentClass ComponentClass of the Component to remove
-- @treturn Entity self
function Entity:remove(name)
   local ok, componentClass = Components.try(name)

   if not ok then
      error("bad argument #1 to 'Entity:get' ("..componentClass..")", 2)
   end

   remove(self, name, componentClass)

   return self
end

--- Assembles an Entity.
-- @tparam function assemblage Function that will assemble an entity
-- @param ... additional arguments to pass to the assemblage function.
-- @treturn Entity self
function Entity:assemble(assemblage, ...)
   if type(assemblage) ~= "function" then
      error("bad argument #1 to 'Entity:assemble' (function expected, got "..type(assemblage)..")")
   end

   assemblage(self, ...)

   return self
end

--- Destroys the Entity.
-- Removes the Entity from its World if it's in one.
-- @return self
function Entity:destroy()
   if self.__world then
      self.__world:removeEntity(self)
   end

   return self
end

-- Internal: Tells the World it's in that this Entity is dirty.
-- @return self
function Entity:__dirty()
   if self.__world then
      self.__world:__dirtyEntity(self)
   end

   return self
end

--- Returns true if the Entity has a Component.
-- @tparam Component componentClass ComponentClass of the Component to check
-- @treturn boolean
function Entity:has(name)
   local ok, componentClass = Components.try(name)

   if not ok then
      error("bad argument #1 to 'Entity:has' ("..componentClass..")", 2)
   end

   return self[name] and true or false
end

--- Gets a Component from the Entity.
-- @tparam Component componentClass ComponentClass of the Component to get
-- @treturn table
function Entity:get(name)
   local ok, componentClass = Components.try(name)

   if not ok then
      error("bad argument #1 to 'Entity:get' ("..componentClass..")", 2)
   end

   return self[name]
end

--- Returns a table of all Components the Entity has.
-- Warning: Do not modify this table.
-- Use Entity:give/ensure/remove instead
-- @treturn table Table of all Components the Entity has
function Entity:getComponents()
   return self.__components
end

--- Returns true if the Entity is in a World.
-- @treturn boolean
function Entity:inWorld()
   return self.__world and true or false
end

--- Returns the World the Entity is in.
-- @treturn World
function Entity:getWorld()
   return self.__world
end

function Entity:serialize()
   local data = {}

   for _, component in pairs(self.__components) do
      if component.__name then
         local componentData = component:serialize()

         if componentData ~= nil then
            componentData.__name = component.__name
            data[#data + 1] = componentData
         end
      end
   end

   return data
end

function Entity:deserialize(data)
   for i = 1, #data do
      local componentData = data[i]

      if (not Components.has(componentData.__name)) then
         error("bad argument #1 to 'Entity:deserialize' (ComponentClass '"..tostring(componentData.__name).."' wasn't yet loaded)") -- luacheck: ignore
      end

      local componentClass = Components[componentData.__name]

      local component = componentClass:__new()
      component:deserialize(componentData)

      self[componentData.__name] = component
      self.__components[componentData.__name] = component

      self:__dirty()
   end
end

return setmetatable(Entity, {
   __call = function(_, ...)
      return Entity.new(...)
   end,
})
