#!/usr/bin/env coffee -p

# Cardinal directions
NORTH = 'north'
SOUTH = 'south'
EAST = 'east'
WEST = 'west'
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

TOLERANCE = 10
UNIT = 100
FACTOR = 2
GAP = 10
SNAPS =
  q:    [-1/2, -1/2]
  a:    [-1/2, -1  ]
  z:    [-1/2, 1/2 ]
  ']':  [1/2,  -1/2]
  '\'': [1/2,  -1  ]
  '/':  [1/2,  1/2 ]
APPS =
  t: 'iTerm'
  e: 'Finder'

# Keys
MOD = ['cmd', 'alt']
MOVE_MOD = ['cmd', 'alt', 'shift']
SIZE_MOD = ['cmd', 'ctrl']
POUR_MOD = ['cmd', 'alt', 'ctrl']
TILE_MOD = ['cmd', 'ctrl', 'shift']
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

dirsOf = (axis) ->
  switch axis
    when VERTICAL then [NORTH, SOUTH]
    when HORIZONTAL then [EAST, WEST]

coeff = (dir) ->
  switch dir
    when NORTH, WEST then -1
    when SOUTH, EAST then  1
    when VERTICAL, HORIZONTAL then 0

isCloser = (dir, a, b) ->
  c = coeff dir
  a * c < b * c

deltaIn = (dir, unit = 1) ->
  c = coeff dir
  switch axisOf dir
    when VERTICAL then    [0, unit * c]
    when HORIZONTAL then  [unit * c, 0]

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
  (_.find (Screen.all().map (s, i) -> [i, s]),
          ([i, s]) -> that.isEqual s)[0]

# Space methods
Space::idx = ->
  that = this
  (_.find (Space.all().map (s, i) -> [i, s]),
          ([i, s]) -> that.isEqual s)[0]

# Window chaining
class ChainWindow
  constructor: (@win, @gap = 0, @unit = 1, @tolerance = 0) ->
    @f = @win.frame()
    @updateScr @win.screen()
    @dropSize = @gap + @tolerance

  set: ->
    @win.setFrame @f
    this

  focus: ->
    @win.focus()
    this

  updateScr: (scr) ->
    @prevScr = if @scr? then @scr else scr
    @prevSf = @prevScr?.visibleFrameInRectangle()
    @scr = scr
    @sf = @scr.visibleFrameInRectangle()

  closestIn: (dir, skipFrame = false, onlyCatch = true) ->
    e = edgeOf @f, dir, @gap - if skipFrame then 0 else 1
    closest = edgeOf @sf, dir
    for win in @win.others {screen: @scr, visible: true}
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
    @move (deltaIn dir, @unit)...
    this

  moveEdgeTo: (dir, c) ->
    switch dir
      when SOUTH then @f.y = c - @f.height - @gap
      when NORTH then @f.y = c + @gap
      when EAST then @f.x = c - @f.width - @gap
      when WEST then @f.x = c + @gap
    this

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

  sizeIn: (dir, center = false, amt = @unit) ->
    @size (deltaIn dir, amt)..., center
    this

  extendIn: (dir, amt = @unit) ->
    switch axisOf dir
      when VERTICAL then @f.height += amt
      when HORIZONTAL then @f.width += amt
    switch dir
      when NORTH then @f.y -= amt
      when WEST then @f.x -= amt
    this

  # Tiled resize.
  # Disclaimer: only works if window covers the entire edge of resize...
  adjustIn: (dir, amt = @unit) ->
    # First, resize our window
    # Reset by filling
    @sizeTo(@dropSize, @dropSize, true)
    @fill()
    # Extend in any direction where there exist windows
    dirs = _.filter (dirsOf (axisOf dir)), (dir) =>
      (@win.neighbors dir).length
    switch dirs.length
      # Sandiwched between two windows: resize from center
      when 2 then @sizeIn dir, true, amt
      # On edge: extend in direction of the window
      when 1 then @extendIn dirs[0], amt * coeff dir
      # Otherwise, no other windows, so maximize
      else
        @maximize()
    @set()

    # Now, resize all other windows
    for win in @win.others {screen: @scr, visible: true}
      new ChainWindow(win, @gap, @unit, @tolerance)
        .sizeTo(@dropSize, @dropSize, true)
        .fill()
        .set()

    this

  fill: (axes = AXES, skipFrame = false) ->
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
    @sizeTo @dropSize, @dropSize, true
    @moveEdgeTo dir, (edgeOf g, dir, @gap)
    @fallIn dir
    @fill [(oppositeOf axisOf dir), (axisOf dir)]
    this

  rePour: ->
    @sizeTo @dropSize, @dropSize, true
    @fill()
    this

  setSpace: (num) ->
    next = Space.all()[num]
    if next?
      next.addWindows [@win]
      for prev in @win.spaces()
        prev.removeWindows [@win] if not prev.isEqual(next)
      @updateScr next.screen()
    this

  # Ensure window fits within the screen
  constrain: ->
    @f.width = Math.min @f.width, @sf.width - 2 * @gap
    @f.height = Math.min @f.height, @sf.height - 2 * @gap
    @f.x = @sf.x + Math.min @f.x - @prevSf.x, @sf.width - (@f.width + @gap)
    @f.y = @sf.y + Math.min @f.y - @prevSf.y, @sf.height - (@f.height + @gap)
    this

  # Ensure window frame is proportionally equivalent to its frame on the
  # previous screen
  reproportion: ->
    # Translate to true origin
    @f.x -= @prevSf.x
    @f.y -= @prevSf.y

    # Scale x
    xFactor = @sf.width / @prevSf.width
    @f.x *= xFactor
    @f.width *= xFactor

    # Scale y
    yFactor = @sf.height / @prevSf.height
    @f.y *= yFactor
    @f.height *= yFactor

    # Translate to new screen origin
    @f.x += @sf.x
    @f.y += @sf.y
    this

  center: ->
    @f.x = @sf.x + (@sf.width - @f.width) / 2
    @f.y = @sf.y + (@sf.height - @f.height) / 2
    this

  maximize: ->
    @moveTo @sf.x + @gap, @sf.y + @gap
    @sizeTo @sf.width - 2 * @gap, @sf.height - 2 * @gap
    this

  # Snap to the sides of the screen
  # x and y are fractions of the screen, negative or positive
  snap: (x = null, y = null) ->
    if x?
      @f.width = @sf.width * Math.abs(x) - 1.5 * @gap
      if x < 0
        @f.x = @sf.x + @gap
      else
        @f.x = @sf.x + @sf.width - @f.width - @gap
    if y?
      @f.height = @sf.height * Math.abs(y) - 1.5 * @gap
      if y < 0
        @f.y = @sf.y + @gap
      else
        @f.y = @sf.y + @sf.height - @f.height - @gap
    this

# Shortcuts
fw = Window.focused
cw = (gap = GAP, unit = UNIT, tolerance = TOLERANCE) ->
  win = fw()
  new ChainWindow(win, gap, unit, tolerance) if win?

# Special
Key.on 'f', MOD, -> cw()?.maximize().set()
Key.on 'c', MOD, -> cw()?.center().set()
Key.on 'i', MOD, -> cw()?.rePour().set()

# Apps
for key, app of APPS
  do (key, app) ->
    Key.on key, MOD, -> App.launch(app).focus()

# Spaces
SPACE_MODS = [
  [
    # Move
    MOVE_MOD,
    (num) -> cw()?.setSpace(num).reproportion().set().focus()
  ],
]

for [mod, action] in SPACE_MODS
  for num in [1..10]
    do (num, mod, action) ->
      s = '' + num
      Key.on (s.substr s.length - 1), mod, -> action (num - 1)
  for key, offset of OFFSET_KEYS
    do (key, mod, action, offset) ->
      Key.on key, mod, ->
        idx = Space.active().idx()
        action (idx + offset)

# Directionals
DIR_MODS = [
  [
    # Select
    MOD,
    (dir) -> fw()?.focusClosestNeighbor(dir)
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
  [
    # Tile
    TILE_MOD,
    (dir) -> cw()?.adjustIn(dir).set()
  ],
]

for [mod, action] in DIR_MODS
  for key, dir of DIR_KEYS
    do (key, mod, action, dir) ->
      Key.on key, mod, -> action dir

# Snaps
for key, dest of SNAPS
  do (key, dest) ->
    Key.on key, MOD, -> cw()?.snap(dest...).set()

# Notify upon load of config
Phoenix.notify 'Config loaded.'
