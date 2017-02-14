-- luacheck: globals hs, read_globals T

-- Bind reload as a failsafe
hs.hotkey.bind({'cmd', 'alt', 'ctrl'}, 'r', nil, hs.reload)

-- Auto-reload
hs.pathwatcher.new(hs.configdir, hs.reload):start()

-- Imports
require('util')
require('grid')
local C = require('consts')
local hints = require('hints')
local window = require('window')

-- Keys
local p = T{
  keys = T{
    mods = T{
      base = {'cmd', 'alt'},
      move = {'cmd', 'alt', 'shift'},
      size = {'cmd', 'ctrl'},
      pour = {'cmd', 'alt', 'ctrl'},
      tile = {'cmd', 'ctrl', 'shift'},
    },
    dirs = T{
      h = C.WEST,
      j = C.SOUTH,
      k = C.NORTH,
      l = C.EAST,
    },
  },
}

p.keys.actions = T{
  direct = T{
    [p.keys.mods.base] = T{
      y = hints.show,
    },
  },
  dirs = T{
    [p.keys.mods.base] = function(dir)
      window.focused():focusWindowIn(dir)
    end,
  },
  snaps = T{
    [p.keys.mods.base] = T{
      m = '0,0 2x2',
      q = '0,0 1x1',
      a = '0,0 1x2',
      z = '0,1 1x1',
      [']'] = '1,0 1x1',
      ["'"] = '1,0 1x2',
      ['/'] = '1,1 1x1',
    }
  },
}

-- Bind actions
p.keys.actions.direct:map(function(acts, mod)
  acts:map(function(fun, key)
    hs.hotkey.bind(mod, key, fun)
  end)
end)
p.keys.actions.dirs:map(function(fun, mod)
  p.keys.dirs:map(function(dir, key)
    hs.hotkey.bind(mod, key, fun:later(dir))
  end)
end)
p.keys.actions.snaps:map(function(snaps, mod)
  snaps:map(function(cell, key)
    hs.hotkey.bind(mod, key, function()
      hs.grid.set(window.focused(), cell)
    end)
  end)
end)

hs.notify.show("Hammerspoon", "Config loaded.", '')
