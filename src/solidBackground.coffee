BackgroundStrategy = require('./backgroundStrategy')

class SolidBackground extends BackgroundStrategy
  
  constructor: (color) ->
    super()
    @color = color
    @ready = yes

  # renders a big solid colored rectangle
  renderToCanvas : (element, context, dTime = 0) ->
    dim = @getDimensions element
    context.fillStyle = @color
    context.fillRect 0, 0, dim.width(), dim.height()

module.exports = SolidBackground
