
class @FrameManager

  constructor: ->
    @frameid = 0
    @nextFrame = null
    @debug = false

  queueFrame : (callback) ->
    @nextFrame = callback
    @frameid = Math.random()

  frame : ->
    callFrame = @nextFrame
    console.log @frameid if @debug
    callFrame() if callFrame isnt null
