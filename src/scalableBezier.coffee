
class @ScalableBezier
  
  constructor: (@startX, @startY, @controlX1, @controlY1, @controlX2, @controlY2, @endX, @endY) ->
    null


  clone: ->
    new ScalableBezier(@startX, @startY, @controlX1, @controlY1, @controlX2, @controlY2, @endX, @endY)


  # scales the bezier's control points in two dimensions
  # most useful if you store the points on a scale of 0.0 to 1.0
  # if you want to be able to scale the curve to fit within a box
  scale: (scaleX, scaleY) ->
    newBezier = @clone()
    newBezier.mutateScale(scaleX, scaleY)
    newBezier


  # mutating version of scale
  mutateScale: (scaleX, scaleY) ->
    @startX *= scaleX
    @startY *= scaleY
    @controlX1 *= scaleX
    @controlY1 *= scaleY
    @controlX2 *= scaleX
    @controlY2 *= scaleY
    @endX *= scaleX
    @endY *= scaleY
    

  # draws a line to the start of the curve, and draws the curve to the given context
  applyToCanvas: (context, offsetX = 0, offsetY = 0) ->
    context.lineTo offsetX + @startX, offsetY + @startY
    context.bezierCurveTo @controlX1 + offsetX, @controlY1 + offsetY, @controlX2 + offsetX, @controlY2 + offsetY, @endX + offsetX, @endY + offsetY


  # renders the control points on a context. mostly for debug purposes.
  renderPoints: (context, offsetX = 0, offsetY = 0, color = "#F00") ->
    context.fillStyle = color
    context.fillRect(@startX + offsetX, @startY + offsetY, 5, 5)
    context.fillRect(@controlX1 + offsetX, @controlY1 + offsetY, 5, 5)
    context.fillRect(@controlX2 + offsetX, @controlY2 + offsetY, 5, 5)
    context.fillRect(@endX + offsetX, @endY + offsetY, 5, 5)


  # reverses the left-to-right order of the control points
  # causing the bezier to be drawn in the opposite direction
  reverse : ->
    newBezier = @clone()
    newBezier.mutableReverse()
    newBezier


  # mutating version of reverse
  mutableReverse: ->

    tmp = @startX
    @startX = @endX
    @endX = tmp

    tmp = @startY
    @startY = @endY
    @endY = tmp

    tmp = @controlX1
    @controlX1 = @controlX2
    @controlX2 = tmp

    tmp = @controlY1
    @controlY1 = @controlY2
    @controlY2 = tmp


