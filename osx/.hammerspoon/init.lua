-- Auto-reload
local watcher = hs.pathwatcher.new(hs.configdir, hs.reload):start()

-- Imports
local C = require('consts')
local U = require('util')
local hints = require('hints')
local window = require('window')
local grid = require('grid')

-- Keys
local p = {
  keys = {
    mods = {
      base = {'cmd', 'alt'},
      move = {'cmd', 'alt', 'shift'},
      size = {'cmd', 'ctrl'},
      pour = {'cmd', 'alt', 'ctrl'},
      tile = {'cmd', 'ctrl', 'shift'},
    },
    dirs = {
      h = C.WEST,
      j = C.SOUTH,
      k = C.NORTH,
      l = C.EAST,
    },
    hints = 'y',
    reload = 'r',
  },
}

-- General
hs.hotkey.bind:withPacked():map({
  {p.keys.mods.pour, p.keys.reload, nil, hs.reload},
  {p.keys.mods.base, p.keys.hints, nil, hints.show},
})

-- Directionals
DIR_MODS = {
  [p.keys.mods.base] = function(dir)
    window.focused():focusWindowIn(dir)
  end,
}
for mod, action in pairs(DIR_MODS) do
  for key, dir in pairs(p.keys.dirs) do
    hs.hotkey.bind(mod, key, nil, action:later(dir))
  end
end

-- Grid cells
GRID_CELLS = {
  ['q'] = '0,0 1x1',
  ['a'] = '0,0 1x2',
  ['z'] = '0,1 1x1',
  [']'] = '1,0 1x1',
  ['"'] = '1,0 1x2',
  ['/'] = '1,1 1x1',
  ['m'] = '0,0 2x2',
}
for key, cell in pairs(GRID_CELLS) do
  hs.hotkey.bind(p.keys.mods.base, key, function()
    hs.grid.set(window.focused(), cell)
  end)
end

hs.notify.show("Hammerspoon", "Config loaded.", '')
