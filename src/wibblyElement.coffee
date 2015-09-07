
class @WibblyElement

  @FrameDispatch : new BigSea.AnimationFrameDispatch()
  
  constructor: (@element) ->
    @redraw_needed = false
    @transitions = []

    @compositeSupported = @isCompositeSupported()
    @element.style.position = 'relative'

    @bezierMask = BigSea.BezierMask.fromElementAttributes(@element)
    @loadBackground(@element)
    @createCanvas()
    @removeLoadingClass(@element)
    WibblyElement.FrameDispatch.register(@)


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
    throw "missing required data-background attribute" if attribute is null

    @background = BackgroundStrategy.Factory attribute.value
    @background.setCallback =>
      @redraw_needed = yes


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
  

  getElementDimensions : (element) ->
    @elementDims ?= new ElementDimensions
    @elementDims.updateFromElement(element)

  
  resize : ->

    dims = @getElementDimensions @element
    
    # change top margin in case margin has changed (e.g. vw units)
    @canvas.style.top = "#{dims.topMargin}px"

    @tmpCanvas ?= new BigSea.TemporaryCanvas
    @tmpCanvas.copyCanvas(@canvas)

    @canvas.width = dims.width
    @canvas.height = dims.totalHeight
    @canvas.style.width = "#{dims.width}px"
    @canvas.style.height = "#{dims.totalHeight}px"

    @tmpCanvas.restoreToContext(@context)


  needsAnimation : ->
    # return no if not @isVisible()
    return yes if @redraw_needed
    return yes if @background.requiresRedrawing
    return yes if @transitions.length > 0
    return no


  draw : (timestamp = 0) =>

    @redraw_needed = false # de-flag redraw since we're working on it...

    dims = @getElementDimensions(@element)

    @drawing = true

    @background.renderToCanvas(@canvas, @context, timestamp)
    if @compositeSupported # faster composite operation version
      @bezierMask.drawClippingShape(@context, dims)

    @processTransitions dims, timestamp

    @drawing = false


  # TODO: This is a refactoring target
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
      @redraw_needed = yes


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

    @redraw_needed = yes

    
