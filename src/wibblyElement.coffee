
class @WibblyElement
  
  constructor: (@element) ->
    @isFirstAnimation = yes
    @transitions = []
    @compositeSupported = @isCompositeSupported()
    @animationRunning = no
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
      @adjustCanvas()


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
  adjustCanvas : ->
    # console.log @background

    dims = @getElementDimensions @element
    @canvas.style.top = "#{dims.topMargin}px"

    height = Math.abs(dims.topMargin) + Math.abs(dims.bottomMargin) + dims.height
    @canvas.height = height
    @canvas.style.height = "#{height}px"

    width = dims.width
    @canvas.width = width
    @canvas.style.width = "#{width}px"

    if not @animationRunning
      @animatedDraw dims, 0


  needsAnimation : ->
    return yes if @background.requiresRedrawing
    return yes if @transitions.length > 0
    return no


  animatedDraw : (dims, timestamp = 0) ->
    @draw(dims, timestamp)
    if @needsAnimation()
      @animationRunning = yes
      console.log "rAFing"
      requestAnimationFrame (ts) => @animatedDraw(@getElementDimensions(@element), ts)
    else
      @animationRunning = no


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
    
    if @compositeSupported # faster composite operation version
      
      # draw the background first
      @context.globalCompositeOperation = 'source-over'
      @context.globalAlpha = 1.0
      @background.renderToCanvas(@canvas, @context, timestamp) if @background.ready
      
      # handle transitions
      @processTransitions dims, timestamp

      # then mask it via destination-in compositing (much faster than clipping video)
      @context.globalCompositeOperation = 'destination-in'
      @drawClippingShape(dims)
      @context.fill()

    else # slow version

      # draw the clipping mask
      @drawClippingShape(dims)
      @context.fill()
      @context.clip()

      # draw the background into the clipping region
      @background.renderToCanvas(@canvas, @context, timestamp) if @background.ready

      # handle transitions
      @processTransitions dims, timestamp


  processTransitions : (dimensions, timestamp) ->
    # TODO: Transitioning to a video background is glitchy at end of transition
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

    
