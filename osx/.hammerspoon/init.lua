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
local window = require('window')

-- Keys
local MODS = {
  base = {'cmd', 'alt'},
  move = {'cmd', 'alt', 'shift'},
  size = {'cmd', 'ctrl', 'shift'},
  pour = {'ctrl', 'alt', 'shift'},
  mash = {'ctrl', 'alt', 'cmd'},
}

local DIR_KEYS = {
  h = C.WEST,
  j = C.SOUTH,
  k = C.NORTH,
  l = C.EAST,
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
