--- Used to filter Entities with specific Components
-- A Filter has an associated Pool that can contain any amount of Entities.
-- @classmod Filter

local PATH = (...):gsub('%.[^%.]+$', '')

local List       = require(PATH..".list")
local Type       = require(PATH..".type")
local Utils      = require(PATH..".utils")
local Components = require(PATH..".components")


local Filter = {}
Filter.__mt = {
   __index = Filter,
}

--- Validates a Filter Definition to make sure every component is valid.
-- @string name Name for the Filter.
-- @tparam table definition Table containing the Filter Definition
-- @tparam onComponent Optional function, called when a component is valid.
function Filter.validate (name, def, onComponent)
   if type(def) ~= 'table' then
      Utils.error(3, "invalid component list for filter '%s' (table expected, got %s)", name, type(def))
   end

   if not onComponent and def.constructor and not Type.isCallable(def.constructor) then
      Utils.error(3, "invalid pool constructor for filter '%s' (callable expected, got %s)", name, type(def.constructor))
   end

   for n, component in ipairs(def) do
      local ok, err, reject = Components.try(component, true)

      if not ok then
         Utils.error(3, "invalid component for filter '%s' at position #%d (%s)", name, n, err)
      end

      if onComponent then
         onComponent(component, reject)
      end
   end
end

--- Parses the Filter Defintion into two tables
-- required: An array of all the required component names.
-- rejected: An array of all the components that will be rejected.
-- @string name Name for the Filter.
-- @tparam table definition Table containing the Filter Definition
-- @treturn table required
-- @treturn table rejected
function Filter.parse (name, def)
   local required, rejected = {}, {}

   Filter.validate(name, def, function (component, reject)
      if reject then
         table.insert(rejected, reject)
      else
         table.insert(required, component)
      end
   end)

   return required, rejected
end

local REQUIRED_METHODS = {"add", "remove", "has", "clear"}
local VALID_POOL_TYPES = {table=true, userdata=true, lightuserdata=true, cdata=true}

function Filter.isValidPool (name, pool)
   local poolType = type(pool)
   --Check that pool is not nil
   if not VALID_POOL_TYPES[poolType] then
      Utils.error(3, "invalid value returned by pool '%s' constructor (table expected, got %s).", name, type(pool))
   end

   --Check if methods are callables
   for _, method in ipairs(REQUIRED_METHODS) do
      if not Type.isCallable(pool[method]) then
         Utils.error(3, "invalid :%s method on pool '%s' (callable expected, got %s).", method, name, type(pool[method]))
      end
   end
end

--- Creates a new Filter
-- @string name Name for the Filter.
-- @tparam table definition Table containing the Filter Definition
-- @treturn Filter The new Filter
-- @treturn Pool The associated Pool
function Filter.new (name, def)
   local pool

   if def.constructor then
      pool = def.constructor(def)
      Filter.isValidPool(name, pool)
   else
      pool = List()
   end

   local required, rejected = Filter.parse(name, def)

   local filter = setmetatable({
      pool = pool,

      __required = required,
      __rejected = rejected,

      __name   = name,
   
      __isFilter = true,
   }, Filter.__mt)

   return filter, pool
end

--- Checks if an Entity fulfills the Filter requirements.
-- @tparam Entity e Entity to check
-- @treturn boolean
function Filter:eligible(e)
   for i=#self.__required, 1, -1 do
      local name = self.__required[i]
      if not e[name] then return false end
   end

   for i=#self.__rejected, 1, -1 do
      local name = self.__rejected[i]
      if e[name] then return false end
   end

   return true
end

function Filter:evaluate (e)
   local has  = self.pool:has(e)
   local eligible = self:eligible(e)

   if not has and eligible then
      self.pool:add(e)
   elseif has and not eligible then
      self.pool:remove(e)
   end

   return self
end


-- Adds an Entity to the Pool, if it passes the Filter.
-- @param e Entity to add
-- @param bypass Whether to bypass the Filter or not.
-- @treturn Filter self
-- @treturn boolean Whether the entity was added or not.
function Filter:add (e, bypass)
   if not bypass and not self:eligible(e) then
      return self, false
   end

   self.pool:add(e)

   return self, true
end

-- Remove an Entity from the Pool associated to this Filter.
-- @param e Entity to remove
-- @treturn Filter self
function Filter:remove (e)
   self.pool:remove(e)
   return self
end

-- Clear the Pool associated to this Filter.
-- @param e Entity to remove
-- @treturn Filter self
function Filter:clear (e)
   self.pool:clear(e)
   return self
end

-- Check if the Pool bound to this System contains the passed Entity
-- @param e Entity to check
-- @treturn boolean Whether the Entity exists.
function Filter:has (e)
   return self.pool:has(e)
end

--- Gets the name of the Filter
-- @treturn string
function Filter:getName()
   return self.__name
end

return setmetatable(Filter, {
  __call  = function(_, ...)
     return Filter.new(...)
  end,
})