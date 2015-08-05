
class @WibblyElement
  
  constructor: (@element) ->
    @isFirstAnimation = yes
    @compositeSupported = @isCompositeSupported()
    console.log "Composite Supported" if @compositeSupported
    @element.style.position = 'relative'
    @top = @loadBezier(@element, 'data-top')
    @bottom = @loadBezier(@element, 'data-bottom')
    @loadBackground(@element)
    @createCanvas()
    @hookEvents()
    @adjustCanvas()


  isCompositeSupported : ->
    test = document.createElement 'canvas'
    ctx = test.getContext '2d'
    ctx.globalCompositeOperation = 'destination-in'
    return ctx.globalCompositeOperation is 'destination-in'


  # loads a bezier attribute into a ScalableBezier object
  loadBezier: (element, attrib) ->
    test = element.attributes.getNamedItem(attrib)
    return null if test is null # isn't set

    attr = test.value.split(' ').map(parseFloat)
    throw "bezier requires 8 points" if attr.length < 8

    new ScalableBezier(attr[0], attr[1], attr[2], attr[3], attr[4], attr[5], attr[6], attr[7])


  # Loads data-background attribute into a BackgroundStrategy subclass
  loadBackground : (element) ->
    attribute = element.attributes.getNamedItem('data-background')
    throw "No data-background attribute - attribute is required" if attribute is null

    @background = BackgroundStrategy.Factory attribute.value
    @background.setCallback =>
      @adjustCanvas @isFirstAnimation
      @isFirstAnimation = no


  # Creats canvas element and 2d context
  createCanvas : ->
    @canvas = document.createElement 'canvas'

    @canvas.style.position = "absolute"
    @canvas.style.left = 0
    @canvas.style.top = 0
    @canvas.style.zIndex = -1

    @context = @canvas.getContext '2d'
    @context.globalCompositeOperation = 'destination-in'

    @element.appendChild @canvas
  

  # gets useful dimension info about the element that we're scaling the canvas to
  getElementDimensions : (element) ->
    style = element.currentStyle || window.getComputedStyle(element)

    width: element.offsetWidth
    height: element.offsetHeight
    topMargin: parseFloat(style.marginTop)
    bottomMargin: parseFloat(style.marginBottom)

  
  # hooks window resize event
  # TODO: throttle or debouce?
  hookEvents : ->
    window.addEventListener 'resize', =>
      @adjustCanvas()


  # Adjusts canvas to cover its containing element
  adjustCanvas : (first_call = no) ->

    dims = @getElementDimensions @element
    @canvas.style.top = "#{dims.topMargin}px"

    height = Math.abs(dims.topMargin) + Math.abs(dims.bottomMargin) + dims.height
    @canvas.height = height
    @canvas.style.height = "#{height}px"

    width = dims.width
    @canvas.width = width
    @canvas.style.width = "#{width}px"

    if first_call and @background.requiresRedrawing
      @animatedDraw dims, 0
    else
      @draw dims, 0


  animatedDraw : (dims, timestamp = 0) ->
    @draw(dims, timestamp)
    requestAnimationFrame (ts) => @animatedDraw(@getElementDimensions(@element), ts)


  drawClippingShape : (dims) ->
    @context.beginPath()

    # if top bezier exists, apply to canvas, else just draw the surrounding box points
    if @top isnt null
      topBezier = @top.scale(dims.width, Math.abs(dims.topMargin))
      @context.moveTo(topBezier.startX, topBezier.startY)
      topBezier.applyToCanvas(@context)
    else
      @context.moveTo(0,0)
      @context.lineTo(dims.width, 0)

    # if bottom bezier exists, apply to canvas, else just draw the surrounding box points
    if @bottom isnt null
      bottomBezier = @bottom.scale(dims.width, Math.abs(dims.bottomMargin)).reverse()
      bottomBezier.applyToCanvas(@context, 0, dims.height + Math.abs(dims.topMargin))
    else
      @context.lineTo(dims.width, dims.height + Math.abs(dims.topMargin) + Math.abs(dims.bottomMargin))
      @context.lineTo(0, dims.height + Math.abs(dims.topMargin) + Math.abs(dims.bottomMargin))

    # @context.closePath()
    # @context.fill()
    # @context.clip() # treat the above drawing as a clipping mask for the background


  # Draws the bezier mask and background
  draw : (dims, timestamp = 0) ->

    # draw the video first
    @context.globalCompositeOperation = 'source-over'
    @background.renderToCanvas(@canvas, @context, timestamp) if @background.ready

    # then mask it via destination-in compositing (much faster than clipping video)
    @context.globalCompositeOperation = 'destination-in'
    @drawClippingShape(dims)
    @context.fill()

    
