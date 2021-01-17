local PATH = (...):gsub("(%.init)$", "")

return {
  serializable = require(PATH..".serializable"),
}
