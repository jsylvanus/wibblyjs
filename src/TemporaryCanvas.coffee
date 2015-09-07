@BigSea ?= {}

class @BigSea.TemporaryCanvas

  constructor : ->
    @internalCanvas = document.createElement('canvas')
    @internalContext = @internalCanvas.getContext('2d')

  copyCanvas : (otherCanvas) ->
    @internalCanvas.width = otherCanvas.width
    @internalCanvas.height = otherCanvas.height
    @internalContext.drawImage(otherCanvas, 0, 0)

  restoreToContext : (otherContext) ->
    otherCanvas = otherContext.canvas
    otherContext.drawImage(@internalCanvas, 0, 0, otherCanvas.width, otherCanvas.height)
