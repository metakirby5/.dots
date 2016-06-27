#!/usr/bin/env coffee -p

# Cardinal directions
NORTH = 'NORTH'
SOUTH = 'SOUTH'
EAST = 'EAST'
WEST = 'WEST'
DIR = 'DIR'
DIRS = [NORTH, SOUTH, EAST, WEST]

# Axes
VERTICAL = 'VERTICAL'
HORIZONTAL = 'HORIZONTAL'
AXIS = 'AXIS'
AXES = [VERTICAL, HORIZONTAL]

# Preferences
Phoenix.set
  openAtLogin: true

UNIT = 100
FACTOR = 2
GAP = 10
APPS =
  t: 'Terminal'
  e: 'Finder'

# Keys
MOD = ['cmd', 'alt']
MOVE_MOD = ['cmd', 'alt', 'shift']
SIZE_MOD = ['cmd', 'ctrl']
POUR_MOD = ['cmd', 'alt', 'ctrl']
DIR_KEYS =
  h: WEST
  j: SOUTH
  k: NORTH
  l: EAST
OFFSET_KEYS =
  n:  1
  p: -1

# Helpers
identify = (x) ->
  if x in DIRS
    DIR
  else if x in AXES
    AXIS
  else
    undefined

oppositeOf = (dirOrAxis) ->
  switch dirOrAxis
    when NORTH then SOUTH
    when SOUTH then NORTH
    when EAST then WEST
    when WEST then EAST
    when VERTICAL then HORIZONTAL
    when HORIZONTAL then VERTICAL

axisOf = (dirOrAxis) ->
  switch dirOrAxis
    when NORTH, SOUTH, VERTICAL then VERTICAL
    when EAST, WEST, HORIZONTAL then HORIZONTAL

coeff = (dir) ->
  switch dir
    when NORTH, WEST then -1
    when SOUTH, EAST then  1
    when VERTICAL, HORIZONTAL then 0

isCloser = (dir, a, b) ->
  c = coeff dir
  a * c < b * c

deltaIn = (dir) ->
  c = coeff dir
  switch axisOf dir
    when VERTICAL then    [0, UNIT * c]
    when HORIZONTAL then  [UNIT * c, 0]

# Rectangle methods
catchable = (f, dir, g) ->
  switch axisOf dir
    when VERTICAL
      f.x < g.x + g.width and f.x + f.width > g.x
    when HORIZONTAL
      f.y < g.y + g.height and f.y + f.height > g.y

edgeOf = (f, dir, gap = 0) ->
  switch dir
    when SOUTH then f.y + f.height + gap
    when NORTH then f.y - gap
    when EAST then f.x + f.width + gap
    when WEST then f.x - gap

# Screen methods
Screen::idx = ->
  that = this
  (_.find (Screen.screens().map (s, i) -> [i, s]),
          ([i, s]) -> that.isEqual s)[0]

# Space methods
Space::idx = ->
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
    @prevScr = if @scr? then @scr else scr
    @prevSf = @prevScr.visibleFrameInRectangle()
    @scr = scr
    @sf = @scr.visibleFrameInRectangle()

  windowsIn: (dir) ->
    switch dir
      when NORTH then @win.windowsToNorth()
      when SOUTH then @win.windowsToSouth()
      when EAST then @win.windowsToEast()
      when WEST then @win.windowsToWest()

  closestIn: (dir, skipFrame = false, onlyCatch = true) ->
    e = edgeOf @f, dir, @gap - if skipFrame then 0 else 1
    closest = edgeOf @sf, dir
    for win in @scr.visibleWindows()
      if not @win.isEqual win
        nf = win.frame()
        ne = edgeOf nf, (oppositeOf dir)
        if (isCloser dir, e, ne) and
           (isCloser dir, ne, closest) and
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

  moveEdgeTo: (dir, c) ->
    switch dir
      when SOUTH then @f.y = c - @f.height - @gap
      when NORTH then @f.y = c + @gap
      when EAST then @f.x = c - @f.width - @gap
      when WEST then @f.x = c + @gap

  size: (dx, dy, center = false) ->
    @move -dx / 2, -dy / 2 if center
    @f.width += dx
    @f.height += dy
    this

  sizeTo: (width, height, center = false) ->
    @move (@f.width - width) / 2, (@f.height - height) / 2 if center
    @f.width = width
    @f.height = height
    this

  sizeIn: (dir, center = false) ->
    @size (deltaIn dir)..., center
    this

  fill: (axes, skipFrame = false) ->
    for axis in axes
      switch axis
        when VERTICAL
          y = (@closestIn NORTH, skipFrame) + @gap
          height = (@closestIn SOUTH, skipFrame) - y - @gap
          @f.y = y
          @f.height = height
        when HORIZONTAL
          x = (@closestIn WEST, skipFrame) + @gap
          width = (@closestIn EAST, skipFrame) - x - @gap
          @f.x = x
          @f.width = width
    this

  fallIn: (dir) ->
    @moveEdgeTo dir, (@closestIn dir, true)
    this

  pourIn: (dir) ->
    g = _.extend {}, @f
    @sizeTo @unit, @unit, true
    @moveEdgeTo dir, (edgeOf g, dir, @gap)
    @fallIn dir
    @fill [(oppositeOf axisOf dir), (axisOf dir)]
    this

  setSpace: (num) ->
    next = Space.spaces()[num]
    if next?
      next.addWindows [@win]
      for prev in @win.spaces()
        prev.removeWindows [@win] if not prev.isEqual(next)
      @updateScr next.screen()
    this

  constrain: ->
    @f.width = Math.min @f.width, @sf.width - 2 * @gap
    @f.height = Math.min @f.height, @sf.height - 2 * @gap
    @f.x = @sf.x + Math.min @f.x - @prevSf.x, @sf.width - (@f.width + @gap)
    @f.y = @sf.y + Math.min @f.y - @prevSf.y, @sf.height - (@f.height + @gap)
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
  do (key, app) ->
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
  for key, offset of OFFSET_KEYS
    do (key, mod, action, offset) ->
      keys.push Phoenix.bind key, mod, ->
        idx = Space.activeSpace().idx()
        action (idx + offset)

# Directionals
DIR_MODS = [
  [
    # Select
    MOD,
    (dir) -> fw()?.focusIn(dir)
  ],
  [
    # Move
    MOVE_MOD,
    (dir) -> cw()?.moveIn(dir).set()
  ],
  [
    # Size
    SIZE_MOD,
    (dir) -> cw()?.sizeIn(dir).set()
  ],
  [
    # Pour
    POUR_MOD,
    (dir) -> cw()?.pourIn(dir).set()
  ],
]

for [mod, action] in DIR_MODS
  for key, dir of DIR_KEYS
    do (key, mod, action, dir) ->
      keys.push Phoenix.bind key, mod, -> action dir

# Notify upon load of config
Phoenix.notify 'Config loaded.'
