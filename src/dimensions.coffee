
# represents a box and some functions you might want to do with a box

class @Dimensions
  

  # the box is basically just a vector
  constructor: (width, height) ->
    @vector = new Vector(width, height)


  # access x as width
  width : -> @vector.x()


  # access y as height
  height : -> @vector.y()


  # Scales this box to fit (fill, actually) another box.
  # returns a new Dimensions obj
  # TODO: refactor name
  scaleToFit : (other) ->
    ratio_x = other.width() / @width()
    ratio_y = other.height() / @height()
    ratio = if ratio_x > ratio_y then ratio_x else ratio_y
    newVec = @vector.scale(ratio)
    new Dimensions newVec.x(), newVec.y()


  # Given another box, get the coordinates needed to center this box within the other.
  # returns a vector
  centerOffset : (other) ->
    off_x = (other.width() - @width()) / 2.0
    off_y = (other.height() - @height()) / 2.0
    new Vector(off_x, off_y)
