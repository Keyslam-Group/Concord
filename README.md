# Concord

Concord is a feature complete ECS.
It's main focus is on speed and usage. You should be able to quickly write code that performs well.

Documentation for Concord can be found in the [Wiki tab](https://github.com/Tjakka5/Concord/wiki).

Auto generated docs for Concord can be found in the [Github page](https://tjakka5.github.io/Concord/). These are still work in progress and might be incomplete though.

## Installation
Download the repository and drop it in your project, then simply require it as:
```lua
local Concord = require(PathToConcord).init()

You will only need to call .init once when you first require it.
```

## Modules
Below is a list of modules.
More information about what each done can be found in the Wiki

```lua
local Concord = require("concord")
local Entity = require("concord.entity")
local Component = require("concord.component")
local System = require("concord.system")
local Instance = require("concord.instance")
```

## Example games
[A Cat Game](https://github.com/flamendless/ECS-A-Cat-Game) by Brbl

[Tetris](https://github.com/pikashira/tetris-love-ecs) by Pikashira

## Contributors
```
Positive07: Constant support and a good rubberduck
Brbl: Early testing and issue reporting
Josh: Squashed a few bugs and docs
Erasio: Took inspiration from HooECS. Also introduced me to ECS.
Brbl, Pikashria: Example games
```

## Licence
MIT Licensed - Copyright Justin van der Leij (Tjakka5)
