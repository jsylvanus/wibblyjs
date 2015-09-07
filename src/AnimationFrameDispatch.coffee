@BigSea ?= {}


class @BigSea.AnimationFrameDispatch


  constructor : ->
    @wibblyElementList = []
    @resize_flagged = true
    @running = false
    @raf_confirmed = false
    window.addEventListener 'resize', @onResizeEvent


  onResizeEvent : =>
    @resize_flagged = true
    if not @raf_confirmed
      @resizeAll()
      @redraw(0, yes) # TODO: measure last frame instead of passing 0


  register : (element) ->
    @wibblyElementList.push element
    if not @running
      @running = true
      requestAnimationFrame(@frame) # if this doesn't work 


  frame : (timestamp = 0) =>
    @raf_confirmed = true
    @running = true
    requestAnimationFrame(@frame)
    if @needsResize()
      @resizeAll()
      @redraw(timestamp, true)
    else
      @redraw(timestamp)


  redraw : (timestamp, force = no) ->
    for item in @wibblyElementList
      if force or item.needsAnimation()
        item.draw(timestamp)


  needsResize : ->
    return no if not @resize_flagged
    @resize_flagged = no
    true
    

  resizeAll : ->
    item.resize() for item in @wibblyElementList
    
