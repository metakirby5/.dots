command: 'vox.widget/fetch'
refreshFrequency: 1000

style: '''
left 2rem
bottom 2rem
width 30rem

font-family sans-serif
color white

.info
  padding-bottom 0.5rem

.artist
  color rgba(white, 0.5)
  padding-bottom 0.1rem

.time
  height 0.1rem
  background-color rgba(white, 0.5)

.time-fill
  width 0
  transition width 0.5s
  height 100%
  background-color white
'''

render: -> '''
<div class="info">
  <div class="artist"></div>
  <div class="track"></div>
</div>
<div class="time">
  <div class="time-fill"></div>
</div>
'''

update: (output, elt) ->
  data = JSON.parse output if output
  $elt = $(elt)
  if !data
    $elt.fadeOut()
  else
    $elt.fadeIn()
    $elt.find('.track').text data.track
    $elt.find('.artist').text data.artist
    $elt.find('.time-fill').width "#{100 * data.currentTime / data.totalTime}%"
