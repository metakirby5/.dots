local C = require('consts')
local U = require('util')

-- args:
--    gaps: the amount of padding between windows, in pixels
return U.export(function(args)
  -- Defaults
  gaps = (args and args.gaps) or 0

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
end)
