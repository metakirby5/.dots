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

isCloser = (dir, a, b, fallthru = 0) ->
  c = coeff dir
  fallthru + a * c < b * c

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

  closestIn: (dir, useFallthru = false, onlyCatch = false) ->
    e = edgeOf @f, dir
    closest = edgeOf @scr.visibleFrameInRectangle(), dir
    for win in @scr.visibleWindows()
      if not @win.isEqual win
        nf = win.frame()
        ne = edgeOf nf, (oppositeOf dir)
        if (isCloser dir, e, ne, if useFallthru then @gap else 0) and
           (isCloser dir, ne, closest, if useFallthru then @gap else 0) and
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

  squashIn: (dirOrAxis, factor = 0) ->
    axis = axisOf dirOrAxis
    g = _.extend {}, @f

    # Change size
    switch axis
      when VERTICAL   then @f.height *= factor
      when HORIZONTAL then @f.width *= factor

    # Move if needed
    fraction = switch dirOrAxis
      when NORTH, SOUTH         then 0
      when EAST, WEST           then 1 - factor
      when VERTICAL, HORIZONTAL then (1 - factor) / 2
    switch axis
      when VERTICAL then @f.y += g.height * fraction
      when HORIZONTAL then @f.x += g.width * fraction
    this

  fill: (axis) ->
    if not axis? or axis is VERTICAL
      @f.y = (@closestIn NORTH, false, true) + @gap
      @f.height = (@closestIn SOUTH, false, true) - @f.y - @gap
    if not axis? or axis is HORIZONTAL
      @f.x = (@closestIn WEST, false, true) + @gap
      @f.width = (@closestIn EAST, false, true) - @f.x - @gap
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
    @squashIn oppositeOf axisOf dir
    @fallIn dir
    @fill()
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
