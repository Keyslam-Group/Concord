--- Entity

local PATH = (...):gsub('%.[^%.]+$', '')

local Type = require(PATH..".type")
local List = require(PATH..".list")

local Entity = {}
Entity.__index = Entity

--- Creates and initializes a new Entity.
-- @return A new Entity
function Entity.new()
   local e = setmetatable({
      removed   = {},
      worlds = List(),

      __isEntity = true,
   }, Entity)

   return e
end

local function give(e, component, ...)
   local comp = component:__initialize(...)
   e[component] = comp

   e:mark()
end

--- Gives an Entity a component with values.
-- @param component The Component to add
-- @param ... The values passed to the Component
-- @return self
function Entity:give(component, ...)
   if not Type.isComponent(component) then
      error("bad argument #1 to 'Entity:give' (Component expected, got "..type(component)..")", 2)
   end

   if self[component] then
      self:remove(component):apply()
   end

   give(self, component, ...)

   return self
end

function Entity:ensure(component, ...)
   if not Type.isComponent(component) then
      error("bad argument #1 to 'Entity:ensure' (Component expected, got "..type(component)..")", 2)
   end

   if self[component] then
      return self
   end

   give(self, component, ...)

   return self
end

--- Removes a component from an Entity.
-- @param component The Component to remove
-- @return self
function Entity:remove(component)
   if not Type.isComponent(component) then
      error("bad argument #1 to 'Entity:remove' (Component expected, got "..type(component)..")")
   end

   self.removed[#self.removed + 1] = component

   self:mark()

   return self
end

function Entity:assemble(assemblage, ...)
   if not Type.isAssemblage(assemblage) then
      error("bad argument #1 to 'Entity:assemble' (Assemblage expected, got "..type(assemblage)..")")
   end

   assemblage:assemble(self, ...)

   return self
end

function Entity:mark()
   for i = 1, self.worlds.size do
      self.worlds:get(i):markEntity(self)
   end
end

function Entity:apply()
   for i = 1, #self.removed do
      local component = self.removed[i]

      self[component] = nil
      self.removed[i] = nil
   end

   return self
end

--- Destroys the Entity.
-- @return self
function Entity:destroy()
   for i = 1, self.worlds.size do
      self.worlds:get(i):removeEntity(self)
   end

   return self
end

--- Gets a Component from the Entity.
-- @param component The Component to get
-- @return The Bag from the Component
function Entity:get(component)
   if not Type.isComponent(component) then
      error("bad argument #1 to 'Entity:get' (Component expected, got "..type(component)..")")
   end

   return self[component]
end

--- Returns true if the Entity has the Component.
-- @param component The Component to check against
-- @return True if the entity has the Bag. False otherwise
function Entity:has(component)
   if not Type.isComponent(component) then
      error("bad argument #1 to 'Entity:has' (Component expected, got "..type(component)..")")
   end

   return self[component] ~= nil
end

return setmetatable(Entity, {
   __call = function(_, ...)
      return Entity.new(...)
   end,
})
