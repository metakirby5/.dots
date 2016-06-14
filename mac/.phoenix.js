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
OFFSETS =
  n: 1
  p: -1

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

deltaIn = (dir) ->
  switch dir
    when NORTH then [0, -UNIT]
    when SOUTH then [0,  UNIT]
    when EAST then  [ UNIT, 0]
    when WEST then  [-UNIT, 0]

# Rectangle methods
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

# Screen methods
Screen::getIdx = ->
  that = this
  (_.find (Screen.screens().map (s, i) -> [i, s]),
          ([i, s]) -> that.isEqual s)[0]

# Space methods
Space::getIdx = ->
  that = this
  (_.find (Space.spaces().map (s, i) -> [i, s]),
          ([i, s]) -> that.isEqual s)[0]

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
    @updateScr @win.screen()

  set: ->
    @win.setFrame @f

  updateScr: (scr) ->
    @scr = scr
    @sf = scr.visibleFrameInRectangle()

  windowsIn: (dir) ->
    switch dir
      when NORTH then @win.windowsToNorth()
      when SOUTH then @win.windowsToSouth()
      when EAST then @win.windowsToEast()
      when WEST then @win.windowsToWest()

  closestIn: (dir, useFallthru = false, onlyCatch = false) ->
    e = edgeOf @f, dir
    closest = edgeOf @scr.visibleFrameInRectangle(), dir
    for win in @scr.visibleWindows()
      if not @win.isEqual win
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
    @move (deltaIn dir)...
    this

  size: (dx, dy) ->
    @f.width += dx
    @f.height += dy
    this

  sizeTo: (width, height) ->
    @f.width = width
    @f.height = height
    this

  sizeIn: (dir) ->
    @size (deltaIn dir)...
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
    @f.y = (@closestIn NORTH, false, true) + @gap
    @f.height = (@closestIn SOUTH, false, true) - @f.y - @gap
    this

  hFill: ->
    @f.x = (@closestIn WEST, false, true) + @gap
    @f.width = (@closestIn EAST, false, true) - @f.x - @gap
    this

  fill: ->
    @vFill()
    @hFill()
    this

  fallIn: (dir) ->
    closest = @closestIn dir, true, true
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

  setSpace: (num) ->
    space = Space.spaces()[num]
    if space?
      space.addWindows [@win]
      Space.activeSpace().removeWindows [@win]
    @updateScr space.screen()
    this

  constrain: ->
    @f.width = Math.min @f.width, @sf.width - 2 * @gap
    @f.height = Math.min @f.height, @sf.height - 2 * @gap
    @f.x = @sf.x + Math.min @f.x, @sf.width - (@f.width + @gap)
    @f.y = @sf.y + Math.min @f.y, @sf.height - (@f.height + @gap)
    this

  center: ->
    @f.x = @sf.x + (@sf.width - @f.width) / 2
    @f.y = @sf.y + (@sf.height - @f.height) / 2
    this

  maximize: ->
    @moveTo @sf.x + @gap, @sf.y + @gap
    @sizeTo @sf.width - 2 * @gap, @sf.height - 2 * @gap
    this

# Shortcuts
fw = Window.focusedWindow
cw = (gap = GAP, unit = UNIT) ->
  win = fw()
  new ChainWindow(win, gap, unit) if win?

# Handlers
keys = []
events = []

# Special
keys.push Phoenix.bind 'r', MOD, -> Phoenix.reload()
keys.push Phoenix.bind 'f', MOD, -> cw()?.maximize().set()
keys.push Phoenix.bind 'c', MOD, -> cw()?.center().set()

# Apps
for key, app of APPS
  keys.push Phoenix.bind key, MOD, -> App.launch(app).focus()

# Spaces
SPACE_MODS = [
  [
    # Move
    MOVE_MOD,
    (num) -> cw()?.setSpace(num).constrain().set()
  ],
]

for [mod, action] in SPACE_MODS
  for num in [1..10]
    do (num, mod, action) ->
      s = '' + num
      keys.push Phoenix.bind (s.substr s.length - 1), mod, -> action (num - 1)
  for key, offset of OFFSETS
    do (key, mod, action, offset) ->
      keys.push Phoenix.bind key, mod, ->
        idx = Space.activeSpace().getIdx()
        action (idx + offset)

# Directionals
DIR_MODS = [
  [
    # Select
    MOD,
    (dir) -> fw()?.focusIn(dir)
  ],
  [
    # Fall
    MOVE_MOD,
    (dir) -> cw()?.fallIn(dir).set()
  ],
  [
    # Squash
    SIZE_MOD,
    (dir) -> cw()?.squashIn(dir, 2).set()
  ],
  [
    # Pour
    POUR_MOD,
    (dir) -> cw()?.pourIn(dir).set()
  ],
]

for [mod, action] in DIR_MODS
  for key, dir of DIRS
    do (key, mod, action, dir) ->
      keys.push Phoenix.bind key, mod, -> action dir

# Notify upon load of config
Phoenix.notify 'Config loaded.'
