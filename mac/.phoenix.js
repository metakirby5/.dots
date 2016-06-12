#!/usr/bin/env coffee -p

# Constants
NORTH = 'NORTH'
SOUTH = 'SOUTH'
EAST = 'EAST'
WEST = 'WEST'

# Preferences
Phoenix.set
  openAtLogin: true

UNIT = 50
FACTOR = 2
GAP = 10
APPS =
  t: 'Terminal'

# Keys
MOD = ['cmd', 'alt']
MOVE_MOD = ['cmd', 'alt', 'shift']
SIZE_MOD = ['cmd', 'ctrl']
POUR_MOD = ['cmd', 'alt', 'ctrl']
DIRS =
  h: WEST
  j: SOUTH
  k: NORTH
  l: EAST

# Helpers
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

# Recthangle methods
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

# Window methods
Window::focusIn = (dir) ->
  switch dir
    when NORTH then @focusClosestWindowInNorth()
    when SOUTH then @focusClosestWindowInSouth()
    when EAST then @focusClosestWindowInEast()
    when WEST then @focusClosestWindowInWest()

# Window chaining
class ChainWindow
  constructor: (@win, @gap = 0, @unit = 1) ->
    @f = @win.frame()
    @scr = Screen.mainScreen()

  set: ->
    @win.setFrame @f

  _windowsIn: (dir) ->
    switch dir
      when NORTH then @win.windowsToNorth()
      when SOUTH then @win.windowsToSouth()
      when EAST then @win.windowsToEast()
      when WEST then @win.windowsToWest()

  _deltaIn: (dir) ->
    switch dir
      when NORTH then [0, -UNIT]
      when SOUTH then [0,  UNIT]
      when EAST then  [ UNIT, 0]
      when WEST then  [-UNIT, 0]

  _closestIn: (dir, useFallthru = false, onlyCatch = false) ->
    e = edgeOf @f, dir
    closest = edgeOf @scr.visibleFrameInRectangle(), dir
    for win in @scr.visibleWindows()
      if not @win.isEqual(win)
        nf = win.frame()
        ne = edgeOf nf, (opposite dir)
        if (closer dir, e, ne, if useFallthru then @gap else 0) and
           (closer dir, ne, closest, if useFallthru then @gap else 0) and
           (not onlyCatch or catchable @f, dir, nf)
          closest = ne
    closest

  move: (dx, dy) ->
    @f.x += dx
    @f.y += dy
    this

  moveTo: (x, y) ->
    @f.x = x
    @f.y = y
    this

  moveIn: (dir) ->
    @move (@_deltaIn dir)...
    this

  size: (dx, dy) ->
    @f.width += dx
    @f.height += dy
    this

  sizeTo: (width, height) ->
    @f.width = width
    @f.height = height
    this

  maximize: ->
    f = @scr.visibleFrameInRectangle()
    @moveTo f.x + @gap, f.y + @gap
    @sizeTo f.width - 2 * @gap, f.height - 2 * @gap
    this

  sizeIn: (dir) ->
    @size (@_deltaIn dir)...
    this

  scale: (fx, fy) ->
    @f.width *= fx
    @f.height *= fy
    this

  squashIn: (dir, factor = Infinity) ->
    switch dir
      when NORTH, SOUTH then @f.height /= factor
      when EAST, WEST then @f.width /= factor
    switch dir
      when SOUTH then @f.y += @f.height * (factor - 1)
      when EAST then @f.x += @f.width * (factor - 1)
    this

  vFill: ->
    @f.y = (@_closestIn NORTH) + @gap
    @f.height = (@_closestIn SOUTH) - @f.y - @gap
    this

  hFill: ->
    @f.x = (@_closestIn WEST) + @gap
    @f.width = (@_closestIn EAST) - @f.x - @gap
    this

  fill: ->
    @vFill()
    @hFill()
    this

  fallIn: (dir) ->
    closest = @_closestIn dir, true, true
    switch dir
      when SOUTH then @f.y = closest - @f.height - @gap
      when NORTH then @f.y = closest + @gap
      when EAST then @f.x = closest - @f.width - @gap
      when WEST then @f.x = closest + @gap
    this

  pourIn: (dir) ->
    @squashIn dir
    @fallIn dir
    @fill()
    this

# Shortcuts
fw = Window.focusedWindow
cw = (gap = GAP, unit = UNIT) ->
  new ChainWindow(Window.focusedWindow(), gap, unit)

# Handlers
keys = []
events = []

# Special
keys.push Phoenix.bind 'r', MOD, -> Phoenix.reload()
keys.push Phoenix.bind 'f', MOD, -> cw().maximize().set()

# Apps
for key, app of APPS
  keys.push Phoenix.bind key, MOD, -> App.launch(app).focus()

# Spaces
# TODO

# Directionals
DIR_MODS = [
  [
    # Select
    MOD,
    (dir) -> fw().focusIn(dir)
  ],
  [
    # Fall
    MOVE_MOD,
    (dir) -> cw().fallIn(dir).set()
  ],
  [
    # Squash
    SIZE_MOD,
    (dir) -> cw().squashIn(dir, 2).set()
  ],
  [
    # Pour
    POUR_MOD,
    (dir) -> cw().pourIn(dir).set()
  ],
]

for [mod, action] in DIR_MODS
  for key, dir of DIRS
    do (key, mod, action, dir) ->
      keys.push Phoenix.bind key, mod, -> action(dir)
