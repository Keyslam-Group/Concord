local Entity = {}
Entity.__index = Entity

--- Creates and initializes a new Entity.
-- @return A new Entity
function Entity.new()
   local e = setmetatable({
      components = {},
      instance   = nil,
   }, Entity)

   return e
end

--- Gives an Entity a component with values.
-- @param component The Component to add
-- @param ... The values passed to the Component
-- @return self
function Entity:give(component, ...)
   self.components[component] = component:__initialize(...)

   return self
end

--- Removes a component from an Entity.
-- @param component The Component to remove
-- @return self
function Entity:remove(component)
   self.components[component] = nil

   return self
end

--- Checks the Entity against the pools again.
-- @return self
function Entity:check()
   self.instance:checkEntity(self)

   return self
end

--- Gets a Component from the Entity
-- @param component The Component to get
-- @return The Bag from the Component
function Entity:get(component)
   return self.components[component]
end

--- Returns true if the Entity has the Component
-- @params component The Component to check against
-- @return True if the entity has the Bag. False otherwise
function Entity:has(component)
   return self.components[component] and true
end

return setmetatable(Entity, {
   __call = function(_, ...) return Entity.new(...) end,
})
