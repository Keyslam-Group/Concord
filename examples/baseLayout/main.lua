local PATH = (...):gsub('%.[^%.]+$', '')

local Concord = require("src")

local C = require(PATH..".src.components")
local S = require(PATH..".src.systems")
