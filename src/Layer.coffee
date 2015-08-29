@BigSea ?= {}

class @BigSea.Layer

  constructor: (left, top, width, height) ->
    @origin = new Vector(left, top)
    @box = new Dimensions(width, height)
