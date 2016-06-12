#!/usr/bin/env coffee -p

# Preferences
Phoenix.set
  openAtLogin: true

# Constants
MOD = ['cmd', 'alt']
MOVE_MOD = ['cmd', 'alt', 'shift']
SIZE_MOD = ['cmd', 'ctrl']
GRAV_MOD = ['ctrl', 'alt', 'cmd']
UNIT = 50
FACTOR = 2
GAP = 10
APPS =
  Terminal: 't'

NORTH = 'NORTH'
SOUTH = 'SOUTH'
EAST = 'EAST'
WEST = 'WEST'

# Handlers
keys = []
events = []

# Helpers
fw = Window.focusedWindow

opposite = (dir) ->
  switch dir
    when NORTH then SOUTH
    when SOUTH then NORTH
    when EAST then WEST
    when WEST then EAST

closer = (dir, a, b, fallthru = 0) ->
  switch dir
    when NORTH, WEST then a - fallthru > b
    when SOUTH, EAST then a + fallthru < b

catchable = (f, dir, g) ->
  switch dir
    when NORTH, SOUTH
      f.x < g.x + g.width and f.x + f.width > g.x
    when EAST, WEST
      f.y < g.y + g.height and f.y + f.height > g.y

edgeOf = (f, dir, gap = 0) ->
  switch dir
    when SOUTH then f.y + f.height + gap
    when NORTH then f.y - gap
    when EAST then f.x + f.width + gap
    when WEST then f.x - gap

Window::move = (dx, dy) ->
  f = @frame()
  f.x += dx
  f.y += dy
  @setFrame f

Window::scale = (fx, fy) ->
  f = @frame()
  f.width *= fx
  f.height *= fy
  @setFrame f

Window::resize = (dx, dy) ->
  f = @frame()
  f.width += dx
  f.height += dy
  @setFrame f

Window::windowsTo = (dir) ->
  switch dir
    when NORTH then @windowsToNorth()
    when SOUTH then @windowsToSouth()
    when EAST then @windowsToEast()
    when WEST then @windowsToWest()

Window::closestTo = (dir, fallthru = 0, onlyCatch = false) ->
  f = @frame()
  e = edgeOf f, dir
  closest = edgeOf Screen.mainScreen().visibleFrameInRectangle(), dir
  for win in @windowsTo dir
    nf = win.frame()
    ne = edgeOf nf, (opposite dir)
    if (closer dir, e, ne, fallthru) and
       (closer dir, ne, closest, fallthru) and
       (not onlyCatch or catchable f, dir, nf)
      closest = ne
  closest

Window::vFill = (gap = 0) ->
  f = @frame()
  f.y = (@closestTo NORTH) + gap
  f.height = (@closestTo SOUTH) - f.y - gap
  @setFrame f

Window::hFill = (gap = 0) ->
  f = @frame()
  f.x = (@closestTo WEST) + gap
  f.width = (@closestTo EAST) - f.x - gap
  @setFrame f

Window::fill = (gap = 0) ->
  f = @frame()
  f.x = (@closestTo WEST) + gap
  f.width = (@closestTo EAST) - f.x - gap
  f.y = (@closestTo NORTH) + gap
  f.height = (@closestTo SOUTH) - f.y - gap
  @setFrame f

Window::fallTo = (dir, gap) ->
  f = @frame()
  closest = @closestTo dir, gap, true
  switch dir
    when SOUTH then f.y = closest - f.height - gap
    when NORTH then f.y = closest + gap
    when EAST then f.x = closest - f.width - gap
    when WEST then f.x = closest + gap
  @setFrame f

# Apps
for app, key of APPS
  keys.push Phoenix.bind key, MOD, -> App.launch(app).focus()

# Spaces
# TODO

# Select
keys.push Phoenix.bind 'h', MOD, -> fw().focusClosestWindowInWest()
keys.push Phoenix.bind 'j', MOD, -> fw().focusClosestWindowInSouth()
keys.push Phoenix.bind 'k', MOD, -> fw().focusClosestWindowInNorth()
keys.push Phoenix.bind 'l', MOD, -> fw().focusClosestWindowInEast()

keys.push Phoenix.bind 'h', MOVE_MOD, -> fw().move -UNIT, 0
keys.push Phoenix.bind 'j', MOVE_MOD, -> fw().move 0, UNIT
keys.push Phoenix.bind 'k', MOVE_MOD, -> fw().move 0, -UNIT
keys.push Phoenix.bind 'l', MOVE_MOD, -> fw().move UNIT, 0

keys.push Phoenix.bind 'h', SIZE_MOD, -> fw().resize -UNIT, 0
keys.push Phoenix.bind 'j', SIZE_MOD, -> fw().resize 0, UNIT
keys.push Phoenix.bind 'k', SIZE_MOD, -> fw().resize 0, -UNIT
keys.push Phoenix.bind 'l', SIZE_MOD, -> fw().resize UNIT, 0
keys.push Phoenix.bind 'f', MOD, -> fw().fill GAP

keys.push Phoenix.bind 'h', GRAV_MOD, ->
  f = fw()
  f.fallTo WEST, GAP
  f.fill GAP
keys.push Phoenix.bind 'j', GRAV_MOD, ->
  f = fw()
  f.fallTo SOUTH, GAP
  f.fill GAP
keys.push Phoenix.bind 'k', GRAV_MOD, ->
  f = fw()
  f.fallTo NORTH, GAP
  f.fill GAP
keys.push Phoenix.bind 'l', GRAV_MOD, ->
  f = fw()
  f.fallTo EAST, GAP
  f.fill GAP
