BackgroundStrategy = require('./backgroundStrategy')
SolidBackground = require('./solidBackground')

class ImageBackground extends BackgroundStrategy
  
  fallbackColor = '#000'

  @SetFallbackColor : (colorstring) ->
    fallbackColor = colorstring

  constructor: (url) ->
    super()
    @callback = null
    if typeof url is 'string'
      @image = @createImage(url)
    else if typeof url is 'object' and url instanceof Array
      @image = @createSrcSetImage(url)
    else
      throw "url provided to ImageBackground constructor must be string or array"
    @fallback = new SolidBackground(fallbackColor)


  # Draw image to canvas, scaling to fit within the allowed space, centered.
  # TODO: refactor to allow different positioning from center
  renderToCanvas : (element, context, dTime = 0) ->
    return @fallback?.renderToCanvas(element, context, dTime) if not @ready

    dims = @getDimensions element
    box = @getRenderBox(dims, @imageCanvas)

    context.drawImage(@imageContext.canvas, box.source.x, box.source.y, box.dims.width, box.dims.height, 0, 0, dims.vector.values[0], dims.vector.values[1])


  createSrcSetImage: (values) ->
    img = document.createElement('img')
    img.addEventListener 'load', =>
      @setReady()
    if @isSrcsetSupported()
      img.srcset = values.join(' ')
    else
      img.src = values[0] # no srcset support = we just use the first image in the list
    img

    
  # creates an image element and sets its load even tot fire @setReady
  createImage: (url) ->
    img = document.createElement('img')
    img.addEventListener 'load', =>
      @setReady()
    img.src = url
    img

    
  createCanvasSource : ->
    dims = @getDimensions @image
    @imageCanvas = document.createElement('canvas')
    @imageCanvas.width = dims.width()
    @imageCanvas.height = dims.height()
    @imageContext = @imageCanvas.getContext('2d')
    @imageContext.drawImage @image, 0, 0


  # toggles @ready and fires @callback if it's been set
  setReady : ->
    @createCanvasSource()
    @ready = yes
    @callback() if @callback isnt null


  # setter for @callback, called by @setReady
  setCallback : (fn) ->
    @callback = fn


  isSrcsetSupported : ->
    img = document.createElement('img')
    typeof img.srcset is 'string'
    

module.exports = ImageBackground
