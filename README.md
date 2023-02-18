# Concord

Concord is a feature complete ECS for LÖVE.
It's main focus is performance and ease of use.
With Concord it is possibile to easily write fast and clean code. 

This readme will explain how to use Concord.

Additionally all of Concord is documented using the LDoc format.
Auto generated docs for Concord can be found in `docs` folder, or on the [GitHub page](https://keyslam-group.github.io/Concord/).

--- 

## Table of Contents  
[Installation](#installation)  
[ECS](#ecs)  
[API](#api) :
- [Components](#components)  
- [Entities](#entities)  
- [Systems](#systems)
- [Worlds](#worlds)
- [Assemblages](#assemblages)
  
[Quick Example](#quick-example)  
[Contributors](#contributors)  
[License](#licence)

---

## Installation
Download the repository and copy the 'concord' folder into your project. Then require it in your project like so: 
```lua
local Concord = require("path.to.concord")
```

Concord has a bunch of modules. These can be accessed through Concord:

```lua
-- Modules
local Entity     = Concord.entity
local Component  = Concord.component
local System     = Concord.system
local World      = Concord.world

-- Containers
local Components  = Concord.components
```

---

## ECS
Concord is an Entity Component System (ECS for short) library.
This is a coding paradigm where _composition_ is used over _inheritance_.
Because of this it is easier to write more modular code. It often allows you to combine any form of behaviour for the objects in your game (Entities).

As the name might suggest, ECS consists of 3 core things: Entities, Components, and Systems. A proper understanding of these is required to use Concord effectively.
We'll start with the simplest one.

### Components
Components are pure raw data. In Concord this is just a table with some fields.
A position component might look like 
`{ x = 100, y = 50}`, whereas a health Component might look like `{ currentHealth = 10, maxHealth = 100 }`.
What is most important is that Components are data and nothing more. They have 0 functionality.

### Entities
Entities are the actual objects in your game. Like a player, an enemy, a crate, or a bullet.
Every Entity has it's own set of Components, with their own values.

A crate might have the following components (Note: Not actual Concord syntax):
```lua
{
    position = { x = 100, y = 200 },
    texture  = { path = "crate.png", image = Image },
    pushable = { },
}
```

Whereas a player might have the following components:
```lua
{
    position     = { x = 200, y = 300 },
    texture      = { path = "player.png", image = Image },
    controllable = { keys = "wasd" },
    health       = { currentHealth = 10, maxHealth = 100},
}
```

Any Component can be given to any Entity (once). Which Components an Entity has will determine how it behaves. This is done through the last thing...

### Systems
Systems are the things that actually _do_ stuff. They contain all your fancy algorithms and cool game logic.
Each System will do one specific task like say, drawing Entities.
For this they will only act on Entities that have the Components needed for this: `position` and `texture`. All other Components are irrelevant.

In Concord this is done something alike this:

```lua
drawSystem = System({pool = {position, texture}}) -- Define a System that takes all Entities with a position and texture Component

function drawSystem:draw() -- Give it a draw function
    for _, entity in ipairs(self.pool) do -- Iterate over all Entities that this System acts on
        local position = entity.position -- Get the position Component of this Entity
        local texture = entity.texture -- Get the texture Component of this Entity

        -- Draw the Entity
        love.graphics.draw(texture.image, position.x, position.y)
    end
end
```

### To summarize...
- Components contain only data.
- Entities contain any set of Components.
- Systems act on Entities that have a required set of Components.

By creating Components and Systems you create modular behaviour that can apply to any Entity.
What if we took our crate from before and gave it the `controllable` Component? It would respond to our user input of course.

Or what if the enemy shot bullets with a `health` Component? It would create bullets that we'd be able to destroy by shooting them.

And all that without writing a single extra line of code. Just reusing code that already existed and is guaranteed to be reuseable.

---

## API

### General design

Concord does a few things that might not be immediately clear. This segment should help understanding.

#### Requiring files

Since you'll have lots of Components and Systems in your game Concord makes it a bit easier to load things in.

```lua
-- Loads all files in the directory, and puts the return value in the table Systems. The key is their filename without any extension
local Systems = {}
Concord.utils.loadNamespace("path/to/systems", Systems)

print(Systems.systemName)

-- Loads all files in the directory. Components automatically register into Concord.components, so loading them into a namespace isn't necessary.
Concord.utils.loadNamespace("path/to/components")

print(Concord.components.componentName)
```

#### Method chaining
```lua
-- Most (if not all) methods will return self
-- This allowes you to chain methods

myEntity
:give("position", 100, 50)
:give("velocity", 200, 0)
:remove("position")
:destroy()

myWorld
:addEntity(fooEntity)
:addEntity(barEntity)
:clear()
:emit("test")
```

### Components
When defining a ComponentClass you need to pass in a name and usually a `populate` function. This will fill the Component with values.

```lua
-- Create the position class with a populate function
-- The component variable is the actual Component given to an Entity
-- The x and y variables are values we pass in when we create the Component 
Concord.component("position" function(component, x, y)
    component.x = x or 0
    component.y = y or 0
end)

-- Create a ComponentClass without a populate function
-- Components of this type won't have any fields.
-- This can be useful to indiciate state.
local pushableComponentClass = Concord.component("position")
```

### Entities
Entities can be freely made and be given Components. You pass the name of the ComponentClass and the values you want to pass. It will then create the Component for you.

Entities can only have a maximum of one of each Component.
Entities can not share Components.

```lua
-- Create a new Entity
local myEntity = Entity() 
-- or
local myEntity = Entity(myWorld) -- To add it to a world immediately ( See World )
```

```lua
-- Give the entity the position Component defined above
-- x will become 100. y will become 50
myEntity:give("position", 100, 50)
```

```lua
-- Retrieve a Component
local position = myEntity.position

print(position.x, position.y) -- 100, 50
```

```lua
-- Remove a Component
myEntity:remove("position")
```

```lua
-- Entity:give will override a Component if the Entity already has it
-- Entity:ensure will only put the Component if the Entity does not already have it

Entity:ensure("position", 0, 0) -- Will give
-- Position is {x = 0, y = 0}

Entity:give("position", 50, 50) -- Will override
-- Position is {x = 50, y = 50}

Entity:give("position", 100, 100) -- Will override
-- Position is {x = 100, y = 100}

Entity:ensure("position", 0, 0) -- Wont do anything
-- Position is {x = 100, y = 100}
```

```lua
-- Retrieve all Components
-- WARNING: Do not modify this table. It is read-only
local allComponents = myEntity:getComponents()

for ComponentClass, Component in ipairs(allComponents) do
    -- Do stuff
end
```

```lua
-- Assemble the Entity ( See Assemblages )
myEntity:assemble(assemblageFunction, 100, true, "foo")
```

```lua
-- Check if the Entity is in a world
local inWorld = myEntity:inWorld()

-- Get the World the Entity is in
local world = myEntity:getWorld()
```

```lua
-- Destroy the Entity
myEntity:destroy()
```

### Systems

Systems are defined as a SystemClass. Concord will automatically create an instance of a System when it is needed.

Systems get access to Entities through `pools`. They are created using a filter.
Systems can have multiple pools.

```lua
-- Create a System
local mySystemClass = Concord.system({pool = {"position"}}) -- Pool named 'pool' will contain all Entities with a position Component

-- Create a System with multiple pools
local mySystemClass = Concord.system({
    pool = { -- This pool will be named 'pool'
        "position",
        "velocity",
    },
    secondPool = { -- This pool's name will be 'secondPool'
        "health",
        "damageable",
    }
})
```

```lua
-- If a System has a :init function it will be called on creation

-- world is the World the System was created for
function mySystemClass:init(world)
    -- Do stuff
end
```

```lua
-- Defining a function
function mySystemClass:update(dt)
    -- Iterate over all entities in the Pool
    for _, e in ipairs(self.pool) 
        -- Do something with the Components
        e.position.x = e.position.x + e.velocity.x * dt
        e.position.y = e.position.y + e.velocity.y * dt
    end

    -- Iterate over all entities in the second Pool
    for _, e in ipairs(self.secondPool) 
        -- Do something
    end
end
```

```lua
-- Systems can be enabled and disabled
-- When systems are disabled their callbacks won't be executed.
-- Note that pools will still be updated
-- This is mainly useful for systems that display debug information
-- Systems are enabled by default

-- Enable a System
mySystem:setEnable(true)

-- Disable a System
mySystem:setEnable(false)

-- Get enabled state
local isEnabled = mySystem:isEnabled()
print(isEnabled) -- false
```

```lua
-- Get the World the System is in
local world = System:getWorld()
```

### Worlds

Worlds are the thing your System and Entities live in.
With Worlds you can `:emit` a callback. All Systems with this callback will then be called.

Worlds can have 1 instance of every SystemClass.
Worlds can have any number of Entities.

```lua
-- Create World
local myWorld = Concord.world()
```

```lua
-- Add an Entity to the World
myWorld:addEntity(myEntity)

-- Remove an Entity from the World
myWorld:removeEntity(myEntity)
```

```lua
-- Add a System to the World
myWorld:addSystem(mySystemClass)

-- Add multiple Systems to the World
myWorld:addSystems(moveSystemClass, renderSystemClass, controlSystemClass)
```

```lua
-- Check if the World has a System
local hasSystem = myWorld:hasSystem(mySystemClass)

-- Get a System from the World
local mySystem = myWorld:getSystem(mySystemClass)
```

```lua
-- Emit an event

-- This will call the 'update' function of all added Systems if they have one
-- They will be called in the order they were added
myWorld:emit("update", dt)

-- You can emit any event with any parameters
myWorld:emit("customCallback", 100, true, "Hello World")
```

```lua
-- Remove all Entities from the World
myWorld:clear()
```

```lua
-- Override-able callbacks

-- Called when an Entity is added to the World
-- e is the Entity added
function myWorld:onEntityAdded(e)
    -- Do something
end

-- Called when an Entity is removed from the World
-- e is the Entity removed
function myWorld:onEntityRemoved(e)
    -- Do something
end
```

### Assemblages

Assemblages are functions to 'make' Entities something.
An important distinction is that they _append_ Components.

```lua
-- Make an Assemblage function
-- e is the Entity being assembled.
-- cuteness and legs are variables passed in
function animal(e, cuteness, legs)
    e
    :give(cutenessComponentClass, cuteness)
    :give(limbs, legs, 0) -- Variable amount of legs. 0 arm.
end)

-- Make an Assemblage that uses animal
-- cuteness is a variables passed in
function cat(e, cuteness)
    e
    :assemble(animal, cuteness * 2, 4) -- Cats are twice as cute, and have 4 legs.
    :give(soundComponent, "meow.mp3")
end)
```

```lua
-- Use an Assemblage
myEntity:assemble(cat, 100) -- 100 cuteness
```

---

## Quick Example
```lua
local Concord = require("concord")

-- Defining components
Concord.component("position", function(c, x, y)
    c.x = x or 0
    c.y = y or 0
end)

Concord.component("velocity", function(c, x, y)
    c.x = x or 0
    c.y = y or 0
end)

local Drawable = Concord.component("drawable")


-- Defining Systems
local MoveSystem = Concord.system({
    pool = {"position", "velocity"}
})

function MoveSystem:update(dt)
    for _, e in ipairs(self.pool) do
        e.position.x = e.position.x + e.velocity.x * dt
        e.position.y = e.position.y + e.velocity.y * dt
    end
end


local DrawSystem = Concord.system({
    pool = {"position", "drawable"}
})

function DrawSystem:draw()
    for _, e in ipairs(self.pool) do
        love.graphics.circle("fill", e.position.x, e.position.y, 5)
    end
end


-- Create the World
local world = Concord.world()

-- Add the Systems
world:addSystems(MoveSystem, DrawSystem)

-- This Entity will be rendered on the screen, and move to the right at 100 pixels a second
local entity_1 = Concord.entity(world)
:give("position", 100, 100)
:give("velocity", 100, 0)
:give("drawable")

-- This Entity will be rendered on the screen, and stay at 50, 50
local entity_2 = Concord.entity(world)
:give("position", 50, 50)
:give("drawable")

-- This Entity does exist in the World, but since it doesn't match any System's filters it won't do anything
local entity_3 = Concord.entity(world)
:give("position", 200, 200)


-- Emit the events
function love.update(dt)
    world:emit("update", dt)
end

function love.draw()
    world:emit("draw")
end
```

---

## Contributors
- __Positive07__: Constant support and a good rubberduck
- __Brbl__: Early testing and issue reporting
- __Josh__: Squashed a few bugs and generated docs
- __Erasio__: I took inspiration from HooECS. He also introduced me to ECS
- __Speak__: Lots of testing for new features of Concord
- __Tesselode__: Brainstorming and helpful support

---

## License
MIT Licensed - Copyright Justin van der Leij (Tjakka5)
