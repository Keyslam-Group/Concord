--- Entity

local PATH = (...):gsub('%.[^%.]+$', '')

local Type = require(PATH..".type")

local Entity = {}
Entity.__index = Entity

--- Creates and initializes a new Entity.
-- @return A new Entity
function Entity.new()
   local e = setmetatable({
      __world = nil,

      __addedComponents   = {},
      __removedComponents = {},
      __operations        = {},

      __components = {},

      __isDirty    = false,
      __wasAdded   = false,
      __wasRemoved = false,

      __isEntity = true,
   }, Entity)

   return e
end

local function giveOperation(e, component)
   local baseComponent = component.__baseComponent

   e[baseComponent] = component
   e.__components[baseComponent] = component
end

local function removeOperation(e, baseComponent)
   e[baseComponent] = nil
   e.__components[baseComponent] = nil
end

local function give(e, baseComponent, ...)
   local component = baseComponent:__initialize(...)

   e.__addedComponents[#e.__addedComponents + 1] = component
   e.__operations[#e.__operations + 1] = giveOperation

   e.__isDirty = true
end

local function remove(e, baseComponent)
   e.__removedComponents[#e.__removedComponents + 1] = baseComponent
   e.__operations[#e.__operations + 1] = removeOperation

   e.__isDirty = true
end

--- Gives an Entity a component with values.
-- @param component The Component to add
-- @param ... The values passed to the Component
-- @return self
function Entity:give(component, ...)
   if not Type.isComponent(component) then
      error("bad argument #1 to 'Entity:give' (Component expected, got "..type(component)..")", 2)
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

   remove(self, component)

   return self
end

function Entity:assemble(assemblage, ...)
   if not Type.isAssemblage(assemblage) then
      error("bad argument #1 to 'Entity:assemble' (Assemblage expected, got "..type(assemblage)..")")
   end

   assemblage:assemble(self, ...)

   return self
end

function Entity:__flush()
   local addi, removei = 1, 1

   for i = 1, #self.__operations do
      local operation = self.__operations[i]

      if (operation == giveOperation) then
         operation(self, self.__addedComponents[addi])
         self.__addedComponents[addi] = nil
         addi = addi + 1
      elseif (operation == removeOperation) then
         operation(self, self.__removedComponents[removei])
         self.__removedComponents[removei] = nil
         removei = removei + 1
      end

      self.__operations[i] = nil
   end
end

--- Destroys the Entity.
-- @return self
function Entity:destroy()
   if self.world then
      self.world:removeEntity(self)
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

function Entity:getComponents()
   return self.__components
end

function Entity:getWorld()
   return self.__world
end

return setmetatable(Entity, {
   __call = function(_, ...)
      return Entity.new(...)
   end,
})
