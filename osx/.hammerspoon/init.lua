-- Auto-reload
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function(files)
  for _ ,file in pairs(files) do
    if file:sub(-4) == ".lua" then
      hs.reload()
    end
  end
end):start()

-- Imports
local C = require('consts')
local U = require('util')
local hints = require('hints')
local window = require('window'){gaps = 10}

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
  h = C.WEST,
  j = C.SOUTH,
  k = C.NORTH,
  l = C.EAST,
}

-- TODO
local OFFSET_KEYS = {
  n = 1,
  p = -1,
}

-- General
hs.hotkey.bind:withPacked():map({
  {MODS.base, 'f', nil, hints.show},
})

-- Directionals
DIR_MODS = {
  [MODS.base] = function(dir)
    window.focused():focusWindowIn(dir)
  end,
}

for mod, action in pairs(DIR_MODS) do
  for key, dir in pairs(DIR_KEYS) do
    hs.hotkey.bind(mod, key, nil, action:later(dir))
  end
end

hs.notify.show("Hammerspoon", "Config loaded.", '')
