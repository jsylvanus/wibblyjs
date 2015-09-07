@BigSea ?= {}

class @BigSea.ElementDimensions
  
  abs = Math.abs
  ceil = Math.ceil

  constructor : ->
    @width = 0
    @height = 0
    @topMargin = 0
    @bottomMargin = 0
    @totalHeight = 0

  updateFromElement : (element) ->
    style = element.currentStyle || window.getComputedStyle(element)
  
    @width = ceil(element.offsetWidth)
    @height = ceil(element.offsetHeight)
    @topMargin = ceil(parseFloat(style.marginTop))
    @bottomMargin = ceil(parseFloat(style.marginBottom))

    # sanity check: in IE these can return NAN if they aren't defined
    @topMargin = 0 if isNaN(@topMargin)
    @bottomMargin = 0 if isNaN(@bottomMargin)

    @totalHeight = @height + abs(@topMargin) + abs(@bottomMargin)

    @
