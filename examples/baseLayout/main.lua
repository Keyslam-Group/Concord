local PATH = (...):gsub('%.[^%.]+$', '')

local Concord = require("lib")

local C = require(PATH..".src.components")
local S = require(PATH..".src.systems")
