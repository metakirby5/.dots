#!/usr/bin/env coffee -p

# Constants
MOD = ['cmd', 'alt']
GRAV_MOD = ['cmd', 'alt', 'shift']
SIZE_MOD = ['cmd', 'ctrl']
UNIT = 50
FACTOR = 2
GAP = 10
APPS = {
  Terminal: 't'
}

NORTH = 'NORTH'
SOUTH = 'SOUTH'
EAST = 'EAST'
WEST = 'WEST'

# Helpers
fw = Window.focusedWindow

opposite = (dir) ->
  switch dir
    when NORTH then SOUTH
    when SOUTH then NORTH
    when EAST then WEST
    when WEST then EAST

closer = (dir, a, b) ->
  switch dir
    when NORTH, WEST then a > b
    when SOUTH, EAST then a < b

edgeOf = (f, dir, gap = 0) ->
  switch dir
    when SOUTH then f.y + f.height + gap
    when NORTH then f.y - gap
    when EAST then f.x + f.width + gap
    when WEST then f.x - gap

Window::windowsTo = (dir) ->
  switch dir
    when NORTH then @windowsToNorth()
    when SOUTH then @windowsToSouth()
    when EAST then @windowsToEast()
    when WEST then @windowsToWest()

Window::closestTo = (dir) ->
  closest = edgeOf Screen.mainScreen().visibleFrameInRectangle(), dir
  for win in @windowsTo dir
    next = edgeOf win.frame(), opposite dir
    if closer dir, next, closest
      closest = next
  next

# Handlers
keys = []
events = []

# Keybinds
for app, key of APPS
  keys.push Phoenix.bind key, MOD, -> App.launch(app).focus()

# Select
keys.push Phoenix.bind 'h', MOD, -> fw().focusClosestWindowInWest()
keys.push Phoenix.bind 'j', MOD, -> fw().focusClosestWindowInSouth()
keys.push Phoenix.bind 'k', MOD, -> fw().focusClosestWindowInNorth()
keys.push Phoenix.bind 'l', MOD, -> fw().focusClosestWindowInEast()

# Size
Window::resize = (dx, dy) ->
  tFrame = @frame()
  tFrame.width += dx
  tFrame.height += dy
  @setFrame(tFrame)

keys.push Phoenix.bind 'h', SIZE_MOD, -> fw().resize(-UNIT, 0)
keys.push Phoenix.bind 'j', SIZE_MOD, -> fw().resize(0, UNIT)
keys.push Phoenix.bind 'k', SIZE_MOD, -> fw().resize(0, -UNIT)
keys.push Phoenix.bind 'l', SIZE_MOD, -> fw().resize(UNIT, 0)

# Cut / Fill
Window::scale = (fx, fy) ->
  tFrame = @frame()
  tFrame.width *= fx
  tFrame.height *= fy
  @setFrame(tFrame)

# Window::fill = () ->
#   for dir in [NORTH, SOUTH, EAST, WEST]

# Gravity
Window::fallTo = (dir) ->
  tFrame = @frame()
  catchable = (f) ->
    switch dir
      when NORTH, SOUTH
        tFrame.x < f.x + f.width and tFrame.x + tFrame.width > f.x
      when EAST, WEST
        tFrame.y < f.y + f.height and tFrame.y + tFrame.height > f.y
  fallable = (a, b) ->
    switch dir
      when NORTH, WEST then a - 1 > b
      when SOUTH, EAST then a + 1 < b

  # Find the closest window we can fall to
  myEdge = edgeOf tFrame, dir
  closest = edgeOf Screen.mainScreen().visibleFrameInRectangle(), dir, -GAP
  for win in @windowsTo dir
    f = win.frame()
    edge = edgeOf f, (opposite dir), GAP
    # If I can fall to it and it can fall to closest so far
    if catchable(f) and fallable(myEdge, edge) and fallable(edge, closest)
      closest = edge

  # Set our frame
  switch dir
    when NORTH then tFrame.y = closest
    when SOUTH then tFrame.y = closest - tFrame.height
    when EAST then tFrame.x = closest - tFrame.width
    when WEST then tFrame.x = closest

  @setFrame(tFrame)

keys.push Phoenix.bind 'h', GRAV_MOD, -> fw().fallTo(WEST)
keys.push Phoenix.bind 'j', GRAV_MOD, -> fw().fallTo(SOUTH)
keys.push Phoenix.bind 'k', GRAV_MOD, -> fw().fallTo(NORTH)
keys.push Phoenix.bind 'l', GRAV_MOD, -> fw().fallTo(EAST)
