local consts = require('consts')
local util = require('util')
local hints = require('hints')
local window = require('window')

-- Preferences
local TOLERANCE = 10 -- TODO
local UNIT = 100 -- TODO
local GAP = 10 -- TODO

local MODS = {
  base = {'cmd', 'alt'},
  move = {'cmd', 'alt', 'shift'}, -- TODO
  size = {'cmd', 'ctrl', 'shift'}, -- TODO
  pour = {'ctrl', 'alt', 'shift'}, -- TODO
  mash = {'ctrl', 'alt', 'cmd'}, -- TODO TBD
}

-- TODO
local APP_KEYS = {
  t = 'iTerm',
  e = 'Finder',
}

-- TODO
local SNAP_KEYS = {
  q      = {-1/2, -1/2},
  a      = {-1/2, -1  },
  z      = {-1/2, 1/2 },
  [']']  = {1/2,  -1/2},
  ['\''] = {1/2,  -1  },
  ['/']  = {1/2,  1/2 },
}

local DIR_KEYS = {
  h = consts.WEST,
  j = consts.SOUTH,
  k = consts.NORTH,
  l = consts.EAST,
}

-- TODO
local OFFSET_KEYS = {
  n = 1,
  p = -1,
}

-- Bind this separately for convenience when crashing
hs.hotkey.bind(MODS.base, 'r', 'Hammerspoon reloaded!', hs.reload)

-- General
hs.hotkey.bind:withPacked():map({
  {MODS.base, '\'', nil, hints.show},
})

-- Directionals
DIR_MODS = {
  [MODS.base] = function(dir)
    window.focused():focusWindowIn(dir, nil, nil, true)
  end,
}

for mod, action in pairs(DIR_MODS) do
  for key, dir in pairs(DIR_KEYS) do
    hs.hotkey.bind(mod, key, nil, action:later(dir))
  end
end
