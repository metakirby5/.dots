#!/usr/bin/env coffee -p

# Reload shortcut first
Key.on 'r', ['cmd', 'alt', 'ctrl'], -> Phoenix.reload()

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
# AVAILABLE KEYS: f v g
Phoenix.set openAtLogin: true
p =
  timeout: 0.2                   # Timeout for e.g. window focus

  ## WINDOWS
  wins:
    tolerance: 10                # Tolerance for window movement (for pouring)
    unit: 100                    # Increment for moving and resizing
    gap: 20                      # Gap between windows

  ## MODAL DIALOGS
  modals:
    unit: 10                     # Increment for overlapping modal offset
    gap: 10                      # Gap between modals
    duration: 3                  # Seconds modal stays open
    weight: 24                   # Font weight of modals
    appearance: 'dark'           # Appearance (vibrance) of modals

  ## MODES
  hints:                         ## WINDOW HINT MODE
    stopEvents:                  # Events which halt hint mode
      [ 'screensDidChange'
      , 'spaceDidChange'
      , 'mouseDidLeftClick'
      , 'mouseDidRightClick'
      , 'appDidActivate'
      , 'appDidHide'
      , 'appDidShow'
      , 'windowDidMove'
      , 'windowDidMinimize'
      , 'windowDidUnminimize' ]
    chars: 'FJDKSLAGHRUEIWOVNCM' # Hint characters (in order)
    titleLength: 15              # Maximum hint title length
    titleCont: '…'               # String to indicate title continuation
    debounce: 150                # Milliseconds to debounce hints

  input:                         ## GENERAL INPUT MODE
    stopEvents:                  # Events which halt input mode
      [ 'screensDidChange'
      , 'spaceDidChange'
      , 'mouseDidLeftClick'
      , 'mouseDidRightClick' ]
    cursor: 'ˌ'                  # String to show to represent cursor position

  eval:                          ## JAVASCRIPT EVAL MODE
    prompt: '> '                 # Prompt character
    instantPrefix: '@'           # Prefix to toggle "instant eval"
    progressStr: '…'             # String to show while "instant eval" errors

  shell:                         ## SHELL COMMAND MODE
    prompt: '$ '                 # Prompt character
    bin: '/usr/local/bin/bash'   # Shell to run (abs. path)

  find:                          ## FIND WINDOW MODE
    prompt: '? '

  ## KEYBINDINGS
  keys:
    ## MODIFIER KEYS
    mods:
      base: ['cmd', 'alt']
      move: ['cmd', 'alt', 'shift']
      size: ['cmd', 'ctrl']
      pour: ['cmd', 'alt', 'ctrl']
      tile: ['cmd', 'ctrl', 'shift']
      fall: ['alt', 'shift']

    ## MULTI-MODIFIER KEYS
    dirs:                    # Directionals
      h: WEST
      j: SOUTH
      k: NORTH
      l: EAST
    offsets:                 # Next, previous
      n:  1
      p: -1

    ## ACTIVATE WITH mods.base
    snaps:                   # Toggle: window snap proportions
      q:      [-1/2, -1/2]
      a:      [-1/2, 1  ]
      z:      [-1/2, 1/2 ]
      ']':    [1/2,  -1/2]
      '\'':   [1/2,  1  ]
      '/':    [1/2,  1/2 ]
      'down': [1, 1/2]
      'up':   [1, -1/2]
    quick: 'tab'             # Random quick actions
    maximize: 'm'            # Toggle: maximize window, w/ gaps
    center: 'c'              # Toggle: center window
    reFill: 'u'              # Toggle: grow window to fill empty space
    mouseTo: 'o'             # Move mouse to window
    status: 'i'              # Show datetime in notification
    sleep: 'delete'          # Put machine to sleep
    mouseOut: '.'            # Move mouse to lower right corner
    winHintMode: 'y'         # Activate window hint mode
    scrHintMode: 's'         # Activate screen hint mode
    evalInputMode: '-'       # Activate JS eval mdoe
    findMode: ';'            # Activate find window mode
    shellInputMode: 'return' # Activate shell input mode
    apps:                    # Launch applications
      t: 'iTerm'
      e: 'Finder'
      ',': 'Google Chrome'

# Utilities
Object.prototype.map = (f) ->
  Object.keys(this).reduce ((o, k) => o[k] = f this[k], k; o), {}
Array.prototype.extend = (a) -> @push a...
Array.prototype.contains = (x) -> -1 < @indexOf x
Array.prototype.equals = (a) -> _.all (_.zip this, a).map ([a, b]) -> a == b
Array.prototype.subsets = ->
  if not this
    [this]
  else
    [x, xs...] = this
    rest = xs.subsets()
    rest.concat rest.map (a) -> a.concat x
String.prototype.map = Array.prototype.map
String.prototype.pop = -> @charAt @length - 1
String.prototype.popped = -> @substr 0, @length - 1
String.prototype.popFront = -> @charAt 0
String.prototype.poppedFront = -> @substr 1
String.prototype.insert = (s, i) -> (@substr 0, i) + s + @substr i
String.prototype.remove = (i) -> (@substr 0, i) + @substr i + 1

lerp = (a, b, t) -> a * (1 - t) + b * t
inverseLerp = (a, b, t) -> (t - a) / (b - a)
smoothStep = (min, max, value) ->
  x = Math.max(0, Math.min(1, (value - min) / (max - min)))
  x * x * (3 - 2 * x)

frameLerp = (f, g, t) ->
  x: lerp f.x, g.x, t
  y: lerp f.y, g.y, t
  width: lerp f.width, g.width, t
  height: lerp f.height, g.height, t

frameCenter = (frame) ->
  x: frame.x + frame.width / 2
  y: frame.y + frame.height / 2

sqDist = (a, b) ->
  Math.pow(a.x - b.x, 2) + Math.pow(a.y - b.y, 2)

# Retry until either f returns true or we hit timeout
persistently = (timeout, f) ->
  keepTrying = true
  Timer.after timeout, -> keepTrying = false

  tryIt = ->
    if f()
      return

    if keepTrying
      _.defer tryIt
      return

    Phoenix.notify 'Persistent call timed out!'
    Phoenix.log "`persistently` timed out:\n#{f}"

  tryIt()


# Every bindable key on a Macbook Pro keyboard
ALL_KEYS = (String.fromCharCode(c) for c in [39]
    .concat [44..57]
    .concat 59
    .concat 61
    .concat [65..93]
    .concat 96)
  .concat ('f' + i for i in [1..19])
  .concat ('keypad' + i for i in [0..9]
    .concat ['Clear', 'Enter']
    .concat ('.*+/-='.split ''))
  .concat [
    'return', 'tab', 'space', 'delete', 'escape', 'help', 'home', 'pageUp',
    'forwardDelete', 'end', 'pageDown', 'left', 'right', 'down', 'up',
  ]

# Mapping of character to character + shift (wish there was a func for this)
SHIFT_KEYS = _.extend
  '`': '~', '1': '!', '2': '@', '3': '#', '4': '$', '5': '%', '6': '^',
  '7': '&', '8': '*', '9': '(', '0': ')', '-': '_', '=': '+', '[': '{',
  ']': '}', '\\': '|', ';': ':', '\'': '"', ',': '<', '.': '>', '/': '?',
, _.zipObject (
  String.fromCharCode(c) for c in [97..122]
), (
  String.fromCharCode(c) for c in [65..90]
)

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

# A fixed length queue
class FixedQueue
  constructor: (@capacity) ->
    @queue = []

  push: (frame) -> @queue = ([frame].concat @queue)[...@capacity]
  length: -> @queue.length
  at: (idx) -> @queue[idx]

# Utility function for toggling with FixedQueue
toggle = (q, x, f) -> f q.at 1 if q.length() >= 2 and _.isEqual x, q.at 0

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
  sfCenter = frameCenter @frame()

  # Build a modal centered within the screen
  hint = Modal.build
    text: seq
    origin: (mf) ->
      x: sfCenter.x - mf.width / 2
      y: sfCenter.y - mf.height / 2

  hint.seq = seq
  hint.curSeqLen = seq.length
  hint

Screen::mouseTo = ->
  f = @flippedFrame()
  Mouse.move
    x: f.x + f.width / 2
    y: f.y + f.height / 2

Screen.moused = ->
  _.find Screen.all(), (s) -> within s.flippedFrame(), Mouse.location()

# Space methods
Space::idx = -> _.findIndex Space.all(), (s) => @isEqual s

# Window methods
Window::chain = -> new ChainWindow this
Window::hint = (seq) ->
  titleLength = p.hints.titleLength
  titleCont = p.hints.titleCont
  f = @frame()
  sf = @screen().frame()
  text = seq

  # If more than one app window visible, show title
  if @app().windows(visible: true).length > 1
    title = @title()
    # If title length is too long, truncate
    if title.length > titleLength
      title = (title.substr 0, titleLength - titleCont.length) + titleCont
    text += ' | ' + title

  # Build a modal centered within the window
  hint = Modal.build
    text: text
    icon: @app().icon()
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

# Mouse methods
Mouse.pointQueue = new FixedQueue 2
Mouse._move = Mouse.move
Mouse.move = (args...) ->
  Mouse.pointQueue.push Mouse.location()
  Mouse._move args...
Mouse.toggle = -> toggle Mouse.pointQueue, Mouse.location(), Mouse.move

# Modal methods
Modal.open = []

Modal._build = Modal.build
Modal.build = (props = {}) ->
  Modal._build _.extend props,
    weight: p.modals.weight
    appearance: p.modals.appearance

Modal::_show = Modal::show
Modal::show = ->
  @untrack()

  # Close on click
  @clickEvent = Event.on 'mouseDidLeftClick', (point) =>
    if within @frame(), point
      @close()

  @resolveOverlaps()
  @_show()
  this

Modal::_close = Modal::close
Modal::close = ->
  @untrack()
  @_close()
  this

Modal::setText = (@text) -> this

Modal::untrack = ->
  Event.off @clickEvent if @clickEvent?  # Disable clickEvent
  Modal.open = _.without Modal.open, this  # Untrack modal location

Modal::resolveOverlaps = ->
  Modal.open = _.without Modal.open, this
  while _.some (Modal.open.map (m) =>
    intersects @frame(), m.frame(), p.modals.gap)
    @origin =
      x: @origin.x
      y: @origin.y - p.modals.unit
  Modal.open.push this

Modal::center = ->
  mf = @frame()
  sf = Screen.moused().frame()
  @origin =
    x: sf.x + sf.width / 2 - mf.width / 2
    y: sf.y + sf.height / 2 - mf.height / 2
  this

Modal::updateSeqLen = (len) ->
  if not @seq?
    return
  next = @seq.substr len
  @text = next + @text.substr(@curSeqLen)
  @curSeqLen = next.length
  this

# Toast messages
class Toaster
  constructor: (@modal = Modal.build()) ->
  @instance: new Toaster()

  toast: (text, s = p.modals.duration) ->
    @modal.setText(text).center().show()

    # Bind escape to close modal
    @binds = [(Key.on 'escape', [], => @close())]

    # Close after specified duration
    Timer.off @mt if @mt?
    @mt = Timer.after s, => @close()
  @toast: (args...) -> @instance.toast args...

  close: ->
    @binds?.map Key.off
    @modal.close()
  @close: (args...) -> @instance.close args...

# Mode binds

# Base mode class
# Emits 'start', 'stop', and 'key' (key, shift)
# Privately emits 'prestart' and 'prestop'
class Mode extends EventEmitter
  constructor: (@stopEvents = []) ->
    super()
    @active = false
    @binds = []

  # Start the mode
  start: ->
    # Don't start if not stopped
    if @active
      return
    @active = true

    # Capture all keys
    @binds = _.flatten ALL_KEYS.map (k) => [
      [], ['shift'], ['ctrl']
    ].map (mod) =>
      Key.on k, mod, => @emit 'key', k, _.first mod

    # Stop on stopEvents
    @events = @stopEvents.map (e) => Event.on e, => @stop()

    @emit 'prestart'
    @emit 'start'

  # Stop the mode
  stop: ->
    # Don't stop if not started
    if not @active
      return
    @active = false

    # Uncapture all keys
    @binds?.map Key.off

    # Stop listening to events
    @events?.map Event.off

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
      @modes.map ((m, n) -> m.stop() if +n != id)

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
  # chars is the possible hint chars
  # objs is the objects to hint
  # parent is the parent of the hint tree, which is undefined for root
  # prefix is the hint prefix
  constructor: (@chars, objs, @parent, @prefix = '') ->
    # Divide children amongst @chars
    indexed = objs.map (o, i) -> {o, i}
    @tree = _.groupBy indexed, ({o, i}) => @chars.charAt i % @chars.length
      .map (os, k) =>
        # Unpack the object
        os = os.map ({o, i}) -> o

        # The sequence for the hint
        seq = @prefix + k

        # If only one candidate for char, end tree here
        if os.length == 1
          o = _.head os
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
  chars: p.hints.chars

  # hintableGetter provides an array of hintables when called
  # action is a function w/ params (hintedObj, mod)
  constructor: (@hintableGetter, @action) ->
    super p.hints.stopEvents
    @bouncedHints = _.debounce @showHints, p.hints.debounce

    # Handle start event
    @on 'start', =>
      hintables = @hintableGetter()

      # Bail if nothing to hint
      if not hintables.length
        Toaster.toast 'Nothing to hint.'
        @stop()
        return

      # Internal state
      @state = new HintTree @chars, hintables
      @len = 0

      # Finally, show hints
      @showHints @state

    # Handle stop event
    @on 'stop', =>
      # Cancel any existing timer for stops
      Timer.off @stopTimer if @stopTimer?

      # Close hints
      @bouncedHints() # cancels debounce
      (if @state instanceof HintTree then @state else @prev)?.map (o) ->
        o.hint.close()

      # Destroy internal state
      delete @state
      delete @len

    # Handle key event
    @on 'key', (k, @mod) =>
      switch k
        when 'escape' then @stop()
        when 'delete' then @pop()
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
      @action obj, @mod

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

# Mode for inputting text
class InputMode extends Mode
  cursor: p.input.cursor

  # @action is (@input, keyPressed) -> [input, output, exit]
  constructor: (@prompt, @action) ->
    super p.input.stopEvents
    @history = []

    # Initialize state, listen to events, and show modal
    @on 'start', =>
      @input = ''
      @pos = 0
      @historyPos = -1
      @inputModal = Modal.build text: @prompt + @cursor
      @inputModal.center().show()

      @output = ''
      @outputModal = Modal.build text: @output

    # Stop listening to events and close modal
    @on 'stop', =>
      @inputModal?.close()
      @outputModal?.close()

    # Handle keypress
    @on 'key', (k, @mod) =>
      k = k.toLowerCase() # normalize
      switch k
        when 'escape' then @stop()
        else @update if @mod == 'shift' then SHIFT_KEYS[k] or k else k

  # Update command state and modal from key event
  update: (k) ->
    switch @mod

      # Readline controls
      when 'ctrl'
        switch k
          when 'a' then @pos = 0
          when 'e' then @pos = @input.length
          when 'b' then @movePos -1
          when 'f' then @movePos 1
          when 'p' then @moveHistory -1
          when 'n' then @moveHistory 1
          when 'u'
            @input = @input.substr @pos
            @pos = 0
          when 'k'
            @input = @input.substr 0, @pos

      # Text
      else
        switch k
          when 'return'
            # Add to history
            if not @history.length or (@input and (_.head @history) != @input)
              @history.unshift @input
            @historyPos = -1
          when 'tab' then  # no-op
          when 'down' then @moveHistory 1
          when 'up' then @moveHistory -1
          when 'left' then @movePos -1
          when 'right' then @movePos 1
          when 'delete'
            @input = @input.remove @pos - 1
            @movePos -1
          when 'forwarddelete'
            @input = @input.remove @pos
          when 'space'
            @input = @input.insert ' ', @pos
            @movePos 1
          else
            @input = @input.insert k, @pos
            @movePos 1

    # Run the action
    [input, @output, exit] = @action @input, k

    # Exit if requested
    return @stop() if exit

    # Set input and reset position
    if input? and input != @input
      @input = input
      @pos = input.length

    # Set modals' text
    @inputModal.setText(@prompt + @input.insert @cursor, @pos).center().show()
    if @output?
      @outputModal.setText(@output).center().show()
    else
      @outputModal.close()

  # Move the cursor position with bounds handling
  movePos: (d) ->
    @pos = Math.min @input.length, Math.max 0, @pos + d

  # Move the history position and set input
  moveHistory: (d) ->
    # Save current line
    if @historyPos == -1
      @current = @input

    @historyPos = Math.min @history.length - 1, Math.max -1, @historyPos - d
    @input = if @historyPos == -1 then @current else @history[@historyPos]
    @pos = @input.length

# Window chaining
class ChainWindow
  @frameQueues: {}  # hash -> FrameQueue

  gap: p.wins.gap
  unit: p.wins.unit

  constructor: (@win) ->
    @dropSize = @gap + p.wins.tolerance
    @updateWin()

    # Save the previous window frame
    @frameQueue().push _.clone @f

  frameQueue: ->
    hash = @win.hash()
    ChainWindow.frameQueues[hash] =
      ChainWindow.frameQueues[hash] or new FixedQueue 2

  # Private: check @sf first
  rSf: (f) -> (args...) =>
    if not (@f? and @sf?)
      return this

    f args...

  # Private: wrap with gap compensation
  ungapped: (f) -> (args...) => do @rSf =>
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
    @updateScr()

  # Private: update window screen for chains
  updateScr: (next = @win.screen()) ->
    @prevScr = @scr ? next
    @prevSf = @prevScr?.flippedVisibleFrame()
    @scr = next
    @sf = @scr?.flippedVisibleFrame()

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

  setFrame: (f) ->
    # NOTE: setFrame no longer works correctly when moving to different
    # NOTE| screens, so use our own implementation. Original does
    # NOTE| size-position-size, but we do position-size-position.
    @win.setTopLeft f
    @win.setSize f
    @win.setTopLeft f

  # Begin chainables

  # Apply frame
  set: ->
    @animations[@win.hash()]?.stop()
    @setFrame @f
    this

  animationFps: 60
  animationSecs: 0.15
  animations: {}
  doSet: ->
    secsPerFrame = 1 / @animationFps

    hash = @win.hash()
    animation = @animations[hash]
    animation?.stop()

    oldFrame = @win.frame()
    newFrame = @f
    t = 0

    startMs = new Date().getTime()
    endMs = startMs + @animationSecs * 1000
    @animations[hash] = anim = new Timer secsPerFrame, true, =>
      t = inverseLerp startMs, endMs, new Date().getTime()
      smoothed = smoothStep 0, 1, t
      f = frameLerp oldFrame, newFrame, smoothed
      @win.setTopLeft f
      @win.setSize f
      if t >= 1
        anim.stop()
    this

  # Focus window
  focus: ->
    # Some apps don't focus the right window,
    # so keep trying until timeout.
    persistently p.timeout, =>
      @win.focus()
      Window.focused()?.isEqual @win
    this

  # Switch window to neighbor
  neighbor: (dir) ->
    # Widnow.neighbours is slow, so implement our own.

    myCenter = frameCenter @f
    axis = axisOf dir
    dirCoeff = coeff dir
    isEligible = (other) ->
      center = frameCenter other.frame()
      switch axis
        when VERTICAL then (center.y - myCenter.y) * dirCoeff > 0
        when HORIZONTAL then (center.x - myCenter.x) * dirCoeff > 0

    all = Window.all visible: true
    inDirection = _.filter all, isEligible
    n = _.minBy inDirection, (other) ->
      sqDist myCenter, frameCenter other.frame()

    if n?
      @win = n
      @updateWin()
    this

  # Center mouse on window
  mouseTo: ->
    Mouse.move frameCenter @f
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
    @win.others(screen: @scr, visible: true).map (win) ->
      win.chain().reFill().set()

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
      next.moveWindows [@win]
      @updateScr next.screens()[0]
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

  # If frame is unchanged, revert to previous state
  toggle: ->
    toggle @frameQueue(), @f, (x) => @f = x
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
cw = ->
  win = Window.focused() or
        Window.recent()[0]
  if not win?
    Toaster.toast 'No windows to chain.'
    null
  else
    win.chain()

# Modes
modes = new ModeManager()

winHint = modes.add new HintMode (->
  _.sortBy (Window.all visible: true), ((w) -> w.hash())
), (w) ->
  w.chain().focus().mouseTo()

scrHint = modes.add new HintMode Screen.all, (s, mod) ->
  if mod == 'shift'
    cw()?.setScreen(s.idx()).reproportion().set().focus().mouseTo()
  else
    s.mouseTo()

evalInput = modes.add new InputMode p.eval.prompt, (input, keyPressed) ->
  instant = (input.charAt 0) == p.eval.instantPrefix
  command = if instant then input.substr 1 else input
  returnPressed = keyPressed == 'return'

  # Eval
  if command and (instant or returnPressed)
    try
      result = JSON.stringify ((s) -> eval "(#{s})").call null, command
      output = result ? ''
    catch e
      err = p.eval.progressStr
      Phoenix.notify e if returnPressed

  # Set input and output
  [ (if instant then p.eval.instantPrefix else '') +
    ((output if returnPressed) ? command)
  , (err or output or p.eval.progressStr if instant)
  , returnPressed and not command ]

shellInput = modes.add new InputMode p.shell.prompt, (input, keyPressed) ->
  returnPressed = keyPressed == 'return'
  if input and returnPressed
    Task.run p.shell.bin, (['-c'].concat input), (r) ->
      Toaster.toast (r.output or r.error).trim()
      Phoenix.log r.error if r.error
  [(if returnPressed then '' else input), null, returnPressed]

class FindMode extends InputMode
  constructor: ->
    super p.find.prompt, (input, keyPressed) ->
      @pattern = input.toLowerCase()

      switch keyPressed
        when 'tab'
          if @mod == 'shift'
            @winIdx--
          else
            @winIdx++
        else
          current = @windows[@winIdx]
          @windows = _.filter @allWindows, (w) => @match w
          @winIdx = @findWinIdx current
          @winIdx = @findWinIdx Window.focused() if @winIdx < 0
          @winIdx = 0 if @winIdx < 0

      @winIdx = (@winIdx + @windows.length) % @windows.length
      window = @windows[@winIdx]
      if window?.hash() != @lastWindow?.hash()
        window?.chain().focus().mouseTo()
        @lastWindow = window

      app = window?.app()
      if app?.hash() != @lastApp?.hash()
        @outputModal.icon = app?.icon()
        @lastApp = app

      [input, window?.title() ? '…', keyPressed == 'return']

    @on 'start', => @allWindows = Window.all visible: true
    @on 'stop', => @reset()
    @reset()

  reset: ->
    @pattern = ''
    @winIdx = 0
    @windows = []
    @lastApp = undefined
    @lastWindow = undefined

  match: (window) ->
    if not @pattern
      return false

    input = "#{window.app().name()} #{window.title()}".toLowerCase()
    input.includes @pattern

  findWinIdx: (window) ->
    hash = window?.hash()
    if not hash
      return -1

    _.findIndex @windows, (w) -> w.hash() == hash

findMode = modes.add new FindMode()

# General
Key.on p.keys.maximize, p.keys.mods.base, -> cw()?.maximize().toggle().doSet()
Key.on p.keys.center, p.keys.mods.base, -> cw()?.center().toggle().doSet()
Key.on p.keys.reFill, p.keys.mods.base, -> cw()?.reFill().toggle().doSet()
Key.on p.keys.mouseTo, p.keys.mods.base, -> cw()?.mouseTo()
Key.on p.keys.winHintMode, p.keys.mods.base, -> modes.toggle winHint
Key.on p.keys.scrHintMode, p.keys.mods.base, -> modes.toggle scrHint
Key.on p.keys.evalInputMode, p.keys.mods.base, -> modes.toggle evalInput
Key.on p.keys.shellInputMode, p.keys.mods.base, -> modes.toggle shellInput
Key.on p.keys.findMode, p.keys.mods.base, -> modes.toggle findMode

# Move mouse out of the way
Key.on p.keys.mouseOut, p.keys.mods.base, ->
  f = Screen.moused().flippedFrame()
  Mouse.move
    x: f.x + f.width
    y: f.y + f.height
  Mouse.toggle()

# Show status
Key.on p.keys.status, p.keys.mods.base, -> Task.run '/bin/sh',
  ["-c", "LANG='ja_JP.UTF-8' date '+%a %-m/%-d %-H:%M'"],
  (r) -> Toaster.toast r.output.trim()

# Sleep
Key.on p.keys.sleep, p.keys.mods.base, -> Task.run '/bin/sh',
  ['-c', 'pmset sleepnow'],
  (r) -> Toaster.toast (r.output or r.error).trim()

# Apps
p.keys.apps.map (app, key) ->
  Key.on key, p.keys.mods.base, ->
    Task.run '/usr/bin/open', ['-a', app], (_) ->
      App.get(app)?.mainWindow()?.chain().mouseTo()

# Spaces
[ [ p.keys.mods.move # move
  , (num) -> cw()?.setSpace(num).reproportion().set().focus().mouseTo() ] ]
.map ([mod, action]) ->
  [1..10].map (num) ->
    s = '' + num
    Key.on (s.substr s.length - 1), mod, -> action (num - 1)
  p.keys.offsets.map (offset, key) ->
    Key.on key, mod, ->
      idx = Screen.moused().currentSpace().idx()
      slen = Space.all().length
      action (idx + offset + slen) % slen

# Directionals
[ [ p.keys.mods.base # select
  , (dir) -> cw()?.neighbor(dir).focus().mouseTo() ]
, [ p.keys.mods.move # move
  , (dir) -> cw()?.moveIn(dir).doSet() ]
, [ p.keys.mods.size # size
  , (dir) -> cw()?.sizeIn(dir).doSet() ]
, [ p.keys.mods.fall # fall
  , (dir) -> cw()?.fallIn(dir).doSet() ]
, [ p.keys.mods.pour # pour
  , (dir) -> cw()?.pourIn(dir).doSet() ]
, [ p.keys.mods.tile # tile
  , (dir) -> cw()?.adjustIn(dir).doSet() ] ]
.map ([mod, action]) -> p.keys.dirs.map (dir, key) ->
  Key.on key, mod, -> action dir

# Snaps
p.keys.snaps.map (dest, key) ->
  Key.on key, p.keys.mods.base, -> cw()?.snap(dest...).toggle().doSet()

# Move window to next/prev screen
moveCurrentWindowToScreen = (delta) ->
  w = cw()
  if not w?
    return
  numScreens = Screen.all().length
  next = (w.scr.idx() + delta + numScreens) % numScreens
  w.setScreen next
    .reproportion()
    .set()
    .focus()
    .mouseTo()
Key.on p.keys.quick, p.keys.mods.base, ->
  moveCurrentWindowToScreen 1
Key.on p.keys.quick, p.keys.mods.base.concat('shift'), ->
  moveCurrentWindowToScreen -1

# Notify upon load of config
Phoenix.notify 'Config loaded.'

# vim:ft=coffee
