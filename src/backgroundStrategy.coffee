Dimensions = require('./dimensions')

class BackgroundStrategy
  
  constructor : ->
    @lastBox = null
    @ready = no
    @requiresRedrawing = no
    @callback = null

  
  # constructs a Dimensions object representing the element's width/height
  # given element MUST have width/height attributes set (e.g. canvas)
  getDimensions : (element) ->
    if element instanceof HTMLVideoElement
      return new Dimensions(element.videoWidth, element.videoHeight)

    if element instanceof HTMLImageElement
      return new Dimensions(element.naturalWidth, element.naturalHeight)

    new Dimensions(element.width, element.height)

  sourceBox : (dCanvas, dSource) ->
    scaledCanvasBox = dCanvas.scaleToFit(dSource)
    offset = scaledCanvasBox.centerOffset(dSource)

    source:
      x: Math.floor(offset.x())
      y: Math.floor(offset.y())
    dims:
      width: Math.floor(scaledCanvasBox.width())
      height: Math.floor(scaledCanvasBox.height())

  getRenderBox : (dCanvas, sourceElement) ->
    if @lastBox isnt null and dCanvas.equals(@lastDims)
      box = @lastBox
    else
      @lastDims = dCanvas
      imageDims = @getDimensions sourceElement
      @lastBox = @sourceBox(dCanvas, imageDims)

      # clip the box to make sure it stays inside the actual canvas
      @lastBox.source.x = 0 if @lastBox.source.x < 0
      @lastBox.source.y = 0 if @lastBox.source.y < 0
      @lastBox.dims.height = imageDims.height() if @lastBox.dims.height > imageDims.height()
      @lastBox.dims.width = imageDims.width() if @lastBox.dims.width > imageDims.width()

      box = @lastBox
    box

  # the following are intended to be overridden by subclasses

  # Note dTime (Delta Time) is intended to be time-since-last-render, currently unused.
  # dTime exists to allow for smooth animation based on requestAnimationFrame()
  renderToCanvas : (element, context, dTime = 0) ->
    null # implement me

  setCallback: (fn) ->
    null # implement me

module.exports = BackgroundStrategy
