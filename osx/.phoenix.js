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
Phoenix.set openAtLogin: true
p =
  wins:
    tolerance: 10
    unit: 100
    factor: 2
    gap: 20
  modals:
    unit: 10
    gap: 10
    duration: 1
    weight: 24
    appearance: 'dark'
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
    chars: 'FJDKSLAGHRUEIWOVNCM'
    titleLength: 15
    titleCont: '…'
    debounce: 150
  keys:
    maximize: 'm'
    center: 'c'
    reFill: 'u'
    winHintMode: 'y'
    scrHintMode: 's'
    status: 'i'
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

# Barebones event class
class EventEmitter
  constructor: ->
    @cbs = {}

  # Add listener
  on: (e, f) ->
    if not @cbs[e]?
      @cbs[e] = []
    @cbs[e].push f

  # Remove listener
  off: (e, f) ->
    @cbs[e] = _.without (@cbs[e] ? []), f

  # Broadcast to listeners
  emit: (e, args...) ->
    @cbs[e]?.map (f) -> f args...

# Every bindable key on a Macbook Pro keyboard
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

# Coordinate system helpers
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

within = (f, p) ->
  f.x <= p.x <= f.x + f.width and
  f.y <= p.y <= f.y + f.height

intersects = (f, g, gap = 0) ->
  f.x <= g.x + g.width + gap and g.x <= f.x + f.width + gap and
  f.y <= g.y + g.height + gap and g.y <= f.y + f.height + gap

gapify = (f, gap) ->
  f.x += gap
  f.y += gap
  f.width -= gap * 2
  f.height -= gap * 2

# Screen methods
Screen::idx = -> _.findIndex Screen.all(), (s) => @isEqual s

Screen::hint = (seq) ->
  sf = @frame()

  # Build a modal centered within the screen
  hint = Modal.build
    text: seq
    origin: (mf) ->
      x: sf.x + sf.width / 2 - mf.width / 2
      y: sf.y + sf.height / 2 - mf.height / 2

  hint.seq = seq
  hint.curSeqLen = seq.length
  hint

Screen::mouseTo = ->
  f = this.flippedFrame()
  Mouse.move
    x: f.x + f.width / 2
    y: f.y + f.height / 2

Screen.moused = ->
  _.find Screen.all(), (s) -> within s.flippedFrame(), Mouse.location()

# Space methods
Space::idx = -> _.findIndex Space.all(), (s) => @isEqual s

# Window methods
Window::hint = (seq) ->
  titleLength = p.hints.titleLength
  titleCont = p.hints.titleCont
  f = @frame()
  sf = @screen().frame()
  text = seq

  # If more than one app window visible, show title
  if this.app().windows(visible: true).length > 1
    title = this.title()
    # If title length is too long, truncate
    if title.length > titleLength
      title = (title.substr 0, titleLength - titleCont.length) + titleCont
    text += ' | ' + title

  # Build a modal centered within the window
  hint = Modal.build
    text: text
    icon: this.app().icon()
    origin: (mf) ->
      x: (Math.min (
        Math.max f.x + f.width / 2 - mf.width / 2, sf.x
      ), sf.x + sf.width - mf.width)
      y: (Math.min (
        Math.max (
          Screen.all()[0].frame().height -
          (f.y + f.height / 2 + mf.height / 2)
        ), sf.y
      ), sf.y + sf.height - mf.height)

  hint.seq = seq
  hint.curSeqLen = seq.length
  hint

# Modal methods
Modal::open = []

Modal::_build = Modal::build
Modal::build = (props) ->
  Modal._build _.extend props,
    weight: p.modals.weight
    appearance: p.modals.appearance

Modal::center = ->
  mf = @frame()
  sf = Screen.moused().frame()
  @origin =
    x: sf.x + sf.width / 2 - mf.width / 2
    y: sf.y + sf.height / 2 - mf.height / 2
  this

Modal::closeAfter = (s = p.modals.duration) ->
  Timer.off @mt if @mt?
  @mt = Timer.after s, => @close()
  this

Modal::updateSeqLen = (len) ->
  if not @seq?
    return
  next = @seq.substr len
  @text = next + @text.substr(@curSeqLen)
  @curSeqLen = next.length
  this

Modal::_show = Modal::show
Modal::show = ->
  Modal::open = _.without(@open, this)
  while _.some(@open.map (m) =>
      intersects @frame(), m.frame(), p.modals.gap)
    @origin =
      x: @origin.x
      y: @origin.y - p.modals.unit
  @open.push this
  @_show()
  this

Modal::_close = Modal::close
Modal::close = ->
  Timer.off @mt if @mt?
  Modal::open = _.without(@open, this)
  @_close()
  this

# Mode binds

# Base mode class
# Emits 'start', 'stop', and 'key'
# Privately emits 'prestart' and 'prestop'
class Mode extends EventEmitter
  constructor: ->
    super
    @active = false
    @binds = []

  # Start the mode
  start: ->
    # Don't start if not stopped
    if @active
      return
    @active = true

    # Capture all keys
    @binds = _.flatten ALL_KEYS.map (k) => [[], ['shift']].map (mod) =>
        Key.on k, mod, => @emit 'key', k, mod
    @emit 'prestart'
    @emit 'start'

  # Stop the mode
  stop: ->
    # Don't stop if not started
    if not @active
      return
    @active = false

    # Uncapture all keys
    @binds.map Key.off
    @emit 'prestop'
    @emit 'stop'

# Manager of modes
class ModeManager
  constructor: ->
    @cid = 0
    @modes = {}
    @cur = undefined

  # Add a mode, return an id
  add: (mode) ->
    id = @cid++
    @modes[id] = mode

    # On this mode starting
    mode.on 'prestart', =>
      @cur = id

      # Shut down all other modes
      @modes.map ((m, n) => m.stop() if +n != id)

    # On this mode stopping
    # Start is not guaranteed to have been run
    mode.on 'prestop', =>
      # Only if stopping the current mode
      delete @cur if @cur == id

    id

  # Stop and remove a mode by id
  remove: (id) ->
    @modes[id]?.stop()
    delete @modes[id]

  # Start mode by id
  start: (id) ->
    @modes[id]?.start()

  # Stop current mode
  stop: ->
    @modes[@cur]?.stop()

  # Start mode by id, or turn off if current mode is id
  toggle: (id) ->
    if @cur == id
      @stop()
    else
      @start id

# Hints
class HintTree
  constructor: (@chars, objs, @parent, @prefix = '') ->
    # Divide children amongst @chars
    @tree = (_.groupBy objs, (e, i) => @chars.charAt(i % @chars.length))
      .map (os, k) =>
        # The sequence for the hint
        seq = @prefix + k

        # If only one candidate for char, end tree here
        if os.length == 1
          o = os[0]
          obj: o
          hint: o.hint seq
        # Otherwise, make a subtree
        else
          new HintTree @chars, os, this, seq

  # Get child
  get: (k) -> @tree[k]

  # Map on all leaf nodes, with exclude
  map: (f, exclude) ->
    @tree.map (v, k) ->
      # Base case - exclude
      if v == exclude
        v
      # Base case - node
      else if v not instanceof HintTree
        f v
      # Recursive case
      else
        v.map f, exclude

class HintMode extends Mode
  constructor: (@hintableGetter, @action,
      @chars = p.hints.chars, @stopEvents = p.hints.stopEvents,
      @kStop = p.hints.kStop, @kPop = p.hints.kPop,
      debounce = p.hints.debounce) ->
    super
    @bouncedHints = _.debounce @showHints, debounce

    # Modal to indicate there's nothing to hint
    @noHintablesMsg = Modal.build
      text: 'Nothing to hint.'

    # Handle start event
    @on 'start', =>
      hintables = @hintableGetter()

      # Bail if nothing to hint
      if not hintables.length
        @noHintablesMsg.center().show()
        @stopTimer = Timer.after p.modals.duration, => @stop()
        return
      @noHintablesMsg.close()

      # Internal state
      @state = new HintTree @chars, hintables
      @len = 0

      # Events
      @events = @stopEvents.map (e) => Event.on e, => @stop()

      # Finally, show hints
      @showHints @state

    # Handle stop event
    @on 'stop', =>
      # Cancel any existing timer for stops
      Timer.off @stopTimer if @stopTimer?

      # Close hints
      @bouncedHints() # cancels debounce
      @noHintablesMsg.close()
      (if @state instanceof HintTree then @state else @prev)?.map (o) ->
        o.hint.close()

      # Disable events
      @events?.map Event.off

      # Destroy internal state
      delete @state
      delete @len

    # Handle key event
    @on 'key', (k) =>
      switch k
        when @kStop then @stop()
        when @kPop then @pop()
        else @push k

  # So we can debounce
  showHints: (state) -> state?.map (o) -> o.hint.show()

  # Advance state machine
  push: (k) ->
    # If no candidate, stop hints
    next = @state?.get(k)
    if not next?
      @stop()
    else
      @len++
      @prev = @state

      # Descend
      @state = next
      @update true

  # Retract state machine
  pop: ->
    # If we pop past empty, stop hints
    if not @len
      @stop()
    else
      @len--
      @prev = @state

      # Ascend
      @state = @state.parent
      @update false

  # Re-show hints reflecting current state,
  # or action on hintable if complete
  update: (descending) ->
    # If state is a leaf, we're done
    if @state not instanceof HintTree
      # Save the object to act on
      obj = @state.obj

      # Cancel hints
      @stop()

      # Do action
      @action obj

    # Otherwise, update texts and only show hints under state
    else
      # Update text
      @state.map (o) =>
        o.hint.updateSeqLen @len

      if descending
        # Hide non-matching hints
        @prev.map (o) ->
          o.hint.close()
        , @state
      else
        # Show matching hints
        @bouncedHints @state

# Window chaining
class ChainWindow
  constructor: (@win, @gap = p.wins.gap, @unit = p.wins.unit,
      @tolerance = p.wins.tolerance) ->
    @dropSize = @gap + @tolerance
    @updateWin()

  # Private: wrap with gap compensation
  ungapped: (f) -> (args...) =>
    ungap = @gap / 2

    # Ungap
    gapify @f,      -ungap
    gapify @sf,      ungap
    gapify @prevSf,  ungap if @prevSf?

    # Call the function
    res = f args...

    # Regap
    gapify @f,       ungap
    gapify @sf,     -ungap
    gapify @prevSf, -ungap if @prevSf?

    # Return the result
    res

  # Private: update window vars
  updateWin: ->
    @f = @win.frame()
    @updateScr @win.screen()

  # Private: update window screen for chains
  updateScr: (scr) ->
    @prevScr = if @scr? then @scr else scr
    @prevSf = @prevScr?.flippedVisibleFrame()
    @scr = scr
    @sf = @scr.flippedVisibleFrame()

  # Private: get closest window edge, with border calculation
  closestIn: (dir, skipFrame = false, onlyCatch = true) ->
    e = edgeOf @f, dir, @gap - if skipFrame then 0 else 1
    closest = edgeOf @sf, dir
    @win.others(screen: @scr, visible: true).map (win) =>
      nf = win.frame()
      ne = edgeOf nf, (oppositeOf dir)
      if (isCloser dir, e, ne) and
         (isCloser dir, ne, closest) and
         (not onlyCatch or catchable @f, dir, nf)
        closest = ne
    closest

  # Begin chainables

  # Apply frame
  set: ->
    @win.setFrame @f
    this

  # Proxy: focus
  focus: ->
    @win.focus()
    this

  # Switch window to neighbor
  neighbor: (dir) ->
    n = (@win.neighbors dir)?[0]
    if n?
      @win = n
      @updateWin()
    this

  # Center mouse on window
  mouseTo: ->
    Mouse.move
      x: @f.x + @f.width / 2
      y: @f.y + @f.height / 2
    this

  # Delta move
  move: (dx, dy) ->
    @f.x += dx
    @f.y += dy
    this

  # Absolute move
  moveTo: (x, y) ->
    @f.x = x
    @f.y = y
    this

  # Default delta move in direction
  moveIn: (dir) ->
    @move (deltaIn dir, @unit)...
    this

  # Move edge to coordinate
  moveEdgeTo: (dir, c) ->
    switch dir
      when SOUTH then @f.y = c - @f.height - @gap
      when NORTH then @f.y = c + @gap
      when EAST then @f.x = c - @f.width - @gap
      when WEST then @f.x = c + @gap
    this

  # Delta resize
  size: (dx, dy, center = false) ->
    @move -dx / 2, -dy / 2 if center
    @f.width += dx
    @f.height += dy
    this

  # Absolute resize
  sizeTo: (width, height, center = false) ->
    @move (@f.width - width) / 2, (@f.height - height) / 2 if center
    @f.width = width
    @f.height = height
    this

  # Default delta size in direction
  sizeIn: (dir, center = false, amt = @unit) ->
    @size (deltaIn dir, amt)..., center
    this

  # Extension in direction
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
    @reFill()
    @sizeIn dir, true, amt
    @set()

    # Now, resize all other windows
    @win.others(screen: @scr, visible: true).map (win) =>
      new ChainWindow(win, @gap, @unit, @tolerance)
        .sizeTo(@dropSize, @dropSize, true)
        .fill()
        .set()

    # Final resize
    @reFill()
    @set()

    this

  # Consume as much unoccupied space as possible
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

  # Recalculate fill
  reFill: ->
    @sizeTo @dropSize, @dropSize, true
    @fill()
    this

  # Move in direction until an edge is hit
  fallIn: (dir) ->
    @moveEdgeTo dir, (@closestIn dir, true)
    this

  # fallIn + fill
  pourIn: (dir) ->
    g = _.extend {}, @f
    @sizeTo @dropSize, @dropSize, true
    @moveEdgeTo dir, (edgeOf g, dir, @gap)
    @fallIn dir
    @fill [(oppositeOf axisOf dir), (axisOf dir)]
    this

  # Absoulute space set
  setSpace: (num) ->
    next = Space.all()[num]
    if next?
      next.addWindows [@win]
      @win.spaces().map (prev) =>
        prev.removeWindows [@win] if not prev.isEqual(next)
      @updateScr next.screen()
    this

  # Absolute screen set
  setScreen: (num) ->
    next = Screen.all()[num]
    if next?
      @setSpace next.currentSpace().idx()
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
  reproportion: -> do @ungapped =>
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

  # Center within screen
  center: ->
    @f.x = @sf.x + (@sf.width - @f.width) / 2
    @f.y = @sf.y + (@sf.height - @f.height) / 2
    this

  # Maximize within screen
  maximize: -> do @ungapped =>
    @moveTo @sf.x, @sf.y
    @sizeTo @sf.width, @sf.height
    this

  # Snap to the sides of the screen
  # x and y are fractions of the screen, negative or positive
  snap: (x = null, y = null) -> do @ungapped =>
    if x?
      @f.width = @sf.width * Math.abs(x)
      if x < 0
        @f.x = @sf.x
      else
        @f.x = @sf.x + @sf.width - @f.width
    if y?
      @f.height = @sf.height * Math.abs(y)
      if y < 0
        @f.y = @sf.y
      else
        @f.y = @sf.y + @sf.height - @f.height
    this

# Shortcuts
cwModal = Modal.build
  text: 'No windows to chain.'
.center()
cw = ->
  win = Window.focused() or
        Window.recent()[0]
  if not win?
    cwModal.center().show().closeAfter()
    null
  else
    cwModal.close()
    new ChainWindow win

# Modes
modes = new ModeManager()
winHint = modes.add new HintMode Window.recent, (w) ->
  (new ChainWindow w).focus().mouseTo()
scrHint = modes.add new HintMode Screen.all, (s) ->
  s.mouseTo()
scrMovHint = modes.add new HintMode Screen.all, (s) ->
  cw()?.setScreen(s.idx()).reproportion().set().focus().mouseTo()

# General
Key.on p.keys.maximize, p.keys.mods.base, -> cw()?.maximize().set()
Key.on p.keys.center, p.keys.mods.base, -> cw()?.center().set()
Key.on p.keys.reFill, p.keys.mods.base, -> cw()?.reFill().set()
Key.on p.keys.winHintMode, p.keys.mods.base, -> modes.toggle winHint
Key.on p.keys.scrHintMode, p.keys.mods.base, -> modes.toggle scrHint
Key.on p.keys.scrHintMode, p.keys.mods.move, -> modes.toggle scrMovHint
Key.on p.keys.status, p.keys.mods.base, -> Task.run '/bin/sh', [
  "-c", "LANG='ja_JP.UTF-8' date '+%a %-m/%-d %-H:%M'"
], (r) ->
  Phoenix.notify r.output
  # Modal.build
  #   text: r.output
  # .center().show().closeAfter()

# Apps
p.keys.apps.map (app, key) ->
  Key.on key, p.keys.mods.base, -> App.launch(app).focus()

# Spaces
[
  [
    # Move
    p.keys.mods.move,
    (num) -> cw()?.setSpace(num).reproportion().set().focus().mouseTo()
  ],
].map ([mod, action]) ->
  [1..10].map (num) ->
    s = '' + num
    Key.on (s.substr s.length - 1), mod, -> action (num - 1)
  p.keys.offsets.map (offset, key) ->
    Key.on key, mod, ->
      idx = Screen.moused().currentSpace().idx()
      slen = Space.all().length
      action (((idx + offset) % slen) + slen) % slen

# Directionals
[
  [
    # Select
    p.keys.mods.base,
    (dir) -> cw()?.neighbor(dir).focus().mouseTo()
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
