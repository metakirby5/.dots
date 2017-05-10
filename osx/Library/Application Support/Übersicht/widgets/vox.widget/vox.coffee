command: 'vox.widget/fetch'
refreshFrequency: 1000

style: '''
left 2rem
bottom 2rem

#vox
  width 30rem
  font-family sans-serif
  color white

#artist
  color rgba(white, 0.5)
  padding-bottom 0.1rem

#info
  padding-bottom 0.5rem

#time
  height 0.1rem
  background-color rgba(white, 0.5)

#time-fill
  width 0
  transition width 0.5s
  height 100%
  background-color white
'''

render: -> '''
<div id="vox">
  <div id="info">
    <div id="artist"></div>
    <div id="track"></div>
  </div>
  <div id="time">
    <div id="time-fill"></div>
  </div>
</div>
'''

update: (output) ->
  data = JSON.parse output if output
  if !data
    $('#vox').hide()
  else
    $('#vox').show()
    $("#track").text data.track
    $("#artist").text data.artist
    $("#time-fill").width "#{100 * data.currentTime / data.totalTime}%"
