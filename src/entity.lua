--- Entity

local PATH = (...):gsub('%.[^%.]+$', '')

local Type = require(PATH..".type")

local Entity = {}
Entity.__mt = {
   __index = Entity,
}

--- Creates and initializes a new Entity.
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

local function give(e, baseComponent, ...)
   local component = baseComponent:__initialize(...)

   e[baseComponent] = component
   e.__components[baseComponent] = component

   e:__dirty()
end

local function remove(e, baseComponent)
   e[baseComponent] = nil
   e.__components[baseComponent] = nil

   e:__dirty()
end

--- Gives an Entity a component with values.
-- @param component The Component to add
-- @param ... The values passed to the Component
-- @return self
function Entity:give(baseComponent, ...)
   if not Type.isBaseComponent(baseComponent) then
      error("bad argument #1 to 'Entity:give' (BaseComponent expected, got "..type(baseComponent)..")", 2)
   end

   give(self, baseComponent, ...)

   return self
end

function Entity:ensure(baseComponent, ...)
   if not Type.isBaseComponent(baseComponent) then
      error("bad argument #1 to 'Entity:ensure' (BaseComponent expected, got "..type(baseComponent)..")", 2)
   end

   if self[baseComponent] then
      return self
   end

   give(self, baseComponent, ...)

   return self
end

--- Removes a component from an Entity.
-- @param component The Component to remove
-- @return self
function Entity:remove(baseComponent)
   if not Type.isBaseComponent(baseComponent) then
      error("bad argument #1 to 'Entity:remove' (BaseComponent expected, got "..type(baseComponent)..")")
   end

   remove(self, baseComponent)

   return self
end

function Entity:assemble(assemblage, ...)
   if not Type.isAssemblage(assemblage) then
      error("bad argument #1 to 'Entity:assemble' (Assemblage expected, got "..type(assemblage)..")")
   end

   assemblage:assemble(self, ...)

   return self
end

--- Destroys the Entity.
-- @return self
function Entity:destroy()
   if self.__world then
      self.__world:removeEntity(self)
   end

   return self
end

function Entity:__dirty()
   if self.__world then
      self.__world:__dirtyEntity(self)
   end
end

--- Gets a Component from the Entity.
-- @param component The Component to get
-- @return The Bag from the Component
function Entity:get(baseComponent)
   if not Type.isBaseComponent(baseComponent) then
      error("bad argument #1 to 'Entity:get' (BaseComponent expected, got "..type(baseComponent)..")")
   end

   return self[baseComponent]
end

--- Returns true if the Entity has the Component.
-- @param component The Component to check against
-- @return True if the entity has the Bag. False otherwise
function Entity:has(baseComponent)
   if not Type.isBaseComponent(baseComponent) then
      error("bad argument #1 to 'Entity:has' (BaseComponent expected, got "..type(baseComponent)..")")
   end

   return self[baseComponent] ~= nil
end

function Entity:getComponents()
   return self.__components
end

function Entity:hasWorld()
   return self.__world and true or false
end

function Entity:getWorld()
   return self.__world
end

return setmetatable(Entity, {
   __call = function(_, ...)
      return Entity.new(...)
   end,
})
