
class @ImageBackground extends @BackgroundStrategy


  constructor: (url) ->
    super()
    @callback = null
    if typeof url is 'string'
      @image = @createImage(url)
    else if typeof url is 'object' and url instanceof Array
      @image = @createSrcSetImage(url)
    else
      throw "url provided to ImageBackground constructor must be string or array"


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
    

  # toggles @ready and fires @callback if it's been set
  setReady : ->
    @ready = yes
    @callback() if @callback isnt null


  # setter for @callback, called by @setReady
  setCallback : (fn) ->
    @callback = fn


  isSrcsetSupported : ->
    img = document.createElement('img')
    typeof img.srcset is 'string'
    
