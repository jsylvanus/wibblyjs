
class @WibblyElement
  
  constructor: (@element) ->
    @lastDims = null
    @drawing = false
    @adjusting = false
    @adjustTimeout = null
    @transitions = []
    @frames = new FrameManager()
    @compositeSupported = @isCompositeSupported()
    @animationRunning = no
    @element.style.position = 'relative'

    @bezierMask = BigSea.BezierMask.fromElementAttributes(@element)

    @loadBackground(@element)
    @createCanvas()
    @hookEvents()
    @removeLoadingClass(@element)
    @adjustCanvas()


  removeLoadingClass : (element) ->
    element.className = element.className.replace(/\bwib-loading\b/, '')

  isCompositeSupported : ->
    test = document.createElement 'canvas'
    ctx = test.getContext '2d'
    ctx.globalCompositeOperation = 'destination-in'
    return ctx.globalCompositeOperation is 'destination-in'


  # Loads data-background attribute into a BackgroundStrategy subclass
  loadBackground : (element) ->
    attribute = element.attributes.getNamedItem('data-background')
    throw "No data-background attribute - attribute is required" if attribute is null

    @background = BackgroundStrategy.Factory attribute.value
    @background.setCallback =>
      @adjustCanvas()


  # Creats canvas element and 2d context
  createCanvas : ->
    @canvas = document.createElement 'canvas'

    @canvas.style.position = "absolute"
    @canvas.style.left = 0
    @canvas.style.top = 0
    @canvas.style.zIndex = -1

    @context = @canvas.getContext '2d'
    @context.globalCompositeOperation = 'source-over'
    @context.save()

    @element.appendChild @canvas
  

  # gets useful dimension info about the element that we're scaling the canvas to
  getElementDimensions : (element) ->
    style = element.currentStyle || window.getComputedStyle(element)
  
    dims =
      width: Math.ceil(element.offsetWidth)
      height: Math.ceil(element.offsetHeight)
      topMargin: Math.ceil(parseFloat(style.marginTop))
      bottomMargin: Math.ceil(parseFloat(style.marginBottom))

    # sanity check: in IE these can return NAN if they aren't defined
    dims.topMargin = 0 if isNaN(dims.topMargin)
    dims.bottomMargin = 0 if isNaN(dims.bottomMargin)

    dims

  
  # hooks window resize event
  # TODO: throttle or debouce?
  hookEvents : ->
    window.addEventListener 'resize', =>
      # adjusts canvas only if draw routine not already running
      @adjustCanvas()

  # Adjusts canvas to cover its containing element
  adjustCanvas : ->
    # console.log @background
    if @adjusting is true
      # console.log "delaying a resize"
      if @adjustTimeout isnt null
        clearTimeout(@adjustTimeout)
        @adjustTimeout = null
      @adjustTimeout = setTimeout((=> @adjustCanvas()), 1000/60)
      return

    @adjusting = true

    dims = @getElementDimensions @element
    @canvas.style.top = "#{dims.topMargin}px"

    height = Math.abs(dims.topMargin) + Math.abs(dims.bottomMargin) + dims.height
    width = dims.width

    tmpCanvas = document.createElement('canvas')
    tmpCanvas.width = width
    tmpCanvas.height = height
    tmpContext = tmpCanvas.getContext('2d')

    tmpContext.drawImage @canvas, 0, 0, @canvas.width, @canvas.height, 0, 0, width, height

    @canvas.width = width
    @canvas.height = height

    @canvas.style.width = "#{width}px"
    @canvas.style.height = "#{height}px"

    @context.drawImage(tmpContext.canvas, 0, 0, tmpCanvas.width, tmpCanvas.height, 0, 0, @canvas.width, @canvas.height)

    if @animationRunning
      # do nothing, it'll get caught on next frame
    else if not @animationRunning and @needsAnimation()
      @animatedDraw() # boot up animation if it isnt running yet
    else
      @frames.queueFrame(=> @draw(dims, 0))
      # @draw(dims, timestamp)
      @frames.frame()

    @adjusting = false


  needsAnimation : ->
    return yes if @background.requiresRedrawing
    return yes if @transitions.length > 0
    return no


  animatedDraw : (timestamp = 0) =>
    # console.log "animatedDraw"
    dims = @getElementDimensions(@element)
    @frames.queueFrame(=> @draw(dims, timestamp))
    @frames.frame()
    # @draw(dims, timestamp)
    if @needsAnimation()
      @animationRunning = yes
      requestAnimationFrame @animatedDraw
    else
      @animationRunning = no


  # Draws the bezier mask and background
  draw : (dims, timestamp = 0) =>

    @drawing = true

    @background.renderToCanvas(@canvas, @context, timestamp)
    if @compositeSupported # faster composite operation version
      @bezierMask.drawClippingShape(@context, dims)

    @processTransitions dims, timestamp

    @drawing = false


  processTransitions : (dimensions, timestamp) ->
    # TODO: Transitioning to a video background is glitchy at end of transition
    return if @transitions.length is 0
    return if timestamp is 0

    for transition in @transitions
      transition.process(@canvas, @context, dimensions, timestamp)
    
    old_required_animation = @background.requiresRedrawing

    # process transition queue
    loop
      break if @transitions.length is 0
      if @transitions[@transitions.length - 1].finished
        @background = @transitions.pop().background
      else
        break

    if not old_required_animation and @background.requiresRedrawing
      @adjustCanvas() # reboot animation
      
    # process each object in @transitions queue
    # finished transitions are popped off of the front of the queue into @background
      

  changeBackground : (backgroundString, duration = 0) ->
    # create new background object
    try
      new_background = BackgroundStrategy.Factory backgroundString
    catch error
      console.log error
      return

    if duration is 0
      @background = new_background
    else
      # create transition object (start time, duration, new background)
      transition = new BackgroundTransition(new_background, duration)
      # shove transition into @transitions queue
      @transitions.unshift transition

    @adjustCanvas()

    
