local PATH = (...):gsub('%.init$', '')

require(PATH..".requireModules")
require(PATH..".entityLifetime")