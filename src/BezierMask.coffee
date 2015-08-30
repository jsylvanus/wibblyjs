@BigSea ?= {}

class @BigSea.BezierMask

  clipCanvas = null
  clipContext = null
  abs = Math.abs

  updateCanvasDimensions = (dims) ->
    clipCanvas.width = dims.width
    clipCanvas.height = dims.height + abs(dims.topMargin) + abs(dims.bottomMargin)


  constructor : (@top, @bottom) ->
    @createClipCanvas()


  createClipCanvas : ->
    clipCanvas = document.createElement('canvas')
    clipCanvas.width = 1
    clipCanvas.height = 1
    clipContext = clipCanvas.getContext('2d')


  updateClippingCanvas : (dims) ->
    updateCanvasDimensions(dims)

    clipContext.beginPath()
    @drawTop(dims)
    @drawBottom(dims)
    clipContext.closePath()
    clipContext.fill()


  drawTop : (dims) ->
    # if top bezier exists, apply to canvas, else just draw the surrounding box points
    if @top isnt null
      topBezier = @top.scale(dims.width, abs(dims.topMargin))
      clipContext.moveTo(topBezier.startX, topBezier.startY)
      topBezier.applyToCanvas(clipContext)
    else
      clipContext.moveTo(0,0)
      clipContext.lineTo(dims.width, 0)


  drawBottom : (dims) ->
    # if bottom bezier exists, apply to canvas, else just draw the surrounding box points
    if @bottom isnt null
      bottomBezier = @bottom.scale(dims.width, abs(dims.bottomMargin)).reverse()
      bottomBezier.applyToCanvas(clipContext, 0, dims.height + abs(dims.topMargin))
    else
      clipContext.lineTo(dims.width, dims.height + abs(dims.topMargin) + abs(dims.bottomMargin))
      clipContext.lineTo(0, dims.height + abs(dims.topMargin) + abs(dims.bottomMargin))


  drawClippingShape : (context, dims) ->
    
    fullHeight = dims.height + abs(dims.topMargin) + abs(dims.bottomMargin)
    fullDims = { w: dims.width, h: fullHeight }

    if not @lastDims?
      @updateClippingCanvas(dims)
      @lastDims = fullDims

    if not (fullDims.w == @lastDims.w and fullDims.h == @lastDims.h)
      @updateClippingCanvas(dims)
      @lastDims = vDims

    context.save()
    context.globalCompositeOperation = 'destination-in'
    context.drawImage(clipContext.canvas, 0, 0, fullDims.w, fullDims.h)
    context.restore()

