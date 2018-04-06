local PATH = (...):gsub('%.[^%.]+$', '')

local Concord = require("concord").init({
   useEvents = true
})

local C = require(PATH..".src.components")
local S = require(PATH..".src.systems")

local a  =5