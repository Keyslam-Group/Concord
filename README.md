# Concord

Concord is a feature complete ECS for LÖVE.
It's main focus is performance and ease of use.
With Concord it is possibile to easily write fast and clean code. 

This readme will explain how to use Concord.

Additionally all of Concord is documented using the LDoc format.
Auto generated docs for Concord can be found in `docs` folder, or on the [Github page](https://tjakka5.github.io/Concord/).

## Installation
Download the repository and copy the 'src' folder in your project. Rename it to something that makes sense (Probably 'concord'), then require it in your project like so: 
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
local Assemblage = Concord.assemblage

-- Containers
local Components  = Concord.components
local Systems     = Concord.systems
local Worlds      = Concord.worlds
local Assemblages = Concord.assemblages
```

## ECS
Concord is an Entity Component System (ECS for short) library.
This is a coding paradigm where _composition_ is used over _inheritance_.
Because of this it is easier to write more modular code. It often allowes you to combine any form of behaviour for the objects in your game (Entities).

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

A crate might have the following components:
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
drawSystem = System({position, texture}) -- Define a System that takes all Entities with a position and texture Component

function drawSystem:draw() -- Give it a draw function
    for _, entity in ipairs(self.pool) do -- Iterate over all Entities that this System acts on
        local position = entity[position] -- Get the position Component of this Entity
        local texture = entity[texture] -- Get the texture Component of this Entity

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

## Documentation

### General design

#### Classes
Concord does a few things that might not be immediately clear. This segment should help understanding.

When you define a Component or System you are actually defining a `ComponentClass` and `SystemClass` respectively. From these instances of them can be created. They also act as identifiers for Concord.

For example. If you want to get a specific Component from an Entity, you'd do `Component = Entity:get(ComponentClass)`.
When ComponentClasses or SystemClasses are required it will be written clearly in the Documentation.

#### Containers
Since you'll be defining or creating lots of Components, Systems, Worlds and Assemblages Concord adds container tables for each of them so that they are easily accessible.

These containers can be accessed through
```lua
local Components  = require("path.to.concord").components
local Systems     = require("path.to.concord").systems
local Worlds      = require("path.to.concord").worlds
local Assemblages = require("path.to.concord").aorlds
```

Concord has helper functions to fill these containers. There are the following options depending on your needs / preference:
```lua
-- Loads each file. They are put in the container according to it's filename ( 'src.components.component_1.lua' becomes 'component_1' )
Concord.loadComponents({"path.to.component_1", "path.to.component_2", "etc"})

-- Loads all files in the directory. They are put in the container according to it's filename ( 'src.components.component_1.lua' becomes 'component_1' )
Concord.loadComponents("path.to.directory.containing.components")


-- Put the ComponentClass into the container directly. Useful if you want more manual control. Note that you need to require the file in this case
Components.register("componentName", ComponentClass)
```
Things can then be accessed through their names:
```lua
local component_1_class   = Components.component_1
local componentName_class = Components.componentName
```

All the above applies the same to all the other containers.

### Components
When defining a ComponentClass you usually pass in a `populate` function. This will fill the Component with values.

```lua
-- Create the ComponentClass with a populate function
-- The component variable is the actual Component given to an Entity
-- The x and y variables are values we pass in when we create the Component 
local positionComponentClass = Concord.component(function(component, x, y)
    component.x = x or 0
    component.y = y or 0
end)

-- Create a ComponentClass without a populate function
-- Components of this type won't have any fields.
-- This can be useful to indiciate state.
local pushableComponentClass = Concord.component()
```

```lua
-- Manually register the Component to the container if we want
Concord.components.register("positionComponent", positionComponentClass)

-- Otherwise return the Component so it can be required
return positionComponentClass
```

### Entities
Entities can be freely made and be given Components. You pass the ComponentClass and the values you want to pass. It will then create the Component for you.

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
myEntity:give(positionComponentClass, 100, 50)
```

```lua
-- Retrieve a Component
local positionComponent = myEntity[positionComponentClass]
-- or
local positionComponent = myEntity:get(positionComponentClass)

print(positionComponent.x, positionComponent.y) -- 100, 50
```

```lua
-- Remove a Component
myEntity:remove(positionComponentClass)
```

```lua
-- Check if the Entity has a Component
local hasPositionComponent = myEntity:has(positionComponentClass)
print(hasPositionComponent) -- false
```

```lua
-- Entity:give will override a Component if the Entity already has it
-- Entity:ensure will only put the Component if the Entity does not already have it

Entity:ensure(positionComponentClass, 0, 0) -- Will give
-- Position is {x = 0, y = 0}

Entity:give(positionComponentClass, 50, 50) -- Will override
-- Position is {x = 50, y = 50}

Entity:give(positionComponentClass, 100, 100) -- Will override
-- Position is {x = 100, y = 100}

Entity:ensure(positionComponentClass, 0, 0) -- Wont do anything
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
myEntity:assemble(myAssemblage, 100, true, "foo")
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

Systems are definded as a SystemClass. Concord will automatically create an instance of a System when it is needed.

Systems get access to Entities through `pools`. They are created using a filter.
Systems can have multiple pools.

```lua
-- Create a System
local mySystemClass = Concord.system({positionComponentClass}) -- Pool will contain all Entities with a position Component

-- Create a System with multiple pools
local mySystemClass = Concord.system(
    { -- This Pool's name will default to 'pool'
        positionCompomponentClass,
        velocityComponentClass,
    },
    { -- This Pool's name will be 'secondPool'
        healthComponentClass,
        damageableComponentClass,
        "secondPool",
    }
)
```

```lua
-- Manually register the Component to the container if we want
Concord.system.register("mySystem", mySystemClass)

-- Otherwise return the Component so it can be required
return mySystemClass
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
        -- Get the Entity's Components
        local positionComponent = e[positionComponentClass]
        local velocityComponent = e[velocityComponentClass]

        -- Do something with the Components
        positionComponent.x = positionComponent.x + velocityComponent.x * dt
        positionComponent.y = positionComponent.y + velocityComponent.y * dt
    end


    -- Iterate over all entities in the second Pool
    for _, e in ipairs(self.secondPool) 
        -- Do something
    end
end
```

```lua
-- Systems can be enabled and disabled
-- Systems are enabled by default

-- Enable a System
mySystem:enable()
-- or
mySystem:setEnable(true)

-- Disable a System
mySystem:disable()
-- or
mySystem:setEnable(false)

-- Toggle the enable state
mySystem:toggleEnabled()

-- Get enabled state
local isEnabled = mySystem:isEnabled()
print(isEnabled) -- true
```

```lua
-- Get the World the System is in
local world = System:getWorld()
```

### Worlds

TODO

### Assemblages

TODO

### Type

TODO

## Contributors
- __Positive07__: Constant support and a good rubberduck
- __Brbl__: Early testing and issue reporting
- __Josh__: Squashed a few bugs and generated docs
- __Erasio__: I took inspiration from HooECS. He also introduced me to ECS
- __Speak__: Lots of testing for new features of Concord
- __Tesselode__: Brainstorming and helpful support
  
## Licence
MIT Licensed - Copyright Justin van der Leij (Tjakka5)
