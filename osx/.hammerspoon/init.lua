-- Auto-reload
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function(files)
  for _ ,file in pairs(files) do
    if file:sub(-4) == ".lua" then
      hs.reload()
    end
  end
end):start()

-- Consts
local C = {
  NORTH   = 'NORTH',
  SOUTH   = 'SOUTH',
  EAST    = 'EAST',
  WEST    = 'WEST',
}

-- Keys
local MOD = {'cmd', 'alt'}

local DIR_KEYS = {
  h = C.WEST,
  j = C.SOUTH,
  k = C.NORTH,
  l = C.EAST,
}

-- Hints
hs.hints.showTitleThresh = 0
hs.hotkey.bind(MOD, 'f', nil, hs.hints.windowHints)

-- Focus
function hs.window:focusWindowIn(dir, ...)
  return ({
    [C.NORTH]   = self.focusWindowNorth,
    [C.SOUTH]   = self.focusWindowSouth,
    [C.EAST]    = self.focusWindowEast,
    [C.WEST]    = self.focusWindowWest,
  })[dir](...)
end

for key, dir in pairs(DIR_KEYS) do
  hs.hotkey.bind(MOD, key, nil, hs.fnutils.partial(function()
    hs.window.focusedWindow():focusWindowIn(dir)
  end))
end

hs.notify.show("Hammerspoon", "Config loaded.", '')
