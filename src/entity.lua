--- Entity
-- Entities are the concrete objects that exist in your project.
-- An Entity have Components and are processed by Systems.
-- An Entity is contained by a maximum of 1 World.

local PATH = (...):gsub('%.[^%.]+$', '')

local Type = require(PATH..".type")

local Entity = {}
Entity.__mt = {
   __index = Entity,
}

--- Creates a new Entity. Optionally adds it to a World.
-- @param world Optional World to add the entity to
-- @return A new Entity
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

local function give(e, componentClass, ...)
   local component = componentClass:__initialize(...)

   e[componentClass] = component
   e.__components[componentClass] = component

   e:__dirty()
end

local function remove(e, componentClass)
   e[componentClass] = nil
   e.__components[componentClass] = nil

   e:__dirty()
end

--- Gives an Entity a Component.
-- If the Component already exists, it's overridden by this new Component
-- @param componentClass ComponentClass to add an instance of
-- @param ... varargs passed to the Component's populate function
-- @return self
function Entity:give(componentClass, ...)
   if not Type.isComponentClass(componentClass) then
      error("bad argument #1 to 'Entity:give' (ComponentClass expected, got "..type(componentClass)..")", 2)
   end

   give(self, componentClass, ...)

   return self
end

--- Ensures an Entity to have a Component.
-- If the Component already exists, no action is taken
-- @param componentClass ComponentClass to add an instance of
-- @param ... varargs passed to the Component's populate function
-- @return self
function Entity:ensure(componentClass, ...)
   if not Type.isComponentClass(componentClass) then
      error("bad argument #1 to 'Entity:ensure' (ComponentClass expected, got "..type(componentClass)..")", 2)
   end

   if self[componentClass] then
      return self
   end

   give(self, componentClass, ...)

   return self
end

--- Removes a Component from an Entity.
-- @param componentClass ComponentClass of the Component to remove
-- @return self
function Entity:remove(componentClass)
   if not Type.isComponentClass(componentClass) then
      error("bad argument #1 to 'Entity:remove' (ComponentClass expected, got "..type(componentClass)..")")
   end

   remove(self, componentClass)

   return self
end

--- Assembles an Entity.
-- @see Assemblage:assemble
-- @param assemblage Assemblage to assemble with
-- @param ... Varargs to pass to the Assemblage's assemble function.
function Entity:assemble(assemblage, ...)
   if not Type.isAssemblage(assemblage) then
      error("bad argument #1 to 'Entity:assemble' (Assemblage expected, got "..type(assemblage)..")")
   end

   assemblage:assemble(self, ...)

   return self
end

--- Destroys the Entity.
-- Removes the Entity from it's World if it's in one.
-- @return self
function Entity:destroy()
   if self.__world then
      self.__world:removeEntity(self)
   end

   return self
end

--- Internal: Tells the World it's in that this Entity is dirty.
-- @return self
function Entity:__dirty()
   if self.__world then
      self.__world:__dirtyEntity(self)
   end

   return self
end

--- Returns true if the Entity has a Component.
-- @param componentClass ComponentClass of the Component to check
-- @return True if the Entity has the Component, false otherwise
function Entity:has(componentClass)
   if not Type.isComponentClass(componentClass) then
      error("bad argument #1 to 'Entity:has' (ComponentClass expected, got "..type(componentClass)..")")
   end

   return self[componentClass] ~= nil
end

--- Gets a Component from the Entity.
-- @param componentClass ComponentClass of the Component to get
-- @return The Component
function Entity:get(componentClass)
   if not Type.isComponentClass(componentClass) then
      error("bad argument #1 to 'Entity:get' (ComponentClass expected, got "..type(componentClass)..")")
   end

   return self[componentClass]
end

--- Returns a table of all Components the Entity has.
-- Warning: Do not modify this table.
-- Use Entity:give/ensure/remove instead
-- @return Table of all Components the Entity has
function Entity:getComponents()
   return self.__components
end

--- Returns true if the Entity is in a World.
-- @return True if the Entity is in a World, false otherwise
function Entity:inWorld()
   return self.__world and true or false
end

--- Returns the World the Entity is in.
-- @return The World the Entity is in.
function Entity:getWorld()
   return self.__world
end

return setmetatable(Entity, {
   __call = function(_, ...)
      return Entity.new(...)
   end,
})