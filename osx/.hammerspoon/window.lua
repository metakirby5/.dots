local consts = require('consts')
local util = require('util')

function hs.window:focusWindowIn(dir, ...)
  (util.switch(dir) {
    [consts.NORTH] = self.focusWindowNorth,
    [consts.SOUTH] = self.focusWindowSouth,
    [consts.EAST] = self.focusWindowEast,
    [consts.WEST] = self.focusWindowWest,
    [consts.DEFAULT] = function() error('Invalid direction.') end,
  })(...)
end

return {
  focused = hs.window.focusedWindow,
}
