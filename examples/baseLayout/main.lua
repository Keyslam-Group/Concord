local PATH = (...):gsub('%.[^%.]+$', '')

local Concord = require("lib").init({
   useEvents = true
})

local C = require(PATH..".src.components")
local S = require(PATH..".src.systems")