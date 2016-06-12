#!/usr/bin/env coffee -p

# Constants
MOD = ['cmd', 'alt']
GRAV_MOD = ['cmd', 'alt', 'shift']
SIZE_MOD = ['cmd', 'ctrl']
MOVE_MOD = ['ctrl', 'alt', 'cmd']
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

Window::move = (dx, dy) ->
  tFrame = @frame()
  tFrame.x+= dx
  tFrame.y += dy
  @setFrame tFrame

Window::scale = (fx, fy) ->
  tFrame = @frame()
  tFrame.width *= fx
  tFrame.height *= fy
  @setFrame tFrame

Window::resize = (dx, dy) ->
  tFrame = @frame()
  tFrame.width += dx
  tFrame.height += dy
  @setFrame tFrame

Window::windowsTo = (dir) ->
  switch dir
    when NORTH then @windowsToNorth()
    when SOUTH then @windowsToSouth()
    when EAST then @windowsToEast()
    when WEST then @windowsToWest()

Window::closestTo = (dir) ->
  f = edgeOf @frame(), dir
  closest = edgeOf Screen.mainScreen().visibleFrameInRectangle(), dir
  for win in @windowsTo dir
    next = edgeOf win.frame(), (opposite dir)
    if (closer dir, f, next) and  (closer dir, next, closest)
      closest = next
  closest

Window::vFill = (gap = 0) ->
  tFrame = @frame()
  tFrame.y = (@closestTo NORTH) + gap
  tFrame.height = (@closestTo SOUTH) - tFrame.y - gap
  @setFrame tFrame

Window::hFill = (gap = 0) ->
  tFrame = @frame()
  tFrame.x = (@closestTo WEST) + gap
  tFrame.width = (@closestTo EAST) - tFrame.x - gap
  @setFrame tFrame

Window::fill = (gap = 0) ->
  tFrame = @frame()
  tFrame.x = (@closestTo WEST) + gap
  tFrame.width = (@closestTo EAST) - tFrame.x - gap
  tFrame.y = (@closestTo NORTH) + gap
  tFrame.height = (@closestTo SOUTH) - tFrame.y - gap
  @setFrame tFrame

Window::fallTo = (dir, gap) ->
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
  closest = edgeOf Screen.mainScreen().visibleFrameInRectangle(), dir, -gap
  for win in @windowsTo dir
    f = win.frame()
    edge = edgeOf f, (opposite dir), gap
    # If I can fall to it and it can fall to closest so far
    if (catchable f) and (fallable myEdge, edge) and (fallable edge, closest)
      closest = edge

  # Set our frame
  switch dir
    when NORTH then tFrame.y = closest
    when SOUTH then tFrame.y = closest - tFrame.height
    when EAST then tFrame.x = closest - tFrame.width
    when WEST then tFrame.x = closest

  @setFrame(tFrame)

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
keys.push Phoenix.bind 'f', MOD, -> fw().maximize()

# TODO fill after fallTo
keys.push Phoenix.bind 'h', GRAV_MOD, -> fw().fallTo WEST, GAP
keys.push Phoenix.bind 'j', GRAV_MOD, -> fw().fallTo SOUTH, GAP
keys.push Phoenix.bind 'k', GRAV_MOD, -> fw().fallTo NORTH, GAP
keys.push Phoenix.bind 'l', GRAV_MOD, -> fw().fallTo EAST, GAP
