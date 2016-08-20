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
p =
  wins:
    tolerance: 10
    unit: 100
    factor: 2
    gap: 10
  modals:
    unit: 10
    gap: 10
  hints:
    stopEvents: [
      'screensDidChange',
      'spaceDidChange',
      'mouseDidLeftClick',
      'mouseDidRightClick',
      'appDidActivate',
      'appDidHide',
      'appDidShow',
      'windowDidFocus',
      'windowDidMove',
      'windowDidMinimize',
      'windowDidUnminimize',
    ]
    kStop: 'escape'
    kPop: 'delete'
    chars: 'FJ' #DKSLAGHRUEIWOVNCM'
    weight: 24
    appearance: 'dark'
    titleLength: 15
    titleCont: '…'
    debounce: 200
  keys:
    maximize: 'm'
    center: 'c'
    rePour: 'i'
    hinter: 'y'
    snaps:
      q:    [-1/2, -1/2]
      a:    [-1/2, -1  ]
      z:    [-1/2, 1/2 ]
      ']':  [1/2,  -1/2]
      '\'': [1/2,  -1  ]
      '/':  [1/2,  1/2 ]
    apps:
      t: 'iTerm'
      e: 'Finder'
    mods:
      base: ['cmd', 'alt']
      move: ['cmd', 'alt', 'shift']
      size: ['cmd', 'ctrl']
      pour: ['cmd', 'alt', 'ctrl']
      tile: ['cmd', 'ctrl', 'shift']
    dirs:
      h: WEST
      j: SOUTH
      k: NORTH
      l: EAST
    offsets:
      n:  1
      p: -1

# Utilities
Object.prototype.map = (f) ->
  Object.keys(this).reduce ((o, k) => o[k] = f this[k], k; o), {}
Array.prototype.extend = (a) -> Array.prototype.push.apply this, a
String.prototype.map = Array.prototype.map
String.prototype.pop = -> this.charAt(this.length - 1)
String.prototype.popped = -> this.substr(0, this.length - 1)
String.prototype.popFront = -> this.charAt(0)
String.prototype.poppedFront = -> this.substr(1)

ALL_KEYS = (String.fromCharCode(c) for c in [39]
    .concat [44..57]
    .concat [59]
    .concat [61]
    .concat [65..93]
    .concat [96])
  .concat ('f' + i for i in [1..19])
  .concat ('keypad' + i for i in [0..9]
    .concat ['Clear', 'Enter']
    .concat ('.*+/-='.split ''))
  .concat [
    'return', 'tab', 'space', 'delete', 'escape', 'help', 'home', 'pageUp',
    'forwardDelete', 'end', 'pageDown', 'left', 'right', 'down', 'up',
  ]

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

intersects = (f, g, gap = 0) ->
  f.x <= g.x + g.width + gap and g.y <= f.x + f.width + gap and
  f.y <= g.y + g.height + gap and g.y <= f.y + f.height + gap

# Screen methods
Screen::idx = ->
  (_.find (Screen.all().map (s, i) -> [i, s]),
          ([i, s]) => @isEqual s)[0]

# Space methods
Space::idx = ->
  (_.find (Space.all().map (s, i) -> [i, s]),
          ([i, s]) => @isEqual s)[0]

# Window methods
Window::hint = (seq,
    weight = p.hints.weight, appearance = p.hints.appearance,
    titleLength = p.hints.titleLength, titleCont = p.hints.titleCont) ->
  f = @frame()
  sf = @screen().frame()
  text = seq

  # If more than one app window visible, show title
  if this.app().windows({visible: true}).length > 1
    title = this.title()
    # If title length is too long, truncate
    if title.length > titleLength
      title = (title.substr 0, titleLength - titleCont.length) + titleCont
    text += ' | ' + title

  # Build a modal centered within the window
  hint = Modal.build
    text: text
    icon: this.app().icon()
    weight: weight
    appearance: appearance
    origin: (hf) =>
      x: (Math.min (
        Math.max f.x + f.width / 2 - hf.width / 2, sf.x
      ), sf.x + sf.width - hf.width)
      y: (Math.min (
        Math.max (
          Screen.all()[0].frame().height -
          (f.y + f.height / 2 + hf.height / 2)
        ), sf.y
      ), sf.y + sf.height - hf.height)

  hint.seq = seq
  hint.curSeqLen = seq.length
  hint

# Modal methods
Modal::open = []
Modal::updateSeqLen = (len) ->
  if not @seq?
    return
  next = @seq.substr len
  @text = next + @text.substr(@curSeqLen)
  @curSeqLen = next.length

Modal::_show = Modal::show
Modal::show = ->
  if not _.contains(@open, this)
    while _.some(@open.map (m) =>
        intersects @frame(), m.frame(), p.modals.gap)
      @origin = {
        x: @origin.x
        y: @origin.y - p.modals.unit
      }
    @open.push this
  @_show()

Modal::_close = Modal::close
Modal::close = ->
  Modal::open = _.without(@shown, this)
  @_close()

# Hints
class HintTree
  constructor: (@chars, wins, @parent, @prefix = '') ->
    # Add children
    @tree = {}
    (_.zip @chars, _.toArray _.groupBy wins, (e, i) => i % @chars.length)
      .map ([k, ws]) => if ws?
        @tree[k] = (
          seq = @prefix + k
          if ws.length == 1
            w = ws[0]
            w.hintInstance = w.hint seq
            w
          else
            new HintTree @chars, ws, this, seq
        )

  # Get child
  get: (k) ->
    @tree[k]

  # Map on all leaf nodes, with exclude
  map: (f, exclude) ->
    @tree.map (v, k) ->
      # Base case -  exclude
      if v == exclude
        v
      # Base case - node
      else if v not instanceof HintTree
        f v
      # Recursive case
      else
        v.map f, exclude

class Hinter
  constructor: (@chars = p.hints.chars, @stopEvents = p.hints.stopEvents,
      @kStop = p.hints.kStop, @kPop = p.hints.kPop,
      debounce = p.hints.debounce) ->
    @active = false
    @bouncedHints = _.debounce @showHints, debounce

  # Advance state machine
  push: (k) ->
    next = @state.get(k)
    if not next
      @stop()
    else
      @len++
      @prev = @state
      @state = next
      @update(true)

  # Retract state machine
  pop: ->
    # If we pop past empty, stop hints
    if not @len
      @stop()
    else
      @len--
      @prev = @state
      @state = @state.parent
      @update(false)

  # Re-show hints reflecting current state, or select window if complete
  update: (descending) ->
    # If state is a leaf, we're done
    if @state not instanceof HintTree
      # Cancel hints
      @stop()

      # Focus window
      w = @state
      w.focus()

      # Center mouse
      Mouse.move
        x: w.frame().x + w.frame().width / 2
        y: w.frame().y + w.frame().height / 2

    # Otherwise, update texts and only show hints under state
    else
      # Update text
      @state.map (w) =>
        w.hintInstance.updateSeqLen(@len)

      if descending
        # Hide non-matching hints
        @prev.map (w) ->
          w.hintInstance.close()
        , @state
      else
        # Show matching hints
        @bouncedHints @state

  # So we can debounce
  showHints: (state) ->
    state?.map (w) -> w.hintInstance.show()

  # Start hint mode
  start: ->
    # Only if not already active
    if @active
      return
    @active = true

    # Internal state
    @state = new HintTree @chars, Window.all {visible: true}
    @len = 0

    # Keybinds
    @binds = []
    @binds.push new Key @kStop, [], => @stop()
    @binds.push new Key @kPop, [], => @pop()
    @binds.extend (_.without ALL_KEYS, @kStop, @kPop).map (k) =>
      new Key k, [], => @push k

    # Events
    @events = []
    @stopEvents.map (e) => @events.push new Event e, => @stop()

    # Finally, show hints
    @showHints @state

  # Stop hint mode
  stop: ->
    # Only if active
    if not @active
      return
    @active = false

    # Close hints, disable keybinds, disable events
    @bouncedHints() # cancels debounce
    (if @state instanceof HintTree then @state else @prev).map (w) ->
      w.hintInstance.close()
    @binds.map (k) -> k.disable()
    @events.map (e) -> e.disable()

  # Toggle hint mode
  toggle: ->
    if @active then @stop() else @start()

# Window chaining
class ChainWindow
  constructor: (@win, @gap = p.wins.gap, @unit = p.wins.unit,
      @tolerance = p.wins.tolerance) ->
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
    @prevSf = @prevScr?.flippedVisibleFrame()
    @scr = scr
    @sf = @scr.flippedVisibleFrame()

  closestIn: (dir, skipFrame = false, onlyCatch = true) ->
    e = edgeOf @f, dir, @gap - if skipFrame then 0 else 1
    closest = edgeOf @sf, dir
    @win.others({screen: @scr, visible: true}).map (win) =>
      nf = win.frame()
      ne = edgeOf nf, (oppositeOf dir)
      if (isCloser dir, e, ne) and
         (isCloser dir, ne, closest) and
         (not onlyCatch or catchable @f, dir, nf)
        closest = ne
    closest

  # Begin chainables

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
    @win.others({screen: @scr, visible: true}).map (win) =>
      new ChainWindow(win, @gap, @unit, @tolerance)
        .sizeTo(@dropSize, @dropSize, true)
        .fill()
        .set()

    this

  fill: (axes = AXES, skipFrame = false) ->
    axes.map (axis) =>
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
      @win.spaces().map (prev) =>
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
cw = ->
  win = fw()
  new ChainWindow(win) if win?

# General
hinter = new Hinter()
Key.on p.keys.maximize, p.keys.mods.base, -> cw()?.maximize().set()
Key.on p.keys.center, p.keys.mods.base, -> cw()?.center().set()
Key.on p.keys.rePour, p.keys.mods.base, -> cw()?.rePour().set()
Key.on p.keys.hinter, p.keys.mods.base, -> hinter.toggle()

# Apps
p.keys.apps.map (app, key) ->
  Key.on key, p.keys.mods.base, -> App.launch(app).focus()

# Spaces
[
  [
    # Move
    p.keys.mods.move,
    (num) -> cw()?.setSpace(num).reproportion().set().focus()
  ],
].map ([mod, action]) ->
  [1..10].map (num) ->
    s = '' + num
    Key.on (s.substr s.length - 1), mod, -> action (num - 1)
  p.keys.offsets.map (offset, key) ->
    Key.on key, mod, ->
      idx = Space.active().idx()
      action (idx + offset)

# Directionals
[
  [
    # Select
    p.keys.mods.base,
    (dir) -> fw()?.focusClosestNeighbor(dir)
  ],
  [
    # Move
    p.keys.mods.move,
    (dir) -> cw()?.moveIn(dir).set()
  ],
  [
    # Size
    p.keys.mods.size,
    (dir) -> cw()?.sizeIn(dir).set()
  ],
  [
    # Pour
    p.keys.mods.pour,
    (dir) -> cw()?.pourIn(dir).set()
  ],
  [
    # Tile
    p.keys.mods.tile,
    (dir) -> cw()?.adjustIn(dir).set()
  ],
].map ([mod, action]) -> p.keys.dirs.map (dir, key) ->
  Key.on key, mod, -> action dir

# Snaps
p.keys.snaps.map (dest, key) ->
  Key.on key, p.keys.mods.base, -> cw()?.snap(dest...).set()

# Notify upon load of config
Phoenix.notify 'Config loaded.'

# vim:ft=coffee
