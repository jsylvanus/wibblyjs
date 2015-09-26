ScalableBezier = require('./scalableBezier')

class BezierMask
  
  abs = Math.abs

  @fromElementAttributes : (element) ->
    top = ScalableBezier.FromAttribute element, 'data-top'
    bottom = ScalableBezier.FromAttribute element, 'data-bottom'
    new BezierMask top, bottom

  updateCanvasDimensions : (dims) ->
    @clipCanvas.width = dims.width
    @clipCanvas.height = @totalHeight(dims)

  constructor : (@top = null, @bottom = null) ->
    @createClipCanvas()
    @lastDims = null


  createClipCanvas : ->
    @clipCanvas = document.createElement('canvas')
    @clipCanvas.width = 1
    @clipCanvas.height = 1
    @clipContext = @clipCanvas.getContext('2d')


  updateClippingCanvas : (dims) ->
    @updateCanvasDimensions(dims)

    @clipContext.beginPath()
    @drawTop(dims)
    @drawBottom(dims)
    @clipContext.closePath()
    @clipContext.fill()


  drawTop : (dims) ->
    # if top bezier exists, apply to canvas, else just draw the surrounding box points
    if @top isnt null
      topBezier = @top.scale(dims.width, abs(dims.topMargin))
      @clipContext.moveTo(topBezier.startX, topBezier.startY)
      topBezier.applyToCanvas(@clipContext)
    else
      @clipContext.moveTo(0,0)
      @clipContext.lineTo(dims.width, 0)


  drawBottom : (dims) ->
    # if bottom bezier exists, apply to canvas, else just draw the surrounding box points
    if @bottom isnt null
      bottomBezier = @bottom.scale(dims.width, abs(dims.bottomMargin)).reverse()
      bottomBezier.applyToCanvas(@clipContext, 0, dims.height + abs(dims.topMargin))
    else
      @clipContext.lineTo dims.width, @totalHeight(dims)
      @clipContext.lineTo 0, @totalHeight(dims)


  drawClippingShape : (context, dims) ->
    
    fullDims = { w: dims.width, h: @totalHeight(dims) }

    if @lastDims is null or not @dimensionsMatch(@lastDims, fullDims)
      @updateClippingCanvas(dims)

    @lastDims = fullDims

    context.save()
    context.globalCompositeOperation = 'destination-in'
    context.drawImage(@clipContext.canvas, 0, 0, fullDims.w, fullDims.h)
    context.restore()

  dimensionsMatch : (last, latest) ->
    last.w == latest.w and last.h == latest.h

  totalHeight : (dims) ->
    dims.height + abs(dims.topMargin) + abs(dims.bottomMargin)

module.exports = BezierMask
