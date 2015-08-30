@BigSea ?= {}

class @BigSea.Layer

  viewport = null

  @Viewport : ->
    viewport = new BigSea.Layer() if viewport is null

    left = window.pageXOffset
    top = window.pageYOffset
    width = Math.max(
      document.documentElement.clientWidth, window.innerWidth or 0)
    height = Math.max(
      document.documentElement.clientHeight, window.innerHeight or 0)

    viewport.update(left, top, width, height)

  elementOffset = (element) -> # private method
    left = element.offsetLeft
    top = element.offsetTop

    while element = element.offsetParent
      left += element.offsetLeft
      top += element.offsetTop

    left : left
    top : top

  constructor: (left, top, width, height) ->
    @origin = new Vector(left, top)
    @box = new Dimensions(width, height)

  left : -> @origin.x()

  top : -> @origin.y()

  width : -> @box.width()

  height : -> @box.height()

  right : -> @left() + @width()

  bottom : -> @top() + @height()

  is_equal_to : (other) ->
    @origin.equals(other.origin) and @box.equals(other.box)

  is_equivalent_to : (other) -> @box.equals(other.box)

  intersects : (other) ->
    @left() < other.right() and @top() < other.bottom() and
      @right() > other.left() and @bottom() > other.top()
    
  contains : (other) ->
    @left() <= other.left() and @top() <= other.top() and
      @bottom() >= other.bottom() and @right() >= other.right()

  update : (left, top, width, height) ->
    @origin.update(left, top)
    @box.update(width, height)
    @

  updateFromElement : (element) ->
    if typeof element.getBoundingClientRect is 'function'
      rect = element.getBoundingClientRect()
      offset = x : window.pageXOffset, y : window.pageYOffset
      @update(rect.left + offset.x, rect.top + offset.y, rect.width, rect.height)
    else
      offset = elementOffset(element)
      @update(offset.left, offset.top, element.offsetWidth, element.offsetHeight)
    @
