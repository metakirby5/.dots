#!/usr/bin/env coffee -p

# Constants
MOD = ['cmd', 'alt']
GRAV_MOD = ['cmd', 'alt', 'shift']
APPS = {
  Terminal: 't'
}

NORTH = 'NORTH'
SOUTH = 'SOUTH'
EAST = 'EAST'
WEST = 'WEST'

# Aliases
fw = Window.focusedWindow

# Handlers
keys = []
events = []

# Keybinds
for app, key of APPS
  keys.push Phoenix.bind key, MOD, -> App.launch(app).focus()

# Directional
keys.push Phoenix.bind 'h', MOD, -> fw().focusClosestWindowInWest()
keys.push Phoenix.bind 'j', MOD, -> fw().focusClosestWindowInSouth()
keys.push Phoenix.bind 'k', MOD, -> fw().focusClosestWindowInNorth()
keys.push Phoenix.bind 'l', MOD, -> fw().focusClosestWindowInEast()

# Gravity
Window::fallTo = (dir) ->
  windows = switch dir
    when NORTH then @windowsToNorth()
    when SOUTH then @windowsToSouth()
    when EAST then @windowsToEast()
    when WEST then @windowsToWest()
  tFrame = @frame()
  myEdge = switch dir
    when NORTH then tFrame.y
    when SOUTH then tFrame.y + tFrame.height
    when EAST then tFrame.x + tFrame.width
    when WEST then tFrame.x
  tScreen = Screen.mainScreen().visibleFrameInRectangle()
  closest = switch dir
    when NORTH then tScreen.y
    when SOUTH then tScreen.y + tScreen.height
    when EAST then tScreen.x + tScreen.width
    when WEST then tScreen.x
  edgeOf = (win) ->
    oFrame = win.frame()
    switch dir
      when NORTH then oFrame.y + oFrame.height
      when SOUTH then oFrame.y
      when EAST then oFrame.x
      when WEST then oFrame.x + oFrame.width
  fallable = (a, b) ->
    switch dir
      when NORTH, WEST then a - 1 > b
      when SOUTH, EAST then a + 1 < b

  # Find the closest window we can fall to
  for win in windows
    edge = edgeOf win
    # If I can fall to it and it can fall to closest so far
    if fallable(myEdge, edge) and fallable(edge, closest)
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
