
# represents a box and some functions you might want to do with a box

class @Dimensions
  
  @FromVector : (vec) ->
    new Dimensions vec.x(), vec.y()

  # the box is basically just a vector
  constructor: (width, height) ->
    @vector = new Vector(width, height)

  equals: (dOther) -> @vector.equals(dOther.vector)

  scale : (factor) ->
    box = new Dimensions(@vector.x(), @vector.y())
    box.mutableScale(factor)
    box

  update : (width, height) ->
    @vector.update(width, height)

  mutableScale : (factor) ->
    @vector.mutScale(factor)

  # access x as width
  width : -> @vector.x()


  # access y as height
  height : -> @vector.y()


  # Scales this box to fill another box, returns a new Dimensions obj
  scaleToFill : (other) ->
    ratio_x = other.width() / @width()
    ratio_y = other.height() / @height()
    ratio = if ratio_x > ratio_y then ratio_x else ratio_y
    Dimensions.FromVector( @vector.scale(ratio) )


  scaleToFit : (other) ->
    ratio_x = other.width() / @width()
    ratio_y = other.height() / @height()
    ratio = if ratio_x < ratio_y then ratio_x else ratio_y
    Dimensions.FromVector( @vector.scale(ratio) )


  # Given another box, get the coordinates needed to center this box within the other.
  # returns a vector
  centerOffset : (other) ->
    off_x = (other.width() - @width()) / 2.0
    off_y = (other.height() - @height()) / 2.0
    new Vector(off_x, off_y)
