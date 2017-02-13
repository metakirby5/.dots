-- luacheck: globals hs

local C = require('consts')
local U = require('util')

function hs.window:focusWindowIn(dir, ...)
  (U.switch(dir) {
    [C.NORTH]   = self.focusWindowNorth,
    [C.SOUTH]   = self.focusWindowSouth,
    [C.EAST]    = self.focusWindowEast,
    [C.WEST]    = self.focusWindowWest,
    [C.DEFAULT] = function() error('Invalid direction.') end,
  })(...)
end

return {
  focused = hs.window.focusedWindow,
}
