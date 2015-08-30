@BigSea ?= {}

class @BigSea.Layer

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
    @left() < other.right() and @top() < other.bottom() and @right() > other.left() and @bottom() > other.top()
    
  contains : (other) ->
    @left() <= other.left() and @top() <= other.top() and @bottom() >= other.bottom() and @right() >= other.right()
