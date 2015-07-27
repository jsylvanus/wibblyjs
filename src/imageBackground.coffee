
class @ImageBackground extends @BackgroundStrategy


  constructor: (url) ->
    @image = @createImage(url)


  # Draw image to canvas, scaling to fit within the allowed space, centered.
  # Does nothing if @ready is false
  # 
  # TODO: refactor to allow different positioning from center
  renderToCanvas : (element, context, dTime = 0) ->
    return if not @ready

    dims = @getDimensions element
    imageDims = @getDimensions @image

    scaledDims = imageDims.scaleToFit(dims)
    offset = scaledDims.centerOffset(dims)

    context.drawImage(@image, offset.x(), offset.y(), scaledDims.width(), scaledDims.height())

    
  # creates an image element and sets its load even tot fire @setReady
  createImage: (url) ->
    img = document.createElement('img')
    img.addEventListener 'load', =>
      @setReady()
    img.src = url
    img
    

  # toggles @ready and fires @callback if it's been set
  setReady : ->
    @ready = yes
    @callback() if @callback isnt null


  # setter for @callback, called by @setReady
  setCallback : (fn) ->
    @callback = fn

