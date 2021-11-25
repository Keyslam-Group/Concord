--- An object that exists in a world. An entity
-- contains components which are processed by systems.
-- @classmod Entity

local PATH = (...):gsub('%.[^%.]+$', '')

local Components = require(PATH..".components")
local Type       = require(PATH..".type")
local Utils      = require(PATH..".utils")

-- Initialize built-in Components (as soon as possible)
local Builtins   = require(PATH..".builtins.init") --luacheck: ignore
-- Builtins is unused but the require already registers the Components

local Entity = {
   SERIALIZE_BY_DEFAULT = true,
}

Entity.__mt = {
   __index = Entity,
}

--- Creates a new Entity. Optionally adds it to a World.
-- @tparam[opt] World world World to add the entity to
-- @treturn Entity A new Entity
function Entity.new(world)
   if (world ~= nil and not Type.isWorld(world)) then
      Utils.error(2, "bad argument #1 to 'Entity.new' (world/nil expected, got %s)", type(world))
   end

   local e = setmetatable({
      __world      = nil,

      __isEntity = true,
   }, Entity.__mt)

   if (world) then
      world:addEntity(e)
   end

   if Entity.SERIALIZE_BY_DEFAULT then
      e:give("serializable")
   end

   return e
end

local function createComponent(e, name, componentClass, ...)
   local component = componentClass:__initialize(e, ...)
   local hadComponent = not not e[name]

   if hadComponent then
      e[name]:removed(true)
   end

   e[name] = component

   if not hadComponent then
      e:__dirty()
   end
end

local function deserializeComponent(e, name, componentData)
   local componentClass = Components[name]
   local hadComponent = not not e[name]

   if hadComponent then
      e[name]:removed(true)
   end

   local component = componentClass:__new(e)
   component:deserialize(componentData)

   e[name] = component

   if not hadComponent then
      e:__dirty()
   end
end

local function giveComponent(e, ensure, name, ...)
   local component
   if Type.isComponent(name) then
      component = name
      name = component:getName()
   end

   if ensure and e[name] then
      return e
   end

   local ok, componentClass = Components.try(name)

   if not ok then
      Utils.error(3, "bad argument #1 to 'Entity:%s' (%s)", ensure and 'ensure' or 'give', componentClass)
   end

   if component then
      local data = component:deserialize()
      if data == nil then
         Utils.error(3, "bad argument #1 to 'Entity:$s' (Component '%s' couldn't be deserialized)", ensure and 'ensure' or 'give', name)
      end

      deserializeComponent(e, name, data)
   else 
      createComponent(e, name, componentClass, ...)
   end

   return e
end


local function removeComponent(e, name)
   if e[name] then
      e[name]:removed(false)

      e[name] = nil

      e:__dirty()
   end
end

--- Gives an Entity a Component.
-- If the Component already exists, it's overridden by this new Component
-- @tparam Component componentClass ComponentClass to add an instance of
-- @param ... additional arguments to pass to the Component's populate function
-- @treturn Entity self
function Entity:give(name, ...)
   return giveComponent(self, false, name, ...)
end

--- Ensures an Entity to have a Component.
-- If the Component already exists, no action is taken
-- @tparam Component componentClass ComponentClass to add an instance of
-- @param ... additional arguments to pass to the Component's populate function
-- @treturn Entity self
function Entity:ensure(name, ...)
   return giveComponent(self, true, name, ...)
end

--- Removes a Component from an Entity.
-- @tparam Component componentClass ComponentClass of the Component to remove
-- @treturn Entity self
function Entity:remove(name)
   local ok, componentClass = Components.try(name)

   if not ok then
      Utils.error(2, "bad argument #1 to 'Entity:remove' (%s)", componentClass)
   end

   removeComponent(self, name)

   return self
end

--- Assembles an Entity.
-- @tparam function assemblage Function that will assemble an entity
-- @param ... additional arguments to pass to the assemblage function.
-- @treturn Entity self
function Entity:assemble(assemblage, ...)
   if type(assemblage) ~= "function" then
      Utils.error(2, "bad argument #1 to 'Entity:assemble' (function expected, got %s)", type(assemblage))
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
      Utils.error(2, "bad argument #1 to 'Entity:has' (%s)", componentClass)
   end

   return self[name] and true or false
end

--- Gets a Component from the Entity.
-- @tparam Component componentClass ComponentClass of the Component to get
-- @treturn table
function Entity:get(name)
   local ok, componentClass = Components.try(name)

   if not ok then
      Utils.error(2, "bad argument #1 to 'Entity:get' (%s)", componentClass)
   end

   return self[name]
end

--- Returns a table of all Components the Entity has.
-- Warning: Do not modify this table.
-- Use Entity:give/ensure/remove instead
-- @treturn table Table of all Components the Entity has
function Entity:getComponents(output)
   output = output or {}
   local components = Utils.shallowCopy(self, output)
   components.__world = nil
   components.__isEntity = nil

   return components
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

function Entity:serialize(ignoreKey)
   local data = {}

   for name, component in pairs(self) do
      -- The key component needs to be treated separately.
      if name == "key" and component.__name == "key" then
         if not ignoreKey then
            data.key = component.value
         end
      --We only care about components that were properly given to the entity
      elseif Type.isComponent(component) and (component.__name == name) then
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
         Utils.error(2, "bad argument #1 to 'Entity:deserialize' (ComponentClass '%s' wasn't yet loaded)", tostring(componentData.__name)) -- luacheck: ignore
      end

      deserializeComponent(self, componentData.__name, componentData)
   end
end

return setmetatable(Entity, {
   __call = function(_, ...)
      return Entity.new(...)
   end,
})
